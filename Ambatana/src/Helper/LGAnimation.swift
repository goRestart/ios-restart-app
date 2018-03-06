//
//  LGAnimation.swift
//  LetGo
//
//  Created by Nestor on 01/03/2018.
//  Copyright © 2018 Ambatana. All rights reserved.
//

import Foundation

extension UIView {
    func alphaAnimated(_ alpha: CGFloat, duration: TimeInterval = 0.2) {
        layoutIfNeeded()
        UIView.animate(withDuration: duration) { [weak self] in
            self?.alpha = alpha
        }
    }
}
