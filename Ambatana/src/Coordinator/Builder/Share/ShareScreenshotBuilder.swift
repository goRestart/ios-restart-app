protocol ShareScreenshotAssembly {
    func buildShareScreenshot(screenshotImage: UIImage) -> UIViewController
}

enum LGShareScreenshotBuilder {
    case modal(root: UIViewController)
}

extension LGShareScreenshotBuilder: ShareScreenshotAssembly {
    func buildShareScreenshot(screenshotImage: UIImage) -> UIViewController {
        switch self {
        case .modal(let root):
            let vm = ShareScreenshotViewModel(screenshotImage: screenshotImage)
            vm.navigator = ShareScreenshotWireframe(root: root)
            return ShareScreenshotViewController(viewModel: vm)
        }
    }
}
