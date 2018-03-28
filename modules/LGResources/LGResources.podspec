Pod::Spec.new do |s|
    s.name             = 'LGResources'
    s.version          = '1.0.0'
    s.summary          = 'Bundle with strings, images and other resources.'
    
    s.homepage         = 'https://github.com/letgoapp'
    s.license          = 'Copyright'
    s.author           = { 'letgo team' => 'ios@letgo.com' }
    s.source           = { :git => 'https://github.com/letgoapp/letgo-ios.git', :tag => s.version.to_s }
    
    s.ios.deployment_target = '8.0'
    
    s.source_files = 'LGResources/Classes/**/*'
    
    s.resource_bundles = {
        'LGResourcesBundle' => ['LGResources/Assets/**/*']
    }

    s.dependency    'SwiftGen', '5.3.0'

    # This script phase runs swiftgen before compiling LGResources source code.
    #
    # "find "$PODS_ROOT"/ -type d -iname *.xcassets"
    # Looks for all .xcassets files inside the LGResources pod
    #
    # "-exec "$PODS_ROOT"/SwiftGen/bin/swiftgen xcassets -p "$PODS_TARGET_SRCROOT"/LGResources/swiftgen-template/xcassets/letgo-swift4-template --param publicAccess -o "$PODS_ROOT"/LGResources/Classes/Assets.swift {} +"
    # Runs SwiftGen fot xcassets using a custom template located inside the pod. 
    s.script_phase = { 
        :name => 'Generate R structure', 
        :script => 'find "$PODS_TARGET_SRCROOT"/ -type d -iname *.xcassets -exec "$PODS_ROOT"/SwiftGen/bin/swiftgen xcassets -p "$PODS_TARGET_SRCROOT"/LGResources/swiftgen-template/xcassets/letgo-swift4-template.stencil --param publicAccess -o "$PODS_TARGET_SRCROOT"/LGResources/Classes/Assets.swift {} +',
        :execution_position => :before_compile
    } 
end
