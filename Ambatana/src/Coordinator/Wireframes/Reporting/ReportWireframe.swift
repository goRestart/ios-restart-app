import Foundation

protocol ReportNavigator: class {
    func openNextStep(with options: ReportOptionsGroup, from: ReportOptionType)
    func openReportSentScreen(sentType: ReportSentType)
    func openReviewUser()
    func closeReporting()
}

final class ReportWireframe: ReportNavigator {

    private let root: UIViewController
    private weak var navigationController: UINavigationController?
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
        guard let navController = navigationController else { return }
        let vm = ReportOptionsListViewModel(optionGroup: options, title: type.title, reportedId: reportedId,
                                            source: source, superReason: nil, listing: type.listing)
        let vc = ReportOptionsListViewController(viewModel: vm)
        vm.navigator = ReportWireframe(root: root,
                                       navigationController: navController,
                                       type: type,
                                       source: source,
                                       reportedId: reportedId)
        navController.pushViewController(vc, animated: true)
    }

    func openReportSentScreen(sentType: ReportSentType) {
        guard let username = type.rateData?.userName, let navController = navigationController else { return }
        let vm = ReportSentViewModel(reportSentType: sentType, reportedObjectId: reportedId, username: username)
        vm.navigator = ReportWireframe(root: root,
                                       navigationController: navController,
                                       type: type,
                                       source: source,
                                       reportedId: reportedId)
        let vc = ReportSentViewController(viewModel: vm)
        vm.delegate = vc
        navController.pushViewController(vc, animated: true)
    }

    func openReviewUser() {
        guard let rate = type.rateData, let navController = navigationController else { return }
        let assembly = RateUserBuilder.modal(navController)
        let vc = assembly.buildRateUser(source: .report, data: rate, showSkipButton: false, onRateUserFinishAction: self)
        navController.present(vc, animated: true, completion: nil)
    }

    func closeReporting() {
        root.dismiss(animated: true, completion: nil)
    }
}

extension ReportWireframe: OnRateUserFinishActionable {
    func onFinish() {
        closeReporting()
    }
}
