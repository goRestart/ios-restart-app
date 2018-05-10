//
//  LGAnimation.swift
//  LetGo
//
//  Created by Nestor on 01/03/2018.
//  Copyright © 2018 Ambatana. All rights reserved.
//

import Foundation

extension UIView {
    func animateTo(alpha: CGFloat, duration: TimeInterval = 0.2, completion: ((Bool) -> Void)? = nil) {
        layoutIfNeeded()
        UIView.animate(withDuration: duration, animations: { [weak self] in
            self?.alpha = alpha
            }, completion: completion)
    }
}
