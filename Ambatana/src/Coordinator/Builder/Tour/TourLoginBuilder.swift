protocol TourLoginAssembly {
    func buildTour(appearance: LoginAppearance,
                   action: @escaping TourPostingAction,
                   tourSkipper: TourSkiperNavigator?) -> UIViewController
}

enum TourLoginBuilder {
    case modal
}

extension TourLoginBuilder: TourLoginAssembly {
    func buildTour(appearance: LoginAppearance = .light,
                   action: @escaping TourPostingAction,
                   tourSkipper: TourSkiperNavigator?) -> UIViewController {
        let nav = UINavigationController()
        nav.setupForModalWithNonOpaqueBackground()
        nav.modalTransitionStyle = .crossDissolve

        let wireframe = TourLoginWireframe(nc: nav, action: action, tourSkipper: tourSkipper)
        let signUpVM = SignUpViewModel(appearance: appearance,
                                       source: .install,
                                       loginAction: {
                                        // Another patch used to spawn the permissions.
                                        // and close the tour login view.
                                        wireframe.tourLoginFinish()
        })

        let vm = TourLoginViewModel(signUpViewModel: signUpVM)
        let vc = TourLoginViewController(viewModel: vm)
        vm.delegate = vc
        vc.setupForModalWithNonOpaqueBackground()
        vc.modalTransitionStyle = .crossDissolve

        signUpVM.router = LoginStandardWireframe(nc: nav)
        vm.navigator = wireframe

        nav.setViewControllers([vc], animated: false)
        return nav
    }
}

