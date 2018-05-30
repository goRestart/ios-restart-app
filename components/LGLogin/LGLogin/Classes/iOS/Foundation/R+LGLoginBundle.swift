import Foundation

private final class BundleToken {}

extension R {
    static let loginBundle: Bundle = {
        let frameworkBundle = Bundle(for: BundleToken.self)
        let bundleURL = frameworkBundle.url(forResource: "LGResourcesBundle",
                                            withExtension: "bundle")!
        return Bundle(url: bundleURL)!
    }()
}
