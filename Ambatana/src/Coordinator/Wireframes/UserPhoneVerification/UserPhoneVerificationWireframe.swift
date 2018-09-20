import Foundation

final class UserPhoneVerificationWireframe: UserPhoneVerificationNavigator {
    private let nc: UINavigationController
    private let assembly: UserVerificationAssembly

    convenience init(nc: UINavigationController) {
        self.init(nc: nc, assembly: LGUserVerificationBuilder.standard(nav: nc))
    }

    init(nc: UINavigationController, assembly: UserVerificationAssembly) {
        self.nc = nc
        self.assembly = assembly
    }

    func openCountrySelector(withDelegate: UserPhoneVerificationCountryPickerDelegate) {
        let vc = assembly.buildUserPhoneVerificationCountryPicker(withDelegate: withDelegate)
        nc.pushViewController(vc, animated: true)
    }

    func closeCountrySelector() {
        nc.popViewController(animated: true)
    }

    func openCodeInput(sentTo phoneNumber: String, with callingCode: String, editing: Bool) {
        let vc = assembly.buildUserPhoneVerificationCodeInput(sentTo: phoneNumber,
                                                                with: callingCode,
                                                                editing: editing)
        nc.pushViewController(vc, animated: true)
    }
    
    func closePhoneVerificaction() {
        guard let vc = nc.viewControllers.filter({ $0 is UserVerificationViewController ||
                                                   $0 is AffiliationChallengesViewController }).first else { return }
        nc.popToViewController(vc, animated: true)
    }
}
