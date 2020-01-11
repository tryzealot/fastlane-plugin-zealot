# frozen_string_literal: true

require 'fastlane/action'
require_relative '../helper/zealot_helper'

module Fastlane
  module Actions
    module SharedValues
      ZEALOT_APP_VERSION_EXISTED = :ZEALOT_APP_VERSION_EXISTED
    end

    class ZealotVersionCheckAction < Action
      extend Fastlane::Helper::ZealotHelper

      def self.run(params)
        response = check_app_version(params)
        parse_response(response, params[:fail_on_error])
      end

      def self.parse_response(response, fail_on_error)
        UI.verbose "[status] #{response.status}"
        UI.verbose "[body] #{response.body}"

        is_existed = case response.status
                     when 200 then true
                     when 404 then false
                     end

        return show_error(response.body['error'], fail_on_error) if is_existed.nil?

        Actions.lane_context[SharedValues::ZEALOT_APP_VERSION_EXISTED] = is_existed

        if is_existed
          UI.important 'Found app version, you can skip upload it'
        else
          UI.success 'Not found app version, you can upload it'
        end

        is_existed
      end
      private_class_method :parse_response

      #####################################################
      # @!group Documentation
      #####################################################

      def self.description
        'Check app version exists from Zealot'
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
          FastlaneCore::ConfigItem.new(key: :bundle_id,
                                       env_name: 'ZEALOT_BUNDLE_ID',
                                       description: 'The bundle id(package name) of app',
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
          FastlaneCore::ConfigItem.new(key: :git_commit,
                                       env_name: 'ZEALOT_GIT_COMMIT',
                                       description: 'The latest git commit of app',
                                       default_value: ENV['GIT_COMMIT'] || ENV['CI_COMMIT_SHA'],
                                       optional: true,
                                       type: String),
          FastlaneCore::ConfigItem.new(key: :verify_ssl,
                                       env_name: 'ZEALOT_VERIFY_SSL',
                                       description: 'Should verify SSL of zealot service',
                                       optional: true,
                                       default_value: true,
                                       type: Boolean),
          FastlaneCore::ConfigItem.new(key: :fail_on_error,
                                       env_name: 'ZEALOT_FAIL_ON_ERROR',
                                       description: 'Should an error http request cause a failure? (true/false)',
                                       optional: true,
                                       default_value: false,
                                       type: Boolean)
        ]
      end

      def self.example_code
        [
          'zealot_version_check(
            endpoint: "...",
            token: "...",
            channel_key: "...",
            bundle_id: "im.ews.zealot",
            git_commit: "ec7b5859f77882892325840eae0716fcaab6c14f"
          )',
          'zealot_version_check(
            endpoint: "...",
            token: "...",
            channel_key: "...",
            bundle_id: "im.ews.zealot",
            release_version: "1.0.0",
            build_version: "1"
          )',
        ]
      end

      def self.output
        [
          [
            'ZEALOT_APP_VERSION_EXISTED', 'The result of app verison existed (Boolean)'
          ]
        ]
      end

      def self.return_value
        Boolean
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
