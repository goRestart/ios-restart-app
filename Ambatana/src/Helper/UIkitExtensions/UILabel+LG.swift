//
//  UILabel+LG.swift
//  LetGo
//
//  Created by Juan Iglesias on 16/11/16.
//  Copyright © 2016 Ambatana. All rights reserved.
//

import Foundation
import LGCoreKit

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

    func setHTMLFromString(htmlText: String) {
        guard let font = self.font else { return }
        let modifiedFont = String(format:"<span style=\"font-family: '-apple-system', '\(font.fontName)'; font-size: \(font.pointSize)\">%@</span>", htmlText)
        guard let data = modifiedFont.data(using: .utf8, allowLossyConversion: true) else { return }
        let options: [String: Any] = [NSDocumentTypeDocumentAttribute: NSHTMLTextDocumentType,
                                      NSCharacterEncodingDocumentAttribute: String.Encoding.utf8.rawValue]
        DispatchQueue.main.async {
            if let attrStr = try? NSAttributedString(data: data, options: options, documentAttributes: nil) {
                self.attributedText = attrStr
            } else {
                // if it fails we keep going 💪🏼
                self.text = htmlText.ignoreHTMLTags

                let message = "Unable to set HTML with AttributedString \(htmlText)"
                logMessage(.error, type: .uikit, message: message)
                report(AppReport.navigation(error: .childCoordinatorPresent), message: message)
            }
        }
    }
}
