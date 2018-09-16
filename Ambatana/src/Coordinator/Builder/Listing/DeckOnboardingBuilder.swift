protocol DeckOnboardingAssembly {
    func buildDeckOnboarding() -> UIViewController
}

enum DeckOnboardingBuilder {
    case modal(UIViewController)
}

extension DeckOnboardingBuilder: DeckOnboardingAssembly {
    func buildDeckOnboarding() -> UIViewController {
        let vm = ListingDeckOnBoardingViewModel()
        switch self {
        case .modal(let root):
            vm.navigator = ListingDeckOnBoardingWireframe(root: root)
            let vc = ListingDeckOnBoardingViewController(viewModel: vm, animator: OnBoardingAnimator())
            vc.modalPresentationStyle = .custom
            return vc
        }
    }
}
