module Fastlane
  module Actions
    module SharedValues
    end

    class RbGitCloneCleanAction < Action
      def self.run(params)

        git_clone_path = Actions.lane_context[SharedValues::RB_GIT_CLONE_TMP_FOLDER]
        FileUtils.rm_rf(git_clone_path)
        UI.message ("Removed temporary folder created in git_clone: /" + git_clone_path).blue

      end



      #####################################################
      # @!group Documentation
      #####################################################

      def self.description
        "Clean all the temporary files created by the rb_git_clone action"
      end

      def self.available_options
      end

      def self.output
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