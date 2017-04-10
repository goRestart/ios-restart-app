module Fastlane
  module Actions
    module SharedValues
      RB_GIT_TAG_VALUE = :RB_GIT_TAG_VALUE
    end

    class RbGitTagAction < Action
      def self.run(params)
        tag_name = params[:tag_name]
        path_to_repo = params[:repository_path] 

        if !path_to_repo.nil?
          cdCommand = "cd #{path_to_repo}"
          UI.message cdCommand
          Actions.sh cdCommand
        end

        command = "git tag #{tag_name} && git push origin #{tag_name}"
        UI.message command
        Actions.sh command

        Actions.lane_context[SharedValues::RB_GIT_TAG_VALUE] = tag_name
        UI.message "Tag created and pushed to repository".blue
      end



      #####################################################
      # @!group Documentation
      #####################################################

      def self.description
        "A short description with <= 80 characters of what this action does"
      end

      def self.available_options
        [
          FastlaneCore::ConfigItem.new(key: :tag_name,
                                       env_name: "RB_GIT_TAG_NAME",
                                       description: "Tag name, usually a version number",
                                       optional: false),
          FastlaneCore::ConfigItem.new(key: :repository_path,
                                       env_name: "RB_GIT_TAG_REPO_PATH",
                                       description: "[Optional] Path to the repository. If not provided will use current directory",
                                       optional: true)
        ]
      end

      def self.output
        [
          ['RB_GIT_TAG_VALUE', 'Tag created']
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