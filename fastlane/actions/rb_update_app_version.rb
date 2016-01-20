module Fastlane
  module Actions
    module SharedValues
      RB_BUILD_NUMBER = :RB_BUILD_NUMBER
      RB_VERSION_NUMBER = :RB_VERSION_NUMBER
    end

    class RbUpdateAppVersionAction < Action
      require 'cfpropertylist'
      require 'json'

      def self.getInfoPlistValue(key, filePath)
        return (`/usr/libexec/PlistBuddy -c "Print :#{key}" "#{filePath}"`).strip
      end

      def self.setInfoPlistVersionValue(key, value, filePath)
        command = "/usr/libexec/PlistBuddy -c 'Set :#{key} #{value}' '#{filePath}'"
        Helper.log.debug command
        Actions.sh command
      end

      def self.run(params)
        branch_name = params[:branch_name]
        build_number = params[:build_number]
        version_number = params[:version_number]
        path_to_repo = params[:repository_path] ||= ""
        push_changes = params[:push_changes]
        autoincrement = params[:autoincrement] #will only work if build_number is not passed
        update_json_files = params[:update_json_files]

        if branch_name
          changeBranchCommand = "(cd #{path_to_repo} && git checkout #{branch_name})"
          Helper.log.debug changeBranchCommand
          Actions.sh changeBranchCommand
        end

        current_app_build_num = getInfoPlistValue("CFBundleVersion", File.join(path_to_repo, ENV["APP_PLIST_PATH"]))
        current_app_version_num = getInfoPlistValue("CFBundleShortVersionString", File.join(path_to_repo, ENV["APP_PLIST_PATH"]))

        if build_number.nil? && autoincrement 
          build_number = (current_app_build_num.to_i + 1).to_s
        end

        sth_changed = false
        if current_app_build_num.strip == build_number
          Helper.log.debug "Build number not changed, it already has the desired value"
        else
          setInfoPlistVersionValue("CFBundleVersion", build_number, File.join(path_to_repo, ENV["APP_PLIST_PATH"]))
          sth_changed = true
        end

        if current_app_version_num.strip == version_number
          Helper.log.debug "Version number not changed, it already has the desired value"
        else
          setInfoPlistVersionValue("CFBundleShortVersionString", version_number, File.join(path_to_repo, ENV["APP_PLIST_PATH"]))
          sth_changed = true
        end

        Helper.log.info "Bundle: #{build_number} Version: #{version_number}".blue

        if update_json_files

        end

        if push_changes && sth_changed
          Helper.log.info "Pushing changes...".blue
          pushChangeCommand = "(cd #{path_to_repo} && git add " + ENV["APP_PLIST_PATH"] + 
                              " && git commit -m '★ Update version to #{version_number} (#{build_number})' && git push)"
          Helper.log.debug pushChangeCommand
          Actions.sh pushChangeCommand
          Helper.log.info "Version changes pushed successfully!".blue
        end

        Actions.lane_context[SharedValues::RB_BUILD_NUMBER] = build_number
        Actions.lane_context[SharedValues::RB_VERSION_NUMBER] = version_number
      end



      #####################################################
      # @!group Documentation
      #####################################################

      def self.description
        "Changes app build number and pushes the change to a specific branch"
      end

      def self.available_options
        [
          FastlaneCore::ConfigItem.new(key: :branch_name,
                                       env_name: "RB_UPDATE_APP_VERSION_BRANCH_NAME",
                                       description: "Name of the branch where the new version number is going to be pushed. Current branch if it's not defined",
                                       optional: true),
          FastlaneCore::ConfigItem.new(key: :build_number,
                                       env_name: "RB_UPDATE_APP_VERSION_BUILD_NUMBER",
                                       description: "Build number aka CFBundleVersion. If no version_number is provided, will be used also as short version number",
                                       optional: true),
          FastlaneCore::ConfigItem.new(key: :version_number,
                                       env_name: "RB_UPDATE_APP_VERSION_VERSION_NUMBER",
                                       description: "Version number aka CFBundleShortVersionString",
                                       optional: false),
          FastlaneCore::ConfigItem.new(key: :repository_path,
                                       env_name: "RB_UPDATE_APP_VERSION_REPO_PATH",
                                       description: "[Optional] Path to the repository. If not provided will use current directory",
                                       optional: true),
          FastlaneCore::ConfigItem.new(key: :push_changes,
                                       env_name: "RB_UPDATE_APP_VERSION_PUSH_CHANGES",
                                       description: "TRUE if you want to push the changes to the current branch",
                                       optional: true,
                                       is_string: false),   
          FastlaneCore::ConfigItem.new(key: :autoincrement,
                                       env_name: "RB_UPDATE_APP_VERSION_AUTOINCREMENT",
                                       description: "TRUE if you want to autoincrement the build_number",
                                       optional: true,
                                       is_string: false),     
          FastlaneCore::ConfigItem.new(key: :update_json_files,
                                       env_name: "RB_UPDATE_APP_VERSION_UPDATE_JSON",
                                       description: "TRUE if you want to update the build_number of the config json files",
                                       optional: true,
                                       is_string: false), 
        ]
      end

      def self.output
        [
          ['RB_BUILD_NUMBER', 'The new build number'],
          ['RB_VERSION_NUMBER', 'The new version value']
        ]
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