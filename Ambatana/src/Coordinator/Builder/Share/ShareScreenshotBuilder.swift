protocol ShareScreenshotAssembly {
    func buildShareScreenshot(screenshotImage: UIImage, socialMessage: SocialMessage) -> UIViewController
}

enum LGShareScreenshotBuilder {
    case modal(root: UIViewController)
}

extension LGShareScreenshotBuilder: ShareScreenshotAssembly {
    func buildShareScreenshot(screenshotImage: UIImage, socialMessage: SocialMessage) -> UIViewController {
        switch self {
        case .modal(let root):
            let vm = ShareScreenshotViewModel(screenshotImage: screenshotImage, socialMessage: socialMessage)
            vm.navigator = ShareScreenshotWireframe(root: root)
            return ShareScreenshotViewController(viewModel: vm)
        }
    }
}
