//
//  UIView+LG.swift
//  LetGo
//
//  Created by Nestor on 24/04/2017.
//  Copyright © 2017 Ambatana. All rights reserved.
//

import Foundation

extension UIView {
    
    var allSubviewsRecursively: [UIView] {
        return subviews + subviews.flatMap { $0.allSubviewsRecursively }
    }
    
    func firstSubview<T>(ofType type: T.Type) -> T? {
        return subviews(ofType: type)?.first
    }
    
    func subviews<T>(ofType type: T.Type) -> [T]? {
        return allSubviewsRecursively.compactMap { $0 as? T }
    }

    func convertToWindow(_ rect: CGRect) -> CGRect {
        return convert(rect, to: nil)
    }

    func removeAllGestureRecognizers() {
        gestureRecognizers?.forEach { removeGestureRecognizer($0) }
    }
}
