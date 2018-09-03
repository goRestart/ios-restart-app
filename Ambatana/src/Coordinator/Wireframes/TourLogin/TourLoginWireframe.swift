import LGCoreKit

final class TourLoginWireframe: TourLoginNavigator {
    private let nc: UINavigationController
    private let action: TourPostingAction
    private let assembly: TourAssembly
    private weak var tourSkipper: TourSkiperNavigator?

    convenience init(nc: UINavigationController,
                     action: @escaping TourPostingAction,
                     tourSkipper: TourSkiperNavigator?) {
        self.init(nc: nc, action: action,
                  assembly: TourBuilder.standard(nc: nc),
                  tourSkipper: tourSkipper)
    }

    init(nc: UINavigationController,
         action: @escaping TourPostingAction,
         assembly: TourAssembly,
         tourSkipper: TourSkiperNavigator?) {
        self.nc = nc
        self.action = action
        self.assembly = assembly
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
        let vc = assembly.buildTourNotification(action: action, skipper: tourSkipper)
        nc.setViewControllers([vc], animated: false)
    }

    private func openTourLocation() {
        nc.addFadeTransition()
        let vc = assembly.buildTourLocation(action: action, skipper: tourSkipper)
        nc.setViewControllers([vc], animated: false)
    }

    private func openTourPosting() {
        nc.addFadeTransition()
        let vc = assembly.buildTourPosting(action: action)
        nc.setViewControllers([vc], animated: false)
    }
}
