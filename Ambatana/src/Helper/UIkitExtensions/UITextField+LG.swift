//
//  UITextField+LG.swift
//  LetGo
//
//  Created by Eli Kohen on 08/01/16.
//  Copyright © 2016 Ambatana. All rights reserved.
//

extension UITextField {
    func textReplacingCharactersInRange(_ range: NSRange, replacementString string: String) -> String {
        if let text = self.text {
            return (text as NSString).replacingCharacters(in: range, with: string)
        }
        return string
    }

    func shouldChangePriceInRange(_ range: NSRange, replacementString string: String, acceptsSeparator: Bool) -> Bool {
        let updatedText = textReplacingCharactersInRange(range, replacementString: string)
        return updatedText.isValidLengthPrice(acceptsSeparator)
    }
}
