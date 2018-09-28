import LGComponents
import LGCoreKit

final class ShareScreenshotViewModel: BaseViewModel {
    
    let screenshotImage: UIImage
    private let socialSharer: SocialSharer
    private let myUserRepository: MyUserRepository
    private var socialMessage: SocialMessage
    var navigator: ShareScreenshotNavigator?
    
    
    // MARK: - Lifecycle
    
    convenience init(screenshotImage: UIImage, socialMessage: SocialMessage) {
        self.init(screenshotImage: screenshotImage,
                  socialMessage: socialMessage,
                  socialSharer: SocialSharer(),
                  myUserRepository: Core.myUserRepository)
    }
    
    init(screenshotImage: UIImage,
         socialMessage: SocialMessage,
         socialSharer: SocialSharer,
         myUserRepository: MyUserRepository) {
        self.screenshotImage = screenshotImage
        self.socialMessage = socialMessage
        self.socialSharer = socialSharer
        self.myUserRepository = myUserRepository
        super.init()
    }
    
    
    // MARK - SocialSharer
    
    func buildShare(type: ShareType, viewController: UIViewController) {
        socialSharer.share(socialMessage, shareType: type, viewController: viewController, image: screenshotImage)
    }
    
    
    // MARK: - Navigation
    
    func close() {
        navigator?.closeShareScreenshot()
    }
}
