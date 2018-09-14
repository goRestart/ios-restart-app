import LGComponents

final class ShareScreenshotViewModel: BaseViewModel {
    
    let screenshotImage: UIImage
    private let socialSharer: SocialSharer
    
    var navigator: ShareScreenshotNavigator?
    
    
    // MARK: - Lifecycle
    
    convenience init(screenshotImage: UIImage) {
        self.init(screenshotImage: screenshotImage,
                  socialSharer: SocialSharer())
    }
    
    init(screenshotImage: UIImage,
         socialSharer: SocialSharer) {
        self.screenshotImage = screenshotImage
        self.socialSharer = socialSharer
        super.init()
    }
    
    
    // MARK - SocialSharer
    
    func buildShare(type: ShareType, viewController: UIViewController) {
        let socialMessage = AppShareSocialMessage(myUserId: nil, myUserName: nil)
        socialSharer.share(socialMessage, shareType: type, viewController: viewController)
    }
    
    
    // MARK: - Navigation
    
    func close() {
        navigator?.closeShareScreenshot()
    }
}
