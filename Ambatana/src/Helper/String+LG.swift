//
//  String+LG.swift
//  LetGo
//
//  Created by Dídac on 17/11/15.
//  Copyright © 2015 Ambatana. All rights reserved.
//

import Foundation

extension String {

    func attributedHyperlinkedStringWithURLDict(urlDict: [String : NSURL], textColor: UIColor, linksColor: UIColor)
        -> NSMutableAttributedString {
        
            // Attributed string works with NSRange and NSRange != Range<String>
            let nsText = NSString(string: self)
            let resultText : NSMutableAttributedString = NSMutableAttributedString(string: self)
            
            resultText.addAttribute(NSForegroundColorAttributeName, value: textColor,
                range: NSMakeRange(0, resultText.length))
            
            for (word, url) in urlDict {
                let range = nsText.rangeOfString(word, options: .CaseInsensitiveSearch)
                
                resultText.addAttribute(NSLinkAttributeName, value: url, range: range)
                resultText.addAttribute(NSForegroundColorAttributeName, value: linksColor, range: range)
            }
            return resultText
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
}
