import LGCoreKit
import RxSwift
import LGComponents

protocol TourLoginViewModelDelegate: BaseViewModelDelegate { }

final class TourLoginViewModel: BaseViewModel {

    var attributedLegalText: NSAttributedString {
        return signUpViewModel.attributedLegalText
    }

    var navigator: TourLoginWireframe?
    weak var delegate: TourLoginViewModelDelegate?

    private let signUpViewModel: SignUpViewModel
    private let categoryRepository: CategoryRepository
    private let featureFlags: FeatureFlaggeable

    private let disposeBag = DisposeBag()

    init(signUpViewModel: SignUpViewModel,
         categoryRepository:CategoryRepository,
         featureFlags: FeatureFlaggeable) {
        self.categoryRepository = categoryRepository
        self.signUpViewModel = signUpViewModel
        self.featureFlags = featureFlags
        super.init()
        self.signUpViewModel.delegate = self
    }
    
    convenience init(signUpViewModel: SignUpViewModel) {
        self.init(signUpViewModel: signUpViewModel,
                  categoryRepository: Core.categoryRepository,
                  featureFlags: FeatureFlags.sharedInstance)
    }

    func facebookButtonPressed() {
        signUpViewModel.connectFBButtonPressed()
    }

    func googleButtonPressed() {
        signUpViewModel.connectGoogleButtonPressed()
    }

    func emailButtonPressed() {
        if featureFlags.showPasswordlessLogin.isActive {
            signUpViewModel.continueWithEmailButtonPressed()
        } else {
            signUpViewModel.signUpButtonPressed()
        }
    }

    func textUrlPressed(url: URL) {
        delegate?.vmOpenInAppWebViewWith(url:url)
    }

}


// MARK: - SignUpViewModelDelegate

extension TourLoginViewModel: SignUpViewModelDelegate {
    func vmPop() { }
    func vmDismiss(_ completion: (() -> Void)?) { }

    // BaseViewModelDelegate forwarding methods

    func vmShowAutoFadingMessage(_ message: String, completion: (() -> ())?) {
        delegate?.vmShowAutoFadingMessage(message, completion: completion)
    }
    func vmShowAutoFadingMessage(title: String, message: String, time: Double, completion: (() -> ())?) {
        delegate?.vmShowAutoFadingMessage(title: title, message: message, time: time, completion: completion)
    }
    func vmShowAutoFadingMessage(message: String, time: Double, completion: (() -> ())?) {
        delegate?.vmShowAutoFadingMessage(message: message, time: time, completion: completion)
    }
    func vmShowLoading(_ loadingMessage: String?) {
        delegate?.vmShowLoading(loadingMessage)
    }
    func vmHideLoading(_ finishedMessage: String?, afterMessageCompletion: (() -> ())?) {
        delegate?.vmHideLoading(finishedMessage, afterMessageCompletion: afterMessageCompletion)
    }
    func vmShowAlertWithTitle(_ title: String?, text: String, alertType: AlertType, actions: [UIAction]?) {
        delegate?.vmShowAlertWithTitle(title, text: text, alertType: alertType, actions: actions)
    }
    func vmShowAlertWithTitle(_ title: String?, text: String, alertType: AlertType, actions: [UIAction]?, dismissAction: (() -> ())?) {
        delegate?.vmShowAlertWithTitle(title, text: text, alertType: alertType, actions: actions, dismissAction: dismissAction)
    }
    func vmShowAlertWithTitle(_ title: String?, text: String, alertType: AlertType, buttonsLayout: AlertButtonsLayout, actions: [UIAction]?) {
        delegate?.vmShowAlertWithTitle(title, text: text, alertType: alertType, buttonsLayout: buttonsLayout, actions: actions)
    }
    func vmShowAlertWithTitle(_ title: String?, text: String, alertType: AlertType, buttonsLayout: AlertButtonsLayout, actions: [UIAction]?, dismissAction: (() -> ())?) {
        delegate?.vmShowAlertWithTitle(title, text: text, alertType: alertType, buttonsLayout: buttonsLayout, actions: actions, dismissAction: dismissAction)
    }
    func vmShowAlert(_ title: String?, message: String?, actions: [UIAction]) {
        delegate?.vmShowAlert(title, message: message, actions: actions)
    }
    func vmShowAlert(_ title: String?, message: String?, cancelLabel: String, actions: [UIAction]) {
        delegate?.vmShowAlert(title, message: message, cancelLabel: cancelLabel, actions: actions)
    }
    func vmShowActionSheet(_ cancelAction: UIAction, actions: [UIAction], withTitle title: String?) {
        delegate?.vmShowActionSheet(cancelAction, actions: actions, withTitle: title)
    }
    func vmShowActionSheet(_ cancelAction: UIAction, actions: [UIAction]) {
        delegate?.vmShowActionSheet(cancelAction, actions: actions)
    }
    func vmShowActionSheet(_ cancelLabel: String, actions: [UIAction]) {
        delegate?.vmShowActionSheet(cancelLabel, actions: actions)
    }
    func vmOpenInAppWebViewWith(url: URL) {
        delegate?.vmOpenInAppWebViewWith(url:url)
    }
}
