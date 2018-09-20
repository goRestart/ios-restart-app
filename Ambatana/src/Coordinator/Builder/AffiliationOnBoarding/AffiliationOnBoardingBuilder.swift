protocol AffiliationOnBoardingAssembly {
    func buildOnBoarding(referrer: ReferrerInfo) -> UIViewController
}

enum AffiliationOnBoardingBuilder {
    case modal(UIViewController)
}

extension AffiliationOnBoardingBuilder: AffiliationOnBoardingAssembly {
    func buildOnBoarding(referrer: ReferrerInfo) -> UIViewController {
        let vm = AffiliationOnBoardingViewModel(referrerInfo: referrer)
        switch self {
        case .modal(let root):
            vm.navigator = AffiliationOnBoardingWireframe(root: root)
        }
        let vc = AffiliationOnBoardingViewController(viewModel: vm)
        return vc
    }
}
