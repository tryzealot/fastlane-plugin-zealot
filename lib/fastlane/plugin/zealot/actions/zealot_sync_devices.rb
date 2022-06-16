# frozen_string_literal: true

require 'credentials_manager'
require 'fastlane/action'
require_relative '../helper/zealot_helper'

module Fastlane
  module Actions

    class ZealotSyncDevicesAction < Action
      extend Fastlane::Helper::ZealotHelper

      def self.run(params)
        require 'spaceship'

        all_platforms = Set[params[:platform]]
        supported_platforms = all_platforms.select { |platform| self.is_supported?(platform.to_sym) }

        if (api_token = Spaceship::ConnectAPI::Token.from(hash: params[:api_key], filepath: params[:api_key_path]))
          UI.message('Creating authorization token for App Store Connect API')
          Spaceship::ConnectAPI.token = api_token

          devices = supported_platforms.flat_map do |platform|
            Spaceship::ConnectAPI::Device.all(filter: { platform: platform == 'ios' ? 'IOS' : 'MAC_OS'})
          end
        else
          username = params[:username]
          UI.message("Login to App Store Connect (#{username})")
          credentials = CredentialsManager::AccountManager.new(user: username)
          Spaceship.login(credentials.user, credentials.password)
          UI.message('Login successful')
          Spaceship.select_team

          # Fetches all devices includes macOS.

          devices = supported_platforms.flat_map { |platform| Spaceship::Device.all(mac: platform == 'mac') }
        end

        UI.message('Fetching list of currently registered devices...')

        print_table(build_table_data(params, devices), title: 'zealot_sync_devices')

        UI.message("Syncing devices to #{params[:endpoint]} ...")
        failed_devices = []
        devices.each do |device|
          begin
            sync_deivce(params, device)
          rescue Faraday::ConnectionFailed
            failed_devices << {udid: device.udid, error: 'Can not connecting to Zealot'}
          rescue Faraday::TimeoutError
            failed_devices << {udid: device.udid, error: 'Timed out to Zealot'}
          end
        end

        failed = failed_devices.size
        successed = devices.size - failed
        UI.success "Successful Synced devices, success: #{successed}, failed: #{failed}"
        UI.verbose "Failed devices: #{failed_devices}"
      end

      #####################################################
      # @!group Documentation
      #####################################################

      def self.description
        'Sync ios devices list to Zealot'
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
          FastlaneCore::ConfigItem.new(key: :username,
                                       env_name: 'ZEALOT_USERNAME',
                                       description: 'The apple id (username) of Apple Developer Portal',
                                       default_value_dynamic: true,
                                       optional: true,
                                       type: String),
          FastlaneCore::ConfigItem.new(key: :api_key_path,
                                       env_name: 'ZEALOT_API_PATH',
                                       description: 'Path to your App Store Connect API Key JSON file (https://docs.fastlane.tools/app-store-connect-api/#using-fastlane-api-key-json-file)',
                                       optional: true,
                                       conflicting_options: [:api_key],
                                       verify_block: proc do |value|
                                         UI.user_error!("Couldn't find API key JSON file at path '#{value}'") unless File.exist?(value)
                                       end),
          FastlaneCore::ConfigItem.new(key: :api_key,
                                       env_name: 'ZEALOT_API_KEY',
                                       description: 'Your App Store Connect API Key information (https://docs.fastlane.tools/app-store-connect-api/#using-fastlane-api-key-hash-option)',
                                       type: Hash,
                                       default_value: Fastlane::Actions.lane_context[Fastlane::Actions::SharedValues::APP_STORE_CONNECT_API_KEY],
                                       default_value_dynamic: true,
                                       optional: true,
                                       sensitive: true,
                                       conflicting_options: [:api_key_path]),
          FastlaneCore::ConfigItem.new(key: :team_id,
                                       env_name: 'ZEALOT_APPLE_TEAM_ID',
                                       description: 'The ID of your Developer Portal team if you\'re in multiple teams',
                                       default_value: CredentialsManager::AppfileConfig.try_fetch_value(:team_id),
                                       default_value_dynamic: true,
                                       optional: true,
                                       type: String,
                                       verify_block: proc do |value|
                                         ENV['FASTLANE_TEAM_ID'] = value.to_s
                                       end),
          FastlaneCore::ConfigItem.new(key: :team_name,
                                       env_name: 'ZEALOT_APPLE_TEAM_NAME',
                                       description: 'The name of your Developer Portal team if you\'re in multiple teams',
                                       default_value: CredentialsManager::AppfileConfig.try_fetch_value(:team_id),
                                       default_value_dynamic: true,
                                       optional: true,
                                       type: String,
                                       verify_block: proc do |value|
                                         ENV['FASTLANE_TEAM_NAME'] = value.to_s
                                       end),
          FastlaneCore::ConfigItem.new(key: :platform,
                                       env_name: 'ZEALOT_APPLE_PLATFORM',
                                       description: 'The platform to use (optional)',
                                       optional: true,
                                       default_value: 'ios',
                                       verify_block: proc do |value|
                                         UI.user_error!('The platform can only be ios or mac') unless %('ios', 'mac').include?(value)
                                       end),
          FastlaneCore::ConfigItem.new(key: :verify_ssl,
                                       env_name: 'ZEALOT_VERIFY_SSL',
                                       description: 'Should verify SSL of zealot service',
                                       optional: true,
                                       default_value: true,
                                       type: Boolean),
          FastlaneCore::ConfigItem.new(key: :timeout,
                                       env_name: 'ZEALOT_TIMEOUT',
                                       description: 'Request timeout in seconds',
                                       type: Integer,
                                       optional: true),
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
          'zealot_sync_devices(
            endpoint: "...",
            token: "...",
            api_key_path: "...",
            team_id: "..."
          )',
          'zealot_sync_devices(
            endpoint: "...",
            token: "...",
            username: "...",
            team_id: "..."
          )'
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
