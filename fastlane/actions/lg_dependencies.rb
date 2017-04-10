module Fastlane
  module Actions
    module SharedValues
    end

    class LgDependenciesAction < Action
      def self.run(params)

        badgeInstalled = system("badge --help > /dev/null")
        imageMagickInstalled = system("convert --version > /dev/null")

        if !badgeInstalled || !imageMagickInstalled
          UI.message ("👻  👻  👻  👻  👻  👻  👻  👻  👻  👻  👻  👻  👻  👻  👻  👻")
          UI.important ("Seems like you don't have all the needed dependencies:")
          if !badgeInstalled
            UI.message ("- Install badge gem: `sudo gem install badge`")
          end
          if !imageMagickInstalled
            UI.message ("- Install Imagemagick: `brew install imagemagick`")
            UI.message ("\t- If the installation fails you probably need the following:")
            UI.message ("\t\t- Update brew permissions: `sudo chown -R $USER:admin /usr/local`")
            UI.message ("\t\t- Link what brew suggests: `brew link ...`")
            UI.message ("\t\t- Try install again: `brew install imagemagick`")
          end
          UI.message ("👻  👻  👻  👻  👻  👻  👻  👻  👻  👻  👻  👻  👻  👻  👻  👻")
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
