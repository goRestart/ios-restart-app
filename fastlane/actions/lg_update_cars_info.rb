module Fastlane
  module Actions
    module SharedValues
    end

    class LgUpdateCarsInfoAction < Action
      def self.run(params)
        require 'open-uri'

        download = open('http://api.stg.letgo.com/api/car-makes')
        # download = open('https://letgo-a.akamaihd.net/api/car-makes')  
        IO.copy_stream(download, './Ambatana/res/data/CarsInfo.json')

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