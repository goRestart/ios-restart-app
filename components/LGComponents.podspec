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
	    
    	loginSpec.dependency 'LGComponents/LGResources'

    	loginSpec.dependency 'FBSDKLoginKit', '4.29.0'  # Obj-c
    	loginSpec.dependency 'GoogleSignIn', '4.1.1'  # Obj-c
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