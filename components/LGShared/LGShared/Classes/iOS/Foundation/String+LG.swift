import UIKit
import CommonCrypto // we can import this because JSONWebToken provides a .modulemap for it

public extension String {

    public var sha256: Data? {
        guard let messageData = self.data(using:String.Encoding.utf8) else { return nil }
        var digestData = Data(count: Int(CC_SHA256_DIGEST_LENGTH))
        _ = digestData.withUnsafeMutableBytes {digestBytes in
            messageData.withUnsafeBytes {messageBytes in
                CC_SHA256(messageBytes, CC_LONG(messageData.count), digestBytes)
            }
        }
        return digestData
    }
    
    public var trim: String {
        let trimSet = CharacterSet.whitespacesAndNewlines
        return trimmingCharacters(in: trimSet)
    }

    public var capitalizedFirstLetterOnly: String  {
        guard !self.isEmpty else { return self }
        var result = self.localizedLowercase
        result.replaceSubrange(result.startIndex...result.startIndex, with: String(result[result.startIndex]).localizedCapitalized)
        return result
    }

    public var specialCharactersRemoved: String {
        let charactersToRemove = CharacterSet.alphanumerics.inverted
        return components(separatedBy: charactersToRemove).joined(separator: "")
    }
    
    public var ignoreHTMLTags: String {
        return replacingOccurrences(of: "<[^>]+>", with: "", options: .regularExpression, range: nil)
    }

    public func attributedHyperlinkedStringWithURLDict(_ urlDict: [String : URL], textColor: UIColor?)
        -> NSMutableAttributedString {
        
            // Attributed string works with NSRange and NSRange != Range<String>
            let nsText = NSString(string: self)
            let resultText : NSMutableAttributedString = NSMutableAttributedString(string: self)

            if let textColor = textColor {
                resultText.addAttribute(NSAttributedStringKey.foregroundColor, value: textColor,
                                        range: NSMakeRange(0, resultText.length))
            }
            
            for (word, url) in urlDict {
                let range = nsText.range(of: word, options: .caseInsensitive)
                guard range.location != NSNotFound else { continue }
                resultText.addAttribute(NSAttributedStringKey.link, value: url, range: range)
            }
            return resultText
    }

    public func isEmail() -> Bool {
        let regex = try? NSRegularExpression(pattern: "^[A-Z0-9._%+-]+@[A-Z0-9.-]+\\.[A-Z]+$", options: .caseInsensitive)
        return regex?.firstMatch(in: self, options: [], range: NSMakeRange(0, count)) != nil
    }

