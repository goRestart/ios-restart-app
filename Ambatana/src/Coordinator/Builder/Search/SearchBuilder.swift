import LGComponents

protocol SearchAssembly {
    func buildSearch(withSearchType searchType: SearchType?,
                     onUserSearchCallback: ((SearchType) -> ())?) -> BaseViewController
}

enum SearchBuilder: SearchAssembly {
    case modal(root: UIViewController)
    
    func buildSearch(withSearchType searchType: SearchType?,
                     onUserSearchCallback: ((SearchType) -> ())?) -> BaseViewController {
        let vm = SearchViewModel(searchType: searchType, onUserSearchCallback: onUserSearchCallback)
        let vc = SearchViewController(vm: vm)
        
        switch self {
        case .modal(let root):
            vm.wireframe = SearchWireframe(root: root)
        }
        
        return vc
    }
}
