module Fastlane
  module Actions
    module SharedValues
    end

    class LgChangelogAction < Action

      def self.parse(line)
        a = line.split(" ")
        url = a[1].gsub(/\[.+\]/, '')
        title = a[2..-1] * " "
        return "- " + title + " " + url + "\n"
      end

      def self.run(params)
        only_upcoming = params[:only_upcoming]

        github_token = ENV["GITHUB_TOKEN"]
        Action.sh "github-changes -k #{github_token} -o letgoapp -r letgo-ios --only-pulls --use-commit-body -b develop -v"

        real_changelog = "\n"

        # Include all changelog lines
        if !only_upcoming
          File.open("CHANGELOG.md", "r") do |f|
            f.each_line do |line|
              real_changelog += parse(line)
            end
          end

          Action.sh "rm CHANGELOG.md"
          return real_changelog
        end

        # Include only the upcoming pull requests
        is_upcoming = false
        File.open("CHANGELOG.md", "r") do |f|
          f.each_line do |line|
            if is_upcoming
              if line.start_with?('-')
                real_changelog += parse(line)
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
        "Download and parse PullRequests changelog from github letgoapp/letgo-ios"
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