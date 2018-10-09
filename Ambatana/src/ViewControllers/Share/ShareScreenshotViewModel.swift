import LGComponents
import LGCoreKit

final class ShareScreenshotViewModel: BaseViewModel, SocialSharerDelegate {

    let screenshotImage: UIImage
    private let screenshotData: ScreenshotData
    private let tracker: Tracker
    private let socialSharer: SocialSharer
    private let myUserRepository: MyUserRepository

    var navigator: ShareScreenshotNavigator?
    
    
    // MARK: - Lifecycle
    
    convenience init(screenshotImage: UIImage, screenshotData: ScreenshotData) {
        self.init(screenshotImage: screenshotImage,
                  screenshotData: screenshotData,
                  tracker: TrackerProxy.sharedInstance,
                  socialSharer: SocialSharer(),
                  myUserRepository: Core.myUserRepository)
    }
    
    init(screenshotImage: UIImage,
         screenshotData: ScreenshotData,
         tracker: Tracker,
         socialSharer: SocialSharer,
         myUserRepository: MyUserRepository) {
        self.screenshotImage = screenshotImage
        self.screenshotData = screenshotData
        self.tracker = tracker
        self.socialSharer = socialSharer
        self.myUserRepository = myUserRepository
        super.init()
        
        socialSharer.delegate = self
    }
    
    
    // MARK: - SocialSharer
    
    func buildShare(type: ShareType, viewController: UIViewController) {
        socialSharer.share(screenshotData.socialMessage,
                           shareType: type,
                           viewController: viewController,
                           image: screenshotImage)
    }
    
    
    // MARK: - SocialSharerDelegate
    
    func shareStartedIn(_ shareType: ShareType) {
        let event = TrackerEvent.shareScreenshot(type: screenshotData.type)
        tracker.trackEvent(event)
    }
    
    func shareFinishedIn(_ shareType: ShareType, withState state: SocialShareState) {
        let event = TrackerEvent.shareScreenshotComplete(type: screenshotData.type,
                                                         network: shareType.trackingShareNetwork)
        tracker.trackEvent(event)
    }
    
    
    // MARK: - Navigation
    
    func close() {
        navigator?.closeShareScreenshot()
    }
}