    public func suggestEmail(domains: [String]) -> String? {
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

    public func stringByReplacingFirstOccurrence(of findString: String, with: String, options: String.CompareOptions = []) -> String {
        guard let rangeOfFoundString = range(of: findString, options: options, range: nil, locale: nil) else { return self }
        return replacingOccurrences(of: findString, with: with, options: options, range: rangeOfFoundString)
    }

    public func makeUsernameFromEmail() -> String? {
        guard let atSignRange = range(of: "@"), isEmail() else { return nil }
        let emailUsername = String(self[..<atSignRange.lowerBound])
        var username = emailUsername
        username = username.replacingOccurrences(of: ".", with: " ")
        username = username.replacingOccurrences(of: "_", with: " ")
        username = username.replacingOccurrences(of: "-", with: " ")
        if let plusSignRange = username.range(of: "+") {
            username = String(username[..<plusSignRange.lowerBound])
        }
        return username.localizedCapitalized
    }

    public func isValidLengthPrice(_ acceptsSeparator: Bool, locale: Locale = Locale.autoupdatingCurrent) -> Bool {
        let separator = components(separatedBy: CharacterSet.decimalDigits)
            .joined(separator: "")
        let formatter = NumberFormatter()
        formatter.numberStyle = NumberFormatter.Style.decimal
        formatter.locale = locale
        if separator.isEmpty {
            return count <= SharedConstants.maxPriceIntegerCharacters
        } else if acceptsSeparator && separator != formatter.decimalSeparator {
            return false
        } else if !acceptsSeparator && !separator.isEmpty {
            return false
        }

        let parts = components(separatedBy: separator)
        guard parts.count == 2 else { return false }

        return parts[0].count <= SharedConstants.maxPriceIntegerCharacters &&
               parts[1].count <= SharedConstants.maxPriceFractionalCharacters
    }

    public func toNameReduced(maxChars: Int) -> String {
        guard count > maxChars else { return self }
        let substring =  String(self[..<self.index(startIndex, offsetBy: maxChars)])
        let words = substring.byWords
        guard words.count > 1 else { return substring+"." }
        let firstPart = words.prefix(words.count - 1).joined(separator: " ")
        guard let lastWordFirstChar = words.last?.first else { return firstPart }
        return firstPart + " " + String(lastWordFirstChar) + "."
    }

    public func clipMoreThan(wordCount: Int) -> String {
        let words = self.byWords
        if words.count <= wordCount { return self }
        return words.prefix(wordCount).joined(separator: " ")
    }

    public func toPriceDouble() -> Double {
        let formatter = NumberFormatter()
        formatter.numberStyle = NumberFormatter.Style.decimal
        formatter.locale = Locale.autoupdatingCurrent
        if let number = formatter.number(from: self) {
            return number.doubleValue
        }
        // Just in case decimal style doesn't work
        formatter.numberStyle = NumberFormatter.Style.currency
        if let number = formatter.number(from: self) {
            return number.doubleValue
        }
        return 0
    }

    public static func fromPriceDouble(_ price: Double) -> String {
        let numFormatter = NumberFormatter()
        numFormatter.numberStyle = NumberFormatter.Style.decimal
        numFormatter.usesGroupingSeparator = false
        if let text = numFormatter.string(from: NSNumber(value: price)) {
            return text
        }
        return ""
    }

    public func decomposeIdSlug() -> String? {
        let slugComponents = self.components(separatedBy: "_")
        guard slugComponents.count > 1 else { return nil }
        let slugId = slugComponents[slugComponents.count - 1]
        return slugId
    }
    
    public func trunc(_ length: Int, trailing: String? = "...") -> String {
        guard count > length else { return self }
        let substring = String(self[..<self.index(self.startIndex, offsetBy: length)])
        return substring + (trailing ?? "")
    }
    
    public func encodeString() -> String {
        let URLCombinedCharacterSet = NSMutableCharacterSet()
        URLCombinedCharacterSet.formUnion(with: .urlQueryAllowed)
        URLCombinedCharacterSet.removeCharacters(in: "+")
        let urlEncoded = self.addingPercentEncoding(withAllowedCharacters: URLCombinedCharacterSet as CharacterSet)
        return urlEncoded ?? self
    }

    public var byWords: [String] {
        var result:[String] = []
        let range = startIndex ..< endIndex
        enumerateSubstrings(in: range, options: .byWords) { (word, _, _, _) in
            guard let substring = word else { return }
            result.append(substring)
        }
        return result
    }

    public func containsLetgo() -> Bool {
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
    
    public func trim(strings: [String], separator: String) -> String {
        let actualSeparator = separator.trim
        return components(separatedBy: actualSeparator)
            .map { $0.trim }
            .filter { return !strings.contains($0) }
            .joined(separator: actualSeparator)
            .trim
    }
    
    public static func make(tagsString: [String], comment: String? = nil) -> String {
        let components: [String]
        if let comment = comment {
            components = tagsString + [comment]
        } else {
            components = tagsString
        }
        return make(components: components, separator: ". ")
    }
    
    public static func make(components: [String?], separator: String) -> String {
        let allValues = components.flatMap { $0 }
        return allValues.joined(separator: separator)
    }
    
    public var isOnlyDigits: Bool {
        let nonNumberCharacters = CharacterSet.decimalDigits.inverted
        return rangeOfCharacter(from: nonNumberCharacters) == nil
    }
    
    public func makeBold(ignoringText: String, font: UIFont) -> NSAttributedString {
        let attributedString = NSMutableAttributedString(string: self,
                                                         attributes: [NSAttributedStringKey.font: font])
        let ignoreTextCount = contains(ignoringText) ? ignoringText.count : 0
        attributedString.addAttribute(
            NSAttributedStringKey.font,
            value: UIFont.boldSystemFont(ofSize: font.pointSize),
            range: NSMakeRange(ignoreTextCount, count-ignoreTextCount)
        )
        return attributedString
    }

    public func heightForWidth(width: CGFloat, maxLines: Int?, withFont font: UIFont) -> CGFloat {

        guard !self.isEmpty else { return 0.0 }

        let textSize = CGSize(width: width, height: CGFloat(Float.greatestFiniteMagnitude))
        
        let requiredSize: CGRect = self.boundingRect(with: textSize,
                                                     options: NSStringDrawingOptions.usesLineFragmentOrigin,
                                                     attributes: [NSAttributedStringKey.font: font],
                                                     context: nil)

        let resultHeight = requiredSize.height
        let charSize = CGFloat(font.lineHeight)
        let lineCount: CGFloat = resultHeight/charSize

        let finalHeight: CGFloat
        let interLineSpace: CGFloat
        if let maxLines = maxLines, lineCount > CGFloat(maxLines) {
            finalHeight = CGFloat(maxLines) * charSize
            interLineSpace = CGFloat(maxLines)
        } else {
            finalHeight = resultHeight
            interLineSpace = lineCount
        }
        return finalHeight + interLineSpace
    }
    
    public func widthFor(height: CGFloat, font: UIFont) -> CGFloat {
        let constraintRect = CGSize(width: CGFloat.greatestFiniteMagnitude, height: height)
        return self.boundingRect(with: constraintRect,
                            options: NSStringDrawingOptions.usesLineFragmentOrigin,
                            attributes: [NSAttributedStringKey.font: font], context: nil).width
    }

    public var isPhoneNumber: Bool {
        let noPlusOrHyphenString = self.components(separatedBy: ["+","-"]).joined(separator: "")
        guard let _ = Int(noPlusOrHyphenString) else {
            return false
        }
        return noPlusOrHyphenString.count == SharedConstants.usaPhoneNumberDigitsCount
    }

    public var addingSquareMeterUnit: String {
        return self + " \(SharedConstants.sizeSquareMetersUnit)"
    }

    public func addUSPhoneFormatDashes() -> String {

        guard self.count >= SharedConstants.usaFirstDashPosition else { return self }

        var firstChunk: String = ""
        var midChunk: String = ""
        var lastChunk: String = ""
        var outputString = ""
        let midChunkStart = String.Index(encodedOffset: SharedConstants.usaFirstDashPosition)
        let midChunkEnd = String.Index(encodedOffset: SharedConstants.usaSecondDashPosition-1)

        if self.count >= SharedConstants.usaFirstDashPosition {
            firstChunk = String(self[self.startIndex..<midChunkStart])
            outputString = firstChunk + "-"
        }
        if self.count >= SharedConstants.usaSecondDashPosition {
            midChunk = String(self[midChunkStart..<midChunkEnd])
            outputString = outputString + midChunk + "-"
            lastChunk = String(self[midChunkEnd..<self.endIndex])
            outputString = outputString + lastChunk
        } else {
            midChunk = String(self[midChunkStart..<String.Index(encodedOffset: self.count)])
            return outputString + midChunk
        }
        return outputString
    }

    public func truncatedNameStringToInitials() -> String {
        let words = self.byWords
        guard words.count > 1 else { return self }
        var name = words.first ?? ""
        for (i, word) in words.enumerated() where i > 0 {
            name = name + " " + word.prefix(1) + "."
        }
        return name
    }
}

extension String {
    
    public func bicolorAttributedText(mainColor: UIColor,
                                      colouredText: String,
                                      otherColor: UIColor,
                                      font: UIFont,
                                      paragraphStyle: NSMutableParagraphStyle? = nil) -> NSMutableAttributedString {
        
        var mainAttributes: [NSAttributedStringKey : Any] = [.font : font]
        if paragraphStyle != nil {
            mainAttributes[.paragraphStyle] = paragraphStyle
        }
        mainAttributes[.foregroundColor] = mainColor
        
        let titleText = NSMutableAttributedString(string: self, attributes: mainAttributes)
        
        guard let range = range(of: colouredText) else { return titleText }
        
        var colouredAttributes = mainAttributes
        colouredAttributes[.foregroundColor] = otherColor
        titleText.setAttributes(colouredAttributes, range: NSRange(range, in: self))
        
        return titleText
    }
    
    public func bifontAttributedText(highlightedText: String,
                                     mainFont: UIFont,
                                     mainColour: UIColor,
                                     otherFont: UIFont,
                                     otherColour: UIColor) -> NSAttributedString {
        let mainAttributes: [NSAttributedStringKey: Any] = [.font: mainFont, .foregroundColor: mainColour]
        let otherAttributes: [NSAttributedStringKey: Any] = [.font: otherFont, .foregroundColor: otherColour]
        
        let attributedString = NSMutableAttributedString(string: self, attributes: mainAttributes)
        
        guard let range = range(of: highlightedText) else { return attributedString }
        attributedString.setAttributes(otherAttributes, range: NSRange(range, in: self))
        
        return attributedString
    }
    
    public var forSorting: String {
        let simple = folding(options: [.diacriticInsensitive, .widthInsensitive, .caseInsensitive], locale: nil)
        let nonAlphaNumeric = CharacterSet.alphanumerics.inverted
        return simple.components(separatedBy: nonAlphaNumeric).joined(separator: "")
    }
    
    public var firstLetterNormalized: String {
        return String(forSorting.prefix(1))
    }
}
