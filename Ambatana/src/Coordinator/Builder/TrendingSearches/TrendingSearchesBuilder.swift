import LGComponents

protocol TrendingSearchesAssembly {
    func buildTrendingSearches() -> BaseViewController
}

enum TrendingSearchesBuilder: TrendingSearchesAssembly {
    case modal(root: UIViewController)
    
    func buildTrendingSearches() -> BaseViewController {
        let vm = TrendingSearchesViewModel()
        let vc = TrendingSearchesViewController(viewModel: vm)
        
        switch self {
        case .modal(let controller):
            vm.wireframe = TrendingSearchesWireframe(root: controller)
        }
        
        return vc
    }
}
