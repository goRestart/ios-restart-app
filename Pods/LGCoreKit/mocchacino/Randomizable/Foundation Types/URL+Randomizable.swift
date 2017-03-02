import Foundation

extension URL: Randomizable {
    public static func makeRandom() -> URL {
        return URL(string: String.makeRandomURL())!
    }
}
