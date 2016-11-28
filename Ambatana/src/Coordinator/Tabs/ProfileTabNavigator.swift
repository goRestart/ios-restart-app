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
    func showFbAppInvite(content: FBSDKAppInviteContent)
    func openEditUserName()
    func openEditLocation()
    func openCreateCommercials()
    func openChangePassword()
    func openHelp()
    func closeSettings()
}

protocol ChangeUsernameNavigator: class {
    func closeChangeUsername()
    func userNameSaved()
}

protocol ChangePasswordNavigator: class {
    func closeChangePassword()
    func passwordSaved()
}

protocol EditLocationNavigator: class {
    func closeEditLocation()
    func locationSaved()
}

protocol HelpNavigator: class {
    func closeHelp()
    func openTerms(url: NSURL)
    func openPrivacy(url: NSURL)
}
