//
//  CGAffineTransform+LG.swift
//  LetGo
//
//  Created by Eli Kohen on 08/04/16.
//  Copyright © 2016 Ambatana. All rights reserved.
//

import Foundation

extension CGAffineTransform {

    static func commercializerVideoToFullScreenTransform(sourceFrame: CGRect) -> CGAffineTransform {
        let windowBounds = UIScreen.mainScreen().bounds
        let ty = windowBounds.center.y - sourceFrame.center.y
        var theTransform = CGAffineTransformMakeTranslation(0, ty)
        theTransform = CGAffineTransformRotate(theTransform, CGFloat(-M_PI_2))
        let dx = windowBounds.height / sourceFrame.width
        let dy = windowBounds.width / sourceFrame.height
        theTransform = CGAffineTransformScale(theTransform, dx, dy)
        return theTransform
    }
}
