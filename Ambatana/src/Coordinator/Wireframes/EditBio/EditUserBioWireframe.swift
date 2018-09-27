import Foundation

final class EditUserBioWireframe: EditUserBioNavigator {
    private weak var nc: UINavigationController?

    init(nc: UINavigationController) {
        self.nc = nc
    }

    func closeEditUserBio() {
        nc?.popViewController(animated: true)
    }
}
