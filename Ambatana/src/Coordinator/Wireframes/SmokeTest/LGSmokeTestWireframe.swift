import UIKit

protocol LGSmokeTestNavigator {
    func openOnBoarding()
    func openThankYou()
    func openDetail()
    func openFeedback()
}

final class LGSmokeTestWireframe: LGSmokeTestNavigator {

    weak var navigationController: UIViewController?
    
    private let assembly: LGSmokeTestAssembly
    private let feature: LGSmokeTestFeature
    private let userAvatarInfo: UserAvatarInfo?
    
    init(feature: LGSmokeTestFeature,
         assembly: LGSmokeTestAssembly,
         userAvatarInfo: UserAvatarInfo? = nil) {
        self.assembly = assembly
        self.feature = feature
        self.userAvatarInfo = userAvatarInfo
    }
    
    func openOnBoarding() {
        let vc = assembly.buildSmokeTestOnBoarding(withFeature: feature,
                                                   startAction: openDetail)
        navigationController?.present(vc, animated: true)
    }
    
    func openThankYou() {
        let vc = assembly.buildSmokeTestThankYou(withFeature: feature)
        navigationController?.present(vc, animated: true)
    }
    
    func openDetail() {
        let vc = assembly.buildSmokeTestDetail(withFeature: feature,
                                               userAvatarInfo: userAvatarInfo,
                                               openFeedbackAction: openFeedback,
                                               openThankYouAction: openThankYou)
        navigationController?.present(vc, animated: true)
    }
    
    func openFeedback() {
        let vc = assembly.buildSmokeTestFeedback(withFeature: feature,
                                                 openThankYouAction: openThankYou)
        navigationController?.present(vc, animated: true)
    }
}
