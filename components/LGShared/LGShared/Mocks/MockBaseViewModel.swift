import Foundation

/// Represents the state of a MockBaseViewModel
final class MockBaseViewModelState {
    var delegateReceivedShowAutoFadingMessage: Bool = false
    var delegateReceivedShowLoading: Bool = false
    var delegateReceivedHideLoading: Bool = false
    var delegateReceivedShowAlert: Bool = false
    var delegateReceivedShowActionSheet: Bool = false
    var lastLoadingMessageShown: String?
    var lastAutofadingMessageShown: String?
    var lastAlertTextShown: String?
    
    init() {
        initialValues()
    }
    
    func reset() {
        initialValues()
    }
    
    private func initialValues() {
        delegateReceivedShowAutoFadingMessage = false
        delegateReceivedShowLoading = false
        delegateReceivedHideLoading = false
        delegateReceivedShowAlert = false
        delegateReceivedShowActionSheet = false
        lastLoadingMessageShown = nil
        lastAutofadingMessageShown = nil
        lastAlertTextShown = nil
    }
}

/// Protocol that will allow us to have a default state for a MockBaseViewModel
protocol HasMockBaseViewModelState {
    var state: MockBaseViewModelState { get set }
}

/// This is the protocol to be used in tests.
protocol MockBaseViewModel: BaseViewModelDelegate, HasMockBaseViewModelState {}

// Default implementation of the MockBaseViewModel that allows to have a state which is used in tests' asserts.
extension MockBaseViewModel {

    func resetViewModelSpec() {
        state.reset()
    }

    func vmShowAutoFadingMessage(_ message: String, completion: (() -> ())?) {
        state.delegateReceivedShowAutoFadingMessage = true
        state.lastAutofadingMessageShown = message
        DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(50)) {
            completion?()
        }
    }

    func vmShowLoading(_ loadingMessage: String?) {
        state.delegateReceivedShowLoading = true
        state.lastLoadingMessageShown = loadingMessage
    }

    func vmHideLoading(_ finishedMessage: String?, afterMessageCompletion: (() -> ())?) {
        state.delegateReceivedHideLoading = true
        state.lastLoadingMessageShown = finishedMessage
        DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(50)) {
            afterMessageCompletion?()
        }
    }

    func vmShowAlertWithTitle(_ title: String?, text: String, alertType: AlertType, actions: [UIAction]?) {
        state.delegateReceivedShowAlert = true
        state.lastAlertTextShown = text
    }

    func vmShowAlertWithTitle(_ title: String?, text: String, alertType: AlertType, buttonsLayout: AlertButtonsLayout, actions: [UIAction]?) {
        state.delegateReceivedShowAlert = true
        state.lastAlertTextShown = text
    }

    func vmShowAlert(_ title: String?, message: String?, actions: [UIAction]) {
        state.delegateReceivedShowAlert = true
        state.lastAlertTextShown = message
    }

    func vmShowAlert(_ title: String?, message: String?, cancelLabel: String, actions: [UIAction]) {
        state.delegateReceivedShowAlert = true
        state.lastAlertTextShown = message
    }
    
    func vmShowAlertWithTitle(_ title: String?, text: String, alertType: AlertType, actions: [UIAction]?, dismissAction: (() -> ())?) {
        state.delegateReceivedShowAlert = true
    }
    
    func vmShowAlertWithTitle(_ title: String?, text: String, alertType: AlertType, buttonsLayout: AlertButtonsLayout, actions: [UIAction]?, dismissAction: (() -> ())?) {
        state.delegateReceivedShowAlert = true
    }

    func vmShowActionSheet(_ cancelAction: UIAction, actions: [UIAction]) {
        state.delegateReceivedShowActionSheet = true
    }

    func vmShowActionSheet(_ cancelLabel: String, actions: [UIAction]) {
        state.delegateReceivedShowActionSheet = true
    }

    func ifLoggedInThen(_ source: EventParameterLoginSourceValue, loggedInAction: () -> Void,
                        elsePresentSignUpWithSuccessAction afterLogInAction: @escaping () -> Void) {}
    func ifLoggedInThen(_ source: EventParameterLoginSourceValue, loginStyle: LoginStyle, loggedInAction: () -> Void,
                        elsePresentSignUpWithSuccessAction afterLogInAction: @escaping () -> Void) {}
    func vmPop() {}
    func vmDismiss(_ completion: (() -> Void)?) {}
    func vmOpenInternalURL(_ url: URL) {}
}
