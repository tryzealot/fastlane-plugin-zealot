# frozen_string_literal: true

require 'fastlane_core/ui/ui'

module Fastlane
  UI = FastlaneCore::UI unless Fastlane.const_defined?("UI")

  module Helper
    module ZealotHelper
      def upload_app(params)
        form = upload_app_params(params)
        print_table(form, title: 'zealot', hidden_keys: [:token])

        endpoint = params[:endpoint]
        UI.success("Uploading to #{endpoint} ...")
        connection = make_connection(params[:endpoint], params[:verify_ssl])
        connection.post do |req|
          req.url('/api/apps/upload')
          req.options.timeout = params[:timeout]
          req.body = form
        end
      rescue Faraday::Error::TimeoutError
        show_error('Uploading build to Apphost timed out ⏳', params[:fail_on_error])
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
        name changelog release_type
        slug source branch git_commit password
      ].freeze

      def avialable_upload_app_params(params)
        UPLOAD_APP_PARAMS_KEYS.each_with_object({}) do |key, obj|
          value = params.fetch(key.to_sym, ask: false)
          obj[key.to_sym] = value if value && !value.empty?
        end
      end

      #####################################

      def check_app_version(params)
        query = build_app_version_check_params(params)
        print_table(query, title: 'zealot_version_check', hidden_keys: ['token'])

        UI.success("Checking app version from Zealot ...")
        connection = make_connection(params[:endpoint], params[:verify_ssl])
        connection.get do |req|
          req.url '/api/apps/version_exist'
          req.params = query
        end
      rescue Faraday::Error::TimeoutError
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

      #####################################

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
          rows.delete(k) if hidden_keys.include?(k.to_s)
          rows[k] = rows[k].path if rows[k].is_a?(UploadIO)
        end
        puts Terminal::Table.new(
          title: "Summary for #{title} #{Fastlane::Zealot::VERSION}".green,
          rows: rows
        )
      end

      def show_error(message, fail_on_error)
        if fail_on_error
          UI.user_error!(message)
        else
          UI.error(message)
        end

        false
      end
    end
  end
end
