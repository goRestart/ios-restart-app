source 'https://github.com/CocoaPods/Specs.git'
source 'git@github.com:letgoapp/letgo-ios-specs.git'

platform :ios, "9.0"

use_frameworks!
inhibit_all_warnings!

workspace "LetGo.xcworkspace"
project "LetGo.xcodeproj"

def shared_pods
    pod "AlamofireImage",       "3.3.1"

    pod "FBSDKLoginKit",        "4.29.0"    # Obj-c
    pod "FBSDKCoreKit",         "4.29.0"    # Obj-c
    pod "FBSDKShareKit",        "4.29.0"    # Obj-c

    pod "RxSwift",              "4.0.0"
    pod "RxSwiftExt",           "3.0.0"
    pod "RxDataSources",        "3.0.2"
    pod "RxCocoa",              "4.0.0"
    pod "RxMKMapView",          "4.0.0"

    #Ads
    pod "Google-Mobile-Ads-SDK","7.31.0"

    #Fabric
    pod "Fabric",               "1.7.2"     # Obj-c
    pod "Crashlytics",          "3.9.3"     # Obj-c
    pod "Branch",               "0.22.5"    # Obj-c

    # Tracking
    pod "Amplitude-iOS",        "4.0.4"     # Obj-c
    pod "AppsFlyerFramework",   "4.8.4"     # Obj-c
    pod "Leanplum-iOS-SDK",     "2.0.5"     # Obj-c
    pod "NewRelicAgent",        "6.1.1"     # Obj-c

    # Stripe
    pod "Stripe",               "13.0.3"

    # letgo components
    pod "LGComponents",            :path => "components"


    # letgo Core

    pod "LGCoreKit",             "4.73.0", :inhibit_warnings => false
#    pod "LGCoreKit",            :path => "../lgcorekit", :inhibit_warnings => false
#    pod "LGCoreKit",            :git => 'git@github.com:letgoapp/letgo-ios-lgcorekit.git', :branch => 'ABIOS-4870-car-next-year', :inhibit_warnings => false

    # letgo Collapsible label
    pod "LGCollapsibleLabel",   "1.2.0", :inhibit_warnings => false     # :path => "../collapsiblelabel"

    # letgo bumper (feature flags)
	pod "bumper",               "1.3.1"     #:path => "../bumper"
    # pod "bumper",            :git => 'git@github.com:letgoapp/bumper.git', :commit => '7ec04a070eca2337f058954d7f53c474d616d7b1', :inhibit_warnings => false


    # Collection View Custom Layout
    pod "CHTCollectionViewWaterfallLayout", "0.9.7" # Obj-c

    # Device info helper
    pod "DeviceGuru",           "~> 3.0.1"

    # Google
    pod "GoogleSignIn",         "4.1.1"     # Obj-c

    pod "GoogleIDFASupport",    "3.14.0"    # Obj-c

    # Logging
    pod "CocoaLumberjack/Swift", "3.3.0"

    # FLEX debugging tool
    pod "FLEX",                 "2.4.0"  # Obj-c

    # User defaults
    pod "SwiftyUserDefaults",   "3.0.1"

    # TextView with placeholder
    pod "KMPlaceholderTextView", :git => 'https://github.com/letgoapp/KMPlaceholderTextView', :commit => '426117c98e8da8fc7d64a7d3c2f0f45c48d595e6', :inhibit_warnings => false

    pod "KeychainSwift",        "11.0.0"
    
    pod 'lottie-ios',           "2.5.0" # Obj-c
    
    # MoPub Ads
    pod "mopub-ios-sdk",        "4.20.0" # Obj-c

    # Gifs
    pod "SwiftyGif",            "4.1.0"

    # IGListKit
    pod "IGListKit", "3.4.0"
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
