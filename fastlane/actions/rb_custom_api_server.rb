module Fastlane
  module Actions
    module SharedValues
    end

    String.class_eval do
      def is_valid_url?
          uri = URI.parse self
          uri.kind_of? URI::HTTP
      rescue URI::InvalidURIError
          false
      end
    end

    class RbCustomApiServerAction < Action
      
      def self.run(params)
        default_url = "https://redbooth.com"
        default_staging_url = "https://release.staging.redbooth.com"
        server_url = params[:server_url]

        if server_url == "prod" || server_url == "p" || server_url == "production"
          server_url = default_url
        end

        if server_url == "staging" || server_url == "s"
          server_url = default_staging_url
        end

        if !server_url.is_valid_url?
          raise "The URL is not valid"
        end

        server_type = "PRODUCTION"
        param_server_type = params[:server_environment]
        if param_server_type == "s"
          server_type = "STAGING"
        end

        File.open(Actions.lane_context[Actions::SharedValues::RB_GIT_CLONE_TMP_FOLDER] +"/Redbooth/Resources/RBAPIConstants.h", 'w') { 
          |file| file.write("#define " + server_type + "\n#define rbkAPIURL @\"" + server_url + "\"")
        }
      end



      #####################################################
      # @!group Documentation
      #####################################################

      def self.description
        "Set the app to use a custom server URL"
      end

      def self.available_options
        [
          FastlaneCore::ConfigItem.new(key: :server_url,
                                       env_name: "RB_API_SERVER_URL",
                                       description: "Server URL where the app should connect",
                                       optional: false),
          FastlaneCore::ConfigItem.new(key: :server_environment,
                                       env_name: "RB_API_ENVIRONMENT",
                                       description: "Inidicates if environment is production or staging",
                                       optional: false),
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