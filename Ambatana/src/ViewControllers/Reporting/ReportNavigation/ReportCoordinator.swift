import Foundation
import LGCoreKit
import LGComponents

enum ReportCoordinatorType {
    case product(listing: Listing)
    case user

    fileprivate var options: ReportOptionsGroup {
        switch self {
        case .product: return ReportOptionsBuilder.reportProductOptions()
        case .user: return ReportOptionsBuilder.reportUserOptions()
        }
    }

    fileprivate var title: String {
        switch self {
        case .product: return R.Strings.reportingListingTitle
        case .user: return R.Strings.reportingUserTitle
        }
    }

    var listing: Listing? {
        switch self {
        case .product(let listing): return listing
        case .user: return nil
        }
    }
}

final class ReportCoordinator: Coordinator {
    var child: Coordinator?
    weak var coordinatorDelegate: CoordinatorDelegate?
    weak var presentedAlertController: UIAlertController?
    var viewController: UIViewController
    var bubbleNotificationManager: BubbleNotificationManager
    var sessionManager: SessionManager

    fileprivate let tracker: Tracker
    fileprivate let featureFlags: FeatureFlaggeable
    fileprivate let type: ReportCoordinatorType
    fileprivate let reportedId: String
    fileprivate let source: EventParameterTypePage
    fileprivate let reportingRepository: ReportingRepository

    convenience init(type: ReportCoordinatorType, reportedId: String, source: EventParameterTypePage) {
        self.init(bubbleNotificationManager: LGBubbleNotificationManager.sharedInstance,
                  featureFlags: FeatureFlags.sharedInstance,
                  tracker: TrackerProxy.sharedInstance,
                  sessionManager: Core.sessionManager,
                  reportingRepository: Core.reportingRepository,
                  type: type,
                  reportedId: reportedId,
                  source: source)
    }

    init(bubbleNotificationManager: BubbleNotificationManager,
         featureFlags: FeatureFlaggeable,
         tracker: Tracker,
         sessionManager: SessionManager,
         reportingRepository: ReportingRepository,
         type: ReportCoordinatorType,
         reportedId: String,
         source: EventParameterTypePage) {
        self.bubbleNotificationManager = bubbleNotificationManager
        self.featureFlags = featureFlags
        self.sessionManager = sessionManager
        self.type = type
        self.reportedId = reportedId
        self.tracker = tracker
        self.source = source
        self.reportingRepository = reportingRepository

        let vm = ReportOptionsListViewModel(optionGroup: type.options, title: type.title, tracker: tracker,
                                            reportedId: reportedId, source: source, reportingRepository: reportingRepository,
                                            superReason: nil, listing: type.listing)
        let vc = ReportOptionsListViewController(viewModel: vm)
        let nav = UINavigationController(rootViewController: vc)
        viewController = nav
        vm.navigator = self
    }

    func presentViewController(parent: UIViewController, animated: Bool, completion: (() -> Void)?) {
        guard viewController.parent == nil else { return }
        parent.present(viewController, animated: animated, completion: completion)
    }

    func dismissViewController(animated: Bool, completion: (() -> Void)?) {
        viewController.dismiss(animated: animated, completion: completion)
    }
}

extension ReportCoordinator: ReportNavigator {

    func openNextStep(with options: ReportOptionsGroup, from: ReportOptionType) {
        guard let navCtl = viewController as? UINavigationController else { return }
        let vm = ReportOptionsListViewModel(optionGroup: options, title: type.title, tracker: tracker,
                                            reportedId: reportedId, source: source, reportingRepository: reportingRepository,
                                            superReason: from, listing: type.listing)
        vm.navigator = self
        let vc = ReportOptionsListViewController(viewModel: vm)
        navCtl.pushViewController(vc, animated: true)
    }

    func openReportSentScreen(type: ReportSentType) {
        guard let navCtl = viewController as? UINavigationController else { return }
        let vm = ReportSentViewModel(reportSentType: type, reportedObjectId: reportedId)
        vm.navigator = self
        let vc = ReportSentViewController(viewModel: vm)
        vm.delegate = vc
        navCtl.pushViewController(vc, animated: true)
    }

    func closeReporting() {
        closeCoordinator(animated: true, completion: nil)
    }

    func openReviewUser(userId: String, userAvatar: File?, userName: String?) {
        let data = RateUserData(userId: userId, userAvatar: userAvatar, userName: userName, listingId: nil, ratingType: .report)
        let child = UserRatingCoordinator(source: .report, data: data)
        openChild(coordinator: child, parent: viewController, animated: true, forceCloseChild: false, completion: nil)
    }
}
