import Foundation

final class MediaViewerStandardWireframe: MediaViewerNavigator {
    private let nc: UINavigationController

    init(nc: UINavigationController) {
        self.nc = nc
    }

    func closeMediaViewer() {
        nc.popViewController(animated: true)
    }
}
