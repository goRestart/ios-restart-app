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
    private let abTestSyncTimeout: TimeInterval

    private let disposeBag = DisposeBag()

    convenience init(signUpViewModel: SignUpViewModel, featureFlags: FeatureFlaggeable) {
        self.init(signUpViewModel: signUpViewModel, featureFlags: featureFlags, syncTimeout: Constants.abTestSyncTimeout)
    }

    init(signUpViewModel: SignUpViewModel, featureFlags: FeatureFlaggeable, syncTimeout: TimeInterval) {
        self.signUpViewModel = signUpViewModel
        self.featureFlags = featureFlags
        self.abTestSyncTimeout = syncTimeout
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
        featureFlags.syncedData.filter{ $0 }.take(1).timeout(abTestSyncTimeout, scheduler: MainScheduler.instance)
            .subscribe(onNext: { [weak self ] _ in self?.setCurrentState(timeout: false) },
                       onError: { [weak self] _ in self?.setCurrentState(timeout: true) })
            .addDisposableTo(disposeBag)
    }

    private func setCurrentState(timeout: Bool) {
        state.value = timeout ? .active(closeEnabled: true, emailAsField: true) : featureFlags.onboardingReview.tourLoginState
        signUpViewModel.collapsedEmailTrackingParam = timeout ? .notAvailable : featureFlags.onboardingReview.collapsedEmailParam
    }

    fileprivate func nextStep() {
        navigator?.tourLoginFinish()
    }
}


// MARK: - Helper

extension OnboardingReview {
    var tourLoginState: TourLoginState {
        switch self {
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

    var collapsedEmailParam: EventParameterBoolean {
        switch self {
        case .testA, .testB:
            return .falseParameter
        case .testC, .testD:
            return .trueParameter
        }
    }
}


// MARK: - SignUpViewModelDelegate

extension TourLoginViewModel: SignUpViewModelDelegate {
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
    func vmOpenInternalURL(_ url: URL) {
        delegate?.vmOpenInternalURL(url)
    }
}
