module Fastlane
  module Actions
    module SharedValues
    end

    class LgAssetsAction < Action
      def self.run(params)
        path_to_repository = params[:repository_path]
        path_to_assets = path_to_repository + "Ambatana/res/img"
        path_to_src = path_to_repository + "Ambatana/src"

        shouldCommit = false
        Dir[path_to_assets + "/*.xcassets"].each do |asset_path|
          Dir[asset_path + "/*.imageset"].each do |imageset_path|
            filename = File.basename(imageset_path, ".*")
            ocurrences = find_text(path_to_src, filename)
            if (ocurrences == 0)
              puts "removing asset: " + imageset_path
              FileUtils.rm_rf Dir.glob("#{imageset_path}")
              shouldCommit = true
            end
          end
        end
        if shouldCommit
          pushChanges(path_to_repository, path_to_assets)  
        end
      end

      def self.find_text(path, text) # -> int
        return `grep -rnw #{path} -e #{text} | wc -l`.to_i
      end

      def self.pushChanges(path_to_repository, path_to_assets)
        UI.message "Pushing changes...".blue
        pushChangeCommand = "(cd #{path_to_repository}" +
          " && git add #{path_to_assets}" +
          " && git commit -m 'remove un-used assets'" +
          " && git pull && git push)"
        UI.message pushChangeCommand
        Actions.sh pushChangeCommand
        UI.success "Version changes pushed successfully!"
      end

      #####################################################
      # @!group Documentation
      #####################################################

      def self.description
        "Removes assets that are not being used in code"
      end

      def self.available_options
        [FastlaneCore::ConfigItem.new(key: :repository_path,
                                       env_name: "RB_ASSETS_REPO_PATH",
                                       description: "Path to the repository",
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