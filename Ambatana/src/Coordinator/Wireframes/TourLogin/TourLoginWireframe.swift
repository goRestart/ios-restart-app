import LGCoreKit

final class TourLoginWireframe: TourLoginNavigator {
    private let nc: UINavigationController
    private let action: TourPostingAction
    private let tourAssembly: TourAssembly
    private let notificationAssembly: TourNotificationsAssembly
    private weak var tourSkipper: TourSkiperNavigator?

    convenience init(nc: UINavigationController,
                     action: @escaping TourPostingAction,
                     tourSkipper: TourSkiperNavigator?) {
        self.init(nc: nc,
                  action: action,
                  tourAssembly: TourBuilder.standard(nc),
                  notificationAssembly: TourNotificationsBuilder.standard(nc),
                  tourSkipper: tourSkipper)
    }

    init(nc: UINavigationController,
         action: @escaping TourPostingAction,
         tourAssembly: TourAssembly,
         notificationAssembly: TourNotificationsAssembly,
         tourSkipper: TourSkiperNavigator?) {
        self.nc = nc
        self.action = action
        self.tourAssembly = tourAssembly
        self.notificationAssembly = notificationAssembly
        self.tourSkipper = tourSkipper
    }

    func tourLoginFinish() {
        let pushPermissionsManager = LGPushPermissionsManager.sharedInstance
        let canAskForPushPermissions = pushPermissionsManager.shouldShowPushPermissionsAlertFromViewController(.onboarding)

        if canAskForPushPermissions {
            openTourNotifications()
        } else if Core.locationManager.shouldAskForLocationPermissions() {
            openTourLocation()
        } else {
            openTourPosting()
        }
    }

    private func openTourNotifications() {
        nc.addFadeTransition()
        let wireframe = TourNotificationWireframe(nc: nc, action: action, skipper: tourSkipper)
        let vc = notificationAssembly.buildTourNotification(type: .onboarding, navigator: wireframe)
        nc.setViewControllers([vc], animated: false)
    }

    private func openTourLocation() {
        nc.addFadeTransition()
        let vc = tourAssembly.buildTourLocation(action: action, skipper: tourSkipper)
        nc.setViewControllers([vc], animated: false)
    }

    private func openTourPosting() {
        nc.addFadeTransition()
        let vc = tourAssembly.buildTourPosting(action: action)
        nc.setViewControllers([vc], animated: false)
    }
}
