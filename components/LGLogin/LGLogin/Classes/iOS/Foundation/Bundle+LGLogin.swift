import Foundation

private final class BundleToken {}

fileprivate extension Bundle {
    static func makeLoginBundle() -> Bundle {
        let frameworkBundle = Bundle(for: BundleToken.self)
        let bundleURL = frameworkBundle.url(forResource: "LGLoginBundle", withExtension: "bundle")!
        return Bundle(url: bundleURL)!
    }
}

let loginBundle = Bundle.makeLoginBundle()
