module Fastlane
  module Actions
    module SharedValues
      RB_CREATED_BRANCH_NAME = :RB_CREATED_BRANCH_NAME
    end

    class RbGitCreateBranchAction < Action

      def self.run(params)
        branch_name = params[:branch_name]
        repository_path = params[:repository_path]
        UI.message ("Creating new branch: " + branch_name).blue

        if repository_path.nil?
          command = "git checkout -b #{branch_name} && git push -u origin #{branch_name}"
        else
          command = "(cd #{repository_path} && git checkout -b #{branch_name} && git push -u origin #{branch_name})"
        end

        UI.message command
        Actions.sh command
        Actions.lane_context[SharedValues::RB_CREATED_BRANCH_NAME] = branch_name
        Actions.lane_context[Actions::SharedValues::RB_INFO_BRANCH_NAME] = branch_name
        UI.message ("New branch #{branch_name} created").blue
      end


      #####################################################
      # @!group Documentation
      #####################################################

      def self.description
        "Creates and pushes a new branch"
      end

      def self.available_options
        [
          FastlaneCore::ConfigItem.new(key: :branch_name,
                                       env_name: "RB_CREATE_BRANCH_NAME",
                                       description: "Name of the branch that is going to be created",
                                       optional: false),
          FastlaneCore::ConfigItem.new(key: :repository_path,
                                       env_name: "RB_CREATE_BRANCH_REPOSITORY_PATH",
                                       description: "Path where the command to create new branch is going to be executed",
                                       optional: true)
        ]
      end

      def self.output
        [
          ['RB_CREATED_BRANCH_NAME', 'Name of the created branch']
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