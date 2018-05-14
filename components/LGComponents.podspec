Pod::Spec.new do |s|
    s.name             = 'LGComponents'
    s.version          = '1.0.0'
    s.summary          = 'Framework containing all the different components the Letgo app uses.'
    
    s.homepage         = 'https://github.com/letgoapp'
    s.license          = 'Copyright'
    s.author           = { 'letgo team' => 'ios@letgo.com' }
    s.source           = { :git => 'https://github.com/letgoapp/letgo-ios.git', :tag => s.version.to_s }
    
    s.swift_version    = '4.0'
    s.ios.deployment_target = '9.0'

    s.static_framework = true

    s.subspec 'LGLogin' do |loginSpec|
	    loginSpec.source_files = 'LGLogin/LGLogin/Classes/**/*'
        
        loginSpec.resource_bundles = {
            'LGLoginBundle' => ['LGLogin/LGLogin/Assets/**/*']
        }
	    
        loginSpec.dependency 'LGComponents/LGAnalytics'
        loginSpec.dependency 'LGComponents/LGShared'
    	loginSpec.dependency 'LGComponents/LGResources'

        loginSpec.dependency 'LGCoreKit',       '4.25.0'

        loginSpec.dependency 'FBSDKLoginKit',   '4.29.0'  # Obj-c
        loginSpec.dependency 'GoogleSignIn',    '4.1.1'  # Obj-c
        loginSpec.dependency 'RxSwift',         '4.0.0'
        loginSpec.dependency 'RxCocoa',         '4.0.0'
    end

    s.subspec 'LGAnalytics' do |spec|
        spec.source_files = 'LGAnalytics/LGAnalytics/Classes/**/*'
        
        spec.dependency 'Amplitude-iOS',      '4.0.4'
        spec.dependency 'AppsFlyerFramework', '4.8.2'
        spec.dependency 'Branch',             '0.22.5'
        spec.dependency 'Crashlytics',        '3.9.3'
        spec.dependency 'Fabric',             '1.7.2'
        spec.dependency 'FBSDKCoreKit',       '4.29.0'
        spec.dependency 'Leanplum-iOS-SDK',   '2.0.5'
        spec.dependency 'LGCoreKit',          '4.25.0'
        spec.dependency 'RxSwift',            '4.0.0'
    end

    s.subspec 'LGShared' do |sharedSpec|  
        sharedSpec.source_files = 'LGShared/LGShared/Classes/**/*'

        sharedSpec.frameworks = 'CoreText'

        sharedSpec.dependency 'LGComponents/LGAnalytics'
        sharedSpec.dependency 'LGComponents/LGResources'

        sharedSpec.dependency 'LGCoreKit',             '4.25.0'

        sharedSpec.dependency 'DeviceGuru',            '3.0.1'
        sharedSpec.dependency 'AlamofireImage',        '3.3.0'
        sharedSpec.dependency 'SwiftyUserDefaults',    '3.0.1'
        sharedSpec.dependency 'CocoaLumberjack/Swift', '3.3.0'
        sharedSpec.dependency 'RxCocoa',               '4.0.0'
    end

    s.subspec 'LGResources' do |resourcesSpec|
	    resourcesSpec.source_files = 'LGResources/LGResources/Classes/**/*'
	    
	    resourcesSpec.resource_bundles = {
	        'LGResourcesBundle' => ['LGResources/LGResources/Assets/**/*']
	    }  

		resourcesSpec.script_phase = { 
			:name => 'Generate R structure', 
			:script => '${PODS_TARGET_SRCROOT}/LGResources/LGResources/generate-r-struct.sh',
			:execution_position => :before_compile
		}      	    
    end

end 