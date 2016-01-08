//
//  UITextField+LG.swift
//  LetGo
//
//  Created by Eli Kohen on 08/01/16.
//  Copyright © 2016 Ambatana. All rights reserved.
//

extension UITextField {
    func textReplacingCharactersInRange(range: NSRange, replacementString string: String) -> String {
        let updatedText: String
        if let text = self.text {
            updatedText = (text as NSString).stringByReplacingCharactersInRange(range, withString: string)
        } else {
            updatedText = string
        }
        return updatedText
    }

    func shouldChangePriceInRange(range: NSRange, replacementString string: String) -> Bool {
        let updatedText =  textReplacingCharactersInRange(range, replacementString: string)
        return updatedText.isValidLengthPrice()
    }
}
