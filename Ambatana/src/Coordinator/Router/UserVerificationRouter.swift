import Foundation

final class UserVerificationRouter: UserVerificationNavigator {
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

    func closeUserVerification() {
        navigationController?.popViewController(animated: true)
    }

    func openEmailVerification() {
        let vc = assembly.buildEmailVerification()
        navigationController?.pushViewController(vc, animated: true)
    }

    func openEditUserBio() {
        let vc = assembly.buildEditUserBio()
        navigationController?.pushViewController(vc, animated: true)
    }

    func openPhoneNumberVerification() {
        let vc = assembly.buildPhoneNumberVerification()
        navigationController?.pushViewController(vc, animated: true)
    }
}
