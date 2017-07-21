module Fastlane
  module Actions
    
    class LgUpdateTaxonomiesAction < Action
      def self.run(params)
        path_to_repo = Actions.lane_context[Actions::SharedValues::RB_GIT_CLONE_TMP_FOLDER]
        path_to_file = 'Ambatana/res/data/Taxonomies.json'

        taxonomies_path = File.join(path_to_repo, path_to_file)
        require 'open-uri'

        download = open('https://letgo-a.akamaihd.net/api/products_taxonomies?country_code=us&locale=en')  
        IO.copy_stream(download, taxonomies_path)

        UI.message "Pushing changes...".blue

        addFile = "cd #{path_to_repo} && git add " + path_to_file
        commitChanges = "git diff --quiet --exit-code --cached || (git commit -m '★ Update taxonomies data' && git push)"
        UI.message addFile
        Actions.sh addFile
        UI.message commitChanges
        Actions.sh commitChanges


      end


      #####################################################
      # @!group Documentation
      #####################################################

      def self.description
        "Copy remote taxonomies JSON file to local folder "
      end

      def self.available_options
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