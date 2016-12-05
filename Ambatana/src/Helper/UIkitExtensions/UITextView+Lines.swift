//
//  UITextView+Lines.swift
//  LetGo
//
//  Created by Eli Kohen on 02/12/2016.
//  Copyright © 2016 Ambatana. All rights reserved.
//

extension UITextView {

    var lineHeight: CGFloat {
        if font == nil {
            text = " " // Force font assignment
            text = ""
        }
        return font?.lineHeight ?? 0
    }

    var minimumHeight: CGFloat {
        var height = lineHeight
        height += textContainerInset.top + textContainerInset.bottom
        return height
    }

    func appropriateHeight(maxLines: UInt) -> CGFloat {
        var height: CGFloat = 0
        let minimumHeight = self.minimumHeight
        let numberOfLines = self.numberOfLines

        if numberOfLines == 1 {
            height = minimumHeight
        } else {
            height = heightForLines(min(numberOfLines, maxLines))
        }

        if height < minimumHeight {
            height = minimumHeight
        }

        return CGFloat(roundf(Float(height)))
    }

    var numberOfLines: UInt {
        var contentHeight = contentSize.height
        contentHeight -= textContainerInset.top + textContainerInset.bottom
        guard let lineHeight = font?.lineHeight else { return 0 }
        let lines = fabs(contentHeight/lineHeight)

        // This helps preventing the content's height to be larger that the bounds' height
        // Avoiding this way to have unnecessary scrolling in the text view when there is only 1 line of content
        if lines == 1 && contentSize.height > bounds.size.height {
            contentSize.height = bounds.size.height
        }
        guard lines > 0 else { return 1 }
        return UInt(lines)
    }

    func scrollToCaret(animated animated: Bool) {
        if animated {
            scrollRangeToVisible(selectedRange)
        } else {
            UIView.performWithoutAnimation { [weak self] in
                guard let selectedRange = self?.selectedRange else { return }
                self?.scrollRangeToVisible(selectedRange)
            }
        }
    }

    private func heightForLines(lines: UInt) -> CGFloat {
        var height = self.textContainerInset.top + self.textContainerInset.bottom
        height += CGFloat(roundf(Float(lineHeight)*Float(lines)))
        return height
    }
}

