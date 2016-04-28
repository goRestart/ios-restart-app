//
//  AppCoordinatorType.swift
//  LetGo
//
//  Created by Albert Hernández López on 27/04/16.
//  Copyright © 2016 Ambatana. All rights reserved.
//

import Foundation
import RxSwift

protocol AppCoordinatorType: CoordinatorType, UITabBarControllerDelegate {
    var window: UIWindow { get }
    var tabBarCtl: TabBarController { get }

//    var homeCoordinator: CoordinatorType { get }
//    var categoriesCoordinator: CoordinatorType { get }
//    var chatCoordinator: CoordinatorType { get }
//    var profileCoordinator: CoordinatorType { get }

    func open()
    func openForceUpdateDialogIfNeeded()
    func openSell()
}
