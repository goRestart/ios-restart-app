source 'https://github.com/CocoaPods/Specs.git'
source 'git@github.com:letgoapp/letgo-ios-specs.git'

platform :ios, "8.0"

use_frameworks!

workspace "LetGo.xcworkspace"
project "LetGo.xcodeproj"

def shared_pods
    pod "AlamofireImage",        "~> 2.4.0"
    pod "Argo",                 "~> 3.0.1"

	pod "FBSDKLoginKit",         "~> 4.9.1"
	pod "FBSDKCoreKit",          "~> 4.9.1"
	pod "FBSDKShareKit",		 "~> 4.9.1"

    pod "RxSwift",              "~> 2.5.0"
    pod "RxCocoa",              "~> 2.5.0"
    pod "RxBlocking",           "~> 2.5.0"
    pod "CollectionVariable",   :git => 'https://github.com/gitdoapp/CollectionVariable', :commit => 'd99e7a8dfaad32823c207e40fca7c2f2c3894ead'

    #Fabric
    pod "Fabric",               "~> 1.6.3"
    pod "Crashlytics",          "~> 3.7.2"
    pod "TwitterKit",           "~> 2.3.0"
    pod "Branch",               "~> 0.12.2"

	# Tracking
	pod "Amplitude-iOS",        "~> 3.5.0"
    pod "AppsFlyerFramework",   "~> 4.3.9"
    pod "Leanplum-iOS-SDK",     "~> 1.3.11"

	# letgo Core
    pod "LGCoreKit",            "0.27.9" #:path => "../lgcorekit"

	# Slack Chat controller
    pod "SlackTextViewController", "1.9.1"

	# letgo Collapsible label
    pod "LGCollapsibleLabel",   "0.1.8" #:path => "../collapsiblelabel"

	# Animation
	pod "pop",                  "~> 1.0.8"

	# Collection View Custom Layout
	pod "CHTCollectionViewWaterfallLayout", "~> 0.9.1"

	# Device info helper
	pod "DeviceUtil",         "~> 1.3.5"

	# Push Notifications
	pod "Kahuna",               "2.3.1"

	# Google -> we have to ask for the Google/"subpod" so it imports Google/Core too
    pod "Google/Analytics",         "~> 3.0.3"
    pod "Google/SignIn",            "~> 3.0.3"

    pod "Firebase/AppIndexing",        "~> 3.4.0"
    pod "GoogleConversionTracking", "~> 3.4.0"
    pod "GoogleIDFASupport",        "~> 3.14.0"


	# Semi modal view controller
	pod "LGSemiModalNavController", "~> 0.2.0"

	# Custom camera
	pod "FastttCamera",         "~> 0.3.4"

	# Ken Burns effect
	pod "JBKenBurnsView",        :git => 'https://github.com/letgoapp/JBKenBurns', :commit => '56419f79cb763f8d2ee3a75e4eca51ebc1deab6a'

	# Reachability, done like this cos' of https://github.com/tonymillion/Reachability/issues/95
	pod "TMReachability",        :git => 'https://github.com/albertbori/Reachability', :commit => 'e34782b386307e386348b481c02c176d58ba45e6'

    # Logging
    pod "CocoaLumberjack/Swift", "~> 2.3.0"

    # FlipTheSwitch
    pod "FlipTheSwitch"

    # FLEX debugging tool
    pod "FLEX",                 "~> 2.0"

    # User defaults
    pod "SwiftyUserDefaults",   "~> 2.2.0"

    # TextView with placeholder
    pod "KMPlaceholderTextView", "~> 1.2.2"

end

target "LetGo" do
	shared_pods
end

target "LetGoGodMode" do
	shared_pods
end

target "letgoTests" do
	shared_pods

    ## Testing
    pod "Quick",            "~> 0.9.2"
    pod "Nimble",           "~> 4.0.1"
    pod "RxTests",          "~> 2.5.0"

    # Mocking
    pod "OHHTTPStubs",      "~> 5.1.0"
    pod "OHHTTPStubs/Swift"
end

post_install do | installer |
    #Update Acknowledgements.plist
    require 'fileutils'
    FileUtils.cp_r('Pods/Target Support Files/Pods-LetGo/Pods-LetGo-acknowledgements.plist', 'Ambatana/res/Settings.bundle/Acknowledgements.plist', :remove_destination => true)
    FileUtils.cp_r('Pods/Target Support Files/Pods-LetGoGodMode/Pods-LetGoGodMode-acknowledgements.plist', 'Ambatana/res/development/Settings.bundle/Acknowledgements.plist', :remove_destination => true)
end
