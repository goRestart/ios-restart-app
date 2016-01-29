module Fastlane
  module Actions
    module SharedValues
    end

    class LgChangelogAction < Action
      def self.run(params)
        only_upcoming = params[:only_upcoming]
        
        github_token = ENV["GITHUB_TOKEN"]
        `github-changes -k #{github_token} -o letgoapp -r letgo-ios --only-pulls --use-commit-body -b develop`

        if !only_upcoming
          change = File.read("CHANGELOG.md")
          `rm CHANGELOG.md`
          return change
        end

        real_changelog = "--- CHANGELOG ---\n"
        is_upcoming = false
        File.open("CHANGELOG.md", "r") do |f|
          f.each_line do |line|
            if is_upcoming
              if line.start_with?('-')
                real_changelog += line
              else
                is_upcoming = false
                break
              end
            end
            if line.start_with?('### upcoming')
              is_upcoming = true
            end
          end
        end

        `rm CHANGELOG.md`
        return real_changelog
      end


      #####################################################
      # @!group Documentation
      #####################################################

      def self.description
        "Uploads all changes in repository_path to remote git server with a commit indicating the version_number and build_number"
      end

      def self.available_options
        [
          FastlaneCore::ConfigItem.new(key: :only_upcoming,
                                       env_name: "LG_SHOW_ONLY_NOT_TAGGED_PULL_REQUESTS",
                                       description: "Will include in the changelog only the pull requests not tagged: the ones that will be included in the next release. Defaults = yes",
                                       optional: true,
                                       is_string: false), 
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