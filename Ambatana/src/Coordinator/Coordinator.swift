//
//  Coordinator.swift
//  LetGo
//
//  Created by AHL on 20/4/16.
//  Copyright © 2016 Ambatana. All rights reserved.
//

import UIKit

protocol Coordinator: class {
    var children: [Coordinator] { get set }
    var viewController: UIViewController { get }

    func openChild(coordinator: Coordinator, animated: Bool, completion: (() -> Void)?)
    func closeChild(coordinator: Coordinator, animated: Bool, completion: (() -> Void)?)
}

extension Coordinator {
    func openChild(coordinator: Coordinator, animated: Bool = true, completion: (() -> Void)? = nil) {
        children.append(coordinator)
        viewController.presentViewController(coordinator.viewController, animated: animated, completion: completion)
    }
    
    func closeChild(coordinator: Coordinator, animated: Bool = true, completion: (() -> Void)? = nil) {
        guard let index = children.indexOf({ $0 === coordinator }) else { return }

        let lastIndex = children.count - 1
        (index...lastIndex).reverse().forEach { i in
            let child = children[i]
            if i == index {
                child.viewController.dismissViewControllerAnimated(animated, completion: completion)
            } else {
                child.viewController.dismissViewControllerAnimated(false, completion: nil)
            }
        }
    }
}
