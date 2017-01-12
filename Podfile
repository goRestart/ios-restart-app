source 'https://github.com/CocoaPods/Specs.git'
source 'git@github.com:letgoapp/letgo-ios-specs.git'

platform :ios, "8.0"

use_frameworks!

workspace "LetGo.xcworkspace"
project "LetGo.xcodeproj"

def shared_pods
    pod "AlamofireImage",       "~> 3.2.0"
    pod "Argo",                 "~> 4.1.1"

    pod "FBSDKLoginKit",        "~> 4.15.1" # Obj-c
    pod "FBSDKCoreKit",         "~> 4.15.1" # Obj-c
    pod "FBSDKShareKit",		"~> 4.15.1" # Obj-c

    pod "RxSwift",              "~> 3.0.1"
    pod "RxCocoa",              "~> 3.0.0"
    pod "RxBlocking",           "~> 3.0.0"

    #Fabric
    pod "Fabric",               "~> 1.6.10" # Obj-c
    pod "Crashlytics",          "~> 3.8.2"  # Obj-c
    pod "TwitterKit",           "~> 2.3.0"  # Obj-c
    pod "Branch",               "~> 0.12.20"# Obj-c

    # Tracking
    pod "Amplitude-iOS",        "~> 3.8.5"  # Obj-c
    pod "AppsFlyerFramework",   "~> 4.5.12" # Obj-c
    pod "Leanplum-iOS-SDK",     "~> 1.4.1"  # Obj-c

    # letgo Core
    pod "LGCoreKit",             :git => 'https://github.com/letgoapp/letgo-ios-lgcorekit', :commit => '16a3091824bdb72309d0820ae1b1233980a8ff36' #:path => "../lgcorekit" ||

    # letgo Collapsible label
    pod "LGCollapsibleLabel",   "1.0.0"     # :path => "../collapsiblelabel"

    # letgo bumper (feature flags)
    pod "bumper",               "1.0.1"     #:path => "../bumper"

    	# Collection View Custom Layout
    pod "CHTCollectionViewWaterfallLayout", "~> 0.9.5"  # Obj-c

    # Device info helper
    pod "DeviceUtil",           "~> 1.3.8"     # Obj-c

    # Google -> we have to ask for the Google/"subpod" so it imports Google/Core too
    pod "Google/SignIn",        "~> 3.0.3"     # Obj-c

    pod "Firebase/AppIndexing", "~> 3.7.1"     # Obj-c
    pod "GoogleIDFASupport",    "~> 3.14.0"    # Obj-c

    # Custom camera
    pod "FastttCamera",         "~> 0.3.4"     # Obj-c

    # Ken Burns effect
    pod "JBKenBurnsView",        :git => 'https://github.com/letgoapp/JBKenBurns', :commit => '56419f79cb763f8d2ee3a75e4eca51ebc1deab6a'   # Swift 3.0: -

    # Reachability, done like this cos' of https://github.com/tonymillion/Reachability/issues/95
    pod "TMReachability",        :git => 'https://github.com/albertbori/Reachability', :commit => 'e34782b386307e386348b481c02c176d58ba45e6'   # Swift 3.0: -

    # Logging
    pod "CocoaLumberjack/Swift", "~> 3.0.0"

    # FLEX debugging tool
    pod "FLEX",                 "~> 2.4.0"  # Obj-c

    # User defaults
    pod "SwiftyUserDefaults",   "~> 3.0.0"

    # TextView with placeholder
    pod "KMPlaceholderTextView", "~> 1.3.0"

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
    pod "Quick",            "~> 1.0.0"
    pod "Nimble",           "~> 5.1.1"
    pod "RxTest",          "~> 3.1.0"

    # Mocking
    pod "OHHTTPStubs",      "~> 5.2.3"
    pod "OHHTTPStubs/Swift"
end

post_install do | installer |
    #Update Acknowledgements.plist
    require 'fileutils'
    FileUtils.cp_r('Pods/Target Support Files/Pods-LetGo/Pods-LetGo-acknowledgements.plist', 'Ambatana/res/Settings.bundle/Acknowledgements.plist', :remove_destination => true)
    FileUtils.cp_r('Pods/Target Support Files/Pods-LetGoGodMode/Pods-LetGoGodMode-acknowledgements.plist', 'Ambatana/res/development/Settings.bundle/Acknowledgements.plist', :remove_destination => true)
end
