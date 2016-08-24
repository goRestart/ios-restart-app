//
//  AccessibilityId.swift
//  LetGo
//
//  Created by Albert Hernández López on 23/08/16.
//  Copyright © 2016 Ambatana. All rights reserved.
//

/**
 Defines the accessibility identifiers used for automated UI testing. The format is the following:
    case <screen><element-name>
 
 i.e:
    case SignUpLoginEmailButton
 */
enum AccessibilityId: String {
    case EraseMe

    /** ABIOS-1554 */
    // ...

    /** ABIOS-1555 */
    // ...

    /** ABIOS-1556 */
    // ...

    /** ABIOS-1557 */
    // TourLogin
    case TourLoginCloseButton
    case TourLoginSignUpButton
    case TourLoginLogInButton
    case TourLoginSkipButton

    // TourNotifications
    case TourNotificationsCloseButton
    case TourNotificationsOKButton
    case TourNotificationsCancelButton

    // TourLocation
    case TourLocationCloseButton
    case TourLocationOKButton
    case TourLocationCancelButton

    // User
    case UserNavBarSettingsButton
    case UserNavBarMoreButton
    case UserHeaderCollapsedNameLabel
    case UserHeaderCollapsedLocationLabel
    case UserHeaderExpandedNameLabel
    case UserHeaderExpandedLocationLabel
    case UserHeaderExpandedAvatarButton
    case UserHeaderExpandedVerifyFacebookButton
    case UserHeaderExpandedVerifyGoogleButton
    case UserHeaderExpandedVerifyEmailButton
    case UserEnableNotificationsButton
    case UserSellingTab
    case UserSoldTab
    case UserFavoritesTab
    case UserProductsFirstLoad
    case UserProductsList
    case UserProductsError
    case UserPushPermissionOK
    case UserPushPermissionCancel

    // Settings
    case SettingsList

    // ChangeUsername
    case ChangeUsernameNameTextfield
    case ChangeUsernameSendButton

    // ChangePassword
    case ChangePasswordPwdTextfield
    case ChangePasswordPwdConfirmTextfield
    case ChangePasswordSendButton

    // Help
    case HelpWebView

}

extension UIAccessibilityIdentification {
    var accessibilityId: AccessibilityId? {
        get {
            guard let accessibilityIdentifier = accessibilityIdentifier else { return nil }
            return AccessibilityId(rawValue: accessibilityIdentifier)
        }
        set {
            accessibilityIdentifier = newValue?.rawValue
        }
    }
}
