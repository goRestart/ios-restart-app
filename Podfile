platform :ios, '8.0'

# workspace & projects
workspace 'LetGo'
xcodeproj 'letgo.xcodeproj'
xcodeproj 'LGCoreKit.xcodeproj'

# app
target 'LetGo' do
    xcodeproj 'letgo.xcodeproj'
    pod 'Parse','1.7.1'
    pod 'ParseFacebookUtilsV4','1.7.1'
    pod 'SDWebImage'
    pod 'Facebook-iOS-SDK', '4.0.1'
    pod 'AppsFlyer-SDK'
    pod 'Amplitude-iOS', '~> 2.4'
end

# letgo core
target 'LGCoreKit' do
    xcodeproj 'LGCoreKit.xcodeproj'
    
    use_frameworks!
    
    pod 'Alamofire', '~> 1.2'
    pod "SwiftyJSON",   ">= 2.2"
    pod "Timepiece", ">= 0.2"
end

target 'LGCoreKitTests' do
    xcodeproj 'LGCoreKit.xcodeproj'
    
    use_frameworks!
    
    pod 'Alamofire', '~> 1.2'
    pod "SwiftyJSON",   ">= 2.2"
    pod "Timepiece", ">= 0.2"
    
    # Testing
    pod 'Quick'
    pod 'Nimble'
end