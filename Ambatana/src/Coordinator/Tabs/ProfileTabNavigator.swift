//
//  ProfileTabNavigator.swift
//  LetGo
//
//  Created by Albert Hernández López on 01/08/16.
//  Copyright © 2016 Ambatana. All rights reserved.
//
import LGCoreKit

protocol ProfileTabNavigator: TabNavigator, PublicProfileNavigator {
    func openSettings()
    func openEditUserBio()
    func editListing(_ listing: Listing, pageType: EventParameterTypePage?)
    func openUserVerificationView()
    func closeProfile()
}

protocol PublicProfileNavigator: class {
    func openUserReport(source: EventParameterTypePage, userReportedId: String, rateData: RateUserData)
    func openListing(_ data: ListingDetailData,
                     source: EventParameterListingVisitSource,
                     actionOnFirstAppear: ProductCarouselActionOnFirstAppear)
}

protocol SettingsNavigator: class {
    func openEditUserName()
    func openEditEmail()
    func openEditLocation(withDistanceRadius distanceRadius: Int?)
    func openChangePassword()
    func openHelp()
    func closeSettings()
    func open(url: URL)
    func openEditUserBio()
    func openNotificationSettings()
}

protocol ChangeUsernameNavigator: class {
    func closeChangeUsername()
}

protocol ChangeEmailNavigator: class {
    func closeChangeEmail()
}

protocol EditLocationNavigator: class {
    func closeEditLocation()
}

protocol EditUserBioNavigator: class {
    func closeEditUserBio()
}

protocol NotificationSettingsNavigator: class {
    func closeNotificationSettings()
    func openSearchAlertsList()
    func openNotificationSettingsList(notificationSettingsType: NotificationSettingsType)
    func openNotificationSettingsListDetail(notificationSetting: NotificationSetting,
                                            notificationSettingsRepository: NotificationSettingsRepository)
}

protocol SearchAlertsListNavigator: class {
    func closeSearchAlertsList()
    func openSearch()
}

protocol VerifyUserEmailNavigator: class {
    func closeEmailVerification()
}

protocol UserVerificationNavigator: class {
    func closeUserVerification()
    func openEditUserBio()
    func openEmailVerification()
    func openPhoneNumberVerification()
}
