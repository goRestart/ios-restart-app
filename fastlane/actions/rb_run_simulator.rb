module Fastlane
  module Actions
    module SharedValues
    end

    class RbRunSimulatorAction < Action
      def self.run(params)

        workspace = params[:workspace]
        scheme = params[:scheme] ||= "RedboothA"
        bundle = params[:bundle_identifier] ||= "com.teambox.TeamboxA"
        sdk = params[:sdk] ||= "iphonesimulator8.3"
        simulator = params[:simulator] ||= "iPhone 6 (8.3 Simulator)"

        ipa_res = `xcodebuild -arch 'i386' -scheme '#{scheme}' -configuration Debug -sdk '#{sdk}' -workspace '#{workspace}' -showBuildSettings | grep 'CODESIGNING_FOLDER_PATH' | sed 's/[ ]*CODESIGNING_FOLDER_PATH = //' | grep '#{scheme}'`

        `xcrun instruments -w '#{simulator}'`

        # wait until there is a device booted
        count=`xcrun simctl list | grep Booted | wc -l | sed -e 's/ //g'`
        while count.to_i < 1 do
            UI.message ("Waiting for iOS Simuator to boot")
            sleep 1
            count=`xcrun simctl list | grep Booted | wc -l | sed -e 's/ //g'`
        end

        # uninstall old / install new
        `xcrun simctl uninstall booted #{bundle}`
        `xcrun simctl install booted #{ipa_res}`

        # run app:
        `xcrun simctl launch booted #{bundle}`
      end


      #####################################################
      # @!group Documentation
      #####################################################

      def self.description
        "Execute the current compilation in a Simulator"
      end

      def self.available_options
        [
          FastlaneCore::ConfigItem.new(key: :bundle_identifier,
                                       env_name: "RB_BUNDLE_IDENTIFIER",
                                       description: "Bundle identifier to run in simulator",
                                       optional: false),
          FastlaneCore::ConfigItem.new(key: :app_path,
                                       env_name: "RB_APP_PATH",
                                       description: "Path to the .app file to install in simulator",
                                       optional: false),
          FastlaneCore::ConfigItem.new(key: :scheme,
                                       env_name: "RB_SCHEME",
                                       description: "Scheme to compile the app",
                                       optional: false),
          FastlaneCore::ConfigItem.new(key: :workspace,
                                       env_name: "RB_WORKSPACE",
                                       description: "Path to workspace",
                                       optional: false),
          FastlaneCore::ConfigItem.new(key: :sdk,
                                       env_name: "RB_BUILD_SDK",
                                       description: "SDK to compile the app (simulator sdk like iphonesimulator8.3",
                                       optional: false),
          FastlaneCore::ConfigItem.new(key: :simulator,
                                       env_name: "RB_SIMULATOR_NAME",
                                       description: "Name of the simulator where you want to execute the app (ex: 'iPhone 6 (8.3 Simulator)'  )",
                                       optional: false),

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