module Fastlane
  module Actions
    module SharedValues
      RB_INFO_BRANCH_NAME = :RB_INFO_BRANCH_NAME
      RB_INFO_SCHEME_NAME = :RB_INFO_SCHEME_NAME
      RB_INFO_VERSION_NUMBER = :RB_INFO_VERSION_NUMBER
      RB_INFO_BUILD_NUMBER = :RB_INFO_BUILD_NUMBER
      RB_INFO_BETA_TESTERS_GROUPS = :RB_INFO_BETA_TESTERS_GROUPS
      RB_INFO_API_SERVER = :RB_INFO_API_SERVER
      RB_INFO_SIMULATOR = :RB_INFO_SIMULATOR
      RB_INFO_BUILD_CONFIGURATION = :RB_INFO_BUILD_CONFIGURATION
      RB_API_ENVIRONMENT = :RB_API_ENVIRONMENT
    end

    class RbInfoCollectorAction < Action
      def self.run(params)

        ask_for_branch_name = params[:ask_for_branch_name]
        ask_for_scheme_name = params[:ask_for_scheme_name]
        ask_for_version_number = params[:ask_for_version_number]
        ask_for_build_number = params[:ask_for_build_number]
        ask_for_beta_testers_groups = params[:ask_for_beta_testers_groups]
        ask_for_api_server = params[:ask_for_api_server]
        ask_for_simulator = params[:ask_for_simulator]
        ask_for_build_configuration = params[:ask_for_build_configuration]
        
        UI.message ("👾  Some data is necessary to run this script, define the next values:").cyan

        if ask_for_branch_name
          branch_name = ask("Branch name = ".yellow)
          if branch_name.nil?
            raise "The branch name is necessary to continue with this script."
          else
            Actions.lane_context[SharedValues::RB_INFO_BRANCH_NAME] = branch_name
            ENV["RB_INFO_BRANCH_NAME"] = branch_name
          end
        end

        if ask_for_scheme_name
          scheme_name = ask("Scheme name (just the letter: L, A, B, P, ...) = ".yellow)
          if scheme_name.nil?
            raise "The scheme name is necessary to continue with this script."
          else
            Actions.lane_context[SharedValues::RB_INFO_SCHEME_NAME] = scheme_name
            ENV["XCODE_SCHEME"] = "Redbooth" + scheme_name
          end
        end

        if ask_for_build_configuration
          build_configuration = ask("Build configuration (Example: Debug, Release, AdHoc, ...) = ".yellow)
          if build_configuration.nil?
            raise "The build configuration is necessary to continue with this script."
          else
            Actions.lane_context[SharedValues::RB_INFO_BUILD_CONFIGURATION] = build_configuration
            ENV["RB_INFO_BUILD_CONFIGURATION"] = build_configuration
          end
        end

        if ask_for_version_number
          version_number = ask("Version number = ".yellow)
          if version_number.nil?
            raise "The version number is necessary to continue with this script."
          else
            Actions.lane_context[SharedValues::RB_INFO_VERSION_NUMBER] = version_number
            ENV["RB_INFO_VERSION_NUMBER"] = version_number
          end
        end

        if ask_for_build_number
          build_number = ask("Build number = ".yellow)
          if build_number.nil?
            raise "The build number is necessary to continue with this script."
          else
            Actions.lane_context[SharedValues::RB_INFO_BUILD_NUMBER] = build_number
            ENV["RB_INFO_BUILD_NUMBER"] = build_number
          end
        end

        if ask_for_beta_testers_groups
          beta_testers_groups = ask("Beta tester groups [iOS=ios-team Redbooth=redbooth-] (Ex: ios-team,redbooth-,redbooth-android) = ".yellow)
          if beta_testers_groups.nil?
            raise "The beta tester groups is necessary to continue with this script."
          else
            Actions.lane_context[SharedValues::RB_INFO_BETA_TESTERS_GROUPS] = beta_testers_groups
            ENV["RB_INFO_BETA_TESTERS_GROUPS"] = beta_testers_groups
          end
        end

        if ask_for_api_server
          api_server = ask("API Server URL to connect the app [shortcuts for production URL: p=https://redbooth.com, staging URL: s=http://release.staging.redbooth.com] = ".yellow)
          if api_server.nil?
            raise "The Api Server is necessary to continue"
          else
            Actions.lane_context[SharedValues::RB_INFO_API_SERVER] = api_server
            ENV["RB_INFO_API_SERVER"] = api_server
          end

          api_environment = ask("API Server environment. Is it Production [p] or Staging [s]?".yellow)
          if api_environment.nil?
            raise "The API environment is necessary to continue"
          else
            Actions.lane_context[SharedValues::RB_API_ENVIRONMENT] = api_environment
            ENV["RB_API_ENVIRONMENT"] = api_environment
          end
        end

        if ask_for_simulator
          deviceList = `xcrun instruments -s devices | grep Simulator | grep Simulator -n`
          UI.message ("#{deviceList}").blue
          selected_number = ask("Select a device from the list above, just the number (default=1)".yellow)
          if selected_number.nil?
            selected_number = 1
          end
          selected_simulator = `xcrun instruments -s devices | grep Simulator | head -n#{selected_number} | tail -n1`
          Actions.lane_context[SharedValues::RB_INFO_SIMULATOR] = selected_simulator
          ENV["RB_INFO_SIMULATOR"] = selected_simulator
        end

      end



      #####################################################
      # @!group Documentation
      #####################################################

      def self.description
        "Collect all the info necessary to run a lane"
      end

      def self.available_options
        [
          FastlaneCore::ConfigItem.new(key: :ask_for_branch_name,
                                       env_name: "RB_INFO_ASK_FOR_BRANCH_NAME",
                                       description: "Mark as true if you wanna ask for this flag and collect the info to share it in the lane",
                                       optional: true,
                                       is_string: false),
          FastlaneCore::ConfigItem.new(key: :ask_for_scheme_name,
                                       env_name: "RB_INFO_ASK_FOR_SCHEME_NAME",
                                       description: "Mark as true if you wanna ask for this flag and collect the info to share it in the lane",
                                       optional: true,
                                       is_string: false),
          FastlaneCore::ConfigItem.new(key: :ask_for_version_number,
                                       env_name: "RB_INFO_ASK_FOR_VERSION_NUMBER",
                                       description: "Mark as true if you wanna ask for this flag and collect the info to share it in the lane",
                                       optional: true,
                                       is_string: false),
          FastlaneCore::ConfigItem.new(key: :ask_for_build_number,
                                       env_name: "RB_INFO_ASK_FOR_BUILD_NUMBER",
                                       description: "Mark as true if you wanna ask for this flag and collect the info to share it in the lane",
                                       optional: true,
                                       is_string: false),
          FastlaneCore::ConfigItem.new(key: :ask_for_beta_testers_groups,
                                       env_name: "RB_INFO_ASK_FOR_BETA_TESTERS_GROUPS",
                                       description: "Mark as true if you wanna ask for this flag and collect the info to share it in the lane",
                                       optional: true,
                                       is_string: false),  
          FastlaneCore::ConfigItem.new(key: :ask_for_api_server,
                                       env_name: "RB_INFO_ASK_FOR_API_SERVER",
                                       description: "Mark as true if you wanna ask for this flag and collect the info to share it in the lane",
                                       optional: true,
                                       is_string: false),  
          FastlaneCore::ConfigItem.new(key: :ask_for_simulator,
                                       env_name: "RB_INFO_ASK_FOR_SIMULATOR",
                                       description: "Choose a simulator from a list to open it",
                                       optional: true,
                                       is_string: false),
          FastlaneCore::ConfigItem.new(key: :ask_for_build_configuration,
                                       env_name: "RB_INFO_ASK_FOR_BUILD_CONFIGURATION",
                                       description: "Choose build configuration",
                                       optional: true,
                                       is_string: false),
        ]
      end

      def self.output
        [
          ['RB_INFO_BRANCH_NAME', 'Branch name'],
          ['RB_INFO_SCHEME_NAME', 'Target name (letter)'],
          ['RB_INFO_VERSION_NUMBER', 'Version number'],
          ['RB_INFO_BUILD_NUMBER', 'Build number'],
          ['RB_INFO_BETA_TESTERS_GROUPS', 'Beta testers groups'],
          ['RB_INFO_API_SERVER', 'API Server'],
          ['RB_INFO_SIMULATOR', 'Simulator'],
          ['RB_INFO_BUILD_CONFIGURATION', 'Build configuration'],
	  ['RB_API_ENVIRONMENT', 'API Environment']
        ]
      end

      def self.author
        'Redbooth Inc'
      end

      def self.is_supported?(platform)
        platform == :ios
      end

    end
  end
end
