source 'https://github.com/CocoaPods/Specs.git'
source 'https://bitbucket.org/ambatana/letgo-ios-specs.git'

platform :ios, "8.0"

use_frameworks!

workspace "LetGo.xcworkspace"
xcodeproj "LetGo.xcodeproj"

pod "Parse",                "1.7.5.3"
pod "SDWebImage"

pod "FBSDKShareKit",        "~> 4.1"
    
# Tracking
# pod "AppsFlyer-SDK"    # Problems with Swift when archiving... :-(
pod "Amplitude-iOS",        "~> 3.0"
    
# letgo Core
pod "LGCoreKit",            "0.13.1" #:path => "../letgo-ios-lgcorekit" #:path => "../LGCoreKit"

# Networking (to be removed when migrating to LGCoreKit)
pod "Alamofire",            "~> 1.2"

# Animation
pod "pop",                  "~> 1.0"

# Collection View Custom Layout
pod "CHTCollectionViewWaterfallLayout", "~> 0.9.1"

# Device info helper
pod "UIDeviceUtil",         "~> 1.1"

# Push Notifications
pod "UrbanAirship-iOS-SDK/Core", "6.2.0"
pod "Kahuna",               "2.0.4"

# New Relic
pod "NewRelicAgent",         "5.2.2"

pod "RealmSwift",           "0.95.0"  # delete!!

target "letgoTests", :exclusive => true do
    ## Testing
    pod "Quick",            "~> 0.3.1"    # Update to 0.4+ when upgrading to Swift 2.0
    pod "Nimble",           "~> 0.4.2"    # Update to 1.0+ when upgrading to Swift 2.0
end

