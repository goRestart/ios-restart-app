//
//  ProfileTabNavigator.swift
//  LetGo
//
//  Created by Albert Hernández López on 01/08/16.
//  Copyright © 2016 Ambatana. All rights reserved.
//

protocol ProfileTabNavigator: TabNavigator {
    func openSettings()
}

protocol SettingsNavigator: class {
    func showFbAppInvite()
    func openEditUserName()
    func openEditLocation()
    func openCreateCommercials()
    func openChangePassword()
    func openHelp()
}

protocol ChangeUsernameNavigator: class {
    func userNameSaved()
}

protocol ChangePasswordNavigator: class {
    func passwordSaved()
}

protocol EditLocationNavigator: class {
    func locationSaved()
}

protocol HelpNavigator: class {
    func openTerms(url: NSURL?)
    func openPrivacy(url: NSURL?)
}
