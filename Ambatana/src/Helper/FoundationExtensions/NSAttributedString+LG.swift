//
//  NSAttributedString+LG.swift
//  LetGo
//
//  Created by Raúl de Oñate Blanco on 14/07/2017.
//  Copyright © 2017 Ambatana. All rights reserved.
//

import Foundation

extension NSAttributedString {
    func setBold(ignoreText: String?, font: UIFont?) -> NSAttributedString {
        var attributedString = NSMutableAttributedString(string: string,
                                                         attributes: [NSFontAttributeName:
                                                            font ?? UIFont.bigBodyFont])
        let ignoreTextCount = ignoreText?.characters.count ?? 0
        attributedString.addAttribute(
            NSFontAttributeName,
            value: UIFont.boldSystemFont(ofSize: font?.pointSize ?? 17),
            range: NSMakeRange(ignoreTextCount, string.characters.count-ignoreTextCount)
        )
        return attributedString
    }
}
