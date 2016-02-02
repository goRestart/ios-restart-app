module Fastlane
  module Actions
    module SharedValues
    end

    class LgStringsAction < Action
      def self.run(params)
        path_to_repo = params[:repository_path]
        pushChangeCommand = "ruby #{path_to_repo}Scripts/strings_update.rb -i #{path_to_repo}"
        Helper.log.debug pushChangeCommand
        Actions.sh pushChangeCommand
      end


      #####################################################
      # @!group Documentation
      #####################################################

      def self.description
        "Updates Web Translate It with the new validated strings from google drive, download all the changes from wti and generate all not-yet valid strings on base + localizables file"
      end

      def self.available_options
        [FastlaneCore::ConfigItem.new(key: :repository_path,
                                       env_name: "RB_STRINGS_REPO_PATH",
                                       description: "Path to the repository",
                                       optional: false)]
      end

      def self.output
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