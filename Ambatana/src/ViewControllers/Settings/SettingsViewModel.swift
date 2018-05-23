import RxSwift
import LGCoreKit
import LGComponents

enum LetGoSetting {
    case changePhoto(placeholder: UIImage?, avatarUrl: URL?)
    case changeEmail(email: String)
    case changeUsername(name: String)
    case changeLocation(location: String)
    case changeUserBio
    case marketingNotifications(switchValue: Variable<Bool>, changeClosure: ((Bool) -> Void))
    case changePassword
    case help
    case termsAndConditions
    case privacyPolicy
    case logOut
    case versionInfo
    case notifications
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
    private let notificationsManager: NotificationsManager
    private let tracker: Tracker
    private let pushPermissionManager: PushPermissionsManager
    private let featureFlags: FeatureFlags
    private let kLetGoUserImageSquareSize: CGFloat = 1024

    private let disposeBag = DisposeBag()

    private var termsAndConditionsURL: URL? {
        return LetgoURLHelper.buildTermsAndConditionsURL()
    }
    
    private var privacyURL: URL? {
        return LetgoURLHelper.buildPrivacyURL()
    }
    
    private var isSearchAlertsEnabled: Bool {
        return featureFlags.searchAlerts.isActive
    }
    
    convenience override init() {
        self.init(myUserRepository: Core.myUserRepository,
                  notificationsManager: LGNotificationsManager.sharedInstance,
                  tracker: TrackerProxy.sharedInstance,
                  pushPermissionManager: LGPushPermissionsManager.sharedInstance,
                  featureFlags: FeatureFlags.sharedInstance)
    }

