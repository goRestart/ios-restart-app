module Fastlane
  module Actions
    module SharedValues
    end

    class RbGitMergeAction < Action
      def self.run(params)
        repo_url = ENV["GIT_REPO_URL"]
        from_branch = params[:from_branch_name]
        to_branch = params[:to_branch_name]
        flag_no_ff = params[:no_fast_fordward]
        repository_path = params[:repository_path]
        UI.message ("Merging " + from_branch + " into " + to_branch).blue

        git_command = "git checkout #{to_branch} && git merge origin/#{from_branch}"
        if flag_no_ff
          git_command = git_command + " --no-ff"
        end

        if !repository_path.nil?
          git_command = "cd #{repository_path} && " + git_command
        end

        git_command = git_command + " && git push"
        UI.message git_command
        Actions.sh git_command
        UI.message ("Merge finished successfully and changes pushed to '#{to_branch}'").blue
      end



      #####################################################
      # @!group Documentation
      #####################################################

      def self.description
        "Merges one branch (from_branch) into another (to_branch): git checkout to_branch && git merge from_branch"
      end

      def self.available_options
        [
          FastlaneCore::ConfigItem.new(key: :from_branch_name,
                                       env_name: "RB_GIT_MERGE_FROM_BRANCH", 
                                       description: "The branch that contains the changes. Will be merged into to_branch_name", 
                                       verify_block: Proc.new do |value|
                                          raise "No 'from branch' name given, pass using `from_branch_name: 'branch'`".red unless (value and not value.empty?)
                                       end),
          FastlaneCore::ConfigItem.new(key: :to_branch_name,
                                       env_name: "RB_GIT_MERGE_TO_BRANCH", 
                                       description: "The branch to update with changes in from_branch_name. to_branch_name merge from_branch_name", 
                                       verify_block: Proc.new do |value|
                                          raise "No 'to branch' name given, pass using `to_branch_name: 'branch'`".red unless (value and not value.empty?)
                                       end),
          FastlaneCore::ConfigItem.new(key: :no_fast_fordward,
                                       env_name: "RB_GIT_MERGE_NO_FF",
                                       description: "If true, merge is executed using --no-ff. Default is false",
                                       is_string: false, 
                                       default_value: false,
                                       optional: true),
          FastlaneCore::ConfigItem.new(key: :repository_path,
                                       env_name: "RB_MERGE_REPOSITORY_PATH",
                                       description: "Path where the command has to be executed",
                                       optional: true) 
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