# frozen_string_literal: true

require 'fastlane/action'
require_relative '../helper/zealot_helper'
require 'fastlane/plugin/debug_file'

module Fastlane
  module Actions

    class ZealotDebugFileAction < Action
      extend Fastlane::Helper::ZealotHelper

      PLATFORM = %I[ios mac macos osx android].freeze

      def self.run(params)
        file = generate_zip_file(params)
        UI.user_error! "Something wrong with compress debug file" unless file

        response = upload_debug_file(params, file)
        if parse_response(response, params[:endpoint], params[:fail_on_error])
          UI.success('Build successfully uploaded to Zealot.')
        end
      end

      def self.generate_zip_file(params)
        new_params = params.all_keys.each_with_object({}) do |key, obj|
          next unless value = params[key]
          obj[key] = value
        end
        path = new_params.delete(:path)
        platform = new_params[:platform]

        case platform
        when :ios, :mac, :macos, :osx
          generate_dsym_zip(new_params, path)
        when :android
          generate_proguard_zip(new_params, path)
        else
          UI.user_error!("No match value of platform: #{value}, avaiable value are #{PLATFORM.join(',')}.")
        end
      end

      def self.generate_dsym_zip(params, path)
        params[:archive_path] = if path
          path
        else
          Actions.lane_context[SharedValues::XCODEBUILD_ARCHIVE] || Fastlane::Actions::DsymAction::ARCHIVE_PATH
        end

        params[:scheme] = params.delete(:xcode_scheme)
        Fastlane::Actions::DsymAction.run(params)
      end

      def self.generate_proguard_zip(params, path)
        params[:app_path] = path if path && !path.empty?
        params[:build_type] = params.delete(:android_build_type)
        params[:flavor] = params.delete(:android_flavor)
        Fastlane::Actions::ProguardAction.run(params)
      end

      def self.parse_response(response, upload_url, fail_on_error)
        return unless response

        UI.verbose response.body.to_s
        if (body = response.body) && (error = body['error'])
          return show_error("Error uploading to Zealot: #{response.body}", fail_on_error)
        end

        true
      end
      private_class_method :parse_response

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
          FastlaneCore::ConfigItem.new(key: :platform,
                                       env_name: 'ZEALOT_PLATFORM',
                                       description: "The name of platfrom, avaiable value are #{PLATFORM.join(',')}",
                                       verify_block: proc do |value|
                                         UI.user_error!("No match value of platform: #{value}") unless PLATFORM.include?(value)
                                       end,
                                       type: :Symbol),
          FastlaneCore::ConfigItem.new(key: :path,
                                       env_name: 'ZEALOT_PATH',
                                       description: 'The path of debug file (iOS/macOS is archive path for Xcode, Android is path for app project)',
                                       optional: true,
                                       type: String),
          FastlaneCore::ConfigItem.new(key: :xcode_scheme,
                                       env_name: 'ZEALOT_XCODE_SCHEME',
                                       description: 'The scheme name of app',
                                       optional: true,
                                       type: String),
          FastlaneCore::ConfigItem.new(key: :android_build_type,
                                       env_name: 'ZEALOT_ANDROID_BUILD_TYPE',
                                       description: 'The build type of app',
                                       default_value: Fastlane::Actions::ProguardAction::RELEASE_TYPE,
                                       optional: true,
                                       type: String),
          FastlaneCore::ConfigItem.new(key: :android_flavor,
                                       env_name: 'ZEALOT_ANDROID_FLAVOR',
                                       description: 'The product flavor of app',
                                       optional: true,
                                       type: String),
          FastlaneCore::ConfigItem.new(key: :extra_files,
                                       env_name: 'ZEALOT_EXTRA_FILES',
                                       description: 'A set file names',
                                       optional: true,
                                       default_value: [],
                                       type: Array),
          FastlaneCore::ConfigItem.new(key: :output_path,
                                       env_name: 'DF_DSYM_OUTPUT_PATH',
                                       description: "The output path of compressed dSYM file",
                                       default_value: '.',
                                       optional: true,
                                       type: String),
          FastlaneCore::ConfigItem.new(key: :release_version,
                                       env_name: 'ZEALOT_RELEASE_VERSION',
                                       description: 'The release version of app',
                                       optional: true,
                                       type: String),
          FastlaneCore::ConfigItem.new(key: :build_version,
                                       env_name: 'ZEALOT_BUILD_VERSION',
                                       description: 'The build version of app',
                                       optional: true,
                                       type: String),
          FastlaneCore::ConfigItem.new(key: :overwrite,
                                       env_name: 'DF_DSYM_OVERWRITE',
                                       description: "Overwrite output compressed file if it existed",
                                       default_value: false,
                                       type: Boolean),
          FastlaneCore::ConfigItem.new(key: :timeout,
                                       env_name: 'ZEALOT_TIMEOUT',
                                       description: 'Request timeout in seconds',
                                       type: Integer,
                                       optional: true),
          FastlaneCore::ConfigItem.new(key: :verify_ssl,
                                       env_name: 'ZEALOT_VERIFY_SSL',
                                       description: 'Should verify SSL of zealot service',
                                       optional: true,
                                       default_value: true,
                                       type: Boolean),
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
          'zealot_debug_file(
            endpoint: "...",
            token: "...",
            channel_key: "...",
            zip_file: "...",
            release_version: "...",
            build_version: "..."
          )'
        ]
      end

      def self.output
        [
          ['ZEAALOT_ERROR_MESSAGE', 'The error message during upload process']
        ]
      end

      def self.category
        :misc
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
