//
//  SettingsViewModel.swift
//  LetGo
//
//  Created by Eli Kohen on 05/08/16.
//  Copyright © 2016 Ambatana. All rights reserved.
//

import RxSwift
import LGCoreKit
import CollectionVariable
import FBSDKShareKit


enum LetGoSetting {
    case InviteFbFriends
    case ChangePhoto(placeholder: UIImage?, avatarUrl: NSURL?)
    case ChangeUsername(name: String)
    case ChangeLocation(location: String)
    case MarketingNotifications(initialState: Bool, changeClosure: (Bool -> Void))
    case CreateCommercializer
    case ChangePassword
    case Help
    case LogOut
    case VersionInfo
}

struct SettingsSection {
    let title: String
    let settings: [LetGoSetting]
}

protocol SettingsViewModelDelegate: BaseViewModelDelegate {
    func vmOpenImagePick()
    func vmOpenFbAppInvite(content: FBSDKAppInviteContent)
}

class SettingsViewModel: BaseViewModel {

    weak var navigator: SettingsNavigator?
    weak var delegate: SettingsViewModelDelegate?

    let avatarLoadingProgress = Variable<Float?>(nil)
    let sections = Variable<[SettingsSection]>([])

    private let myUserRepository: MyUserRepository
    private let commercializerRepository: CommercializerRepository
    private let notificationsManager: NotificationsManager
    private let locationManager: LocationManager
    private let tracker: Tracker

    private let kLetGoUserImageSquareSize: CGFloat = 1024

    private let disposeBag = DisposeBag()

    private var commercializerEnabled: Bool {
        guard let countryCode = locationManager.currentPostalAddress?.countryCode else { return false }
        return !commercializerRepository.templatesForCountryCode(countryCode).isEmpty
    }


    convenience override init() {
        self.init(myUserRepository: Core.myUserRepository, commercializerRepository: Core.commercializerRepository,
                  locationManager: Core.locationManager, notificationsManager: NotificationsManager.sharedInstance,
                  tracker: TrackerProxy.sharedInstance)
    }

    init(myUserRepository: MyUserRepository, commercializerRepository: CommercializerRepository,
         locationManager: LocationManager, notificationsManager: NotificationsManager, tracker: Tracker) {
        self.myUserRepository = myUserRepository
        self.commercializerRepository = commercializerRepository
        self.locationManager = locationManager
        self.notificationsManager = notificationsManager
        self.tracker = tracker

        super.init()

        setupRx()
    }

    override func didBecomeActive(firstTime: Bool) {
        super.didBecomeActive(firstTime)
        if firstTime {
            tracker.trackEvent(TrackerEvent.profileEditStart())
        }
    }


    // MARK: - Public

    var sectionCount: Int {
        return sections.value.count
    }

    func sectionTitle(section: Int) -> String {
        guard 0..<sections.value.count ~= section else { return "" }
        return sections.value[section].title
    }

    func settingsCount(section: Int) -> Int {
        guard 0..<sections.value.count ~= section else { return 0 }
        return sections.value[section].settings.count
    }

    func settingAtSection(section: Int, index: Int) -> LetGoSetting? {
        guard 0..<sections.value.count ~= section else { return nil }
        guard 0..<sections.value[section].settings.count ~= index else { return nil }
        return sections.value[section].settings[index]
    }

    func settingSelectedAtSection(section: Int, index: Int) {
        guard let setting = settingAtSection(section, index: index) else { return }
        settingSelected(setting)
    }

    func imageSelected(image: UIImage) {
        avatarLoadingProgress.value = 0.0

        let size = CGSizeMake(kLetGoUserImageSquareSize, kLetGoUserImageSquareSize)
        let resizedImage = image.resizedImageWithContentMode( .ScaleAspectFill, size: size,
            interpolationQuality: .Medium) ?? image
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
        let trackerEvent = TrackerEvent.appInviteFriendCancel(.Facebook, typePage: .Settings)
        TrackerProxy.sharedInstance.trackEvent(trackerEvent)
    }

    func fbAppInviteDone() {
        let trackerEvent = TrackerEvent.appInviteFriendComplete(.Facebook, typePage: .Settings)
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
        promoteSettings.append(.InviteFbFriends)
        if commercializerEnabled {
            promoteSettings.append(.CreateCommercializer)
        }
        settingSections.append(SettingsSection(title: LGLocalizedString.settingsSectionPromote, settings: promoteSettings))

        var profileSettings = [LetGoSetting]()
        let myUser = myUserRepository.myUser
        let placeholder = LetgoAvatar.avatarWithColor(UIColor.defaultAvatarColor, name: myUser?.name)
        profileSettings.append(.ChangePhoto(placeholder: placeholder, avatarUrl: myUser?.avatar?.fileURL))
        profileSettings.append(.ChangeUsername(name: myUser?.name ?? ""))
        profileSettings.append(.ChangeLocation(location: myUser?.postalAddress.city ?? myUser?.postalAddress.state ??
            myUser?.postalAddress.countryCode ?? ""))
        if let email = myUser?.email where email.isEmail() {
            profileSettings.append(.ChangePassword)
        }
        profileSettings.append(.MarketingNotifications(initialState: notificationsManager.marketingNotifications.value,
            changeClosure: { [weak self] enabled in self?.setMarketingNotifications(enabled) } ))
        settingSections.append(SettingsSection(title: LGLocalizedString.settingsSectionProfile, settings: profileSettings))

        var supportSettings = [LetGoSetting]()
        supportSettings.append(.Help)
        settingSections.append(SettingsSection(title: LGLocalizedString.settingsSectionSupport, settings: supportSettings))

        var logoutAndInfo = [LetGoSetting]()
        logoutAndInfo.append(.LogOut)
        logoutAndInfo.append(.VersionInfo)
        settingSections.append(SettingsSection(title: "", settings: logoutAndInfo))
        sections.value = settingSections
    }

    private func settingSelected(setting: LetGoSetting) {
        switch (setting) {
        case .InviteFbFriends:
            let content = FBSDKAppInviteContent()
            content.appLinkURL = NSURL(string: Constants.facebookAppLinkURL)
            content.appInvitePreviewImageURL = NSURL(string: Constants.facebookAppInvitePreviewImageURL)
            delegate?.vmOpenFbAppInvite(content)
            let trackerEvent = TrackerEvent.appInviteFriend(.Facebook, typePage: .Settings)
            tracker.trackEvent(trackerEvent)
        case .ChangePhoto:
            delegate?.vmOpenImagePick()
        case .ChangeUsername:
            navigator?.openEditUserName()
        case .ChangeLocation:
            navigator?.openEditLocation()
        case .CreateCommercializer:
            navigator?.openCreateCommercials()
        case .ChangePassword:
            navigator?.openChangePassword()
        case .Help:
            navigator?.openHelp()
        case .LogOut:
            logoutUser()
        case .VersionInfo, .MarketingNotifications:
            break
        }
    }

    private func logoutUser() {
        tracker.trackEvent(TrackerEvent.logout())
        Core.sessionManager.logout()
    }

    private func setupRx() {
        myUserRepository.rx_myUser.asObservable().bindNext { [weak self] _ in
            self?.populateSettings()
        }.addDisposableTo(disposeBag)
    }

    private func setMarketingNotifications(enabled: Bool) {
        notificationsManager.marketingNotifications.value = enabled

        let event = TrackerEvent.MarketingPushNotifications(myUserRepository.myUser?.objectId,
                                                            enabled: enabled ? .True : .False)
        tracker.trackEvent(event)
    }
}
