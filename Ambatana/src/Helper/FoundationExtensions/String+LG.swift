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
            return localizedUppercaseString
        } else {
            return uppercaseStringWithLocale(NSLocale.currentLocale())
        }
    }

    var lowercase: String {
        if #available(iOS 9.0, *) {
            return localizedLowercaseString
        } else {
            return lowercaseStringWithLocale(NSLocale.currentLocale())
        }
    }

    var capitalized: String {
        if #available(iOS 9.0, *) {
            return localizedCapitalizedString
        } else {
            return capitalizedStringWithLocale(NSLocale.currentLocale())
        }
    }

    var trim: String {
        let trimSet = NSCharacterSet.whitespaceAndNewlineCharacterSet()
        return stringByTrimmingCharactersInSet(trimSet)
    }

    var capitalizedFirstLetterOnly: String  {
        guard !self.isEmpty else { return self }
        var result = self
        result.replaceRange(result.startIndex...result.startIndex, with: String(result[result.startIndex]).capitalizedString)
        return result
    }

    func attributedHyperlinkedStringWithURLDict(urlDict: [String : NSURL], textColor: UIColor)
        -> NSMutableAttributedString {
        
            // Attributed string works with NSRange and NSRange != Range<String>
            let nsText = NSString(string: self)
            let resultText : NSMutableAttributedString = NSMutableAttributedString(string: self)
            
            resultText.addAttribute(NSForegroundColorAttributeName, value: textColor,
                range: NSMakeRange(0, resultText.length))
            
            for (word, url) in urlDict {
                let range = nsText.rangeOfString(word, options: .CaseInsensitiveSearch)
                
                resultText.addAttribute(NSLinkAttributeName, value: url, range: range)
            }
            return resultText
    }

    func isEmail() -> Bool {
        let regex = try? NSRegularExpression(pattern: "^[A-Z0-9._%+-]+@[A-Z0-9.-]+\\.[A-Z]+$", options: .CaseInsensitive)
        return regex?.firstMatchInString(self, options: [], range: NSMakeRange(0, self.characters.count)) != nil
    }

    func isValidLengthPrice() -> Bool {
        let separator = componentsSeparatedByCharactersInSet(NSCharacterSet.decimalDigitCharacterSet())
            .joinWithSeparator("")
        if separator.isEmpty {
            return characters.count <= Constants.maxPriceIntegerCharacters
        } else if separator.characters.count > 1 {
            return false
        }

        let parts = componentsSeparatedByString(separator)
        guard parts.count == 2 else { return false }

        return parts[0].characters.count <= Constants.maxPriceIntegerCharacters &&
               parts[1].characters.count <= Constants.maxPriceFractionalCharacters
    }

    func toNameReduced(maxChars maxChars: Int) -> String {
        guard characters.count > maxChars else { return self }
        let substring = substringToIndex(startIndex.advancedBy(maxChars))
        let words = substring.byWords
        guard words.count > 1 else { return substring+"." }
        let firstPart = words.prefix(words.count - 1).joinWithSeparator(" ")
        guard let lastWordFirstChar = words.last?.characters.first else { return firstPart }
        return firstPart + " " + String(lastWordFirstChar) + "."
    }

    func toPriceDouble() -> Double {
        let formatter = NSNumberFormatter()
        formatter.numberStyle = NSNumberFormatterStyle.DecimalStyle
        formatter.locale = NSLocale.autoupdatingCurrentLocale()
        if let number = formatter.numberFromString(self) {
            return Double(number)
        }
        // Just in case decimal style doesn't work
        formatter.numberStyle = NSNumberFormatterStyle.CurrencyStyle
        if let number = formatter.numberFromString(self) {
            return Double(number)
        }
        return 0
    }

    static func fromPriceDouble(price: Double) -> String {
        let numFormatter = NSNumberFormatter()
        numFormatter.numberStyle = NSNumberFormatterStyle.DecimalStyle
        numFormatter.usesGroupingSeparator = false
        if let text = numFormatter.stringFromNumber(price) {
            return text
        }
        return ""
    }

    func decomposeIdSlug() -> String? {
        let slugComponents = self.componentsSeparatedByString("_")
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
    
    func trunc(length: Int, trailing: String? = "...") -> String {
        guard self.characters.count > length else { return self }
        return self.substringToIndex(self.startIndex.advancedBy(length)) + (trailing ?? "")
    }
    
    func encodeString() -> String {
        let URLCombinedCharacterSet = NSMutableCharacterSet()
        URLCombinedCharacterSet.formUnionWithCharacterSet(.URLQueryAllowedCharacterSet())
        URLCombinedCharacterSet.removeCharactersInString("+")
        let urlEncoded = self.stringByAddingPercentEncodingWithAllowedCharacters(URLCombinedCharacterSet)
        return urlEncoded ?? self
    }

    var byWords: [String] {
        var result:[String] = []
        enumerateSubstringsInRange(characters.indices, options: .ByWords) {
            guard let substring = $0.substring else { return }
            result.append(substring)
        }
        return result
    }
}
