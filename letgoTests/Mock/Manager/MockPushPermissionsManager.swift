@testable import LetGoGodMode

final class MockPushPermissionsManager: PushPermissionsManager {
    var pushPermissionsSettingsMode: Bool = true
    var pushNotificationActive: Bool = true
    var didRegisterUserNotificationSettingsCalled = false
    
    func shouldShowPushPermissionsAlertFromViewController(_ prePermissionType: PrePermissionType) -> Bool { return true}
    
    func showPushPermissionsAlert(prePermissionType type: PrePermissionType) { }
    
    func application(_ application: Application,
                     didRegisterUserNotificationSettings notificationSettings: UIUserNotificationSettings) {
        didRegisterUserNotificationSettingsCalled = true
    }
    
    
    @discardableResult
    func showPrePermissionsViewFrom(_ viewController: UIViewController, type: PrePermissionType) -> UIViewController? {
        return nil
    }
}
