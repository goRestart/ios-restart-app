public final class HelpWireframe: HelpNavigator {
    
    private weak var navigationController: UINavigationController?
    
    init(navigationController: UINavigationController) {
        self.navigationController = navigationController
    }
    
    public func closeHelp() {
        navigationController?.popViewController(animated: true)
    }
}
