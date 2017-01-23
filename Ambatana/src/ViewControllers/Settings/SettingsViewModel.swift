//
//  SettingsViewModel.swift
//  LetGo
//
//  Created by Eli Kohen on 05/08/16.
//  Copyright © 2016 Ambatana. All rights reserved.
//

import RxSwift
import LGCoreKit
import FBSDKShareKit


enum LetGoSetting {
    case inviteFbFriends
    case changePhoto(placeholder: UIImage?, avatarUrl: URL?)
    case changeUsername(name: String)
    case changeLocation(location: String)
    case marketingNotifications(switchValue: Variable<Bool>, changeClosure: ((Bool) -> Void))
    case createCommercializer
    case changePassword
    case help
    case logOut
    case versionInfo
}

struct SettingsSection {
    let title: String
    let settings: [LetGoSetting]
}

protocol SettingsViewModelDelegate: BaseViewModelDelegate {
    func vmOpenImagePick()
}

class SettingsViewModel: BaseViewModel {

    weak var navigator: SettingsNavigator?
    weak var delegate: SettingsViewModelDelegate?

    let avatarLoadingProgress = Variable<Float?>(nil)
    let sections = Variable<[SettingsSection]>([])
    let switchMarketingNotificationValue = Variable<Bool>(true)

    private let myUserRepository: MyUserRepository
    private let commercializerRepository: CommercializerRepository
    private let notificationsManager: NotificationsManager
    private let locationManager: LocationManager
    private let tracker: Tracker
    private let pushPermissionManager: PushPermissionsManager

    private let kLetGoUserImageSquareSize: CGFloat = 1024

    private let disposeBag = DisposeBag()

    private var commercializerEnabled: Bool {
        guard let countryCode = locationManager.currentPostalAddress?.countryCode else { return false }
        return !commercializerRepository.templatesForCountryCode(countryCode).isEmpty
    }


    convenience override init() {
        self.init(myUserRepository: Core.myUserRepository, commercializerRepository: Core.commercializerRepository,
                  locationManager: Core.locationManager, notificationsManager: NotificationsManager.sharedInstance,
                  tracker: TrackerProxy.sharedInstance, pushPermissionManager: PushPermissionsManager.sharedInstance)
    }

    init(myUserRepository: MyUserRepository, commercializerRepository: CommercializerRepository,
         locationManager: LocationManager, notificationsManager: NotificationsManager, tracker: Tracker,
         pushPermissionManager: PushPermissionsManager) {
        self.myUserRepository = myUserRepository
        self.commercializerRepository = commercializerRepository
        self.locationManager = locationManager
        self.notificationsManager = notificationsManager
        self.tracker = tracker
        self.pushPermissionManager = pushPermissionManager
        super.init()

        setupRx()
    }

    override func didBecomeActive(_ firstTime: Bool) {
        super.didBecomeActive(firstTime)
        if firstTime {
            tracker.trackEvent(TrackerEvent.profileEditStart())
        }
        switchMarketingNotificationValue.value = pushPermissionManager.pushNotificationActive && notificationsManager.marketingNotifications.value
    }
    
    override func backButtonPressed() -> Bool {
        navigator?.closeSettings()
        return true
    }


    // MARK: - Public

    var sectionCount: Int {
        return sections.value.count
    }

    func sectionTitle(_ section: Int) -> String {
        guard 0..<sections.value.count ~= section else { return "" }
        return sections.value[section].title
    }

    func settingsCount(_ section: Int) -> Int {
        guard 0..<sections.value.count ~= section else { return 0 }
        return sections.value[section].settings.count
    }

    func settingAtSection(_ section: Int, index: Int) -> LetGoSetting? {
        guard 0..<sections.value.count ~= section else { return nil }
        guard 0..<sections.value[section].settings.count ~= index else { return nil }
        return sections.value[section].settings[index]
    }

    func settingSelectedAtSection(_ section: Int, index: Int) {
        guard let setting = settingAtSection(section, index: index) else { return }
        settingSelected(setting)
    }

