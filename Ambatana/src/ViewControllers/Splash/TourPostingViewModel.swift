import Foundation
import LGComponents

protocol TourPostingViewModelDelegate: BaseViewModelDelegate { }

class TourPostingViewModel: BaseViewModel {
    weak var navigator: TourPostingNavigator?

    let titleText = R.Strings.onboardingPostingTitleB
    let subtitleText = R.Strings.onboardingPostingSubtitleB
    let okButtonText = R.Strings.onboardingPostingButtonB
    
    let featureFlags: FeatureFlaggeable

    weak var delegate: TourPostingViewModelDelegate?
    
    init(featureFlags: FeatureFlaggeable) {
        self.featureFlags = featureFlags
        super.init()
    }
    
    convenience override init() {
        self.init(featureFlags: FeatureFlags.sharedInstance)
    }

    func cameraButtonPressed() {
        navigator?.tourPostingPost(fromCamera: true)
    }

    func okButtonPressed() {
        navigator?.tourPostingPost(fromCamera: false)
    }

    func closeButtonPressed() {
            let actionOk = UIAction(interface: UIActionInterface.text(R.Strings.onboardingAlertYes),
                                    action: { [weak self] in self?.navigator?.tourPostingPost(fromCamera: false) })
            let actionCancel = UIAction(interface: UIActionInterface.text(R.Strings.onboardingAlertNo),
                                        action: { [weak self] in self?.navigator?.tourPostingClose() })
            delegate?.vmShowAlert(R.Strings.onboardingPostingAlertTitle,
                                  message: R.Strings.onboardingPostingAlertSubtitle,
                                  actions: [actionCancel, actionOk])
    }
}
