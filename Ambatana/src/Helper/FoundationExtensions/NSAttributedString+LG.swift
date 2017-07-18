//
//  NSAttributedString+LG.swift
//  LetGo
//
//  Created by Raúl de Oñate Blanco on 14/07/2017.
//  Copyright © 2017 Ambatana. All rights reserved.
//

import Foundation

extension NSAttributedString {
    func setBold(ignoreText: String, font: UIFont) -> NSAttributedString {
        let attributedString = NSMutableAttributedString(string: string, attributes: [NSFontAttributeName: font])
        let boldFontAttribute = [NSFontAttributeName: UIFont.boldSystemFont(ofSize: font.pointSize)]
        attributedString.addAttributes(boldFontAttribute, range: NSMakeRange(ignoreText.characters.count, string.characters.count-ignoreText.characters.count))
        return attributedString
    }
}
