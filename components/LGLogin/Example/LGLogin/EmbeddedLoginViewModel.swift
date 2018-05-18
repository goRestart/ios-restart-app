import LGComponents

final class EmbeddedLoginViewModel: BaseViewModel {
    weak var navigator: EmbeddedLoginViewModelNavigator?

    private let signUpViewModel: SignUpViewModel


    // MARK: - Lifecycle

    init(signUpViewModel: SignUpViewModel) {
        self.signUpViewModel = signUpViewModel
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
}

