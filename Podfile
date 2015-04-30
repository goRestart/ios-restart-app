platform :ios, "8.0"

# workspace & projects
workspace "LetGo"
xcodeproj "LetGo.xcodeproj"
xcodeproj "LGCoreKit.xcodeproj"

# app
target "LetGo" do
    xcodeproj "letgo.xcodeproj"
    
    use_frameworks!
    
    pod "Parse",                ">= 1.7"
    #pod "ParseFacebookUtilsV4", ">= 1.7"
    pod "SDWebImage"
    #pod "Facebook-iOS-SDK",     ">= 4.0"
    #Should be fixed in a future release
    #https://github.com/facebook/facebook-ios-sdk/issues/725
    pod "FBSDKCoreKit", :git => "https://github.com/facebook/facebook-ios-sdk.git", :branch => "dev"
    pod "FBSDKShareKit", :git => "https://github.com/facebook/facebook-ios-sdk.git", :branch => "dev"
    pod "FBSDKLoginKit", :git => "https://github.com/facebook/facebook-ios-sdk.git", :branch => "dev"
    
    pod "AppsFlyer-SDK"
    pod "Amplitude-iOS",        ">= 2.4"
    
    pod "Alamofire",            ">= 1.2"
    pod "SwiftyJSON",           ">= 2.2"
    pod "Timepiece",            ">= 0.2"
end

# letgo core
target "LGCoreKit" do
    xcodeproj "LGCoreKit.xcodeproj"
    
    use_frameworks!
    
    pod "Alamofire",            ">= 1.2"
    pod "SwiftyJSON",           ">= 2.2"
    pod "Timepiece",            ">= 0.2"
end

target "LGCoreKitTests" do
    xcodeproj "LGCoreKit.xcodeproj"
    
    use_frameworks!
    
    pod "Alamofire",            ">= 1.2"
    pod "SwiftyJSON",           ">= 2.2"
    pod "Timepiece",            ">= 0.2"
    
    # Testing
    pod "Quick"
    pod "Nimble"
end