//
//  UINavigationController+LG.swift
//  LetGo
//
//  Created by Albert Hernández López on 04/05/16.
//  Copyright © 2016 Ambatana. All rights reserved.
//

import UIKit

extension UINavigationController {
    var isAtRootViewController: Bool {
        return viewControllers.count <= 1
    }
}