    func imageSelected(_ image: UIImage) {
        avatarLoadingProgress.value = 0.0

        let size = CGSize(width: kLetGoUserImageSquareSize, height: kLetGoUserImageSquareSize)
        let resizedImage = image.resizedImageWithContentMode( .scaleAspectFill, size: size,
            interpolationQuality: .medium) ?? image
        let croppedImage = resizedImage.croppedCenteredImage() ?? resizedImage
        guard let imageData = UIImageJPEGRepresentation(croppedImage, 0.9) else { return }

        Core.myUserRepository.updateAvatar(imageData,
            progressBlock: { [weak self] progressAsInt in
                self?.avatarLoadingProgress.value = Float(progressAsInt) / 100.0
            },
            completion: { [weak self] updateResult in
                self?.avatarLoadingProgress.value = nil
                if let _ = updateResult.value {
                    self?.populateSettings()
                    self?.tracker.trackEvent(TrackerEvent.profileEditEditPicture())
                } else {
                    self?.delegate?.vmShowAutoFadingMessage(LGLocalizedString.settingsChangeProfilePictureErrorGeneric,
                        completion: nil)
                }
            }
        )
    }

    func fbAppInviteCancel() {
        let trackerEvent = TrackerEvent.appInviteFriendCancel(.facebook, typePage: .settings)
        TrackerProxy.sharedInstance.trackEvent(trackerEvent)
    }

    func fbAppInviteDone() {
        let trackerEvent = TrackerEvent.appInviteFriendComplete(.facebook, typePage: .settings)
        TrackerProxy.sharedInstance.trackEvent(trackerEvent)

        delegate?.vmShowAutoFadingMessage(LGLocalizedString.settingsInviteFacebookFriendsOk, completion: nil)
    }

    func fbAppInviteFailed() {
        delegate?.vmShowAutoFadingMessage(LGLocalizedString.settingsInviteFacebookFriendsError, completion: nil)
    }


    // MARK: - Private

    private func populateSettings() {
        var settingSections = [SettingsSection]()

        var promoteSettings = [LetGoSetting]()
        promoteSettings.append(.inviteFbFriends)
        if commercializerEnabled {
            promoteSettings.append(.createCommercializer)
        }
        settingSections.append(SettingsSection(title: LGLocalizedString.settingsSectionPromote, settings: promoteSettings))

        var profileSettings = [LetGoSetting]()
        let myUser = myUserRepository.myUser
        let placeholder = LetgoAvatar.avatarWithColor(UIColor.defaultAvatarColor, name: myUser?.name)
        profileSettings.append(.changePhoto(placeholder: placeholder, avatarUrl: myUser?.avatar?.fileURL))
        profileSettings.append(.changeUsername(name: myUser?.name ?? ""))
        profileSettings.append(.changeLocation(location: myUser?.postalAddress.city ?? myUser?.postalAddress.state ??
            myUser?.postalAddress.countryCode ?? ""))
        if let email = myUser?.email, email.isEmail() {
            profileSettings.append(.changePassword)
        }
        profileSettings.append(.marketingNotifications(switchValue: switchMarketingNotificationValue,
            changeClosure: { [weak self] enabled in self?.checkMarketingNotifications(enabled) } ))
        settingSections.append(SettingsSection(title: LGLocalizedString.settingsSectionProfile, settings: profileSettings))

        var supportSettings = [LetGoSetting]()
        supportSettings.append(.help)
        settingSections.append(SettingsSection(title: LGLocalizedString.settingsSectionSupport, settings: supportSettings))

        var logoutAndInfo = [LetGoSetting]()
        logoutAndInfo.append(.logOut)
        logoutAndInfo.append(.versionInfo)
        settingSections.append(SettingsSection(title: "", settings: logoutAndInfo))
        sections.value = settingSections
    }

