//
//  NSAttributedString+LG.swift
//  LetGo
//
//  Created by Raúl de Oñate Blanco on 14/07/2017.
//  Copyright © 2017 Ambatana. All rights reserved.
//

import Foundation

extension NSAttributedString {
    
    func setBoldPartFromTerm(_ text: String) -> NSAttributedString {
        let attributedString = NSMutableAttributedString(string:self.string, attributes: [NSFontAttributeName:UIFont.systemFont(ofSize: 15.0)])
        let boldFontAttribute = [NSFontAttributeName: UIFont.boldSystemFont(ofSize: 15.0)]
        attributedString.addAttributes(boldFontAttribute, range:(self.string as NSString).range(of: text))
        return attributedString
    }
    
}