    init(myUserRepository: MyUserRepository,
         notificationsManager: NotificationsManager,
         tracker: Tracker,
         pushPermissionManager: PushPermissionsManager,
         featureFlags: FeatureFlags) {
        self.myUserRepository = myUserRepository
        self.notificationsManager = notificationsManager
        self.tracker = tracker
        self.pushPermissionManager = pushPermissionManager
        self.featureFlags = featureFlags
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
                    self?.delegate?.vmShowAutoFadingMessage(R.Strings.settingsChangeProfilePictureErrorGeneric,
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

        delegate?.vmShowAutoFadingMessage(R.Strings.settingsInviteFacebookFriendsOk, completion: nil)
    }

    func fbAppInviteFailed() {
        delegate?.vmShowAutoFadingMessage(R.Strings.settingsInviteFacebookFriendsError, completion: nil)
    }


    // MARK: - Private

    private func populateSettings() {
        var settingSections = [SettingsSection]()

        var profileSettings = [LetGoSetting]()
        let myUser = myUserRepository.myUser
        let placeholder = LetgoAvatar.avatarWithColor(UIColor.defaultAvatarColor, name: myUser?.name)
        profileSettings.append(.changePhoto(placeholder: placeholder, avatarUrl: myUser?.avatar?.fileURL))
        profileSettings.append(.changeUsername(name: myUser?.name ?? ""))
        profileSettings.append(.changeEmail(email: myUser?.email ?? ""))
        
        var location: String = ""
        if let city = myUser?.postalAddress.city {
            location = city
        } else if let state = myUser?.postalAddress.state {
            location = state
        } else if let countryCode = myUser?.postalAddress.countryCode {
            location = countryCode
        }
        profileSettings.append(.changeLocation(location: location))
        profileSettings.append(.changeUserBio)

        if let email = myUser?.email, email.isEmail() {
            profileSettings.append(.changePassword)
        }
        
        if isSearchAlertsEnabled {
            profileSettings.append(.notifications)
        } else {
            profileSettings.append(.marketingNotifications(switchValue: switchMarketingNotificationValue,
                                                           changeClosure: { [weak self] enabled in
                                                            self?.checkMarketingNotifications(enabled) } ))
        }

        settingSections.append(SettingsSection(title: R.Strings.settingsSectionProfile, settings: profileSettings))

        var supportSettings = [LetGoSetting]()
        supportSettings.append(.help)
        supportSettings.append(.termsAndConditions)
        supportSettings.append(.privacyPolicy)
        settingSections.append(SettingsSection(title: R.Strings.settingsSectionSupport, settings: supportSettings))

        var logoutAndInfo = [LetGoSetting]()
        logoutAndInfo.append(.logOut)
        logoutAndInfo.append(.versionInfo)
        settingSections.append(SettingsSection(title: "", settings: logoutAndInfo))
        sections.value = settingSections
    }

    private func settingSelected(_ setting: LetGoSetting) {
        switch setting {
        case .changePhoto:
            delegate?.vmOpenImagePick()
        case .changeUsername:
            navigator?.openEditUserName()
        case .changeEmail:
            navigator?.openEditEmail()
        case .changeLocation:
            navigator?.openEditLocation(withDistanceRadius: nil)
        case .changePassword:
            navigator?.openChangePassword()
        case .help:
            navigator?.openHelp()
        case .changeUserBio:
            navigator?.openEditUserBio()
        case .termsAndConditions:
            guard let url = termsAndConditionsURL else { return }
            navigator?.open(url: url)
        case .privacyPolicy:
            guard let url = privacyURL else { return }
            navigator?.open(url: url)
        case .logOut:
            let positive = UIAction(interface: .styledText(R.Strings.settingsLogoutAlertOk, .standard),
                                    action: { [weak self] in
                    self?.logoutUser()
                }, accessibilityId: .settingsLogoutAlertOK)

            let negative = UIAction(interface: .styledText(R.Strings.commonCancel, .cancel),
                                    action: {}, accessibilityId: .settingsLogoutAlertCancel)
            delegate?.vmShowAlertWithTitle(nil, text: R.Strings.settingsLogoutAlertMessage,
                                           alertType: .plainAlertOld, actions: [positive, negative])
        case .versionInfo, .marketingNotifications:
            break
        case .notifications:
            navigator?.openSettingsNotifications()
        }
    }

    private func logoutUser() {
        tracker.trackEvent(TrackerEvent.logout())
        Core.sessionManager.logout()
    }

    private func setupRx() {
        myUserRepository.rx_myUser.bind { [weak self] _ in
            self?.populateSettings()
        }.disposed(by: disposeBag)
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
            interface: .button(R.Strings.settingsMarketingNotificationsAlertCancel, .secondary(fontSize: .medium, withBorder: true)),
            action: { [weak self] in
                self?.forceMarketingNotifications(enabled: false)
        })
        let  activateAction = UIAction(
            interface: .button(R.Strings.settingsMarketingNotificationsAlertActivate, .primary(fontSize: .medium)),
            action: { [weak self] in
                self?.setMarketingNotification(enabled: true)
                self?.pushPermissionManager.showPushPermissionsAlert(prePermissionType: .profile)
        })
        
        delegate?.vmShowAlertWithTitle(nil, text: R.Strings.settingsGeneralNotificationsAlertMessage,
                                       alertType: .plainAlertOld, actions: [cancelAction, activateAction])
    }
    
    private func showDeactivateConfirmation() {
        let cancelAction = UIAction(
            interface: .button(R.Strings.settingsMarketingNotificationsAlertCancel, .secondary(fontSize: .medium, withBorder: true)),
            action: { [weak self] in
                self?.forceMarketingNotifications(enabled: true)
        })
        let  deactivateAction = UIAction(
            interface: .button(R.Strings.settingsMarketingNotificationsAlertDeactivate, .secondary(fontSize: .medium, withBorder: true)),
            action: { [weak self] in
                self?.setMarketingNotification(enabled: false)
        })
        delegate?.vmShowAlertWithTitle(nil, text: R.Strings.settingsMarketingNotificationsAlertMessage,
                                       alertType: .plainAlertOld, actions: [cancelAction, deactivateAction], dismissAction: cancelAction.action)
    }
    
    private func forceMarketingNotifications(enabled: Bool) {
        notificationsManager.marketingNotifications.value = enabled
        switchMarketingNotificationValue.value = enabled
    }
}
