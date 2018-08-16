import Foundation

protocol ReportUpdateNavigator {
    func closeReportUpdate()
}

final class ReportUpdateRouter: ReportUpdateNavigator {
    private weak var root: UIViewController!

    init(root: UIViewController) {
        self.root = root
    }

    func closeReportUpdate() {
        root?.dismiss(animated: true, completion: nil)
    }
}
