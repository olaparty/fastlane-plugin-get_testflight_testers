module Fastlane
  module Actions
    class GetTestflightTestersAction < Action
      def self.run(params)
        require 'spaceship'

        app_identifier = params[:app_identifier]

        if (api_token = Spaceship::ConnectAPI::Token.from(hash: params[:api_key]))
          UI.message("Creating authorization token for App Store Connect API")
          Spaceship::ConnectAPI.token = api_token
        elsif !Spaceship::ConnectAPI.token.nil?
          UI.message("Using existing authorization token for App Store Connect API")
        else
          params[:username] ||= CredentialsManager::AppfileConfig.try_fetch_value(:apple_id)
  
          # Username is now optional since addition of App Store Connect API Key
          # Force asking for username to prompt user if not already set
          params.fetch(:username, force_ask: true)
  
          UI.message("Login to App Store Connect (#{params[:username]})")
          Spaceship::ConnectAPI.login(params[:username], use_portal: false, use_tunes: true, tunes_team_id: params[:team_id], team_name: params[:team_name])
          UI.message("Login successful")
        end

        UI.message("Fetching all TestFlight testers, this might take a few minutes, depending on the number of testers")

        # Convert from bundle identifier to app ID
        spaceship_app ||= Spaceship::ConnectAPI::App.find(app_identifier)
        UI.user_error!("Couldn't find app '#{app_identifier}' on iTunes Connect") unless spaceship_app

        all_testers = spaceship_app.get_beta_testers(includes: 'apps,betaGroups')
        UI.success("Total testers: #{all_testers.length}  🦋")

        all_testers.length
      end

      def self.description
        "Get TestFlight testers counts"
      end

      def self.authors
        ["olaparty"]
      end

      def self.details
        "Get TestFlight testers counts"
      end

      def self.available_options
        user = CredentialsManager::AppfileConfig.try_fetch_value(:itunes_connect_id)
        user ||= CredentialsManager::AppfileConfig.try_fetch_value(:apple_id)

        [
          FastlaneCore::ConfigItem.new(key: :username,
                                     short_option: "-u",
                                     env_name: "get_testflight_testers_USERNAME",
                                     description: "Your Apple ID Username",
                                     optional: true,
                                     default_value: user),
          FastlaneCore::ConfigItem.new(key: :app_identifier,
                                       short_option: "-a",
                                       env_name: "get_testflight_testers_APP_IDENTIFIER",
                                       description: "The bundle identifier of the app to upload or manage testers (optional)",
                                       optional: true,
                                       default_value: ENV["TESTFLIGHT_APP_IDENTITIFER"] || CredentialsManager::AppfileConfig.try_fetch_value(:app_identifier)),
          FastlaneCore::ConfigItem.new(key: :team_id,
                                       short_option: "-q",
                                       env_name: "get_testflight_testers_TEAM_ID",
                                       description: "The ID of your iTunes Connect team if you're in multiple teams",
                                       optional: true,
                                       is_string: false, # as we also allow integers, which we convert to strings anyway
                                       default_value: CredentialsManager::AppfileConfig.try_fetch_value(:itc_team_id),
                                       verify_block: proc do |value|
                                         ENV["FASTLANE_ITC_TEAM_ID"] = value.to_s
                                       end),
          FastlaneCore::ConfigItem.new(key: :team_name,
                                       short_option: "-r",
                                       env_name: "get_testflight_testers_TEAM_NAME",
                                       description: "The name of your iTunes Connect team if you're in multiple teams",
                                       optional: true,
                                       default_value: CredentialsManager::AppfileConfig.try_fetch_value(:itc_team_name),
                                       verify_block: proc do |value|
                                         ENV["FASTLANE_ITC_TEAM_NAME"] = value.to_s
                                       end),
          FastlaneCore::ConfigItem.new(key: :days_of_inactivity,
                                     short_option: "-k",
                                     env_name: "get_testflight_testers_WAIT_PROCESSING_INTERVAL",
                                     description: "Numbers of days a tester has to be inactive for (no build uses) for them to be removed",
                                     default_value: 30,
                                     type: Integer,
                                     verify_block: proc do |value|
                                       UI.user_error!("Please enter a valid positive number of days") unless value.to_i > 0
                                     end),
          FastlaneCore::ConfigItem.new(key: :oldest_build_allowed,
                                     short_option: "-b",
                                     env_name: "get_testflight_testers_OLDEST_BUILD_ALLOWED",
                                     description: "Oldest build number allowed. All testers with older builds will be removed",
                                     optional: true,
                                     default_value: 0,
                                     type: Integer,
                                     verify_block: proc do |value|
                                       UI.user_error!("Please enter a valid build number") unless value.to_i >= 0
                                     end),
          FastlaneCore::ConfigItem.new(key: :limit,
                                     short_option: "-l",
                                     env_name: "get_testflight_testers_LIMIT",
                                     description: "Limit the number of testers to fetch",
                                     optional: true,
                                     default_value: 200,
                                     type: Integer
                                     ),
          FastlaneCore::ConfigItem.new(key: :dry_run,
                                     short_option: "-d",
                                     env_name: "get_testflight_testers_DRY_RUN",
                                     description: "Only print inactive users, don't delete them",
                                     default_value: false,
                                     is_string: false),
          FastlaneCore::ConfigItem.new(key: :api_key,
                                     env_names: ["PILOT_API_KEY"],
                                     description: "Your App Store Connect API Key information (https://docs.fastlane.tools/app-store-connect-api/#using-fastlane-api-key-hash-option)",
                                     type: Hash,
                                     optional: true,
                                     sensitive: true,
                                     conflicting_options: [:username]),

        ]
      end

      def self.is_supported?(platform)
        platform == :ios
      end
    end
  end
end
