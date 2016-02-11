source 'https://github.com/CocoaPods/Specs.git'
source 'git@github.com:letgoapp/letgo-ios-specs.git'

platform :ios, "8.0"

use_frameworks!

workspace "LetGo.xcworkspace"
xcodeproj "LetGo.xcodeproj"

def shared_pods
	pod "Parse",                "~> 1.9.0"
	pod "SDWebImage"

	pod "FBSDKLoginKit",         "~> 4.9.1"
	pod "FBSDKCoreKit",          "~> 4.9.1"
	pod "FBSDKShareKit",		 "~> 4.9.1"

	# Tracking
	# pod "AppsFlyer-SDK"    # Problems with Swift when archiving... :-(
	pod "Amplitude-iOS",        "~> 3.4.1"
	    
	# letgo Core
    pod "LGCoreKit",            :path => "../lgcorekit" #"0.19.1"

	# Slack Chat controller
	pod "SlackTextViewController", "~> 1.7.2"

	# letgo Collapsible label
	pod "LGCollapsibleLabel",   "0.1.1"    #:path => "../collapsiblelabel"

	# Animation
	pod "pop",                  "~> 1.0.8"

	# Collection View Custom Layout
	pod "CHTCollectionViewWaterfallLayout", "~> 0.9.1"

	# Device info helper
	pod "DeviceUtil",         "~> 1.3.5"

	# Push Notifications
	pod "Kahuna",               "2.3.1"

	# New Relic
	pod "NewRelicAgent",         "5.3.6"

	# Google app indexing
	pod "GoogleAppIndexing",    "~> 2.0.1"

	# Google Analytics
	pod "Google/Analytics",     "~> 1.3.2"

	#Google IDFA Support
	pod "GoogleIDFASupport",    "~> 3.14.0"

	# Adjust
	pod "Adjust",               "~> 4.5.0" #:git => "git://github.com/adjust/ios_sdk.git", :tag => "v4.5.0"

	# Semi modal view controller
	pod "LGSemiModalNavController", "~> 0.2.0"

	# Custom camera
	pod "FastttCamera",         "~> 0.3.4"

	# Ken Burns effect
	pod "JBKenBurnsView",        :git => 'https://github.com/letgoapp/JBKenBurns', :commit => '56419f79cb763f8d2ee3a75e4eca51ebc1deab6a'

	# Reachability, done like this cos' of https://github.com/tonymillion/Reachability/issues/95
	pod "TMReachability",       :git => 'https://github.com/albertbori/Reachability', :commit => 'e34782b386307e386348b481c02c176d58ba45e6'
end

target "LetGo" do
	shared_pods
end

target "LetGoGodMode" do
	shared_pods

    # FLEX debugging tool
    pod "FLEX",                 "~> 2.0"
end

target "letgoTests" do
	shared_pods

    ## Testing
    pod "Quick",            "~> 0.9"
    pod "Nimble",           "~> 3.1"
end

post_install do | installer |
    require 'fileutils'
    FileUtils.cp_r('Pods/Target Support Files/Pods-LetGo/Pods-LetGo-acknowledgements.plist', 'Ambatana/res/Settings.bundle/Acknowledgements.plist', :remove_destination => true)
    FileUtils.cp_r('Pods/Target Support Files/Pods-LetGoGodMode/Pods-LetGoGodMode-acknowledgements.plist', 'Ambatana/res/development/Settings.bundle/Acknowledgements.plist', :remove_destination => true)
end
