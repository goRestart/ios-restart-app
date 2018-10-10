protocol ReportAssembly {
    func buildReport(type: ReportFlowType, reportedId: String, source: EventParameterTypePage) -> UIViewController
}

enum ReportBuilder {
    case modal(UIViewController)
}

extension ReportBuilder: ReportAssembly {
    func buildReport(type: ReportFlowType, reportedId: String, source: EventParameterTypePage) -> UIViewController {
        let vm = ReportOptionsListViewModel(optionGroup: type.options, title: type.title, reportedId: reportedId,
                                            source: source, superReason: nil, listing: type.listing)
        let vc = ReportOptionsListViewController(viewModel: vm)
        let nav = UINavigationController(rootViewController: vc)

        switch self {
        case .modal(let root):
            vm.navigator = ReportWireframe(root: root, navigationController: nav, type: type, source: source, reportedId: reportedId)
        }

        return nav
    }
}

