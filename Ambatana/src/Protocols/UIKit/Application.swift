
//
//  Application.swift
//  LetGo
//
//  Created by Albert Hernández López on 16/05/17.
//  Copyright © 2017 Ambatana. All rights reserved.
//

import UIKit

protocol Application {
    var applicationState: UIApplicationState { get }
    
    // Push notifications
    var areRemoteNotificationsEnabled: Bool { get }
    func registerForRemoteNotifications()
}

extension UIApplication: Application {}
