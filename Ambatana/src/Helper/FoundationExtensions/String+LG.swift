//
//  String+LG.swift
//  LetGo
//
//  Created by Dídac on 17/11/15.
//  Copyright © 2015 Ambatana. All rights reserved.
//

import Foundation

extension String {

    var uppercase: String {
        if #available(iOS 9.0, *) {
            return localizedUppercase
        } else {
            return uppercased(with: Locale.current)
        }
    }

    var lowercase: String {
        if #available(iOS 9.0, *) {
            return localizedLowercase
        } else {
            return lowercased(with: Locale.current)
        }
    }

    var capitalized: String {
        if #available(iOS 9.0, *) {
            return localizedCapitalized
        } else {
            return self.capitalized(with: Locale.current)
        }
    }

    var trim: String {
        let trimSet = CharacterSet.whitespacesAndNewlines
        return trimmingCharacters(in: trimSet)
    }

    var capitalizedFirstLetterOnly: String  {
        guard !self.isEmpty else { return self }
        var result = self
        result.replaceSubrange(result.startIndex...result.startIndex, with: String(result[result.startIndex]).capitalized)
        return result
    }
    
    var specialCharactersRemoved: String {
        let charactersToRemove = CharacterSet.alphanumerics.inverted
        return components(separatedBy: charactersToRemove).joined(separator: "")
    }

    func attributedHyperlinkedStringWithURLDict(_ urlDict: [String : URL], textColor: UIColor)
        -> NSMutableAttributedString {
        
            // Attributed string works with NSRange and NSRange != Range<String>
            let nsText = NSString(string: self)
            let resultText : NSMutableAttributedString = NSMutableAttributedString(string: self)
            
            resultText.addAttribute(NSForegroundColorAttributeName, value: textColor,
                range: NSMakeRange(0, resultText.length))
            
            for (word, url) in urlDict {
                let range = nsText.range(of: word, options: .caseInsensitive)
                
                resultText.addAttribute(NSLinkAttributeName, value: url, range: range)
            }
            return resultText
    }

    func isEmail() -> Bool {
        let regex = try? NSRegularExpression(pattern: "^[A-Z0-9._%+-]+@[A-Z0-9.-]+\\.[A-Z]+$", options: .caseInsensitive)
        return regex?.firstMatch(in: self, options: [], range: NSMakeRange(0, self.characters.count)) != nil
    }

    func suggestEmail(domains: [String]) -> String? {
        guard let regex = try? NSRegularExpression(pattern: "^[A-Z0-9._%+-]+@",
                                                   options: .caseInsensitive) else { return nil }
        let mutableString = NSMutableString(string: self)
        let range = NSMakeRange(0, mutableString.length)
        let regexMatches = regex.replaceMatches(in: mutableString, options: [], range: range, withTemplate: "")
        let string = mutableString as String

        // isEmpty is checked to prevent the first domain suggestion when typing "user@"
        guard regexMatches == 1, !string.isEmpty else { return nil }

        for domain in domains {
            if domain.hasPrefix(string as String) {
                let concat = domain.stringByReplacingFirstOccurrence(of: string, with: "")
                return self + concat
            }
        }
        return nil
    }

    func stringByReplacingFirstOccurrence(of findString: String, with: String, options: String.CompareOptions = []) -> String {
        guard let rangeOfFoundString = range(of: findString, options: options, range: nil, locale: nil) else { return self }
        return replacingOccurrences(of: findString, with: with, options: options, range: rangeOfFoundString)
    }

    func makeUsernameFromEmail() -> String? {
        guard let atSignRange = range(of: "@"), isEmail() else { return nil }
        let emailUsername = substring(to: atSignRange.lowerBound)
        var username = emailUsername
        username = username.replacingOccurrences(of: ".", with: " ")
        username = username.replacingOccurrences(of: "_", with: " ")
        username = username.replacingOccurrences(of: "-", with: " ")
        if let plusSignRange = username.range(of: "+") {
            username = username.substring(to: plusSignRange.lowerBound)
        }
        return username.capitalized
    }

    func isValidLengthPrice(_ acceptsSeparator: Bool, locale: Locale = Locale.autoupdatingCurrent) -> Bool {
        let separator = components(separatedBy: CharacterSet.decimalDigits)
            .joined(separator: "")
        let formatter = NumberFormatter()
        formatter.numberStyle = NumberFormatter.Style.decimal
        formatter.locale = locale
        if separator.isEmpty {
            return characters.count <= Constants.maxPriceIntegerCharacters
        } else if acceptsSeparator && separator != formatter.decimalSeparator {
            return false
        } else if !acceptsSeparator && !separator.isEmpty {
            return false
        }

        let parts = components(separatedBy: separator)
        guard parts.count == 2 else { return false }

        return parts[0].characters.count <= Constants.maxPriceIntegerCharacters &&
               parts[1].characters.count <= Constants.maxPriceFractionalCharacters
    }

    func toNameReduced(maxChars: Int) -> String {
        guard characters.count > maxChars else { return self }
        let substring = self.substring(to: characters.index(startIndex, offsetBy: maxChars))
        let words = substring.byWords
        guard words.count > 1 else { return substring+"." }
        let firstPart = words.prefix(words.count - 1).joined(separator: " ")
        guard let lastWordFirstChar = words.last?.characters.first else { return firstPart }
        return firstPart + " " + String(lastWordFirstChar) + "."
    }

    func toPriceDouble() -> Double {
        let formatter = NumberFormatter()
        formatter.numberStyle = NumberFormatter.Style.decimal
        formatter.locale = Locale.autoupdatingCurrent
        if let number = formatter.number(from: self) {
            return Double(number)
        }
        // Just in case decimal style doesn't work
        formatter.numberStyle = NumberFormatter.Style.currency
        if let number = formatter.number(from: self) {
            return Double(number)
        }
        return 0
    }

    static func fromPriceDouble(_ price: Double) -> String {
        let numFormatter = NumberFormatter()
        numFormatter.numberStyle = NumberFormatter.Style.decimal
        numFormatter.usesGroupingSeparator = false
        if let text = numFormatter.string(from: NSNumber(value: price)) {
            return text
        }
        return ""
    }

    func decomposeIdSlug() -> String? {
        let slugComponents = self.components(separatedBy: "_")
        guard slugComponents.count > 1 else { return nil }
        let slugId = slugComponents[slugComponents.count - 1]
        return slugId
    }
    
    func stringByRemovingEmoji() -> String {
        return String(self.characters.filter { !$0.isEmoji })
    }
    
    func hasEmojis() -> Bool {
        return unicodeScalars.filter { $0.isEmoji }.count > 0
    }
    
    func trunc(_ length: Int, trailing: String? = "...") -> String {
        guard self.characters.count > length else { return self }
        return self.substring(to: self.characters.index(self.startIndex, offsetBy: length)) + (trailing ?? "")
    }
    
    func encodeString() -> String {
        let URLCombinedCharacterSet = NSMutableCharacterSet()
        URLCombinedCharacterSet.formUnion(with: .urlQueryAllowed)
        URLCombinedCharacterSet.removeCharacters(in: "+")
        let urlEncoded = self.addingPercentEncoding(withAllowedCharacters: URLCombinedCharacterSet as CharacterSet)
        return urlEncoded ?? self
    }

    var byWords: [String] {
        var result:[String] = []
        let range = startIndex ..< endIndex
        enumerateSubstrings(in: range, options: .byWords) { (word, _, _, _) in
            guard let substring = word else { return }
            result.append(substring)
        }
        return result
    }

    func containsLetgo() -> Bool {
        let lowercaseString = lowercased()
        return lowercaseString.range(of: "letgo") != nil ||
            lowercaseString.range(of: "ietgo") != nil ||
            lowercaseString.range(of: "letg0") != nil ||
            lowercaseString.range(of: "ietg0") != nil ||
            lowercaseString.range(of: "let go") != nil ||
            lowercaseString.range(of: "iet go") != nil ||
            lowercaseString.range(of: "let g0") != nil ||
            lowercaseString.range(of: "iet g0") != nil
    }
}
