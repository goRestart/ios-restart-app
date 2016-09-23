module Fastlane
  module Actions
    module SharedValues
    end

    class LgBumperAction < Action
      def self.run(params)
        source_json = params[:source_json]
        destination_dir = params[:destination_dir]
        scriptCommand = "ruby ./Pods/bumper/scripts/flags_generator/flags_generator.rb -s #{source_json} -d #{destination_dir}"
        puts scriptCommand
        Helper.log.debug scriptCommand
        Actions.sh scriptCommand
      end


      #####################################################
      # @!group Documentation
      #####################################################

      def self.description
        "Updates Web Translate It with the new validated strings from google drive, download all the changes from wti and generate all not-yet valid strings on base + localizables file"
      end

      def self.available_options
        [FastlaneCore::ConfigItem.new(key: :source_json,
                                       env_name: "RB_BUMPER_SOURCE_JSON",
                                       description: "Bumper json source path",
                                       optional: false),
        FastlaneCore::ConfigItem.new(key: :destination_dir,
                                       env_name: "RB_BUMPER_DESTINATION_DIR",
                                       description: "Bumper swift generated file dir",
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