//
//  MockPushPermissionManager.swift
//  LetGo
//
//  Created by Juan Iglesias on 23/03/17.
//  Copyright © 2017 Ambatana. All rights reserved.
//


@testable import LetGoGodMode

struct MockPushPermissionsManager: PushPermissionsManager {
    
    var pushPermissionsSettingsMode: Bool = true
    var pushNotificationActive: Bool = true
    
    func shouldShowPushPermissionsAlertFromViewController(_ prePermissionType: PrePermissionType) -> Bool { return true}
    
    func showPushPermissionsAlert(prePermissionType type: PrePermissionType) { }
    
    func application(_ application: UIApplication,
                     didRegisterUserNotificationSettings notificationSettings: UIUserNotificationSettings) { }
    
    
    @discardableResult
    func showPrePermissionsViewFrom(_ viewController: UIViewController, type: PrePermissionType,
                                    completion: (() -> ())?) -> UIViewController? { return nil }
}
