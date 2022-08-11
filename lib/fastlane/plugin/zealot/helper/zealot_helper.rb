# frozen_string_literal: true

require 'fastlane_core/ui/ui'

module Fastlane
  UI = FastlaneCore::UI unless Fastlane.const_defined?("UI")

  module Helper
    module ZealotHelper
      def upload_debug_file(params, file)
        form = upload_debug_file_params(params, file)
        print_table(form, title: 'zealot_debug_file')

        endpoint = params[:endpoint]
        UI.success("Uploading to #{endpoint} ...")
        connection = make_connection(params[:endpoint], params[:verify_ssl])
        begin
          connection.post do |req|
            req.url('/api/debug_files/upload')
            req.options.timeout = params[:timeout]
            req.body = form
          end
        rescue Faraday::ConnectionFailed
          show_error('Can not connecting to Zealot', params[:fail_on_error])
        rescue Faraday::TimeoutError
          show_error('Uploading build to Zealot timed out ⏳', params[:fail_on_error])
        end
      end

      def upload_debug_file_params(params, file)
        {
          token: params[:token],
          channel_key: params[:channel_key],
          release_version: params[:release_version],
          build_version: params[:build_version],
          file: Faraday::UploadIO.new(file, 'application/octet-stream')
        }
      end

      #######################################

      def upload_app(params)
        form = upload_app_params(params)
        print_table(form, title: 'zealot', hidden_keys: hidden_keys(params))

        endpoint = params[:endpoint]
        UI.success("Uploading to #{endpoint} ...")
        connection = make_connection(params[:endpoint], params[:verify_ssl])
        connection.post do |req|
          req.url('/api/apps/upload')
          req.options.timeout = params[:timeout]
          req.body = form
        end
      rescue Faraday::ConnectionFailed
        show_error('Can not connecting to Zealot service, make sure it be health to upload.', params[:fail_on_error])
      rescue Faraday::TimeoutError
        show_error('Uploading build to Zealot timed out ⏳', params[:fail_on_error])
      end

      def upload_app_params(params)
        form = {
          token: params[:token],
          channel_key: params[:channel_key],
          file: Faraday::UploadIO.new(params[:file], 'application/octet-stream')
        }

        form.merge(avialable_upload_app_params(params))
      end

      UPLOAD_APP_PARAMS_KEYS = %w[
        name changelog release_type slug branch password
        git_commit custom_fields source ci_url
      ].freeze

      def avialable_upload_app_params(params)
        UPLOAD_APP_PARAMS_KEYS.each_with_object({}) do |key, obj|
          value = params.fetch(key.to_sym, ask: false)
          value = JSON.dump(value) if key == 'custom_fields' && value
          value = detect_ci_url(params) if key == 'ci_url'
          value = detect_source(params) if key == 'source'
          obj[key.to_sym] = value if value && !value.empty?
        end
      end

      #####################################

      def check_app_version(params)
        query = build_app_version_check_params(params)
        print_table(query, title: 'zealot_version_check', hidden_keys: hidden_keys(params))

        UI.success("Checking app version from Zealot ...")
        connection = make_connection(params[:endpoint], params[:verify_ssl])
        connection.get do |req|
          req.url '/api/apps/version_exist'
          req.params = query
        end
      rescue Faraday::ConnectionFailed
        show_error('Can not connecting to Zealot', params[:fail_on_error])
      rescue Faraday::TimeoutError
        show_error('Check app version from Zealot timed out ⏳', params[:fail_on_error])
      end

      def build_app_version_check_params(params)
        token = params[:token]
        channel_key = params[:channel_key]
        bundle_id = params[:bundle_id]
        release_version = params[:release_version]
        build_version = params[:build_version]
        git_commit = params[:git_commit]

        UI.user_error! 'bundle id is missing' if bundle_id.to_s.empty?

        has_version = !(release_version.to_s.empty? && build_version.to_s.empty?)
        has_git_commit = !git_commit.to_s.empty?
        UI.user_error! 'release_version + build_version or git_commit is missing' unless has_version || has_git_commit

        if has_version
          {
            token: token,
            channel_key: channel_key,
            bundle_id: bundle_id,
            release_version: release_version,
            build_version: build_version
          }
        else
          {
            token: token,
            channel_key: channel_key,
            bundle_id: bundle_id,
            git_commit: git_commit
          }
        end
      end

      #######################################

      def sync_deivce(params, device)
        body = { token: params[:token], name: device.name, model: device.model }
        http_request(:put, "/api/devices/#{device.udid}", body, params)
      end

      def build_table_data(params, devices)
        data = {
          'Endpoint' => params[:endpoint],
          'Token' => params[:token],
          "Devices (#{devices.size})" => devices.map {|d| "#{d.name}: #{d.udid}"}.join("\n")
        }
      end

      #####################################

      def http_request(method, uri, body, params)
        connection = make_connection(params[:endpoint], params[:verify_ssl])
        connection.run_request(method, uri, body, nil) do |req|
          req.options.timeout = params[:timeout] if params[:timeout]
        end
      end

      def make_connection(endpoint, verify_ssl = true)
        require 'faraday'
        require 'faraday_middleware'

        Faraday.new(url: endpoint, ssl: { verify: verify_ssl }) do |builder|
          builder.request(:multipart)
          builder.request(:url_encoded)
          builder.request(:retry, max: 3, interval: 5)
          builder.response(:json, content_type: /\bjson$/)
          builder.adapter(:net_http)
        end
      end

      def print_table(form, title: 'zealot', hidden_keys: [], remove_empty_value: true)
        rows = form.dup
        rows.keys.each do |k|
          rows.delete(k) if remove_empty_value && !rows[k]
          rows.delete(k) if hidden_keys.include?(k.to_sym)
          rows[k] = rows[k].path if rows[k].is_a?(UploadIO)
        end

        puts Terminal::Table.new(
          title: "Summary for #{title} #{Fastlane::Zealot::VERSION}".green,
          rows: rows
        )
      end

      def show_error(message, fail_on_error, store_shared_value = true)
        Actions.lane_context[Fastlane::Actions::SharedValues::ZEAALOT_ERROR_MESSAGE] = message if store_shared_value

        if fail_on_error
          UI.user_error!(message)
        else
          UI.error(message)
        end

        false
      end

      def hidden_keys(params)
        return [] unless params[:hide_user_token]

        [:token]
      end

      def detect_source(params)
        return 'jenkins' if jenkins?
        return 'gitlab-ci' if gitlab?

        params[:source]
      end

      def detect_ci_url(params)
        return params[:ci_url] if params[:ci_url]

        if ENV['BUILD_URL']
          # Jenkins
          return ENV['BUILD_URL']
        elsif ENV['CI_JOB_URL']
          # Gitlab >= 11.1, Runner 0.5
          return ENV['CI_JOB_URL']
        elsif ENV['CI_PROJECT_URL']
          # Gitlab >= 8.10, Runner 0.5
          return "#{ENV['CI_PROJECT_URL']}/-/jobs/#{ENV['CI_BUILD_ID']}"
        end
      end

      def jenkins?
        %w(JENKINS_URL JENKINS_HOME).each do |current|
          return true if ENV.key?(current)
        end

        return false
      end

      def gitlab?
        ENV.key?('GITLAB_CI')
      end
    end
  end
end
