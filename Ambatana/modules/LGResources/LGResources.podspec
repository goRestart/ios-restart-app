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
end
