source 'https://github.com/CocoaPods/Specs.git'
source 'https://bitbucket.org/ambatana/letgo-ios-specs.git'

platform :ios, "8.0"

use_frameworks!

workspace "LetGo.xcworkspace"
xcodeproj "LetGo.xcodeproj"
#xcodeproj "LGCoreKit.xcodeproj"

# app
target "LetGo" do
    pod "Parse",                ">= 1.7"
    #It's added manually, as it's fucked up by Facebook/Parse...
    #pod "ParseFacebookUtilsV4", ">= 1.7"
    pod "SDWebImage"

    #Should be fixed in a future release
    #https://github.com/facebook/facebook-ios-sdk/issues/725
    #pod "Facebook-iOS-SDK",     ">= 4.0"
    pod "FBSDKCoreKit", :git => "https://github.com/facebook/facebook-ios-sdk.git", :branch => "dev"
    pod "FBSDKShareKit", :git => "https://github.com/facebook/facebook-ios-sdk.git", :branch => "dev"
    pod "FBSDKLoginKit", :git => "https://github.com/facebook/facebook-ios-sdk.git", :branch => "dev"
    
    # Tracking
    pod "AppsFlyer-SDK"
    pod "Amplitude-iOS",        ">= 2.4"
    
    # letgo Core
    pod 'LGCoreKit',            "0.0.1"
    
    # Networking (to be removed when migrating to LGCoreKit)
    pod "Alamofire",            ">= 1.2"
#    pod "SwiftyJSON",           ">= 2.2"
#    pod "Timepiece",            ">= 0.2"
#    pod "Bolts",                ">= 1.1"
end