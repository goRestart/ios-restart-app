import Foundation

final class UserPhoneVerificationRouter: UserPhoneVerificationNavigator {
    private weak var navigationController: UINavigationController?
    private let assembly: UserVerificationAssembly

    convenience init(navigationController: UINavigationController) {
        self.init(navigationController: navigationController,
                  assembly: LGUserVerificationBuilder.standard(nav: navigationController))
    }

    init(navigationController: UINavigationController, assembly: UserVerificationAssembly) {
        self.navigationController = navigationController
        self.assembly = assembly
    }

    func openCountrySelector(withDelegate: UserPhoneVerificationCountryPickerDelegate) {
        let vc = assembly.buildUserPhoneVerificationCountryPicker(withDelegate: withDelegate)
        navigationController?.pushViewController(vc, animated: true)
    }

    func closeCountrySelector() {
        navigationController?.popViewController(animated: true)
    }

    func openCodeInput(sentTo phoneNumber: String, with callingCode: String) {
        let vc = assembly.buildUserPhoneVerificationCodeInput(sentTo: phoneNumber,
                                                                with: callingCode)
        navigationController?.pushViewController(vc, animated: true)
    }
    
    func closePhoneVerificaction() {
        guard let vc = navigationController?.viewControllers
            .filter({ $0 is UserVerificationViewController }).first else { return }
        navigationController?.popToViewController(vc, animated: true)
    }
}
