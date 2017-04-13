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
        UI.message scriptCommand
        Actions.sh scriptCommand
      end


      #####################################################
      # @!group Documentation
      #####################################################

      def self.description
        "Bumper pod fastlane action: Generates BumperFeatures.swift file"
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