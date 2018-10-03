import Foundation

final class UserVerificationWireframe: UserVerificationNavigator {
    private weak var nc: UINavigationController?
    private let assembly: UserVerificationAssembly

    convenience init(nc: UINavigationController) {
        self.init(nc: nc, assembly: LGUserVerificationBuilder.standard(nav: nc))
    }

    init(nc: UINavigationController, assembly: UserVerificationAssembly) {
        self.nc = nc
        self.assembly = assembly
    }

    func closeUserVerification() {
        nc?.popViewController(animated: true)
    }

    func openEmailVerification() {
        let vc = assembly.buildEmailVerification()
        nc?.pushViewController(vc, animated: true)
    }

    func openEditUserBio() {
        let vc = assembly.buildEditUserBio()
        nc?.pushViewController(vc, animated: true)
    }

    func openPhoneNumberVerification(editing: Bool) {
        let vc = assembly.buildPhoneNumberVerification(editing: editing)
        nc?.pushViewController(vc, animated: true)
    }
}
