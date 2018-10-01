import Foundation

protocol ReportNavigator: class {
    func openNextStep(with options: ReportOptionsGroup, from: ReportOptionType)
    func openReportSentScreen(sentType: ReportSentType)
    func openReviewUser()
    func closeReporting()
}

final class ReportWireframe: ReportNavigator {

    private let root: UIViewController
    private let navigationController: UINavigationController
    private let type: ReportFlowType
    private let source: EventParameterTypePage
    private let reportedId: String

    init(root: UIViewController, navigationController: UINavigationController, type: ReportFlowType,
         source: EventParameterTypePage, reportedId: String) {
        self.root = root
        self.navigationController = navigationController
        self.type = type
        self.source = source
        self.reportedId = reportedId
    }

    func openNextStep(with options: ReportOptionsGroup, from: ReportOptionType) {
        let vm = ReportOptionsListViewModel(optionGroup: options, title: type.title, reportedId: reportedId,
                                            source: source, superReason: nil, listing: type.listing)
        let vc = ReportOptionsListViewController(viewModel: vm)
        vm.navigator = ReportWireframe(root: root, navigationController: navigationController, type: type, source: source, reportedId: reportedId)
        navigationController.pushViewController(vc, animated: true)
    }

    func openReportSentScreen(sentType: ReportSentType) {
        guard let username = type.rateData?.userName else { return }
        let vm = ReportSentViewModel(reportSentType: sentType, reportedObjectId: reportedId, username: username)
        vm.navigator = ReportWireframe(root: root, navigationController: navigationController, type: type, source: source, reportedId: reportedId)
        let vc = ReportSentViewController(viewModel: vm)
        vm.delegate = vc
        navigationController.pushViewController(vc, animated: true)
    }

    func openReviewUser() {
    }

    func closeReporting() {
        root.dismiss(animated: true, completion: nil)
    }
}
