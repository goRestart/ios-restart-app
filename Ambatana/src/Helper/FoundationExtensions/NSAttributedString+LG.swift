//
//  NSAttributedString+LG.swift
//  LetGo
//
//  Created by Raúl de Oñate Blanco on 14/07/2017.
//  Copyright © 2017 Ambatana. All rights reserved.
//

import Foundation

extension NSAttributedString {
    
    func setBoldPartFromTerm(_ text: String, font: UIFont) -> NSAttributedString {
        let attributedString = NSMutableAttributedString(string:self.string, attributes: [NSFontAttributeName: font])
        let boldFontAttribute = [NSFontAttributeName: UIFont.boldSystemFont(ofSize: font.pointSize)]
        attributedString.addAttributes(boldFontAttribute, range:NSMakeRange(text.characters.count, self.string.characters.count-text.characters.count))
        return attributedString
    }
    
}
