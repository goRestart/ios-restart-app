source 'https://github.com/CocoaPods/Specs.git'
source 'git@github.com:letgoapp/letgo-ios-specs.git'

platform :ios, "8.0"

use_frameworks!

workspace "LetGo.xcworkspace"
project "LetGo.xcodeproj"

def shared_pods
    pod "AlamofireImage",       "3.2.0"     # 3.3.0 swift 3.2
    pod "Argo",                 "4.1.2"     # not updated, low activity

    pod "FBSDKLoginKit",        "4.22.0"    # Obj-c
    pod "FBSDKCoreKit",         "4.22.0"    # Obj-c
    pod "FBSDKShareKit",		"4.22.0"    # Obj-c

    pod "RxSwift",              "3.1.0"     # 3.6.1 support for Xcode 9b3 / 4.0.0-beta.0 swift 4
    pod "RxSwiftExt",           "2.1.0"     # branch https://github.com/RxSwiftCommunity/RxSwiftExt/tree/swift4.0 swift 4
    pod "RxCocoa",              "3.1.0"     # branch https://github.com/ReactiveX/RxSwift/tree/rxswift4.0-swift4.0 swift 4
    pod "RxBlocking",           "3.1.0"     # NOT USED IN LETGO !!!

    #Fabric
    pod "Fabric",               "1.6.11"    # Obj-c
    pod "Crashlytics",          "3.8.3"     # Obj-c
    pod "TwitterKit",           "2.3.0"     # Obj-c
    pod "Branch",               "0.12.27"   # Obj-c

    # Tracking
    pod "Amplitude-iOS",        "3.8.5"     # Obj-c
    pod "AppsFlyerFramework",   "4.7.11"    # Obj-c
#    pod "Leanplum-iOS-SDK",     "2.0.1"    # Obj-c
    pod "Leanplum-iOS-SDK", :git => 'https://github.com/Leanplum/Leanplum-iOS-SDK-internal', :tag => '2.0.3.95'
    pod "NewRelicAgent",        "5.10.1"    # Obj-c

    # letgo Core
    pod "LGCoreKit",             "3.21.0"
#    pod "LGCoreKit",            :path => "../lgcorekit"
#    pod "LGCoreKit",            :git => 'git@github.com:letgoapp/letgo-ios-lgcorekit.git', :commit => 'c9e831185127eba48ab50f35cf001c1f3b1254cc'

    # letgo Collapsible label
    pod "LGCollapsibleLabel",   "1.1.0"     # :path => "../collapsiblelabel"

    # letgo bumper (feature flags)
    pod "bumper",               "1.1.0"     #:path => "../bumper"

    # Collection View Custom Layout
    pod "CHTCollectionViewWaterfallLayout", "0.9.5" # Obj-c

    # Device info helper
    pod "DeviceGuru",           "~> 2.1.0"  # 3.0.0 swift 4

    # Google -> we have to ask for the Google/"subpod" so it imports Google/Core too
    pod "Google/SignIn",        "3.0.3"     # Obj-c

    pod "Firebase/AppIndexing", "3.7.1"     # Obj-c
    pod "GoogleIDFASupport",    "3.14.0"    # Obj-c

    # Custom camera
#    pod "CameraManager",        "3.1.1"
    pod "CameraManager",        :git => 'https://github.com/letgoapp/CameraManager', :commit => '3c8a514c1c94234fe7fa27734431e7dd3e53abfb' # pr https://github.com/imaginary-cloud/CameraManager/pull/121 swift 4, we need to preserv our changes!

    # Ken Burns effect
    pod "JBKenBurnsView",        :git => 'https://github.com/letgoapp/JBKenBurns', :commit => '56419f79cb763f8d2ee3a75e4eca51ebc1deab6a' # Obj-c

    # Reachability, done like this cos' of https://github.com/tonymillion/Reachability/issues/95
    pod "TMReachability",        :git => 'https://github.com/albertbori/Reachability', :commit => 'e34782b386307e386348b481c02c176d58ba45e6' # Obj-c

    # Logging
    pod "CocoaLumberjack/Swift", "3.0.0" # branch master https://github.com/CocoaLumberjack/CocoaLumberjack swift 4

    # FLEX debugging tool
    pod "FLEX",                 "2.4.0"  # Obj-c

    # User defaults
    pod "SwiftyUserDefaults",   "3.0.0" # pr https://github.com/radex/SwiftyUserDefaults/pull/135 swift 4 (not too much activity)

    # TextView with placeholder
    pod "KMPlaceholderTextView", "1.3.0" # not updated, we could make our component for this, shouldn't be hard

    # TODO: This is an override to check our fork, remove after original repo merges our pr.
    pod "KeychainSwift",        :git => 'git@github.com:letgoapp/keychain-swift.git', :commit => 'f6230869f4d26d720f36eb227bd269c3d712986b' # branch https://github.com/evgenyneu/keychain-swift/tree/swift-4.0 swift 4

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
    pod "Quick",            "1.0.0" # working on it, nothing final/released
    pod "Nimble",           "5.1.1" # 7.0.1 swift 4 (we have to migrate to new predicate type results) https://github.com/Quick/Nimble#migrating-from-the-old-matcher-api
    pod "RxTest",           "3.1.0" # same as RxSwift - 3.6.1 support for Xcode 9b3 / 4.0.0-beta.0 swift 4

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
