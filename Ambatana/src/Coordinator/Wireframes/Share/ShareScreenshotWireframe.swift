final class ShareScreenshotWireframe: ShareScreenshotNavigator {
    
    private let root: UIViewController?
    
    init(root: UIViewController) {
        self.root = root
    }
    
    func closeShareScreenshot() {
        root?.dismiss(animated: false)
    }
}
