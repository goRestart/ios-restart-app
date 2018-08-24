import Foundation

final class UserVerificationWireframe: UserVerificationNavigator {
    private let nc: UINavigationController
    private let assembly: UserVerificationAssembly

    convenience init(nc: UINavigationController) {
        self.init(nc: nc, assembly: LGUserVerificationBuilder.standard(nav: nc))
    }

    init(nc: UINavigationController, assembly: UserVerificationAssembly) {
        self.nc = nc
        self.assembly = assembly
    }

    func closeUserVerification() {
        nc.popViewController(animated: true)
    }

    func openEmailVerification() {
        let vc = assembly.buildEmailVerification()
        nc.pushViewController(vc, animated: true)
    }

    func openEditUserBio() {
        let vc = assembly.buildEditUserBio()
        nc.pushViewController(vc, animated: true)
    }

    func openPhoneNumberVerification() {
        let vc = assembly.buildPhoneNumberVerification()
        nc.pushViewController(vc, animated: true)
    }
}
