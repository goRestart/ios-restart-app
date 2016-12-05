//
//  UIView+Corners.swift
//  LetGo
//
//  Created by Eli Kohen on 14/11/2016.
//  Copyright © 2016 Ambatana. All rights reserved.
//

import Foundation

extension UIView {

    /*
     Helper to make the view rounded
     */
    var rounded: Bool {
        set {
            // XCode8 bug ->  http://stackoverflow.com/questions/39380128/ios-10-gm-with-xcode-8-gm-causes-views-to-disappear-due-to-roundedcorners-clip/39380129#39380129
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
            // XCode8 bug ->  http://stackoverflow.com/questions/39380128/ios-10-gm-with-xcode-8-gm-causes-views-to-disappear-due-to-roundedcorners-clip/39380129#39380129
            layoutIfNeeded()
            clipsToBounds = true
            layer.cornerRadius = newValue
        }
        get {
            return layer.cornerRadius
        }
    }
}
