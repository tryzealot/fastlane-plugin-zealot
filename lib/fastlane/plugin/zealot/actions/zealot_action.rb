require 'fastlane/action'
require_relative '../helper/zealot_helper'

module Fastlane
  module Actions
    module SharedValues
      ZEALOT_RELEASE_URL = :ZEALOT_RELEASE_URL
      ZEALOT_QRCODE_URL = :ZEALOT_QRCODE_URL
      ZEALOT_INSTALL_URL = :ZEALOT_INSTALL_URL
    end

    class ZealotAction < Action
      def self.run(params)
        upload_url = params[:endpoint]
        timeout = params[:timeout]
        fail_on_error = params[:fail_on_error]
        form = build_params(params)

        # Dump request form
        print_table(form, params[:hide_user_token])

        response = upload(upload_url, form, timeout, fail_on_error)
        if parse_response(response, upload_url, fail_on_error)
          UI.success("Release URL: #{Actions.lane_context[SharedValues::ZEALOT_RELEASE_URL]}")
          UI.success("QRCode URL: #{Actions.lane_context[SharedValues::ZEALOT_QRCODE_URL]}")
          UI.success("Download URL: #{Actions.lane_context[SharedValues::ZEALOT_INSTALL_URL]}")
          UI.success('Build successfully uploaded to Zealot.')
        end
      end

      def self.upload(upload_url, form, timeout, fail_on_error)
        require 'faraday'
        require 'faraday_middleware'

        UI.success("Uploading to #{upload_url} ...")
        connection = Faraday.new(url: upload_url) do |builder|
          builder.request(:multipart)
          builder.request(:url_encoded)
          builder.request(:retry, max: 3, interval: 5)
          builder.response(:json, content_type: /\bjson$/)
          builder.use(FaradayMiddleware::FollowRedirects)
          builder.adapter(:net_http)
        end

        begin
          connection.post do |req|
            req.url('/api/apps/upload')
            req.options.timeout = timeout
            req.body = form
          end
        rescue Faraday::Error::TimeoutError
          show_error('Uploading build to Apphost timed out ⏳', fail_on_error)
        end
      end
      private_class_method :upload

      def self.parse_response(response, upload_url, fail_on_error)
        return show_error("Error uploading to Apphost: empty response", fail_on_error) unless response

        UI.verbose response.body.to_s

        if (body = response.body) && (error = body['error'])
          return show_error("Error uploading to Apphost: #{response.body}", fail_on_error)
        end

        Actions.lane_context[SharedValues::ZEALOT_RELEASE_URL] = body['release_url']
        Actions.lane_context[SharedValues::ZEALOT_INSTALL_URL] = body['install_url']
        Actions.lane_context[SharedValues::ZEALOT_QRCODE_URL] = body['qrcode_url']

        true
      end
      private_class_method :parse_response

      def self.build_params(params)
        form = {
          token: params[:token],
          channel_key: params[:channel_key],
          file: Faraday::UploadIO.new(params[:file], 'application/octet-stream')
        }

        form.merge(avialable_params(params))
      end
      private_class_method :build_params

      UPLOAD_PARAMS_KEYS = %w[
        name changelog release_type
        slug source branch git_commit password
      ].freeze

      def self.avialable_params(params)
        UPLOAD_PARAMS_KEYS.each_with_object({}) do |key, obj|
          value = params.fetch(key.to_sym, ask: false)
          obj[key.to_sym] = value if value && !value.empty?
        end
      end
      private_class_method :avialable_params

      def self.print_table(form, hide_user_token)
        rows = form.dup
        rows[:file] = rows[:file].path if rows[:file]
        rows[:token] = '*' * 10 if hide_user_token
        puts Terminal::Table.new(
          title: "Summary for zealot #{Fastlane::Zealot::VERSION}".green,
          rows: rows
        )
      end

      def self.show_error(message, fail_on_error)
        if fail_on_error
          UI.user_error!(message)
        else
          UI.error(message)
        end

        false
      end
      private_class_method :show_error

      #####################################################
      # @!group Documentation
      #####################################################

      def self.description
        'Upload a new build to Zealot'
      end

      def self.available_options
        [
          FastlaneCore::ConfigItem.new(key: :endpoint,
                                       env_name: 'ZEALOT_ENDPOINT',
                                       description: 'The endpoint of zealot',
                                       type: String),
          FastlaneCore::ConfigItem.new(key: :token,
                                       env_name: 'ZEALOT_TOKEN',
                                       description: 'The token of user',
                                       sensitive: true,
                                       verify_block: proc do |value|
                                         UI.user_error!("No user token for Zealot given, pass using `token: 'token'`") if value.nil? || value.empty?
                                       end,
                                       type: String),
          FastlaneCore::ConfigItem.new(key: :channel_key,
                                       env_name: 'ZEALOT_CHANNEL_KEY',
                                       description: 'The key of app\'s channel',
                                       type: String),
          FastlaneCore::ConfigItem.new(key: :file,
                                       env_name: 'ZEALOT_FILE',
                                       description: 'The path of app file. Optional if you use the `gym`, `ipa`, `xcodebuild` or `gradle` action. ',
                                       default_value: Actions.lane_context[SharedValues::IPA_OUTPUT_PATH] || Dir['*.ipa'].last || Actions.lane_context[SharedValues::GRADLE_APK_OUTPUT_PATH] || Dir['*.apk'].last,
                                       verify_block: proc do |value|
                                         UI.user_error!("Couldn't pass empty to file") if value.nil? || value.empty?
                                         UI.user_error!("Couldn't find file at path '#{value}'") unless File.exist?(value)
                                       end,
                                       optional: true,
                                       type: String),
          FastlaneCore::ConfigItem.new(key: :name,
                                       env_name: 'ZEALOT_NAME',
                                       description: 'The name of app to display on zealot',
                                       optional: true,
                                       type: String),
          FastlaneCore::ConfigItem.new(key: :changelog,
                                       env_name: 'ZEALOT_CHANGELOG',
                                       description: 'The changelog of app',
                                       optional: true,
                                       type: String),
          FastlaneCore::ConfigItem.new(key: :slug,
                                       env_name: 'ZEALOT_SLUG',
                                       description: 'The slug of app',
                                       optional: true,
                                       type: String),
          FastlaneCore::ConfigItem.new(key: :release_type,
                                       env_name: 'ZEALOT_RELEASE_TYPE',
                                       description: 'The release type of app',
                                       optional: true,
                                       type: String),
          FastlaneCore::ConfigItem.new(key: :branch,
                                       env_name: 'ZEALOT_BRANCH',
                                       description: 'The name of git branch',
                                       optional: true,
                                       type: String),
          FastlaneCore::ConfigItem.new(key: :git_commit,
                                       env_name: 'ZEALOT_GIT_COMMIT',
                                       description: 'The hash of git commit',
                                       optional: true,
                                       type: String),
          FastlaneCore::ConfigItem.new(key: :password,
                                       env_name: 'ZEALOT_PASSWORD',
                                       description: 'The password of app to download',
                                       optional: true,
                                       type: String),
          FastlaneCore::ConfigItem.new(key: :source,
                                       env_name: 'ZEALOT_SOURCE',
                                       description: 'The name of upload source',
                                       optional: true,
                                       default_value: 'fastlane',
                                       type: String),
          FastlaneCore::ConfigItem.new(key: :timeout,
                                       env_name: 'ZEALOT_TIMEOUT',
                                       description: 'Request timeout in seconds',
                                       type: Integer,
                                       optional: true),
          FastlaneCore::ConfigItem.new(key: :hide_user_token,
                                       env_name: 'ZEALOT_HIDE_USER_TOKEN',
                                       description: 'replase user token to *** to keep secret',
                                       optional: true,
                                       default_value: true,
                                       type: Boolean,),
          FastlaneCore::ConfigItem.new(key: :fail_on_error,
                                       env_name: 'ZEALOT_FAIL_ON_ERROR',
                                       description: 'Should an error uploading app cause a failure? (true/false)',
                                       optional: true,
                                       default_value: false,
                                       type: Boolean)
        ]
      end

      def self.example_code
        [
          'zealot(
            endpoint: "...",
            token: "...",
            channel_key: "..."
          )',
          'zealot(
            endpoint: "...",
            token: "...",
            channel_key: "...",
            name: "custom_app_name",
            release_type: "adhoc",
            branch: "develop",
            git_commit: "8s20an32",
            source: "jenkins",
            file: "./app.{ipa,apk}"
          )',
        ]
      end

      def self.output
        [
          [
            'ZEALOT_RELEASE_URL', 'The release URL of the newly uploaded build',
            'ZEALOT_INSTALL_URL', 'The install URL of the newly uploaded build',
            'ZEALOT_QRCODE_URL', 'The QRCode URL of the newly uploaded build'
          ]
        ]
      end

      def self.category
        :beta
      end

      def self.authors
        ['icyleaf']
      end

      def self.is_supported?(_)
        true
      end
    end
  end
end
