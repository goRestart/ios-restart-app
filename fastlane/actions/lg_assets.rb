module Fastlane
  module Actions
    module SharedValues
    end

    class LgAssetsAction < Action
      def self.run(params)
        path_to_repository = params[:repository_path]
        path_to_assets = path_to_repository + "Ambatana/res/img"
        path_to_src = path_to_repository + "Ambatana/src"

        Dir[path_to_assets + "/*.xcassets"].each do |asset_path|
          Dir[asset_path + "/*.imageset"].each do |imageset_path|
            filename = File.basename(imageset_path, ".*")
            ocurrences = find_text(path_to_src, filename)
            if (ocurrences == 0)
              puts "removing asset: " + imageset_path
              FileUtils.rm_rf Dir.glob("#{imageset_path}/*")
            end
          end
        end
      end

      def self.find_text(path, text) # -> int
        return `grep -rnw #{path} -e #{text} | wc -l`.to_i
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