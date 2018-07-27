import Foundation

final class UserVerificationRouter {

    let navigationController: UINavigationController

    init(navigationController: UINavigationController) {
        self.navigationController = navigationController
    }

    func closeUserVerification() {
        navigationController.popViewController(animated: true)
    }

    func openEmailVerification(verifyUserNavigator: VerifyUserEmailNavigator?) {
        let vm = UserVerificationEmailViewModel()
        vm.navigator = verifyUserNavigator
        let vc = UserVerificationEmailViewController(viewModel: vm)
        navigationController.pushViewController(vc, animated: true)
    }

    func openEditUserBio(navigator: EditUserBioNavigator?) {
        let vm = EditUserBioViewModel()
        vm.navigator = navigator
        let vc = EditUserBioViewController(viewModel: vm)
        navigationController.pushViewController(vc, animated: true)
    }

    func openPhoneNumberVerification(navigator: UserPhoneVerificationNavigator?) {
        let vm = UserPhoneVerificationNumberInputViewModel()
        vm.navigator = navigator
        let vc = UserPhoneVerificationNumberInputViewController(viewModel: vm)
        vm.delegate = vc
        navigationController.pushViewController(vc, animated: true)
    }
}
