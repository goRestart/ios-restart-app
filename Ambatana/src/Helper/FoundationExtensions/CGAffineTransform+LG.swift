//
//  CGAffineTransform+LG.swift
//  LetGo
//
//  Created by Eli Kohen on 08/04/16.
//  Copyright © 2016 Ambatana. All rights reserved.
//

import Foundation

extension CGAffineTransform {

    static func commercializerVideoToFullScreenTransform(_ sourceFrame: CGRect) -> CGAffineTransform {
        let windowBounds = UIScreen.main.bounds
        let ty = windowBounds.center.y - sourceFrame.center.y
        var theTransform = CGAffineTransform(translationX: 0, y: ty)
        theTransform = theTransform.rotated(by: CGFloat(-M_PI_2))
        let dx = windowBounds.height / sourceFrame.width
        let dy = windowBounds.width / sourceFrame.height
        theTransform = theTransform.scaledBy(x: dx, y: dy)
        return theTransform
    }
}
