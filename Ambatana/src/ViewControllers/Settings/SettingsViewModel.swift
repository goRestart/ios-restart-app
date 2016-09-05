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
    case ChangePhoto(placeholder: UIImage, avatarUrl: NSURL?)
    case ChangeUsername(name: String)
    case ChangeLocation(location: String)
    case CreateCommercializer
    case ChangePassword
    case Help
    case LogOut
}

protocol SettingsViewModelDelegate: BaseViewModelDelegate {
    func vmOpenSettingsDetailVC(vc: UIViewController)
    func vmOpenImagePick()
    func vmOpenFbAppInvite(content: FBSDKAppInviteContent)
}

class SettingsViewModel: BaseViewModel {

    weak var delegate: SettingsViewModelDelegate?

    var settingsChanges: Observable<CollectionChange<LetGoSetting>> {
        return settingsData.changesObservable
    }
    let avatarLoadingProgress = Variable<Float?>(nil)

    private let myUserRepository: MyUserRepository
    private let commercializerRepository: CommercializerRepository
    private let locationManager: LocationManager
    private let tracker: Tracker

    private let settingsData = CollectionVariable<LetGoSetting>([])
    private let kLetGoUserImageSquareSize: CGFloat = 1024

    private let disposeBag = DisposeBag()

    private var commercializerEnabled: Bool {
        guard let countryCode = locationManager.currentPostalAddress?.countryCode else { return false }
        return !commercializerRepository.templatesForCountryCode(countryCode).isEmpty
    }


    convenience override init() {
        self.init(myUserRepository: Core.myUserRepository, commercializerRepository: Core.commercializerRepository,
                  locationManager: Core.locationManager, tracker: TrackerProxy.sharedInstance)
    }

    init(myUserRepository: MyUserRepository, commercializerRepository: CommercializerRepository,
         locationManager: LocationManager, tracker: Tracker) {
        self.myUserRepository = myUserRepository
        self.commercializerRepository = commercializerRepository
        self.locationManager = locationManager
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

    var settingsCount: Int {
        return settingsData.value.count
    }

    func settingAtIndex(index: Int) -> LetGoSetting? {
        guard 0..<settingsData.value.count ~= index else { return nil }
        return settingsData.value[index]
    }

    func settingSelectedAtIndex(index: Int) {
        guard let setting = settingAtIndex(index) else { return }
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
            let vc = ChangeUsernameViewController()
            delegate?.vmOpenSettingsDetailVC(vc)
        case .ChangeLocation:
            let vc = EditLocationViewController(viewModel: EditLocationViewModel(mode: .EditUserLocation))
            delegate?.vmOpenSettingsDetailVC(vc)
        case .CreateCommercializer:
            let vc = CreateCommercialViewController(viewModel: CreateCommercialViewModel())
            delegate?.vmOpenSettingsDetailVC(vc)
        case .ChangePassword:
            let vc = ChangePasswordViewController()
            delegate?.vmOpenSettingsDetailVC(vc)
        case .Help:
            let vc = HelpViewController()
            delegate?.vmOpenSettingsDetailVC(vc)
        case .LogOut:
            logoutUser()
        }
    }

    func imageSelected(image: UIImage) {
        avatarLoadingProgress.value = 0.0
        let size = CGSizeMake(kLetGoUserImageSquareSize, kLetGoUserImageSquareSize)
        guard let resizedImage = image.resizedImageWithContentMode( .ScaleAspectFill, size: size,
            interpolationQuality: .Medium), croppedImage = resizedImage.croppedCenteredImage(),
            imageData = UIImageJPEGRepresentation(croppedImage, 0.9) else {
                avatarLoadingProgress.value = nil
                delegate?.vmShowAutoFadingMessage(LGLocalizedString.settingsChangeProfilePictureErrorGeneric,
                                                  completion: nil)
                return
        }

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
        var settings: [LetGoSetting] = []

        let myUser = myUserRepository.myUser
        settings.append(.InviteFbFriends)
        let placeholder = LetgoAvatar.avatarWithColor(UIColor.defaultAvatarColor, name: myUser?.name)
        settings.append(.ChangePhoto(placeholder: placeholder, avatarUrl: myUser?.avatar?.fileURL))
        settings.append(.ChangeUsername(name: myUser?.name ?? ""))
        settings.append(.ChangeLocation(location: myUser?.postalAddress.city ?? myUser?.postalAddress.countryCode ?? ""))
        if commercializerEnabled {
            settings.append(.CreateCommercializer)
        }
        if let email = myUser?.email where email.isEmail() {
            settings.append(.ChangePassword)
        }
        settings.append(.Help)
        settings.append(.LogOut)

        settingsData.removeAll()
        settingsData.appendContentsOf(settings)
    }

    private func logoutUser() {
        Core.sessionManager.logout()
        tracker.trackEvent(TrackerEvent.logout())
        tracker.setUser(nil)
    }

    private func setupRx() {
        myUserRepository.rx_myUser.asObservable().bindNext { [weak self] _ in
            self?.populateSettings()
        }.addDisposableTo(disposeBag)
    }
}


extension LetGoSetting {
    var title: String {
        switch (self) {
        case .InviteFbFriends:
            return LGLocalizedString.settingsInviteFacebookFriendsButton
        case .ChangePhoto:
            return LGLocalizedString.settingsChangeProfilePictureButton
        case .ChangeUsername:
            return LGLocalizedString.settingsChangeUsernameButton
        case .ChangeLocation:
            return LGLocalizedString.settingsChangeLocationButton
        case .CreateCommercializer:
            return LGLocalizedString.commercializerCreateFromSettings
        case .ChangePassword:
            return LGLocalizedString.settingsChangePasswordButton
        case .Help:
            return LGLocalizedString.settingsHelpButton
        case .LogOut:
            return LGLocalizedString.settingsLogoutButton
        }
    }

    var image: UIImage? {
        switch (self) {
        case .InviteFbFriends:
            return UIImage(named: "ic_fb_settings")
        case .ChangeUsername:
            return UIImage(named: "ic_change_username")
        case .ChangeLocation:
            return UIImage(named: "ic_location_edit")
        case .CreateCommercializer:
            return UIImage(named: "ic_play_video")
        case .ChangePassword:
            return UIImage(named: "edit_profile_password")
        case .Help:
            return UIImage(named: "ic_help")
        case .LogOut:
            return UIImage(named: "edit_profile_logout")
        case let .ChangePhoto(placeholder,_):
            return placeholder
        }
    }

    var imageURL: NSURL? {
        switch self {
        case let .ChangePhoto(_,avatarUrl):
            return avatarUrl
        default:
            return nil
        }
    }

    var imageRounded: Bool {
        switch self {
        case .ChangePhoto:
            return true
        default:
            return false
        }
    }

    var textColor: UIColor {
        switch (self) {
        case .LogOut:
            return UIColor.lightGrayColor()
        case .CreateCommercializer:
            return UIColor.primaryColor
        default:
            return UIColor.darkGrayColor()
        }
    }

    var textValue: String? {
        switch self {
        case let .ChangeUsername(name):
            return name
        case let .ChangeLocation(location):
            return location
        default:
            return nil
        }
    }

    var showsDisclosure: Bool {
        switch self {
        case .LogOut:
            return false
        default:
            return true
        }
    }
}
