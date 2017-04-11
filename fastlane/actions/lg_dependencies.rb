module Fastlane
  module Actions
    module SharedValues
    end

    class LgDependenciesAction < Action
      def self.run(params)

        UI.message ("Make sure you run this lane both with sudo and without to first update gems and then update commands")

        gemsRequired = ["fastlane", "badge"]
        commandsRequired = ["imagemagick"]

        if Process.uid == 0 
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
        else
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
            UI.message ("The following commands are outdated: #{commandsToUpdate.join(', ')}") unless commandsToUpdate.empty?
            if UI.input("Do you want to update them? [yes/no]") == "yes"
              commandsToUpdate.each do |commandName|
                brewUpdate(commandName)
              end
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
