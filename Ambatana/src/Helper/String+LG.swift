//
//  String+LG.swift
//  LetGo
//
//  Created by Dídac on 17/11/15.
//  Copyright © 2015 Ambatana. All rights reserved.
//

import Foundation

extension String {
    
    func setTextsAsLinksWithURLs(urlDict: [String:String], textColor: UIColor, linksColor: UIColor) -> NSMutableAttributedString {
        
        // Attributed string works with NSRange and NSRange != Range<String>
        let nsText = NSString(string: self)
        let resultText : NSMutableAttributedString = NSMutableAttributedString(string: self)
        
        resultText.addAttribute(NSForegroundColorAttributeName, value: textColor, range: NSMakeRange(0, resultText.length-1))
        
        for (word, url) in urlDict {
            let range = nsText.rangeOfString(word, options: .CaseInsensitiveSearch)
            
            resultText.addAttribute(NSLinkAttributeName, value: NSURL(string: url)!, range: range)
            resultText.addAttribute(NSForegroundColorAttributeName, value: linksColor, range: range)
        }
        return resultText
        
    }
}