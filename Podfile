source 'https://github.com/CocoaPods/Specs.git'
source 'https://bitbucket.org/ambatana/letgo-ios-specs.git'

platform :ios, "8.0"

use_frameworks!

workspace "LetGo.xcworkspace"
xcodeproj "LetGo.xcodeproj"

# app
target "LetGo" do
    #pod "Parse",                ">= 1.7"
    #It's added manually, as it's fucked up by Facebook/Parse...
    #pod "ParseFacebookUtilsV4", ">= 1.7"
    pod "SDWebImage"

    #Should be fixed in a future release
    #https://github.com/facebook/facebook-ios-sdk/issues/725
    #pod "Facebook-iOS-SDK",     ">= 4.1"
    pod "FBSDKCoreKit",         ">= 4.1"
    pod "FBSDKShareKit",        ">= 4.1"
    pod "FBSDKLoginKit",        ">= 4.1"
    #pod "FBSDKCoreKit", :git => "https://github.com/facebook/facebook-ios-sdk.git", :branch => "dev"
    #pod "FBSDKShareKit", :git => "https://github.com/facebook/facebook-ios-sdk.git", :branch => "dev"
    #pod "FBSDKLoginKit", :git => "https://github.com/facebook/facebook-ios-sdk.git", :branch => "dev"
    
    # Tracking
#    pod "AppsFlyer-SDK"    # Problems with Swift when archiving... :-(
    pod "Amplitude-iOS",        ">= 2.4"
    
    # letgo Core
    pod "LGCoreKit",            "0.1.6"
    
    # Networking (to be removed when migrating to LGCoreKit)
    pod "Alamofire",            ">= 1.2"
    
    # Animation
    pod "pop",                  ">= 1.0"
end