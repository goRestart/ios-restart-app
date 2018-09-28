import Foundation

final class MediaViewerModalWireframe: MediaViewerNavigator {
    private let root: UIViewController

    init(root: UIViewController) {
        self.root = root
    }

    func closeMediaViewer() {
        root.dismiss(animated: true, completion: nil)
    }
}
