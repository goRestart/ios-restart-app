//
//  NSAttributedString+LG.swift
//  LetGo
//
//  Created by Facundo Menzella on 22/03/2018.
//  Copyright © 2018 Ambatana. All rights reserved.
//

import Foundation

extension NSAttributedString {
    
    var stringByRemovingLinks: NSAttributedString {
        let withoutLinks = NSMutableAttributedString(attributedString: self)
        let range = NSMakeRange(0, withoutLinks.length)
        withoutLinks.removeAttribute(.link, range: range)
        return withoutLinks
    }
    
    func height(forContainerWidth containerWidth: CGFloat,
                maxLines: Int?,
                withFont font: UIFont) -> CGFloat {
        let rect = self.boundingRect(with: CGSize.init(width: containerWidth,
                                                       height: CGFloat.greatestFiniteMagnitude), options: [.usesLineFragmentOrigin, .usesFontLeading], context: nil)
        
        let resultHeight = rect.height
        let charSize = CGFloat(font.lineHeight)
        let lineCount: CGFloat = resultHeight/charSize
        
        let finalHeight: CGFloat
        let interLineSpace: CGFloat
        if let maxLines = maxLines, lineCount > CGFloat(maxLines) {
            finalHeight = CGFloat(maxLines) * charSize
            interLineSpace = CGFloat(maxLines)
        } else {
            finalHeight = resultHeight
            interLineSpace = lineCount
        }
        return finalHeight + interLineSpace
    }
}
