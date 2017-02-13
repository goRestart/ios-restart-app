//
//  AutocompleteField.swift
//  Example
//
//  Created by Filip Stefansson on 05/11/15.
//  Copyright © 2015 Filip Stefansson. All rights reserved.
//

// Originally from https://github.com/thestr4ng3r/AutocompleteField, commit: 2b3eae30ad51d35f5716afda91ef77fa796a0d77 (Swift 3)
// Modified to delete useless functionality & inherit from LGTextField :D

import Foundation
import UIKit


@IBDesignable class AutocompleteField: LGTextField {
    @IBInspectable var completionColor : UIColor = UIColor(white: 0, alpha: 0.22)
    var suggestion : String? {
        didSet {
            setLabel(text: suggestion)
        }
    }
    // Move the suggestion label up or down. Sometimes there's a small difference, and this can be used to fix it.
    var pixelCorrection : CGFloat = 0

    fileprivate var label = UILabel()


    // MARK: - Lifecycle

    override public init(frame: CGRect) {
        super.init(frame: frame)
        setupLabel()
    }

    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setupLabel()
    }

    // ovverride to set frame of the suggestion label whenever the textfield frame changes.
    override func layoutSubviews() {
        label.frame = CGRect(x: insetX, y: insetY + pixelCorrection,
                             width: frame.width - 2 * insetX - clearButtonSide / 2,
                             height: frame.height - 2 * insetY)
        super.layoutSubviews()
    }


    // MARK: - Private methods

    /**
     Sets up the suggestion label with the same font styling and alignment as the textfield.
     */
    fileprivate func setupLabel() {
        setLabel(text: nil)
        label.lineBreakMode = .byClipping
        if #available(iOS 9.0, *) {
            label.allowsDefaultTighteningForTruncation = false
        }
        addSubview(label)
    }


    /**
     Set content of the suggestion label.
     - parameter text: Suggestion text
     */
    private func setLabel(text: String?) {
        guard let text = text, !text.isEmpty else {
            label.attributedText = nil
            return
        }

        // create an attributed string instead of the regular one.
        // In this way we can hide the letters in the suggestion that the user has already written.
        let attributedString = NSMutableAttributedString(
            string: text,
            attributes: [NSFontAttributeName: font ?? UIFont.systemFont(size: 17),
                         NSForegroundColorAttributeName: completionColor])

        // Hide the letters that are under the fields text.
        // If the suggestion is abcdefgh and the user has written abcd
        // we want to hide those letters from the suggestion.
        if let inputText = self.text {
            attributedString.addAttribute(NSForegroundColorAttributeName,
                                          value: UIColor.clear,
                                          range: NSRange(location: 0,
                                                         length: inputText.characters.count)
            )
        }

        label.attributedText = attributedString
        label.textAlignment = textAlignment
    }
}
