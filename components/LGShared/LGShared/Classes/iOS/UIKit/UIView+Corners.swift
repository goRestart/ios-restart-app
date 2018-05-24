//
//  UIView+Corners.swift
//  LetGo
//
//  Created by Eli Kohen on 14/11/2016.
//  Copyright © 2016 Ambatana. All rights reserved.
//

import UIKit

extension UIView {
    /*
     Helper to make the view rounded
     */
    func setRoundedCorners() {
        clipsToBounds = true
        layer.cornerRadius =  min(bounds.size.height, bounds.size.width) / 2.0
    }

    /*
     Helper to set corner radius
     */
    var cornerRadius: CGFloat {
        set {
            clipsToBounds = true
            layer.cornerRadius = newValue
        }
        get {
            return layer.cornerRadius
        }
    }
}
