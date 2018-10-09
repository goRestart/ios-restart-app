protocol ShareScreenshotAssembly {
    func buildShareScreenshot(screenshotImage: UIImage,
                              screenshotData: ScreenshotData) -> UIViewController
}

enum LGShareScreenshotBuilder {
    case modal(root: UIViewController)
}

extension LGShareScreenshotBuilder: ShareScreenshotAssembly {
    func buildShareScreenshot(screenshotImage: UIImage,
                              screenshotData: ScreenshotData) -> UIViewController {
        switch self {
        case .modal(let root):
            let vm = ShareScreenshotViewModel(screenshotImage: screenshotImage,
                                              screenshotData: screenshotData)
            vm.navigator = ShareScreenshotWireframe(root: root)
            return ShareScreenshotViewController(viewModel: vm)
        }
    }
}