    private func settingSelected(_ setting: LetGoSetting) {
        switch (setting) {
        case .inviteFbFriends:
            let content = FBSDKAppInviteContent()
            content.appLinkURL = URL(string: Constants.facebookAppLinkURL)
            content.appInvitePreviewImageURL = URL(string: Constants.facebookAppInvitePreviewImageURL)
            guard let delegate = delegate as? FBSDKAppInviteDialogDelegate else { return }
            navigator?.showFbAppInvite(content, delegate: delegate)
            let trackerEvent = TrackerEvent.appInviteFriend(.facebook, typePage: .settings)
            tracker.trackEvent(trackerEvent)
        case .changePhoto:
            delegate?.vmOpenImagePick()
        case .changeUsername:
            navigator?.openEditUserName()
        case .changeLocation:
            navigator?.openEditLocation()
        case .createCommercializer:
            navigator?.openCreateCommercials()
        case .changePassword:
            navigator?.openChangePassword()
        case .help:
            navigator?.openHelp()
        case .logOut:
            let positive = UIAction(interface: .styledText(LGLocalizedString.settingsLogoutAlertOk, .standard),
                                    action: { [weak self] in
                    self?.logoutUser()
                }, accessibilityId: .settingsLogoutAlertOK)

            let negative = UIAction(interface: .styledText(LGLocalizedString.commonCancel, .cancel),
                                    action: {}, accessibilityId: .settingsLogoutAlertCancel)
            delegate?.vmShowAlertWithTitle(nil, text: LGLocalizedString.settingsLogoutAlertMessage,
                                           alertType: .plainAlert, actions: [positive, negative])
        case .versionInfo, .marketingNotifications:
            break
        }
    }

    private func logoutUser() {
        tracker.trackEvent(TrackerEvent.logout())
        Core.sessionManager.logout()
    }

    private func setupRx() {
        myUserRepository.rx_myUser.bindNext { [weak self] _ in
            self?.populateSettings()
        }.addDisposableTo(disposeBag)
    }

    private func checkMarketingNotifications(_ enabled: Bool) {
        if enabled {
            showPrePermissionsIfNeeded()
        } else {
            showDeactivateConfirmation()
        }

    }
    
    private func setMarketingNotification(enabled: Bool) {
        notificationsManager.marketingNotifications.value = enabled
        let event = TrackerEvent.marketingPushNotifications(myUserRepository.myUser?.objectId, enabled: enabled)
        tracker.trackEvent(event)
    }
    
    private func showPrePermissionsIfNeeded() {
        guard !pushPermissionManager.pushNotificationActive else {
            setMarketingNotification(enabled: true)
            return
        }
        let cancelAction = UIAction(
            interface: .button(LGLocalizedString.settingsMarketingNotificationsAlertCancel, .secondary(fontSize: .medium, withBorder: true)),
            action: { [weak self] in
                self?.forceMarketingNotifications(enabled: false)
        })
        let  activateAction = UIAction(
            interface: .button(LGLocalizedString.settingsMarketingNotificationsAlertActivate, .primary(fontSize: .medium)),
            action: { [weak self] in
                self?.setMarketingNotification(enabled: true)
                self?.pushPermissionManager.showPushPermissionsAlert(prePermissionType: .profile)
        })
        
        delegate?.vmShowAlertWithTitle(nil, text: LGLocalizedString.settingsGeneralNotificationsAlertMessage,
                                       alertType: .plainAlert, actions: [cancelAction, activateAction])
    }
    
    private func showDeactivateConfirmation() {
        let cancelAction = UIAction(
            interface: .button(LGLocalizedString.settingsMarketingNotificationsAlertCancel, .secondary(fontSize: .medium, withBorder: true)),
            action: { [weak self] in
                self?.forceMarketingNotifications(enabled: true)
        })
        let  deactivateAction = UIAction(
            interface: .button(LGLocalizedString.settingsMarketingNotificationsAlertDeactivate, .secondary(fontSize: .medium, withBorder: true)),
            action: { [weak self] in
                self?.setMarketingNotification(enabled: false)
        })
        
        delegate?.vmShowAlertWithTitle(nil, text: LGLocalizedString.settingsMarketingNotificationsAlertMessage,
                                       alertType: .plainAlert, actions: [cancelAction, deactivateAction])
    }
    
    private func forceMarketingNotifications(enabled: Bool) {
        notificationsManager.marketingNotifications.value = enabled
        switchMarketingNotificationValue.value = enabled
    }
}
