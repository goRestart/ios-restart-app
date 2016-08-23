//
//  AccessibilityId.swift
//  LetGo
//
//  Created by Albert Hernández López on 23/08/16.
//  Copyright © 2016 Ambatana. All rights reserved.
//

/**
 Defines the accessibility identifiers used for automated UI testing. The format is the following:
    <screen><element-name> = "<element-name>"
 
 i.e:
    static var SignUpLoginEmailButton = "EmailButton"
 */
struct AccessibilityId {
    /** ABIOS-1554 */
    // ...

    /** ABIOS-1555 */
    // ...
    static var NotificationsRefresh = "Refresh"
    static var NotificationsTable = "Table"
    static var NotificationsLoading = "Loading"
    static var NotificationsEmptyView = "EmptyView"
    static var NotificationsCellPrimaryImage = "CellPrimaryImage"
    static var NotificationsCellSecondaryImage = "CellSecondaryImage"

    /** ABIOS-1556 */
    // ...

    /** ABIOS-1557 */
    // ...
}
