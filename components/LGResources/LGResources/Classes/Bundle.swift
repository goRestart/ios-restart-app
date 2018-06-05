import Foundation

public class R {}

private final class BundleToken {}

public extension R {
    public static let bundle: Bundle = {
        let frameworkBundle = Bundle(for: BundleToken.self)
        let path = frameworkBundle.path(forResource: "LGResourcesBundle",
                                        ofType: "bundle")!
        return Bundle(path: path)!
    }()
}
