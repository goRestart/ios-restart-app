//
//  UIImageView+Corners.swift
//  LetGo
//
//  Created by Eli Kohen on 21/10/2016.
//  Copyright © 2016 Ambatana. All rights reserved.
//

import Foundation

extension UIImageView {

    /*
     Helper to make the image rounded
     */
    var rounded: Bool {
        set {
            layoutIfNeeded()
            clipsToBounds = true
            layer.cornerRadius = newValue ? frame.size.height / 2 : 0
        }
        get {
            return layer.cornerRadius == frame.size.height / 2
        }
    }

    /*
     Helper to set corner radius
    */
    var cornerRadius: CGFloat {
        set {
            layoutIfNeeded()
            clipsToBounds = true
            layer.cornerRadius = newValue
        }
        get {
            return layer.cornerRadius
        }
    }
}
