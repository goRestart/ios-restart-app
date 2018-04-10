Pod::Spec.new do |s|
    s.name             = 'LGComponents'
    s.version          = '1.0.0'
    s.summary          = 'Bundle with strings, images and other resources.'
    
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

	    resourcesSpec.dependency    'SwiftGen', '5.3.0'

	    # 
	    # This script phase runs swiftgen before compiling LGResources source code.
	    #
	    # ********
	    # find "$PODS_ROOT"/ -type d -iname *.xcassets -exec "$PODS_ROOT"/SwiftGen/bin/swiftgen xcassets 
	    # -p "$PODS_TARGET_SRCROOT"/LGResources/swiftgen-template/xcassets/letgo-swift4-template 
	    # --param publicAccess -o "$PODS_ROOT"/LGResources/Classes/Assets.swift {} +;
	    # ********
	    # Explanation: Looks for all .xcassets files inside the LGResources pod and runs SwiftGen for xcassets passing the assets 
	    # list as param and using a custom template located inside the pod. 
	    #
	    # 
	    # ********
	    # "$PODS_ROOT"/SwiftGen/bin/swiftgen strings 
	    # -p "$PODS_TARGET_SRCROOT"/LGResources/swiftgen-template/strings/letgo-flat-swift4.stencil 
	    # --param publicAccess --param enumName=Strings 
	    # "$PODS_TARGET_SRCROOT"/LGResources/Assets/i18n/Base.lproj/Localizable.strings 
	    # -o "$PODS_TARGET_SRCROOT"/LGResources/Classes/Strings.swift ;
	    # ********
	    # Explanation: Runs SwiftGen for strings using a cusomt template located inside the pod.
	    # To generate the 'Strings.swift' file takes 'Base.lproj/Localizable.strings' as the 
	    # reference file.
	    #
	    resourcesSpec.script_phase = { 
	        :name => 'Generate R structure', 
	        :script => 
	        'find "$PODS_TARGET_SRCROOT"/LGResources/ -type d -iname *.xcassets ' +
	        '-exec "$PODS_ROOT"/SwiftGen/bin/swiftgen xcassets ' +
	        '-p "$PODS_TARGET_SRCROOT"/LGResources/LGResources/swiftgen-template/xcassets/letgo-swift4-template.stencil ' +
	        '--param publicAccess ' +
	        '-o "$PODS_TARGET_SRCROOT"/LGResources/LGResources/Classes/Assets.swift {} +;' +
	        '' +
	        '"$PODS_ROOT"/SwiftGen/bin/swiftgen strings ' +
	        '-p "$PODS_TARGET_SRCROOT"/LGResources/LGResources/swiftgen-template/strings/letgo-flat-swift4.stencil ' +
	        '--param publicAccess --param enumName=Strings ' +
	        '"$PODS_TARGET_SRCROOT"/LGResources/LGResources/Assets/i18n/Base.lproj/Localizable.strings ' + 
	        '-o "$PODS_TARGET_SRCROOT"/LGResources/LGResources/Classes/Strings.swift ;' +
	        '',
	        :execution_position => :before_compile
	    } 	    
    end

end 