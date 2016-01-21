module Fastlane
  module Actions
    module SharedValues
    end

    class RbLoadEnvironmentAction < Action
      def self.run(params)
        sh 'cp ~/.env_fastlane ./fastlane/.env'
        require 'dotenv'
        Dotenv.load
      end


      #####################################################
      # @!group Documentation
      #####################################################

      def self.description
        "Load .env file from ~/.env_fastlane"
      end

      def self.available_options
        [ ]
      end

      def self.output
        [ ]
      end

      def self.authors
        ["Redbooth Inc"]
      end

      def self.is_supported?(platform)
        platform == :ios
      end
    end
  end
end