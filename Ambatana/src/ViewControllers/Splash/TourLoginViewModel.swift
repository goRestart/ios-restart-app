//
//  TourLoginViewModel.swift
//  LetGo
//
//  Created by Isaac Roldan on 4/2/16.
//  Copyright © 2016 Ambatana. All rights reserved.
//

import RxSwift

protocol TourLoginViewModelDelegate: BaseViewModelDelegate {
}

enum TourLoginState {
    case loading
    case active(closeEnabled: Bool, emailAsField: Bool)
}

final class TourLoginViewModel: BaseViewModel {

    var attributedLegalText: NSAttributedString {
        return signUpViewModel.attributedLegalText
    }
    let state = Variable<TourLoginState>(.loading)

    weak var navigator: TourLoginNavigator?
    weak var delegate: TourLoginViewModelDelegate?

    private let signUpViewModel: SignUpViewModel
    private let featureFlags: FeatureFlaggeable

    private let disposeBag = DisposeBag()

    init(signUpViewModel: SignUpViewModel, featureFlags: FeatureFlaggeable) {
        self.signUpViewModel = signUpViewModel
        self.featureFlags = featureFlags
        super.init()
        self.signUpViewModel.delegate = self
        setupRxBindings()
    }

    func closeButtonPressed() {
        nextStep()
    }

    func facebookButtonPressed() {
        signUpViewModel.connectFBButtonPressed()
    }

    func googleButtonPressed() {
        signUpViewModel.connectGoogleButtonPressed()
    }

    func emailButtonPressed() {
        signUpViewModel.signUpButtonPressed()
    }

    func textUrlPressed(url: URL) {
        delegate?.vmOpenInternalURL(url)
    }


    // MARK: - Private

    func setupRxBindings() {
        let stateFromData: Observable<TourLoginState> = featureFlags.syncedData.map { [weak self] syncedData in
            guard syncedData, let featureFlags = self?.featureFlags else { return .loading }
            switch featureFlags.onboardingReview {
            case .testA:
                return .active(closeEnabled: true, emailAsField: true)
            case .testB:
                return .active(closeEnabled: false, emailAsField: true)
            case .testC:
                return .active(closeEnabled: true, emailAsField: false)
            case .testD:
                return .active(closeEnabled: false, emailAsField: false)
            }
        }
        stateFromData.bindTo(state).addDisposableTo(disposeBag)
    }

    fileprivate func nextStep() {
        navigator?.tourLoginFinish()
    }
}


extension TourLoginViewModel: SignUpViewModelDelegate {

    func vmOpenSignup(_ viewModel: SignUpLogInViewModel) {
        navigator?.tourLoginOpenLoginSignup(signupLoginVM: viewModel) { [weak self] in
            self?.nextStep()
        }
    }

    func vmFinish(completedLogin completed: Bool) {
        nextStep()
    }

    func vmFinishAndShowScammerAlert(_ contactUrl: URL, network: EventParameterAccountNetwork, tracker: Tracker) {
        nextStep()
    }

    func vmPop() {
        nextStep()
    }
    func vmDismiss(_ completion: (() -> Void)?) {
        nextStep()
        completion?()
    }

    // BaseViewModelDelegate forwarding methods

    func vmShowAutoFadingMessage(_ message: String, completion: (() -> ())?) {
        delegate?.vmShowAutoFadingMessage(message, completion: completion)
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
    func vmShowAlertWithTitle(_ title: String?, text: String, alertType: AlertType, buttonsLayout: AlertButtonsLayout, actions: [UIAction]?) {
        delegate?.vmShowAlertWithTitle(title, text: text, alertType: alertType, buttonsLayout: buttonsLayout, actions: actions)
    }
    func vmShowAlert(_ title: String?, message: String?, actions: [UIAction]) {
        delegate?.vmShowAlert(title, message: message, actions: actions)
    }
    func vmShowAlert(_ title: String?, message: String?, cancelLabel: String, actions: [UIAction]) {
        delegate?.vmShowAlert(title, message: message, cancelLabel: cancelLabel, actions: actions)
    }
    func vmShowActionSheet(_ cancelAction: UIAction, actions: [UIAction]) {
        delegate?.vmShowActionSheet(cancelAction, actions: actions)
    }
    func vmShowActionSheet(_ cancelLabel: String, actions: [UIAction]) {
        delegate?.vmShowActionSheet(cancelLabel, actions: actions)
    }
    func ifLoggedInThen(_ source: EventParameterLoginSourceValue, loggedInAction: () -> Void,
                        elsePresentSignUpWithSuccessAction afterLogInAction: @escaping () -> Void) {
        delegate?.ifLoggedInThen(source, loggedInAction: loggedInAction, elsePresentSignUpWithSuccessAction: afterLogInAction)
    }
    func ifLoggedInThen(_ source: EventParameterLoginSourceValue, loginStyle: LoginStyle, loggedInAction: () -> Void,
                        elsePresentSignUpWithSuccessAction afterLogInAction: @escaping () -> Void) {
        delegate?.ifLoggedInThen(source, loginStyle: loginStyle, loggedInAction: loggedInAction, elsePresentSignUpWithSuccessAction: afterLogInAction)
    }
    func vmOpenInternalURL(_ url: URL) {
        delegate?.vmOpenInternalURL(url)
    }
}
