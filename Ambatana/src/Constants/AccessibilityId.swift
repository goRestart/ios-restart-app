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
    case NotificationsRefresh
    case NotificationsTable
    case NotificationsLoading
    case NotificationsEmptyView
    case NotificationsCellPrimaryImage
    case NotificationsCellSecondaryImage

    /** ABIOS-1556 */
    // ...

    /** ABIOS-1557 */
    // ...
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
