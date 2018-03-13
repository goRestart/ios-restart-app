gem 'google_drive', '>=2.0.0'
require 'google_drive'

module Fastlane
  module Actions
    module SharedValues
    end

    class LgStringsAction < Action
      def self.run(params)
        path_to_repo = params[:repository_path]
        mark_unused_strings = params[:mark_unused_strings]
        remove_unused_strings = params[:remove_unused_strings]
        pushChangeCommand = "ruby #{path_to_repo}fastlane/scripts/strings_update.rb -i #{path_to_repo}"

        if mark_unused_strings 
          pushChangeCommand << " -c -m"
        end

        if remove_unused_strings
          pushChangeCommand << " -r"
        end

        ENV["STRINGS_CREDENTIALS_PATH"] = Dir.home + '/.locgen/lg_strings_update_v2.json'
        ENV["STRINGS_CLIENT_ID"] = "992995045432-2u7mrinee9u8o4fo3nuaivhjlq7ogpt6.apps.googleusercontent.com"
        ENV["STRINGS_CLIENT_SECRET"] = "GhEnWQ2ucBbQHdr-mSUmgltF"

        FileUtils.mkdir_p(File.dirname(ENV["STRINGS_CREDENTIALS_PATH"]))
        begin
          session = GoogleDrive.saved_session(ENV["STRINGS_CREDENTIALS_PATH"], nil, ENV["STRINGS_CLIENT_ID"], ENV["STRINGS_CLIENT_SECRET"])
        rescue 
          UI.error 'Couldn\'t access Google Drive. Check your credentials!'
          exit -1
        end        

        UI.message pushChangeCommand
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
                                       optional: false), 
        FastlaneCore::ConfigItem.new(key: :mark_unused_strings,
                                       env_name: "RB_STRINGS_MARK_UNUSED",
                                       description: "Mark all the unused strings in Localizables",
                                       optional: true,
                                       is_string: false),
        FastlaneCore::ConfigItem.new(key: :remove_unused_strings,
                                       env_name: "RB_STRINGS_REMOVE_UNUSED",
                                       description: "Remove all the unused strings in Localizables",
                                       optional: true,
                                       is_string: false)]
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