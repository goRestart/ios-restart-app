module Fastlane
  module Actions
    module SharedValues
      RB_GIT_CLONE_TMP_FOLDER = :RB_GIT_CLONE_TMP_FOLDER
      RB_GIT_CLONE_WORKSPACE_PATH = :RB_GIT_CLONE_WORKSPACE_PATH
    end

    class RbGitCloneAction < Action
      def self.run(params)

        repo_url = ENV["GIT_REPO_URL"]
        branch_name = params[:branch_name]
        shallow_clone = params[:shallow_clone]
        tmp_folder = "tmp_lane_git_clone_folder"
        flag_single_branch = params[:clone_single_branch]

        if repo_url.nil?
          repo_url = ask("Repo url to clone: ".yellow)
          if repo_url.nil?
            UI.error "Repo url not defined!"
            exit 1
          end
        end

        if branch_name.nil?
          branch_name = ask("Branch name: ".yellow)
          if branch_name.nil?
            UI.error "Branch name not defined!"
            exit 1
          end
        end

        # Save paths in the actions context
        Actions.lane_context[SharedValues::RB_GIT_CLONE_TMP_FOLDER] = tmp_folder
        Actions.lane_context[SharedValues::RB_GIT_CLONE_WORKSPACE_PATH] = tmp_folder

        UI.message ("Github repo: " + repo_url).blue
        UI.message ("Github branch: " + branch_name).blue
        UI.message ("Temporary folder: " + tmp_folder).blue

        single_branch_command = ""
        if flag_single_branch
          single_branch_command = "--single-branch"
        end

        # Clean temporary folder
        FileUtils.rm_rf(tmp_folder)

        command = "git clone #{repo_url} --recursive --branch '#{branch_name}' #{single_branch_command} '#{tmp_folder}'"
        if shallow_clone
          command += " --depth=1"
        end

        Actions.sh command

        UI.message "Git clone completed".blue

      end

      #####################################################
      # @!group Documentation
      #####################################################

      def self.description
        "Creates a temporary folder and clones the specified branch"
      end

      def self.available_options
        [
          FastlaneCore::ConfigItem.new(key: :branch_name,
                                       env_name: "RB_GIT_CLONE_BRANCH_NAME",
                                       description: "Branch name to execute the git clone",
                                       optional: false),
          FastlaneCore::ConfigItem.new(key: :clone_single_branch,
                                       env_name: "RB_GIT_CLONE_SINGLE_BRANCH",
                                       description: "If true, clone adds the --single-branch command. Default is true",
                                       is_string: false,
                                       default_value: true,
                                       optional: true),
          FastlaneCore::ConfigItem.new(key: :shallow_clone,
                                       env_name: "LG_GIT_CLONE_SHALLOW_CLONE",
                                       description: "If true, clone adds the --depth=1 command. Default is false",
                                       is_string: false,
                                       default_value: false,
                                       optional: true)
        ]
      end

      def self.output
        [
          ['RB_GIT_CLONE_TMP_FOLDER', 'The path to the new temporary folder where the repo is cloned'],
          ['RB_GIT_CLONE_WORKSPACE_PATH', 'Relative path to Redbooth workspace file']
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
