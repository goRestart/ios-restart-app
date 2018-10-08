import UIKit
import LGCoreKit
import Result
import RxSwift
import LGComponents

enum LoginSource: String {
    case Chats = "messages"
    case Sell = "posting"
    case Profile = "view-profile"
    
    case Favourite = "favourite"
    case MakeOffer = "offer"
    case AskQuestion = "question"
    case ReportFraud = "report-fraud"
}

enum LoginAppearance {
    case dark, light
}

protocol SignUpViewModelDelegate: BaseViewModelDelegate {}

class SignUpViewModel: BaseViewModel {

    var attributedLegalText: NSAttributedString {
        guard let conditionsURL = termsAndConditionsURL, let privacyURL = privacyURL else {
            return NSAttributedString(string: R.Strings.mainSignUpTermsConditions)
        }

        let links = [R.Strings.mainSignUpTermsConditionsTermsPart: conditionsURL,
            R.Strings.mainSignUpTermsConditionsPrivacyPart: privacyURL]
        let localizedLegalText = R.Strings.mainSignUpTermsConditions
        let attributtedLegalText = localizedLegalText.attributedHyperlinkedStringWithURLDict(links,
            textColor: UIColor.darkGrayText)
        let range = NSMakeRange(0, attributtedLegalText.length)
        attributtedLegalText.addAttribute(NSAttributedStringKey.font, value: UIFont.smallBodyFont, range: range)
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.alignment = .center
        attributtedLegalText.addAttribute(NSAttributedStringKey.paragraphStyle, value: paragraphStyle, range: range)
        return attributtedLegalText
    }

    var showpasswordlessLogin: Bool {
        return self.featureFlags.showPasswordlessLogin.isActive
    }

    private var termsAndConditionsURL: URL? {
        return LetgoURLHelper.buildTermsAndConditionsURL()
    }
    private var privacyURL: URL? {
        return LetgoURLHelper.buildPrivacyURL()
    }

    fileprivate let sessionManager: SessionManager
    fileprivate let installationRepository: InstallationRepository
    fileprivate let keyValueStorage: KeyValueStorageable
    fileprivate let featureFlags: FeatureFlaggeable
    fileprivate let tracker: Tracker
    let appearance: LoginAppearance
    fileprivate let loginSource: EventParameterLoginSourceValue

    private let googleLoginHelper: ExternalAuthHelper
    private let fbLoginHelper: ExternalAuthHelper

    let previousFacebookUsername: Variable<String?>
    let previousGoogleUsername: Variable<String?>

    weak var delegate: SignUpViewModelDelegate?

    var router: LoginNavigator?

    private var onLoginCallback: (()->())?
    private var onCancelCallback: (()->())?
    
    // MARK: - Lifecycle
    
    init(sessionManager: SessionManager, installationRepository: InstallationRepository,
         keyValueStorage: KeyValueStorageable, featureFlags: FeatureFlaggeable, tracker: Tracker, appearance: LoginAppearance,
         source: EventParameterLoginSourceValue, googleLoginHelper: ExternalAuthHelper, fbLoginHelper: ExternalAuthHelper,
         loginAction: (()->())?, cancelAction: (()->())?) {
        self.sessionManager = sessionManager
        self.installationRepository = installationRepository
        self.keyValueStorage = keyValueStorage
        self.featureFlags = featureFlags
        self.tracker = tracker
        self.appearance = appearance
        self.loginSource = source
        self.googleLoginHelper = googleLoginHelper
        self.fbLoginHelper = fbLoginHelper
        self.previousFacebookUsername = Variable<String?>(nil)
        self.previousGoogleUsername = Variable<String?>(nil)
        self.onLoginCallback = loginAction
        self.onCancelCallback = cancelAction
        super.init()

        let rememberedAccount = updatePreviousEmailAndUsernamesFromKeyValueStorage()

        // Tracking
        tracker.trackEvent(TrackerEvent.loginVisit(loginSource, rememberedAccount: rememberedAccount))
    }
    
    convenience init(appearance: LoginAppearance,
                     source: EventParameterLoginSourceValue,
                     router: LoginNavigator? = nil,
                     loginAction: (()->())? = nil,
                     cancelAction: (()->())? = nil
                     ) {
        let sessionManager = Core.sessionManager
        let installationRepository = Core.installationRepository
        let keyValueStorage = KeyValueStorage.sharedInstance
        let featureFlags = FeatureFlags.sharedInstance
        let tracker = TrackerProxy.sharedInstance
        let googleLoginHelper = GoogleLoginHelper()
        let fbLoginHelper = FBLoginHelper()
        self.init(sessionManager: sessionManager, installationRepository: installationRepository,
                  keyValueStorage: keyValueStorage, featureFlags: featureFlags, tracker: tracker, appearance: appearance,
                  source: source, googleLoginHelper: googleLoginHelper, fbLoginHelper: fbLoginHelper,
                  loginAction: loginAction, cancelAction: cancelAction)
    }


