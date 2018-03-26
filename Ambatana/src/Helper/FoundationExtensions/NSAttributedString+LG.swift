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
}
