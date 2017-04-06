extension String: Randomizable {
    public static func makeRandom() -> String {
        return String.makeRandom(length: Int.makeRandom(min: 5, max: 10))
    }
}

public extension String {
    static func makeRandom(length: Int) -> String {
        return makeRandom(length: length,
                          allowedChars: "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789")
    }

    static func makeRandom(length: Int, allowedChars: String) -> String {
        let allowedCharsStr = allowedChars as NSString
        return (0..<length).map { _ in
        let index = Int.makeRandom(min: 0, max: allowedCharsStr.length - 1)
        var character = allowedCharsStr.character(at: index)
        return NSString(characters: &character, length: 1) as String
        }.joined(separator: "")
    }

    static func makeRandomEmail() -> String {
        let name = String.makeRandom(length: 10)
        let domain = String.makeRandom(length: 10)
        return "\(name)@\(domain).com"
    }

    static func makeRandomPhrase(words: Int, wordLengthMin: Int = 2, wordLengthMax: Int = 10) -> String {
        var phrase = ""
        for _ in 0..<words {
            let length = Int.makeRandom(min: wordLengthMin, max: wordLengthMax)
            let word = String.makeRandom(length: length)
            if phrase.isEmpty {
                phrase = word
            } else {
                phrase += " \(word)"
            }
        }
        return phrase
    }

    static func makeRandomURL() -> String {
        return "http://\(makeRandom(length: 10)).com/\(makeRandom(length: 5))"
    }
}
