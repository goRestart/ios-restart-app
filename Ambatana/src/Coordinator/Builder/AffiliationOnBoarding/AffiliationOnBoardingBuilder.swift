protocol AffiliationOnBoardingAssembly {
    func buildOnBoarding(referrer: ReferrerInfo, onCompletion: AffiliationOnBoardingOnCompletion?) -> UIViewController 
}

enum AffiliationOnBoardingBuilder {
    case modal(UIViewController)
}

extension AffiliationOnBoardingBuilder: AffiliationOnBoardingAssembly {
    func buildOnBoarding(referrer: ReferrerInfo, onCompletion: AffiliationOnBoardingOnCompletion?) -> UIViewController {
        let vm = AffiliationOnBoardingViewModel(referrerInfo: referrer)
        switch self {
        case .modal(let root):
            vm.navigator = AffiliationOnBoardingWireframe(root: root, onCompletion: onCompletion)
            let vc = AffiliationOnBoardingViewController(viewModel: vm)
            vc.modalTransitionStyle = .crossDissolve
            vc.modalPresentationStyle = .overCurrentContext
            return vc
        }
    }
}
