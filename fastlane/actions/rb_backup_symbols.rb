module Fastlane
  module Actions
    module SharedValues
    end

    class RbBackupSymbolsAction < Action
      def self.run(params)
        symbols_path = params[:symbols_path]
        symbols_build_number = params[:symbols_build_number]
        symbols_build_scheme = params[:symbols_build_scheme]
        symbols_backup_path = params[:symbols_backup_path]
        backup_ipa = params[:backup_ipa]

        timestamp = Time.new.strftime("%Y-%m-%d_%H.%M.%S")
        complete_backup_path = File.expand_path("#{symbols_backup_path}/#{symbols_build_scheme}/#{symbols_build_number}/#{timestamp}")

        dsym_path = Dir["#{symbols_path}/*.dSYM.zip"].first
        if dsym_path.nil?
          dsym_path = Dir["#{symbols_path}/*.dSYM"].first
        end

        if dsym_path
          FileUtils.mkdir_p(complete_backup_path)
          FileUtils.cp(dsym_path, complete_backup_path)
          UI.message "Symbols file (#{dsym_path}) copied to backups folder (#{complete_backup_path})"
        else
          UI.error "Couldn't find the symbols file, backup not done"
        end

        if backup_ipa
          ipa_path = Dir["#{symbols_path}/*.ipa"].first
          if ipa_path
            FileUtils.mkdir_p(complete_backup_path)
            FileUtils.cp(ipa_path, complete_backup_path)
            UI.message "Ipa file (#{ipa_path}) copied to backups folder (#{complete_backup_path})"
          else
            UI.error "Couldn't find the ipa file, backup not done"
          end
        end

      end

      #####################################################
      # @!group Documentation
      #####################################################

      def self.description
        "Save a backup of the symbols file in the local machine. You also can backup the ipa file."
      end

      def self.available_options
        [
          FastlaneCore::ConfigItem.new(key: :symbols_path,
                                       env_name: "RB_SYMBOLS_PATH",
                                       description: "Path where the symbols file is to copy it and do a backup",
                                       optional: false),
          FastlaneCore::ConfigItem.new(key: :symbols_build_number,
                                       env_name: "RB_SYMBOLS_BUILD_NUMBER",
                                       description: "Build number of the build which produced the symbols",
                                       optional: false),
          FastlaneCore::ConfigItem.new(key: :symbols_build_scheme,
                                       env_name: "RB_SYMBOLS_BUILD_SCHEME",
                                       description: "Scheme name of the build which produced the symbols",
                                       optional: false),
          FastlaneCore::ConfigItem.new(key: :symbols_backup_path,
                                       env_name: "RB_SYMBOLS_BACKUP_PATH",
                                       description: "Path where the symbols file is going to be copied",
                                       optional: false),
          FastlaneCore::ConfigItem.new(key: :backup_ipa,
                                       env_name: "RB_BACKUP_IPA",
                                       description: "YES if you wanna backup the ipa file as well",
                                       optional: true,
                                       is_string: false),
        ]
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