    // MARK: - Public methods

    func closeButtonPressed() {
        let trackerEvent = TrackerEvent.loginAbandon(loginSource)
        tracker.trackEvent(trackerEvent)
        router?.close(onFinish: { self.onCancelCallback?() })
    }

    func connectFBButtonPressed() {
        logInWithFacebook()
    }

    func connectGoogleButtonPressed() {
        logInWithGoogle()
    }

    func signUpButtonPressed() {
        router?.showSignInWithEmail(source: loginSource,
                                     appearance: appearance,
                                     loginAction: { [weak self] in
                                        self?.router?.close(onFinish: self?.onLoginCallback)
                                     },
                                     cancelAction: onCancelCallback)
    }

    func logInButtonPressed() {
        router?.showLoginWithEmail(source: loginSource,
                                   loginAction: {[weak self] in
                                        self?.router?.close(onFinish: self?.onLoginCallback)
                                   },
                                   cancelAction: onCancelCallback)
    }

    func continueWithEmailButtonPressed() {
        router?.showPasswordlessEmail()
        tracker.trackEvent(.loginEmailStart())
    }

    func helpButtonPressed() {
        router?.showHelp()
    }

    func urlPressed(url: URL) {
        router?.open(url: url)
    }


    // MARK: - Private methods

    private func logInWithFacebook() {
        fbLoginHelper.login({ [weak self] in
            guard let strongSelf = self else { return }
            strongSelf.delegate?.vmShowLoading(nil)
            }, loginCompletion: { [weak self] result in
                self?.processAuthResult(result, accountProvider: .facebook)
                if result.isSuccess {
                    self?.trackLoginFBOK()
                } else if let trackingError = result.trackingError {
                    self?.trackLoginFBFailedWithError(trackingError)
                }
            })
    }

    private func logInWithGoogle() {
        googleLoginHelper.login({ [weak self] in
            // Google OAuth completed. Token obtained
            guard let strongSelf = self else { return }
            strongSelf.delegate?.vmShowLoading(nil)
        }) { [weak self] result in
            self?.processAuthResult(result, accountProvider: .google)
            if result.isSuccess {
                self?.trackLoginGoogleOK()
            } else if let trackingError = result.trackingError {
                self?.trackLoginGoogleFailedWithError(trackingError)
            }
        }
    }

    private func processAuthResult(_ result: ExternalServiceAuthResult, accountProvider: AccountProvider) {
        switch result {
        case let .success(myUser):
            savePreviousEmailOrUsername(accountProvider, username: myUser.name)
            delegate?.vmHideLoading(nil) { [weak self] in
                self?.router?.close(onFinish: {
                    self?.onLoginCallback?()
                })
            }
        case .scammer:
            delegate?.vmHideLoading(nil) { [weak self] in
                self?.showScammerAlert(accountProvider.accountNetwork)
            }
        case .deviceNotAllowed:
            delegate?.vmHideLoading(nil) { [weak self] in
                self?.showDeviceNotAllowedAlert(accountProvider.accountNetwork)
            }
        case .unavailable:
            delegate?.vmHideLoading(nil) { [weak self] in
                self?.showServiceUnavailable()
            }
        case .cancelled, .network, .notFound, .conflict, .badRequest, .internalError, .loginError:
            delegate?.vmHideLoading(result.errorMessage, afterMessageCompletion: nil)
        }
    }
    
    private func showServiceUnavailable() {
        router?.showAlert(
            withTitle: R.Strings.mainSignUpFbConnectErrorUnavailableTitle,
            andBody: R.Strings.mainSignUpFbConnectErrorUnavailableMessage,
            andType: .plainAlert,
            andActions: [UIAction.init(interface: .text(R.Strings.commonOk), action: {})])
    }

