import LGComponents
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
            let wordSize = word.size(withAttributes: attributes)
            if wordSize.width > maxSize.width {
                maxSize = wordSize
                maxWidthString = NSMutableAttributedString(string: word, attributes: attributes)
            }
        }
        if let maxWidth = maxWidthString {
            while maxSize.width > self.frame.width {
                font = font.withSize(font.pointSize - 1.0)
                maxWidth.addAttribute(NSAttributedStringKey.font, value: font, range: NSRange(location: 0, length: maxWidth.length))
                maxSize = maxWidth.size()
            }
        }
        return Int(font.pointSize)
    }

    func setHTMLFromString(htmlText: String) {
        guard let font = self.font else { return }
        let modifiedFont = String(format:"<span style=\"font-family: '-apple-system', '\(font.fontName)'; font-size: \(font.pointSize)\">%@</span>", htmlText)
        guard let data = modifiedFont.data(using: .utf8, allowLossyConversion: true) else { return }
        if let attrStr = try? NSAttributedString(data: data, options: [.documentType: NSAttributedString.DocumentType.html,
                                                                       .characterEncoding: String.Encoding.utf8.rawValue],
                                                 documentAttributes: nil) {
            self.attributedText = attrStr
        } else {
            // if it fails we keep going 💪🏼
            self.text = htmlText.ignoreHTMLTags

            let message = "Unable to set HTML with AttributedString \(htmlText)"
            logMessage(.error, type: .uikit, message: message)
            report(AppReport.uikit(error: .unableToConvertHTMLToString), message: message)
        }
    }
    
    func boldStyledHTML(htmlBuffer: String) {
        guard let font = self.font else { return }
        
        let styledChunks = HTMLBoldParser.parse(htmlBuffer: htmlBuffer)
        let attrStr = NSMutableAttributedString()
        
        for chunk in styledChunks {
            switch chunk {
            case .normal(let text):
                attrStr.append(NSAttributedString(string: text))
            case .bold(let text):
                attrStr.append(NSAttributedString(
                    string: text, attributes: [
                        .font : UIFont.boldSystemFont(ofSize: font.pointSize)
                    ]
                ))
            }
        }
        
        attributedText = attrStr
    }
    
    func addKern(value: NSNumber) {
        guard let text = text, !text.isEmpty else { return }
        let attributedString = NSMutableAttributedString(string: text)
        let range = NSRange(location: 0, length: attributedString.length - 1)
        attributedString.addAttribute(NSAttributedStringKey.kern, value: value, range: range)
        attributedText = attributedString
    }

    func isTruncated() -> Bool {
        return self.countLabelLines() > self.numberOfLines
    }

    func countLabelLines() -> Int {
        // Call self.layoutIfNeeded() before if your view uses auto layout
        guard let myText = self.text as NSString? else { return 1 }
        let attributes = [NSAttributedStringKey.font: self.font!]

        let labelSize = myText.boundingRect(with: CGSize(width: self.bounds.width,
                                                         height: CGFloat.greatestFiniteMagnitude),
                                            options: NSStringDrawingOptions.usesLineFragmentOrigin,
                                            attributes: attributes, context: nil)
        return Int(ceil(CGFloat(labelSize.height) / self.font.lineHeight))
    }

    func truncateWordsWithDotsIfNeeded() {
        guard isTruncated() else { return }
        self.text = text?.truncatedNameStringToInitials()
    }
}
