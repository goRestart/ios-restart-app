import LGCoreKit

protocol TourSkiperNavigator: class {
    var shouldSkipTour: Bool { get }
    func skipTour()
}

final class TourNotificationWireframe: TourNotificationsNavigator {
    private let nc: UINavigationController
    private let action: TourPostingAction
    private let locationManager: LocationManager
    private let assembly: TourAssembly

    private weak var skipper: TourSkiperNavigator?

    private let featureFlags: FeatureFlaggeable
    private var shouldShowBlockingPosting: Bool { return featureFlags.onboardingIncentivizePosting.isActive }

    convenience init(nc: UINavigationController, action: @escaping TourPostingAction, skipper: TourSkiperNavigator?) {
        self.init(nc: nc, action: action,
                  locationManager: Core.locationManager,
                  featureFlags: FeatureFlags.sharedInstance,
                  assembly: TourBuilder.standard(nc),
                  skipper: skipper)
    }

    init(nc: UINavigationController,
         action: @escaping TourPostingAction,
         locationManager: LocationManager,
         featureFlags: FeatureFlaggeable,
         assembly: TourAssembly,
         skipper: TourSkiperNavigator?) {
        self.nc = nc
        self.action = action
        self.locationManager = locationManager
        self.assembly = assembly
        self.featureFlags = featureFlags
        self.skipper = skipper
    }

    func showTourLocation() {
        nc.addFadeTransition()

        let vc = assembly.buildTourLocation(action: action, skipper: skipper)
        nc.setViewControllers([vc], animated: false)
    }

    func closeTour() {
        action(TourPosting(posting: false, source: nil))
    }

    func tourNotificationsFinish() {
        if locationManager.shouldAskForLocationPermissions() {
            showTourLocation()
        } else {
            openNextTour()
        }
    }

    private func openNextTour() {
        if let tourSkipper = skipper, tourSkipper.shouldSkipTour {
            tourSkipper.skipTour()
        } else if shouldShowBlockingPosting {
            action(TourPosting(posting: true, source: .onboardingBlockingPosting))
        } else {
            openTourPosting()
        }
    }

    private func openTourPosting() {
        nc.addFadeTransition()

        let vc = assembly.buildTourPosting(action: action)
        nc.setViewControllers([vc], animated: false)
    }
}
