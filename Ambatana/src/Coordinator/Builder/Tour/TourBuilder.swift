protocol TourAssembly {
    func buildTourLocation(action: @escaping TourPostingAction,
                           skipper: TourSkiperNavigator?) -> TourLocationViewController
    func buildTourPosting(action: @escaping TourPostingAction) -> TourPostingViewController
}

enum TourBuilder: TourAssembly {
    case standard(UINavigationController)
    
    func buildTourLocation(action: @escaping TourPostingAction,
                           skipper: TourSkiperNavigator?) -> TourLocationViewController {
        let vm = TourLocationViewModel(source: .install)
        let vc = TourLocationViewController(viewModel: vm)
        switch self {
        case .standard(let nc):
            vm.navigator = TourLocationWireframe(nc: nc, action: action, skipper: skipper)
        }
        return vc
    }
    
    func buildTourPosting(action: @escaping TourPostingAction) -> TourPostingViewController {
        let vm = TourPostingViewModel()
        let vc = TourPostingViewController(viewModel: vm)
        switch self {
        case .standard(let nc):
            vm.navigator = TourPostingWireframe(nc: nc, action: action)
        }
        return vc
    }
}
