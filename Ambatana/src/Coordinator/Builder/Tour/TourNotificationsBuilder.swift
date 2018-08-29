protocol TourNotificationsAssembly {
    func buildTourNotification(type: PrePermissionType, navigator: TourNotificationsNavigator) -> UIViewController
}

enum TourNotificationsBuilder {
    case standard(UINavigationController)
    case modal(UIViewController)
}

extension TourNotificationsBuilder: TourNotificationsAssembly {
    func buildTourNotification(type: PrePermissionType, navigator: TourNotificationsNavigator) -> UIViewController {
        let vm = TourNotificationsViewModel(
            title: type.title,
            subtitle: type.subtitle,
            pushText: type.pushMessage,
            source: type
        )
        vm.navigator = navigator

        let vc = TourNotificationsViewController(viewModel: vm)
        switch self {
        case .standard(_):
            return vc
        case .modal(_):
            return UINavigationController(rootViewController: vc)
        }
    }
}
