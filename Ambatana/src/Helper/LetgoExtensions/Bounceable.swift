//
//  Bounceable.swift
//  LetGo
//
//  Created by Facundo Menzella on 22/11/2017.
//  Copyright © 2017 Ambatana. All rights reserved.
//

import Foundation
import UIKit

protocol Bounceable {
    func bounce(withCompletionBlock completionBlock: @escaping () -> ())
    func bounce()
}

extension UIView: Bounceable {

    func bounce() {
        transform = CGAffineTransform(scaleX: 0.8, y: 0.8)
        UIView.animate(withDuration: 0.3,
                       delay: 0,
                       usingSpringWithDamping: 0.2,
                       initialSpringVelocity: 6.0,
                       options: .allowUserInteraction,
                       animations: { [weak self] in
                        self?.transform = .identity
        })
    }

    func bounce(withCompletionBlock completionBlock: @escaping () -> ()) {
            transform = CGAffineTransform(scaleX: 0.8, y: 0.8)
            UIView.animate(withDuration: 0.3,
                           delay: 0,
                           usingSpringWithDamping: 0.2,
                           initialSpringVelocity: 6.0,
                           options: .allowUserInteraction,
                           animations: { [weak self] in
                            self?.transform = .identity
            },
                           completion: { completion in
                            completionBlock()
            })
            
        }
}
