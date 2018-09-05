import LGComponents

protocol SearchAssembly {
    func buildSearch(withSearchType searchType: SearchType?,
                     searchCallback: ((SearchType) -> ())?) -> BaseViewController
}

enum SearchBuilder: SearchAssembly {
    case modal(root: UIViewController)
    
    func buildSearch(withSearchType searchType: SearchType?,
                     searchCallback: ((SearchType) -> ())?) -> BaseViewController {
        let vm = SearchViewModel(searchType: searchType, searchCallback: searchCallback)
        let vc = SearchViewController(vm: vm)
        
        switch self {
        case .modal(let root):
            vm.wireframe = SearchWireframe(root: root)
        }
        
        return vc
    }
}
