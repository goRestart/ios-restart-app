source 'https://github.com/CocoaPods/Specs.git'
source 'git@github.com:letgoapp/letgo-ios-specs.git'

platform :ios, "9.0"

use_frameworks!

workspace "LetGo.xcworkspace"
project "LetGo.xcodeproj"

def shared_pods
    pod "AlamofireImage",       "3.3.0"

    pod "FBSDKLoginKit",        "4.22.0"    # Obj-c
    pod "FBSDKCoreKit",         "4.22.0"    # Obj-c
    pod "FBSDKShareKit",        "4.22.0"    # Obj-c

    pod "RxSwift",              "4.0.0"
    pod "RxSwiftExt",           "3.0.0"
    pod "RxCocoa",              "4.0.0"

    #Ads
    pod "Google-Mobile-Ads-SDK","7.24.1"

    #Fabric
    pod "Fabric",               "1.6.11"    # Obj-c
    pod "Crashlytics",          "3.8.3"     # Obj-c
    pod "TwitterKit",           "2.3.0"     # Obj-c
    pod "Branch",               "0.12.27"   # Obj-c

    # Tracking
    pod "Amplitude-iOS",        "3.8.5"     # Obj-c
    pod "AppsFlyerFramework",   "4.7.11"    # Obj-c
#    pod "Leanplum-iOS-SDK",     "2.0.1"    # Obj-c
    pod "Leanplum-iOS-SDK",     "2.0.4"
    pod "NewRelicAgent",        "5.14.2"    # Obj-c

    # letgo Core
#    pod "LGCoreKit",             "3.28.2"
#    pod "LGCoreKit",            :path => "../lgcorekit"
    pod "LGCoreKit",            :git => 'git@github.com:letgoapp/letgo-ios-lgcorekit.git', :commit => '4dd05897a9278b6716bbc8dde4957baec2e5ca7e'

    # letgo Collapsible label
    pod "LGCollapsibleLabel",   "1.2.0"     # :path => "../collapsiblelabel"

    # letgo bumper (feature flags)
#    pod "bumper",               "1.1.0"     #:path => "../bumper"
    pod "bumper",            :git => 'git@github.com:letgoapp/bumper.git', :commit => '7ec04a070eca2337f058954d7f53c474d616d7b1'


    # Collection View Custom Layout
    pod "CHTCollectionViewWaterfallLayout", "0.9.5" # Obj-c

    # Device info helper
    pod "DeviceGuru",           "~> 3.0.1"

    # Google -> we have to ask for the Google/"subpod" so it imports Google/Core too
    pod "Google/SignIn",        "3.0.3"     # Obj-c

    pod "Firebase/AppIndexing", "3.7.1"     # Obj-c
    pod "GoogleIDFASupport",    "3.14.0"    # Obj-c

    # Custom camera
    pod "CameraManager",        "4.0.1"

    # Ken Burns effect
    pod "JBKenBurnsView",        :git => 'https://github.com/letgoapp/JBKenBurns', :commit => '56419f79cb763f8d2ee3a75e4eca51ebc1deab6a' # Obj-c

    # Logging
    pod "CocoaLumberjack/Swift", "3.3.0"

    # FLEX debugging tool
    pod "FLEX",                 "2.4.0"  # Obj-c

    # User defaults
    pod "SwiftyUserDefaults",   :git => 'https://github.com/Dschee/SwiftyUserDefaults', :commit => 'dd3d8ddc5bf95db09b66185182b5a555ac59efd5' # PR: https://github.com/radex/SwiftyUserDefaults/pull/135 swift 4 (not too much activity)

    # TextView with placeholder
    pod "KMPlaceholderTextView", :git => 'https://github.com/letgoapp/KMPlaceholderTextView', :commit => '426117c98e8da8fc7d64a7d3c2f0f45c48d595e6'

    pod "KeychainSwift",        "10.0.0"

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
    pod "Quick",            "1.2.0"
    pod "Nimble",           "7.0.2"
    pod "RxTest",           "4.0.0"

    # Mocking
    pod "OHHTTPStubs",      "5.2.3" # not updated - https://github.com/AliSoftware/OHHTTPStubs/issues/257
    pod "OHHTTPStubs/Swift"
end

post_install do | installer |
    #Update Acknowledgements.plist
    require 'fileutils'
    FileUtils.cp_r('Pods/Target Support Files/Pods-LetGo/Pods-LetGo-acknowledgements.plist', 'Ambatana/res/Settings.bundle/Acknowledgements.plist', :remove_destination => true)
    FileUtils.cp_r('Pods/Target Support Files/Pods-LetGoGodMode/Pods-LetGoGodMode-acknowledgements.plist', 'Ambatana/res/development/Settings.bundle/Acknowledgements.plist', :remove_destination => true)
end
