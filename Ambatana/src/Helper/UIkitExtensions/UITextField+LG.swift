//
//  UITextField+LG.swift
//  LetGo
//
//  Created by Eli Kohen on 08/01/16.
//  Copyright © 2016 Ambatana. All rights reserved.
//

extension UITextField {
    func textReplacingCharactersInRange(range: NSRange, replacementString string: String) -> String {
        if let text = self.text {
            return (text as NSString).stringByReplacingCharactersInRange(range, withString: string)
        }
        return string
    }

    func shouldChangePriceInRange(range: NSRange, replacementString string: String) -> Bool {
        let updatedText = textReplacingCharactersInRange(range, replacementString: string)
        return updatedText.isValidLengthPrice()
    }
}
