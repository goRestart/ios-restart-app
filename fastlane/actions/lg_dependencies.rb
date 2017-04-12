module Fastlane
  module Actions
    module SharedValues
    end

    class LgDependenciesAction < Action
      def self.run(params)        

        gemsRequired = ["fastlane", "badge", "danger", "octokit", "crack", "byebug", "micro-optparse", "google_drive", "colorize", "web_translate_it"]
        commandsRequired = ["imagemagick"]

        if params[:lg_just_info]
          checkGems(gemsRequired)
          checkCommands(commandsRequired)
        else
          UI.message ("Make sure you run this lane both with sudo and without to first update gems and then update commands")
          if Process.uid == 0 
            # Sudo required to install/update gems
            checkAndUpdateGems(gemsRequired)
          else
            checkGems(gemsRequired)
            # Non-Sudo required to install/update commands
            checkAndUpdateCommands(commandsRequired)
          end
        end
      end

      def self.checkGems(gemsRequired)
        gemsToInstall = []
        gemsRequired.each do |gemName|
          gemsToInstall.push(gemName) unless checkGemExists(gemName)
        end
        if !gemsToInstall.empty?
          UI.error ("The following gems are required: #{gemsToInstall.join(', ')}")
          UI.important ("You can install them by executing 'sudo gem install [gemname] or call 'sudo fastlane dependencies' to install them all")
          exit
        end

        gemsToUpdate = []
        gemsRequired.each do |gemName|
          gemsToUpdate.push(gemName) unless !checkGemOutdated(gemName)
        end

        if !gemsToUpdate.empty?
          UI.important ("The following gems are outdated: #{gemsToUpdate.join(', ')}")
          UI.message ("You can update them by executing 'sudo gem update [gemname] or call 'sudo fastlane dependencies' to update them all").cyan
        end
      end

      def self.checkAndUpdateGems(gemsRequired)
        gemsToInstall = []
        gemsRequired.each do |gemName|
          gemsToInstall.push(gemName) unless checkGemExists(gemName)
        end
        if !gemsToInstall.empty?
          UI.message ("The following gems are required: #{gemsToInstall.join(', ')}")
          if UI.input("Do you want to install them? [yes/no]") == "yes"
            gemsToInstall.each do |gemName|
              installGem(gemName)
            end
          else
            UI.error ("All requirements must be installed to continue")
            exit
          end
        end

        gemsToUpdate = []
        gemsRequired.each do |gemName|
          gemsToUpdate.push(gemName) unless !checkGemOutdated(gemName)
        end

        if !gemsToUpdate.empty?
          UI.message ("The following gems are outdated: #{gemsToUpdate.join(', ')}")
          if UI.input("Do you want to update them? [yes/no]") == "yes"
            gemsToUpdate.each do |gemName|
              updateGem(gemName)
            end
          end
        end
      end

      def self.checkCommands(commandsRequired)
        commandsToInstall = []
        commandsRequired.each do |commandName|
          commandsToInstall.push(commandName) unless checkBrewPkgExists(commandName)
        end 

        if !commandsToInstall.empty? 
          UI.error ("The following commands are required: #{commandsToInstall.join(', ')}")
          UI.important ("You can install them by executing 'brew install [commandName] or call 'fastlane dependencies' to install them all")
          UI.message ("If you don't have homebrew installed, do so by looking at: https://brew.sh")
          exit
        end

        commandsToUpdate = []
        commandsRequired.each do |commandName|
          commandsToUpdate.push(commandName) unless !checkBrewPkgOutdated(commandName)
        end

        if !commandsToUpdate.empty? 
          UI.important ("The following commands are outdated: #{commandsToUpdate.join(', ')}")
          UI.message ("You can update them by executing 'brew upgrade [commandName] or call 'fastlane dependencies' to update them all").cyan
        end
      end

      def self.checkAndUpdateCommands(commandsRequired)
        commandsToInstall = []
        commandsRequired.each do |commandName|
          commandsToInstall.push(commandName) unless checkBrewPkgExists(commandName)
        end 

        if !commandsToInstall.empty? 
          UI.message ("The following commands are required: #{commandsToInstall.join(', ')}")
          if UI.input("Do you want to install them? [yes/no]") == "yes"
            commandsToInstall.each do |commandName|
              brewInstall(commandName)
            end
          else
            UI.error ("All requirements must be installed to continue")
            exit
          end
        end

        commandsToUpdate = []
        commandsRequired.each do |commandName|
          commandsToUpdate.push(commandName) unless !checkBrewPkgOutdated(commandName)
        end

        if !commandsToUpdate.empty? 
          UI.message ("The following commands are outdated: #{commandsToUpdate.join(', ')}")
          if UI.input("Do you want to update them? [yes/no]") == "yes"
            commandsToUpdate.each do |commandName|
              brewUpdate(commandName)
            end
          end
        end
      end

      def self.checkGemExists(name)
        localVersion = getGemVersion(name, false)
        return !localVersion.empty? 
      end

      def self.checkGemOutdated(name)
        localVersion = getGemVersion(name, false)
        remoteVersion = getGemVersion(name, true)
        outdated = localVersion < remoteVersion
        UI.message ("Gem #{name} is outdated: You're in #{localVersion} and current one is #{remoteVersion}") unless !outdated
        return outdated
      end

      def self.getGemVersion(name, remote)
        command = ""
        if remote
          command = "gem list #{name} -r | grep -w '#{name}' | head -n1 | sed 's/.*(\\(.*\\))/\\1/'"
        else 
          command = "gem list #{name} | grep -w '#{name}' | head -n1 | sed 's/.*(\\(.*\\))/\\1/'"
        end
        return FastlaneCore::CommandExecutor.execute(command: command, 
                                                             print_all: false, 
                                                             print_command: false,
                                                             error: proc do |error_output| 
                                                              return ""
                                                             end)
      end

      def self.installGem(name)
        FastlaneCore::CommandExecutor.execute(command: "gem install #{name}",
                                                             print_all: false,
                                                             print_command: true,
                                                             error: proc do |error_output| 
                                                              return false
                                                             end)
      end

      def self.updateGem(name)
        FastlaneCore::CommandExecutor.execute(command: "gem update #{name}",
                                                             print_all: false,
                                                             print_command: true,
                                                             error: proc do |error_output| 
                                                              return false
                                                             end)
      end

      def self.checkBrewPkgExists(name)
        listInfo = FastlaneCore::CommandExecutor.execute(command: "brew list #{name}",
                                                             print_all: false,
                                                             print_command: false,
                                                             error: proc do |error_output| 
                                                              return false
                                                             end)
        return !listInfo.empty?
      end

      def self.checkBrewPkgOutdated(name)
        localVersion = getBrewPkgVersion(name, false)
        remoteVersion = getBrewPkgVersion(name, true)
        outdated = localVersion < remoteVersion
        UI.message ("Brew package #{name} is outdated: You're in #{localVersion} and current one is #{remoteVersion}") unless !outdated
        return outdated
      end

      def self.getBrewPkgVersion(name, remote)
        command = ""
        if remote 
          command = "brew info imagemagick | cat | head -n1 | sed 's/[^0-9.]*\\([0-9.]*\\).*/\\1/'"
        else
          command = "brew list imagemagick --versions | sed 's/[^0-9.]*\\([0-9.]*\\).*/\\1/'"
        end
        return FastlaneCore::CommandExecutor.execute(command: command, 
                                                     print_all: false, 
                                                     print_command: false,
                                                     error: proc do |error_output| 
                                                      return ""
                                                     end)
      end

      def self.brewUpdate(name)
        FastlaneCore::CommandExecutor.execute(command: "brew upgrade #{name}",
                                                             print_all: false,
                                                             print_command: true,
                                                             error: proc do |error_output| 
                                                              return false
                                                             end)
      end

      def self.brewInstall(name)
        FastlaneCore::CommandExecutor.execute(command: "brew install #{name}",
                                                             print_all: false,
                                                             print_command: true,
                                                             error: proc do |error_output| 
                                                              return false
                                                             end)
      end

      #####################################################
      # @!group Documentation
      #####################################################

      def self.description
        "Check that you have installed all the needed dependencies to use all our custom fastlane actions"
      end

      def self.available_options
        [           
          FastlaneCore::ConfigItem.new(key: :lg_just_info,
                                       env_name: "LG_DEPENDENCIES_JUST_INFO",
                                       description: "Whether to show just information or install/update",
                                       is_string: false,
                                       default_value: true,
                                       optional: true)
        ]
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
