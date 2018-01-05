//
//  LGCGAffineTransform.swift
//  LetGo
//
//  Created by Facundo Menzella on 05/01/2018.
//  Copyright © 2018 Ambatana. All rights reserved.
//

import Foundation

/**
 *  For more information please check
 *  the apple docs https://developer.apple.com/documentation/coregraphics/cgaffinetransform
 */
extension CGAffineTransform {
    static var invertedVertically: CGAffineTransform { return CGAffineTransform(a: 1, b: 0,
                                                                                c: 0, d: -1,
                                                                                tx: 0, ty: 0) }
}
