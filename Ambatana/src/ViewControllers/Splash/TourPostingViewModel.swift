import Foundation
import LGComponents

protocol TourPostingViewModelDelegate: BaseViewModelDelegate { }

final class TourPostingViewModel: BaseViewModel {
    var navigator: TourPostingNavigator?

    let titleText = R.Strings.onboardingPostingTitleB
    let subtitleText = R.Strings.onboardingPostingSubtitleB
    let okButtonText = R.Strings.onboardingPostingButtonB
    
    let featureFlags: FeatureFlaggeable

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

    func cancelButtonPressed() {
        navigator?.tourPostingClose()
    }
}
