source 'https://github.com/CocoaPods/Specs.git'
source 'https://bitbucket.org/ambatana/letgo-ios-specs.git'

platform :ios, "8.0"

use_frameworks!

workspace "LetGo.xcworkspace"
xcodeproj "LetGo.xcodeproj"

pod "Parse",                "~> 1.9.0"
pod "SDWebImage"

pod "FBSDKShareKit",        "~> 4.7"
    
# Tracking
# pod "AppsFlyer-SDK"    # Problems with Swift when archiving... :-(
pod "Amplitude-iOS",        "~> 3.1.1"
    
# letgo Core
pod "LGCoreKit",            :path => "../letgo-ios-lgcorekit" #"0.14.11" # :path => "../LGCoreKit"

# Animation
pod "pop",                  "~> 1.0"

# Collection View Custom Layout
pod "CHTCollectionViewWaterfallLayout", "~> 0.9.1"

# Device info helper
pod "UIDeviceUtil",         "~> 1.1"

# Push Notifications
pod "Kahuna",               "~> 2.2"

# New Relic
pod "NewRelicAgent",         "~> 5.3.1"

# Google app indexing
pod "GoogleAppIndexing",    "~> 2.0"

target "letgoTests", :exclusive => true do
    ## Testing
    pod "Quick",            "~> 0.4"
    pod "Nimble",           "~> 2.0"
    
    pod "Kahuna",           "~> 2.2"

end

post_install do | installer |
    require 'fileutils'
    FileUtils.cp_r('Pods/Target Support Files/Pods/Pods-Acknowledgements.plist', 'Ambatana/res/Settings.bundle/Acknowledgements.plist', :remove_destination => true)
end

