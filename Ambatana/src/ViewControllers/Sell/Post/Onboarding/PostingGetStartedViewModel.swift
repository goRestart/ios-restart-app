import LGCoreKit
import RxSwift
import LGComponents

class PostingGetStartedViewModel: BaseViewModel {
    
    weak var navigator: BlockingPostingNavigator?

    let tracker: Tracker
    var myUserRepository: MyUserRepository
    let featureFlags: FeatureFlaggeable
    
    var userAvatarURL: URL? {
        return myUserRepository.myUser?.avatar?.fileURL
    }
    let userAvatarImage = Variable<UIImage?>(nil)
    var userName: String? {
        return myUserRepository.myUser?.shortName
    }

    var welcomeText: String {
        guard let name = userName else { return R.Strings.postGetStartedWelcomeLetgoText }
        return R.Strings.postGetStartedWelcomeUserText(name)
    }

    var infoText: String {
        return R.Strings.postGetStartedIntroText
    }

    var buttonText: String {
        return R.Strings.postGetStartedButtonText
    }

    var buttonIcon: UIImage? {
        return #imageLiteral(resourceName: "ic_camera_blocking_tour")
    }

    var discardText: String {
        return R.Strings.postGetStartedDiscardText
    }
    
    var shouldShowSkipButton: Bool {
        return featureFlags.onboardingIncentivizePosting == .blockingPostingSkipWelcome
    }

    
    // MARK: - Lifecycle
    
    override convenience init() {
        self.init(myUserRepository: Core.myUserRepository,
                  tracker: TrackerProxy.sharedInstance,
                  featureFlags: FeatureFlags.sharedInstance)
    }

    init(myUserRepository: MyUserRepository, tracker: Tracker, featureFlags: FeatureFlaggeable) {
        self.myUserRepository = myUserRepository
        self.tracker = tracker
        self.featureFlags = featureFlags
        super.init()
        retrieveImageForAvatar()
    }
    
    override func didBecomeActive(_ firstTime: Bool) {
        super.didBecomeActive(firstTime)
        guard firstTime else { return }
        trackVisit()
    }

    func retrieveImageForAvatar() {
        guard let avatarUrl = userAvatarURL else { return }
        ImageDownloader.sharedInstance.downloadImageWithURL(avatarUrl) { [weak self] result, url in
            guard let imageWithSource = result.value, url == self?.userAvatarURL else { return }
            self?.userAvatarImage.value = imageWithSource.image
        }
    }

    
    // MARK: - Navigation
    
    func nextAction() {
        navigator?.openCamera()
    }
    
    func skipAction() {
        trackPostSellAbandon()
        navigator?.closePosting()
    }
    
    
    // MARK: - Tracker
    
    private func trackVisit() {
        let event = TrackerEvent.listingSellStart(.onboarding,
                                                  buttonName: PostingSource.onboardingBlockingPosting.buttonName,
                                                  sellButtonPosition: PostingSource.onboardingBlockingPosting.sellButtonPosition,
                                                  category: nil,
                                                  mostSearchedButton: PostingSource.onboardingBlockingPosting.mostSearchedButton,
                                                  predictiveFlow: false)
        tracker.trackEvent(event)
    }
    
    private func trackPostSellAbandon() {
        let event = TrackerEvent.listingSellAbandon(abandonStep: .welcomeOnboarding)
        tracker.trackEvent(event)
    }
}

