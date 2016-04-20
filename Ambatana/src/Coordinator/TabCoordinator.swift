//
//  TabCoordinator.swift
//  LetGo
//
//  Created by AHL on 20/4/16.
//  Copyright © 2016 Ambatana. All rights reserved.
//

import Foundation

protocol TabCoordinatorDelegate: class {
    func willOpenController(viewController: UIViewController, atTab tab: Tab)
    func didOpenController(viewController: UIViewController, atTab tab: Tab)
}

class TabCoordinator {
    weak var delegate: TabCoordinatorDelegate?
}