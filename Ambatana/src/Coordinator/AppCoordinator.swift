//
//  AppCoordinator.swift
//  LetGo
//
//  Created by AHL on 20/4/16.
//  Copyright © 2016 Ambatana. All rights reserved.
//

import LGCoreKit

class AppCoordinator: UITabBarControllerDelegate {
    let window: UIWindow
    
    let sessionManager: SessionManager
    
    init(window: UIWindow, sessionManager: SessionManager) {
        self.window = window
        self.sessionManager = sessionManager
    }
    
    func start() {
        let tabBarController = TabBarController()
        tabBarController.delegate = self
        window.rootViewController = tabBarController
        window.makeKeyAndVisible()
    }
}

extension AppCoordinator: UITabBarControllerDelegate {
    func tabBarController(tabBarController: UITabBarController,
        shouldSelectViewController viewController: UIViewController) -> Bool {
            guard let tab = AppCoordinator.tabInController(tabBarController, forVC: viewController) else { return false }
            let topVC = AppCoordinator.topViewControllerInController(viewController)
            
            if let scrollable = navVC.topViewController as? ScrollableToTop
                where tabBarController.selectedViewController == viewController {
                    topVC.scrollToTop()
            }
            
            if let navVC = viewController as? UINavigationController, topVC = navVC.topViewController as? ScrollableToTop
                where selectedViewController == viewController {
                    topVC.scrollToTop()
            }
            
            let shouldOpenLogin = tab.logInRequired && !sessionManager.loggedIn
            if let source = tab.logInSource where shouldOpenLogin {
                openLogin(.FullScreen, source: source, afterLogInSuccessful: { [weak self] in
                    self?.tabBarCtl.switchToTab(tab)
                })
            }
            return !shouldOpenLogin
    }
}

extension AppCoordinator {
    private static func tabInController(tabBarController: UITabBarController, forVC vc: UIViewController) -> Tab? {
        guard let viewControllers = tabBarController.viewControllers else { return nil }
        let parent = vc.navigationController ?? vc
        let vcIdx = (viewControllers as NSArray).indexOfObject(parent)
        return tab
    }
    private static func topViewControllerInController(controller: UIViewController) -> UIViewController {
        if let navCtl = controller as? UIViewNavigationController {
            return navCtl.topViewController
        }
        return controller
    }
    private func openLogin(style: LoginStyle, source: EventParameterLoginSourceValue,
        afterLogInSuccessful: () -> ()) {
            let viewModel = SignUpViewModel(source: source)
            switch loginStyle {
            case .FullScreen:
                let vc = MainSignUpViewController(viewModel: viewModel)
                vc.afterLoginAction = afterLogInAction
                let navCtl = UINavigationController(rootViewController: vc)
                navCtl.view.backgroundColor = UIColor.whiteColor()
                tabCtl.presentViewController(navCtl, animated: true, completion: nil)
            case .Popup(let message):
                let vc = PopupSignUpViewController(viewModel: viewModel, topMessage: message)
                vc.preDismissAction = preDismissAction
                vc.afterLoginAction = afterLogInAction
                tabCtl.presentViewController(vc, animated: true, completion: nil)
            }
    }
}

private extension Tab {
    var logInRequired: Bool {
        switch self {
        case .Home, .Categories, .Sell:
            return false
        case .Chats, .Profile:
            return true
        }
    }
    var logInSource: EventParameterLoginSourceValue? {
        switch self {
        case .Home, .Categories, .Sell:
            return nil
        case .Chats:
            return .Chats
        case .Profile:
            return .Profile
        }
    }
}