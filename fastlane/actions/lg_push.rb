module Fastlane
  module Actions
    module SharedValues
    end

    class LgPushAction < Action
      def self.run(params)

        path_to_repo = params[:repository_path]
        build_number = params[:build_number]
        version_number = params[:version_number]

        UI.message "Pushing changes...".blue
        pushChangeCommand = "(cd #{path_to_repo} && git add ." + 
                        " && git commit -m '★ Update version to #{version_number} (#{build_number})' && git pull && git push)"
        UI.message pushChangeCommand
        Actions.sh pushChangeCommand
        UI.success "Version changes pushed successfully!"
      end


      #####################################################
      # @!group Documentation
      #####################################################

      def self.description
        "Uploads all changes in repository_path to remote git server with a commit indicating the version_number and build_number"
      end

      def self.available_options
        [
         FastlaneCore::ConfigItem.new(key: :repository_path,
                                       env_name: "RB_UPDATE_APP_VERSION_REPO_PATH",
                                       description: "Path to the repository",
                                       optional: false),
          FastlaneCore::ConfigItem.new(key: :build_number,
                                       env_name: "RB_UPDATE_APP_VERSION_BUILD_NUMBER",
                                       description: "Build number aka CFBundleVersion",
                                       optional: false),
          FastlaneCore::ConfigItem.new(key: :version_number,
                                       env_name: "RB_UPDATE_APP_VERSION_VERSION_NUMBER",
                                       description: "Version number aka CFBundleShortVersionString",
                                       optional: false),
        ]
      end

      def self.output
        [ ]
      end

      def self.authors
        ["letgo"]
      end

      def self.is_supported?(platform)
        platform == :ios
      end
    end
  end
end