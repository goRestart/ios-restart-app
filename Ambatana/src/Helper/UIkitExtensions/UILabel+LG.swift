//
//  UILabel+LG.swift
//  LetGo
//
//  Created by Juan Iglesias on 16/11/16.
//  Copyright © 2016 Ambatana. All rights reserved.
//

import Foundation

extension UILabel {
    
    func fontSizeAdjusted() -> Int {
        guard let labelText = self.text else { return Int(self.font.pointSize)}
        guard var font = self.font else { return Int(self.font.pointSize)}
        var range =  NSMakeRange(0, 1)
        let attributedString = self.attributedText
        let attributes = attributedString?.attributes(at: 0, effectiveRange: &range)
        let characters = CharacterSet.whitespacesAndNewlines
        var words = labelText.components(separatedBy: characters)
        var maxSize = CGSize.zero
        var maxWidthString: NSMutableAttributedString? = nil
        for i in 0..<words.count {
            let word = words[i]
            let wordSize = word.size(attributes: attributes)
            if wordSize.width > maxSize.width {
                maxSize = wordSize
                maxWidthString = NSMutableAttributedString(string: word, attributes: attributes)
            }
        }
        if let maxWidth = maxWidthString {
            while maxSize.width > self.frame.width {
                font = font.withSize(font.pointSize - 1.0)
                maxWidth.addAttribute(NSFontAttributeName, value: font, range: NSRange(location: 0, length: maxWidth.length))
                maxSize = maxWidth.size()
            }
        }
        return Int(font.pointSize)
    }
}
