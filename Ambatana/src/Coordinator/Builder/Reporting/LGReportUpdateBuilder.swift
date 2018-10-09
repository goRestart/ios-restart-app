import Foundation
import LGCoreKit

protocol ReportUpdateAssembly {
    func buildReportUpdate(reportId: String, reason: ReportOptionType, userId: String, username: String, product: String?) -> ReportUpdateViewController
}

enum LGReportUpdateBuilder {
    case modal(root: UIViewController)
}

extension LGReportUpdateBuilder: ReportUpdateAssembly {
    func buildReportUpdate(reportId: String, reason: ReportOptionType, userId: String, username: String, product: String?) -> ReportUpdateViewController {
        switch self {
        case .modal(let root):
            let updateType = ReportUpdateType(reason: reason, username: username, productName: product)
            let viewModel = ReportUpdateViewModel(type: updateType, reportId: reportId, reportedUserId: userId)
            viewModel.navigator = ReportUpdateWireframe(root: root)
            return ReportUpdateViewController(viewModel: viewModel)
        }
    }
}
