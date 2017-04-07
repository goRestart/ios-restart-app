//
//  PushPermissionManager.swift
//  LetGo
//
//  Created by Juan Iglesias on 23/03/17.
//  Copyright © 2017 Ambatana. All rights reserved.
//

protocol PushPermissionsManager {

    var pushPermissionsSettingsMode: Bool { get }
    var pushNotificationActive: Bool { get }
    
    func shouldShowPushPermissionsAlertFromViewController(_ prePermissionType: PrePermissionType) -> Bool
    
    func showPushPermissionsAlert(prePermissionType type: PrePermissionType)
    
    func application(_ application: UIApplication,
                     didRegisterUserNotificationSettings notificationSettings: UIUserNotificationSettings)
    
    
    @discardableResult
    func showPrePermissionsViewFrom(_ viewController: UIViewController, type: PrePermissionType,
                                    completion: (() -> ())?) -> UIViewController?

}
