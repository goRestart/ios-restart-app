module Fastlane
  module Actions
    module SharedValues
    end

    class LgDependenciesAction < Action
      def self.run(params)

        res = system("github-changes --help > /dev/null")
        if res != true
          Helper.log.info ("👻  👻  👻  👻  👻  👻  👻  👻  👻  👻  👻  👻  👻  👻  👻  👻")
          Helper.log.info ("Seems like you don't have all the needed dependencies:")
          Helper.log.info ("- Download npm from https://nodejs.org/dist/v5.5.0/node-v5.5.0.pkg")
          Helper.log.info ("- Install github-changes with `npm install -g github-changes`")
          Helper.log.info ("👻  👻  👻  👻  👻  👻  👻  👻  👻  👻  👻  👻  👻  👻  👻  👻")
          exit
        end

      end


      #####################################################
      # @!group Documentation
      #####################################################

      def self.description
        "Check that you have installed all the needed dependencies to use all our custom fastlane actions"
      end

      def self.available_options
        [ ]
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
