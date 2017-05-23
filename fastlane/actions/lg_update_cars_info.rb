module Fastlane
  module Actions
    
    class LgUpdateCarsInfoAction < Action
      def self.run(params)
        path_to_repo = Actions.lane_context[Actions::SharedValues::RB_GIT_CLONE_TMP_FOLDER]
        path_to_file = 'Ambatana/res/data/CarsInfo.json'

        carInfo_path = File.join(path_to_repo, path_to_file)
        require 'open-uri'

        #download = open('http://api.stg.letgo.com/api/car-makes')
        download = open('https://letgo-a.akamaihd.net/api/car-makes')  
        IO.copy_stream(download, carInfo_path)

        UI.message "Pushing changes...".blue
        pushChangeCommand = "(cd #{path_to_repo} && git add " + path_to_file + 
                              " && git commit -m '★ Update cars info data)' && git push)"
        UI.message pushChangeCommand
        Actions.sh pushChangeCommand
        UI.message "Cars info updated & pushed successfully!".blue


      end


      #####################################################
      # @!group Documentation
      #####################################################

      def self.description
        "Copy remote cars Info JSON file to local folder "
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