//
//  BaseCoordinator.swift
//  LetGo
//
//  Created by Nestor Garcia on 05/12/2016.
//  Copyright © 2016 Ambatana. All rights reserved.
//

import UIKit

class BaseCoordinator: NSObject {
    
    weak var viewController: UIViewController?
    
    fileprivate let bubbleNotificationManager: BubbleNotificationManager
    
    init(viewController: UIViewController, bubbleNotificationManager: BubbleNotificationManager) {
        self.viewController = viewController
        self.bubbleNotificationManager = bubbleNotificationManager
        super.init()
    }
}

extension BaseCoordinator: BaseNavigator {
    func showBubble(with data: BubbleNotificationData, duration: TimeInterval) {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { return }
        guard let window = appDelegate.window else { return }
        bubbleNotificationManager.showBubble(data, duration: duration, view: window)
    }
}
