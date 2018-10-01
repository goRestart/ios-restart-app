import LGCoreKit

final class TourLocationWireframe: TourLocationNavigator {
    private weak var nc: UINavigationController?
    private let action: TourPostingAction
    private let assembly: TourAssembly

    private weak var skipper: TourSkiperNavigator?
    private let featureFlags: FeatureFlaggeable
    private var shouldShowBlockingPosting: Bool { return featureFlags.onboardingIncentivizePosting.isActive }

    convenience init(nc: UINavigationController,
                     action: @escaping TourPostingAction,
                     skipper: TourSkiperNavigator?) {
        self.init(nc: nc, action: action,
                  assembly: TourBuilder.standard(nc),
                  featureFlags: FeatureFlags.sharedInstance,
                  skipper: skipper)
    }

    init(nc: UINavigationController,
         action: @escaping TourPostingAction,
         assembly: TourAssembly,
         featureFlags: FeatureFlaggeable,
         skipper: TourSkiperNavigator?) {
        self.nc = nc
        self.action = action
        self.assembly = assembly
        self.featureFlags = featureFlags
        self.skipper = skipper
    }

    func tourLocationFinish() {
        openNextTour()
    }

    private func openNextTour() {
        guard false else {
            action(TourPosting(posting: false, source: .onboardingBlockingPosting))
            return
        }
        if let tourSkipper = skipper, tourSkipper.shouldSkipTour {
            tourSkipper.skipTour()
        } else if shouldShowBlockingPosting {
            action(TourPosting(posting: true, source: .onboardingBlockingPosting))
        } else {
            openTourPosting()
        }
    }

    private func openTourPosting() {
        nc?.addFadeTransition()

        let vc = assembly.buildTourPosting(action: action)
        nc?.setViewControllers([vc], animated: false)
    }

}
