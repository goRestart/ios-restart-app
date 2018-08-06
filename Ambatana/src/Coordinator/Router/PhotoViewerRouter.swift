import Foundation

protocol PhotoViewerNavigator: class {
    func closePhotoViewer()
}

final class PhotoViewerRouter: PhotoViewerNavigator {
    private weak var root: UIViewController?

    init(root: UIViewController) {
        self.root = root
    }

    func closePhotoViewer() {
        root?.dismiss(animated: true, completion: nil)
    }
}
