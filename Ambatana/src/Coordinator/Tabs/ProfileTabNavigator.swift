//
//  ProfileTabNavigator.swift
//  LetGo
//
//  Created by Albert Hernández López on 01/08/16.
//  Copyright © 2016 Ambatana. All rights reserved.
//

import FBSDKShareKit

protocol ProfileTabNavigator: TabNavigator {
    func openSettings()
}

protocol SettingsNavigator: class {
    func showFbAppInvite(_ content: FBSDKAppInviteContent, delegate: FBSDKAppInviteDialogDelegate)
    func openEditUserName()
    func openEditEmail()
    func openEditLocation(withDistanceRadius distanceRadius: Int?)
    func openChangePassword()
    func openHelp()
    func closeSettings()
}

protocol ChangeUsernameNavigator: class {
    func closeChangeUsername()
}

protocol ChangeEmailNavigator: class {
    func closeChangeEmail()
}

protocol ChangePasswordNavigator: class {
    func closeChangePassword()
}

protocol EditLocationNavigator: class {
    func closeEditLocation()
}

protocol HelpNavigator: class {
    func closeHelp()
    func open(url: URL)
}
