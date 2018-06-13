module Fastlane      
module Actions
module SharedValues
	LG_BUILD_NUMBER = :LG_BUILD_NUMBER
	LG_VERSION_NUMBER = :LG_VERSION_NUMBER
end

class LgFetchAppVersionAction < Action
	require 'cfpropertylist'
	require 'json'

	def self.getInfoPlistValue(key, filePath)
		return (`/usr/libexec/PlistBuddy -c "Print :#{key}" "#{filePath}"`).strip
	end

	def self.setInfoPlistVersionValue(key, value, filePath)
		command = "/usr/libexec/PlistBuddy -c 'Set :#{key} #{value}' '#{filePath}'"
		UI.message command
		Actions.sh command
	end

	def self.run(params)
		plist_path = ENV["APP_PLIST_PATH"]

		build_number = getInfoPlistValue("CFBundleVersion", plist_path)
		version_number = getInfoPlistValue("CFBundleShortVersionString", plist_path)

		UI.message "Bundle: #{build_number} Version: #{version_number}".blue

		Actions.lane_context[SharedValues::LG_BUILD_NUMBER] = build_number
		Actions.lane_context[SharedValues::LG_VERSION_NUMBER] = version_number
	end

	#####################################################
	# @!group Documentation
	#####################################################
	def self.available_options
	[
		FastlaneCore::ConfigItem.new(key: :branch_name,
									env_name: "RB_UPDATE_APP_VERSION_BRANCH_NAME",
									description: "Name of the branch where the new version number is going to be pushed. Current branch if it's not defined",
									optional: true),
		FastlaneCore::ConfigItem.new(key: :repository_path,
									env_name: "RB_UPDATE_APP_VERSION_REPO_PATH",
									description: "[Optional] Path to the repository. If not provided will use current directory",
									optional: true)
	]
	end
	def self.description
		"Fetches both the app version and build number"
	end

	def self.output
		[
			['LG_BUILD_NUMBER', 'The current build number'],
			['LG_VERSION_NUMBER', 'The current version number']
		]
	end

	def self.author
		'letgo ™'
	end

	def self.is_supported?(platform)
		platform == :ios
	end
end
end
end
