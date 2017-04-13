module Fastlane
  module Actions
    module SharedValues
    end

    class LgRevertGitAction < Action
      def self.run(params)
        path_to_repo = params[:repository_path]
        items_to_revert = params[:items_to_revert]

        command = "git checkout #{items_to_revert}"
        if !path_to_repo.nil?
          command = "cd #{path_to_repo} && git checkout #{items_to_revert}"
        end
        UI.message command
        Actions.sh command
      end


      #####################################################
      # @!group Documentation
      #####################################################

      def self.description
        "Reverts changes on git"
      end

      def self.available_options
        [
          FastlaneCore::ConfigItem.new(key: :items_to_revert,
                                       env_name: "LG_REVERT_GIT_ITEMS_TO_REVERT",
                                       description: "Items to revert inside repo path",
                                       optional: false),
          FastlaneCore::ConfigItem.new(key: :repository_path,
                                       env_name: "LG_REVERT_GIT_REPO_PATH",
                                       description: "[Optional] Path to the repository. If not provided will use current directory",
                                       optional: true)
        ]
      end

      def self.output
        []
      end

      def self.author
        'LetGo'
      end

      def self.is_supported?(platform)
        platform == :ios
      end
    end
  end
end
