import Foundation
import LGCoreKit

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
        defer { trackScreenshotEvent() }
        guard featureFlags.shareAfterScreenshot.isActive else { return }
        guard let topVC = UIApplication.getTopMostViewController() else { return }
        guard isNavigableToShareScreenshot(viewController: topVC) else { return }
        guard let image = UIApplication.shared.takeWindowSnapshot() else { return }
        let shareScreenshotAssembly = LGShareScreenshotBuilder.modal(root: topVC)
        let socialMessage = makeSocialMessage(topVC: topVC)
        
        let shareScreenshotVC = shareScreenshotAssembly.buildShareScreenshot(screenshotImage: image,
                                                                             socialMessage: socialMessage)
        topVC.navigationController?.present(shareScreenshotVC, animated: true, completion: nil)
    }
    
    
    // MARK: - Social message generator
    
    private func makeSocialMessage(topVC: UIViewController) -> SocialMessage {
        let socialMessage: SocialMessage
        let myUserId = myUserRepository.myUser?.objectId
        let myUserName = myUserRepository.myUser?.name
        if let profileViewController = topVC as? UserProfileViewController,
            let profileSocialMessage = profileViewController.retrieveSocialMessage() {
            socialMessage = profileSocialMessage
        } else if let listingViewController = topVC as? ListingCarouselViewController,
            let listingSocialMessage = listingViewController.retrieveSocialMessage() {
            socialMessage = listingSocialMessage
        } else {
            socialMessage = AppShareSocialMessage(myUserId: myUserId, myUserName: myUserName)
        }
        return socialMessage
    }
    
    private func isNavigableToShareScreenshot(viewController: UIViewController) -> Bool {
        if viewController.isKind(of: ShareScreenshotViewController.self) {
            // Should not navigate to another screenshot view controller if screenshot has taken from there
            return false
        }
        return true
    }
    
    // MARK: - Tracking
    
    private func trackScreenshotEvent() {
        let event = TrackerEvent.userDidTakeScreenshot()
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
