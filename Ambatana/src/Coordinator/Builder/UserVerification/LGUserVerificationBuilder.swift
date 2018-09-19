import Foundation

protocol UserVerificationAssembly {
    func buildUserVerification() -> UserVerificationViewController
    func buildEmailVerification() -> UserVerificationEmailViewController
    func buildEditUserBio() -> EditUserBioViewController
    func buildPhoneNumberVerification(editing: Bool) -> UserPhoneVerificationNumberInputViewController
    func buildUserPhoneVerificationCountryPicker(withDelegate delegate: UserPhoneVerificationCountryPickerDelegate) -> UserPhoneVerificationCountryPickerViewController
    func buildUserPhoneVerificationCodeInput(sentTo phoneNumber: String,
                                             with callingCode: String,
                                             editing: Bool) -> UserPhoneVerificationCodeInputViewController
}

enum LGUserVerificationBuilder {
    case standard(nav: UINavigationController)
}

extension LGUserVerificationBuilder: UserVerificationAssembly {
    func buildUserVerification() -> UserVerificationViewController {
        switch self {
        case .standard(let nav):
            let vm = UserVerificationViewModel()
            vm.navigator = UserVerificationWireframe(nc: nav)
            let vc = UserVerificationViewController(viewModel: vm)
            return vc
        }
    }

    func buildEmailVerification() -> UserVerificationEmailViewController {
        switch self {
        case .standard(let nav):
            let vm = UserVerificationEmailViewModel()
            vm.navigator = VerifyUserEmailWireframe(nc: nav)
            let vc = UserVerificationEmailViewController(viewModel: vm)
            return vc
        }
    }

    func buildEditUserBio() -> EditUserBioViewController {
        switch self {
        case .standard(let nav):
            let vm = EditUserBioViewModel()
            vm.navigator = EditUserBioWireframe(nc: nav)
            let vc = EditUserBioViewController(viewModel: vm)
            return vc
        }
    }

    func buildPhoneNumberVerification(editing: Bool) -> UserPhoneVerificationNumberInputViewController {
        switch self {
        case .standard(let nav):
            let vm = UserPhoneVerificationNumberInputViewModel(isEditing: editing)
            vm.navigator = UserPhoneVerificationWireframe(nc: nav)
            let vc = UserPhoneVerificationNumberInputViewController(viewModel: vm)
            vm.delegate = vc
            return vc
        }
    }

    func buildUserPhoneVerificationCountryPicker(withDelegate delegate: UserPhoneVerificationCountryPickerDelegate) -> UserPhoneVerificationCountryPickerViewController {
        switch self {
        case .standard(let nav):
            let vm = UserPhoneVerificationCountryPickerViewModel()
            vm.navigator = UserPhoneVerificationWireframe(nc: nav)
            vm.delegate = delegate
            let vc = UserPhoneVerificationCountryPickerViewController(viewModel: vm)
            return vc
        }
    }

    func buildUserPhoneVerificationCodeInput(sentTo phoneNumber: String,
                                             with callingCode: String,
                                             editing: Bool) -> UserPhoneVerificationCodeInputViewController {
        switch self {
        case .standard(let nav):
            let vm = UserPhoneVerificationCodeInputViewModel(callingCode: callingCode,
                                                             phoneNumber: phoneNumber,
                                                             isEditing: editing)
            vm.navigator = UserPhoneVerificationWireframe(nc: nav)
            let vc = UserPhoneVerificationCodeInputViewController(viewModel: vm)
            vm.delegate = vc
            return vc
        }
    }
}