import Foundation

extension Data: Randomizable {
    public static func makeRandom() -> Data {
        return makeRandom(bytes: Int.makeRandom())
    }
}

extension Data {
    public static func makeRandom(bytes: Int) -> Data {
        let random = String.makeRandom(length: bytes)
        return random.data(using: .utf8)!    // utf-8 encodes 1 char as 1 byte
    }
}