    private func showScammerAlert(_ network: EventParameterAccountNetwork) {
        guard let contactURL = LetgoURLHelper.buildContactUsURL(userEmail: nil,
                                                                installation: installationRepository.installation,
                                                                listing: nil,
                                                                type: .scammer) else {
                router?.close()
                return
            }

        let contact = UIAction(
            interface: .button(R.Strings.loginScammerAlertContactButton, .primary(fontSize: .medium)),
            action: {
                self.tracker.trackEvent(TrackerEvent.loginBlockedAccountContactUs(network, reason: .accountUnderReview))
                self.router?.close(onFinish: { self.router?.open(url: contactURL) })
        })
        let keepBrowsing = UIAction(
            interface: .button(R.Strings.loginScammerAlertKeepBrowsingButton, .secondary(fontSize: .medium,
                                                                                         withBorder: false)),
            action: {
                self.tracker.trackEvent(TrackerEvent.loginBlockedAccountKeepBrowsing(network, reason: .accountUnderReview))
                self.router?.close()
        })

        let actions = [contact, keepBrowsing]

        router?.showAlert(
            withTitle: R.Strings.loginScammerAlertTitle,
            andBody: R.Strings.loginScammerAlertMessage,
            andType: .iconAlert(icon: R.Asset.IconsButtons.icModerationAlert.image),
            andActions: actions
        )
        tracker.trackEvent(TrackerEvent.loginBlockedAccountStart(network, reason: .accountUnderReview))
    }

    private func showDeviceNotAllowedAlert(_ network: EventParameterAccountNetwork) {
        guard let contactURL = LetgoURLHelper.buildContactUsURL(userEmail: nil,
                                                                installation: installationRepository.installation,
                                                                listing: nil,
                                                                type: .deviceNotAllowed) else {
                                                                    router?.close(onFinish: self.onCancelCallback)
                                                                    return
        }

        let contact = UIAction(
            interface: .button(R.Strings.loginDeviceNotAllowedAlertContactButton, .primary(fontSize: .medium)),
            action: {
                self.tracker.trackEvent(TrackerEvent.loginBlockedAccountContactUs(network, reason: .secondDevice))
                self.router?.close(onFinish: { self.router?.open(url: contactURL) })
        })
        
        let keepBrowsing = UIAction(
            interface: .button(R.Strings.loginDeviceNotAllowedAlertOkButton, .secondary(fontSize: .medium,
                                                                                        withBorder: false)),
            action: {
                self.tracker.trackEvent(TrackerEvent.loginBlockedAccountKeepBrowsing(network, reason: .secondDevice))
                self.router?.close()
        })
        
        router?.showAlert(
            withTitle: R.Strings.loginDeviceNotAllowedAlertTitle,
            andBody: R.Strings.loginDeviceNotAllowedAlertMessage,
            andType: .iconAlert(icon: R.Asset.IconsButtons.icDeviceBlockedAlert.image),
            andActions: [contact, keepBrowsing])
        tracker.trackEvent(TrackerEvent.loginBlockedAccountStart(network, reason: .secondDevice))
    }

    private func trackLoginFBOK() {
        let rememberedAccount = previousFacebookUsername.value != nil
        tracker.trackEvent(TrackerEvent.loginFB(loginSource, rememberedAccount: rememberedAccount))
    }

    private func trackLoginFBFailedWithError(_ error: EventParameterLoginError) {
        tracker.trackEvent(TrackerEvent.loginFBError(error))
    }

    private func trackLoginGoogleOK() {
        let rememberedAccount = previousGoogleUsername.value != nil
        tracker.trackEvent(TrackerEvent.loginGoogle(loginSource, rememberedAccount: rememberedAccount))
    }

    private func trackLoginGoogleFailedWithError(_ error: EventParameterLoginError) {
        tracker.trackEvent(TrackerEvent.loginGoogleError(error))
    }
}


// MARK: > Previous user name

fileprivate extension SignUpViewModel {
    func updatePreviousEmailAndUsernamesFromKeyValueStorage() -> Bool {
        guard let accountProviderString = keyValueStorage[.previousUserAccountProvider],
            let accountProvider = AccountProvider(rawValue: accountProviderString) else { return false }

        let username = keyValueStorage[.previousUserEmailOrName]
        updatePreviousEmailAndUsernames(accountProvider, username: username)
        return true
    }

    func updatePreviousEmailAndUsernames(_ accountProvider: AccountProvider, username: String?) {
        switch accountProvider {
        case .email, .passwordless:
            previousFacebookUsername.value = nil
            previousGoogleUsername.value = nil
        case .facebook:
            previousFacebookUsername.value = username
            previousGoogleUsername.value = nil
        case .google:
            previousFacebookUsername.value = nil
            previousGoogleUsername.value = username
        }
    }

    func savePreviousEmailOrUsername(_ accountProvider: AccountProvider, username: String?) {
        keyValueStorage[.previousUserAccountProvider] = accountProvider.rawValue
        keyValueStorage[.previousUserEmailOrName] = username
    }
}
