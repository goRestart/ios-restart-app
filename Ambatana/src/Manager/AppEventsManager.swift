import Foundation
import LGCoreKit

struct ScreenshotData {
    let type: ScreenshotType
    let socialMessage: SocialMessage
}

enum ScreenshotType {
    case profile(userToId: String)
    case listingDetail(listingId: String)
    case searchComplete(searchString: String, feedSource: EventParameterFeedSource)
    case listingList(feedSource: EventParameterFeedSource)
    case other
    
    var trackingType: EventParameterScreenshotType? {
        switch self {
        case .profile:
            return .profileVisit
        case .listingDetail:
            return .listingDetailVisit
        case .searchComplete:
            return .searchComplete
        case .listingList:
            return .listingList
        case .other:
            return nil
        }
    }
    
    var listingId: String? {
        switch self {
        case .listingDetail(let listingId):
            return listingId
        case .profile, .searchComplete, .listingList, .other:
            return nil
        }
    }
    
    var feedSource: EventParameterFeedSource? {
        switch self {
        case .listingList(let feedSource):
            return feedSource
        case .searchComplete(_, let feedSource):
            return feedSource
        case .profile, .listingDetail, .other:
            return nil
        }
    }
    
    var searchString: String? {
        switch self {
        case .searchComplete(let searchString, _):
            return searchString
        case .profile, .listingDetail, .listingList, .other:
            return nil
        }
    }
    
    var userToId: String? {
        switch self {
        case .profile(let userToId):
            return userToId
        case .other, .listingDetail, .searchComplete, .listingList:
            return nil
        }
    }
}

final class AppEventsManager {

    static let sharedInstance: AppEventsManager = AppEventsManager()

    private let tracker: Tracker
    private let featureFlags: FeatureFlaggeable
    private let myUserRepository: MyUserRepository

    convenience init() {
         self.init(tracker: TrackerProxy.sharedInstance,
                   featureFlags: FeatureFlags.sharedInstance,
                   myUserRepository: Core.myUserRepository)
    }

    init(tracker: Tracker, featureFlags: FeatureFlaggeable, myUserRepository: MyUserRepository) {
        self.tracker = tracker
        self.featureFlags = featureFlags
        self.myUserRepository = myUserRepository
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(userDidTakeScreenshot),
                                               name: .UIApplicationUserDidTakeScreenshot,
                                               object: nil)
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    @objc func userDidTakeScreenshot(_ notification: Notification) {
        guard let topVC = UIApplication.getTopMostViewController() else {
            trackScreenshotEvent(screenshotType: nil)
            return
        }
        let screenshotData = processScreenshot(topVC: topVC)
        trackScreenshotEvent(screenshotType: screenshotData.type)

        guard featureFlags.shareAfterScreenshot.isActive else { return }
        guard isNavigableToShareScreenshot(viewController: topVC) else { return }
        guard let image = UIApplication.shared.takeWindowSnapshot() else { return }
        let shareScreenshotAssembly = LGShareScreenshotBuilder.modal(root: topVC)
        let shareScreenshotVC = shareScreenshotAssembly.buildShareScreenshot(screenshotImage: image,
                                                                             screenshotData: screenshotData)
        topVC.navigationController?.present(shareScreenshotVC, animated: false, completion: nil)
    }
    
    
    // MARK: - Screenshot processor
    
    private func processScreenshot(topVC: UIViewController) -> ScreenshotData {
        let myUserId = myUserRepository.myUser?.objectId
        let myUserName = myUserRepository.myUser?.name
        let screenshotType: ScreenshotType
        let socialMessage: SocialMessage
        if let profileViewController = topVC as? UserProfileViewController,
            let profileSocialMessage = profileViewController.retrieveSocialMessage(),
            let userToId = profileViewController.userToId {
            screenshotType = .profile(userToId: userToId)
            socialMessage = profileSocialMessage
        } else if let listingViewController = topVC as? ListingCarouselViewController,
            let listingSocialMessage = listingViewController.retrieveSocialMessage(),
            let listingId = listingViewController.listingId {
            screenshotType = .listingDetail(listingId: listingId)
            socialMessage = listingSocialMessage
        } else if let feedViewController = topVC as? MainListingsViewController,
            let searchString = feedViewController.searchString {
            let feedSource = feedViewController.feedSource
            screenshotType = .searchComplete(searchString: searchString, feedSource: feedSource)
            socialMessage = AppShareSocialMessage(myUserId: myUserId, myUserName: myUserName)
        } else if let feedViewController = topVC as? MainListingsViewController {
            let feedSource = feedViewController.feedSource
            screenshotType = .listingList(feedSource: feedSource)
            socialMessage = AppShareSocialMessage(myUserId: myUserId, myUserName: myUserName)
        } else {
            screenshotType = .other
            socialMessage = AppShareSocialMessage(myUserId: myUserId, myUserName: myUserName)
        }
        return ScreenshotData(type: screenshotType,
                              socialMessage: socialMessage)
    }
    
    private func isNavigableToShareScreenshot(viewController: UIViewController) -> Bool {
        if viewController.isKind(of: ShareScreenshotViewController.self) {
            // Should not navigate to another screenshot view controller if screenshot has taken from there
            return false
        }
        return true
    }
    
    // MARK: - Tracking
    
    private func trackScreenshotEvent(screenshotType: ScreenshotType?) {
        let event = TrackerEvent.userDidTakeScreenshot(type: screenshotType)
        tracker.trackEvent(event)
    }
}

fileprivate extension UIApplication {
    class func getTopMostViewController(base: UIViewController? = UIApplication.shared.keyWindow?.rootViewController) -> UIViewController? {
        if let nav = base as? UINavigationController {
            return getTopMostViewController(base: nav.visibleViewController)
        }
        if let tab = base as? UITabBarController {
            if let selected = tab.selectedViewController {
                return getTopMostViewController(base: selected)
            }
        }
        if let presented = base?.presentedViewController {
            return getTopMostViewController(base: presented)
        }
        return base
    }
}

fileprivate extension UIApplication {
    func takeWindowSnapshot() -> UIImage? {
        return keyWindow?.layer.takeSnapshot()
    }
}

fileprivate extension CALayer {
    func takeSnapshot() -> UIImage? {
        let scale = UIScreen.main.scale
        UIGraphicsBeginImageContextWithOptions(frame.size, false, scale)
        if let context = UIGraphicsGetCurrentContext() {
            render(in: context)
            let screenshot = UIGraphicsGetImageFromCurrentImageContext()
            UIGraphicsEndImageContext()
            return screenshot
        }
        return nil
    }
}
