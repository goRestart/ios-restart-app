//
//  MockApplication.swift
//  LetGo
//
//  Created by Albert Hernández López on 16/05/17.
//  Copyright © 2017 Ambatana. All rights reserved.
//

@testable import LetGoGodMode

class MockApplication: Application {
    var applicationState: UIApplicationState = .active
    var areRemoteNotificationsEnabled: Bool = false
    
    var registerForRemoteNotificationsCalled: Bool = false
    
    func registerForRemoteNotifications() {
        registerForRemoteNotificationsCalled = true
    }
}
