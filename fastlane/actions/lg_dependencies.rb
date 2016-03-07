module Fastlane
  module Actions
    module SharedValues
    end

    class LgDependenciesAction < Action
      def self.run(params)

        githubChangesInstalled = system("github-changes --help > /dev/null")
        badgeInstalled = system("badge --help > /dev/null")
        imageMagickInstalled = system("convert --version > /dev/null")

        if !githubChangesInstalled || !badgeInstalled || !imageMagickInstalled
          Helper.log.info ("👻  👻  👻  👻  👻  👻  👻  👻  👻  👻  👻  👻  👻  👻  👻  👻")
          Helper.log.info ("Seems like you don't have all the needed dependencies:")
          if !githubChangesInstalled
            Helper.log.info ("- Download npm from https://nodejs.org/dist/v5.5.0/node-v5.5.0.pkg")
            Helper.log.info ("- Install github-changes with `npm install -g github-changes`")
          end
          if !badgeInstalled
            Helper.log.info ("- Install badge gem: `sudo gem install badge`")
          end
          if !imageMagickInstalled
            Helper.log.info ("- Install Imagemagick: `brew install imagemagick`")
            Helper.log.info ("\t- If the installation fails you probably need the following:")
            Helper.log.info ("\t\t- Update brew permissions: `sudo chown -R $USER:admin /usr/local`")
            Helper.log.info ("\t\t- Link what brew suggests: `brew link ...`")
            Helper.log.info ("\t\t- Try install again: `brew install imagemagick`")
          end
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
