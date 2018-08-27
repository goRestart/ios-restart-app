final class TourSkiperWireframe: TourSkiperNavigator {
    private let deepLinksRouter: DeepLinksRouter
    private let appCoordinator: AppCoordinator

    var shouldSkipTour: Bool { return deepLinksRouter.initialDeeplinkAvailable }

    init(appCoordinator: AppCoordinator, deepLinksRouter: DeepLinksRouter) {
        self.appCoordinator = appCoordinator
        self.deepLinksRouter = deepLinksRouter
    }

    func skipTour() {
        appCoordinator.tabBarCtl.dismissAllPresented { [weak self] in
            self?.earlyExitTour()
        }
    }

    private func earlyExitTour() {
        if let pendingDeepLink = deepLinksRouter.consumeInitialDeepLink() {
            appCoordinator.openDeepLink(deepLink: pendingDeepLink)
        } else {
            appCoordinator.openHome()
        }
    }
}
