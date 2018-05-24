import Foundation

private final class BundleToken {}

let resourcesBundle: Bundle = {
    let path = Bundle(for: BundleToken.self).path(forResource: "LGResourcesBundle", ofType: "bundle")!
    return Bundle(path: path)!
}()

public struct R {
    
    public static let bundle: Bundle = {
        return resourcesBundle
    }()
}
