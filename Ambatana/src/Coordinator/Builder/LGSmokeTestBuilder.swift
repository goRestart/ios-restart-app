
import UIKit

protocol LGSmokeTestAssembly {
    func buildSmokeTestOnBoarding(withFeature feature: LGSmokeTestFeature,
                                  startAction: (() -> Void)?) -> UIViewController
    func buildSmokeTestDetail(withFeature feature: LGSmokeTestFeature,
                              userAvatarInfo: UserAvatarInfo?,
                              openFeedbackAction: (() -> Void)?,
                              openThankYouAction: (() -> Void)?) -> UIViewController
    func buildSmokeTestFeedback(withFeature feature: LGSmokeTestFeature,
                                openThankYouAction: (() -> Void)?) -> UIViewController
    func buildSmokeTestThankYou(withFeature feature: LGSmokeTestFeature) -> UIViewController
}

enum LGSmokeTestBuilder {
    case modal(UINavigationController)
}

extension LGSmokeTestBuilder: LGSmokeTestAssembly {
    
    func buildSmokeTestOnBoarding(withFeature feature: LGSmokeTestFeature,
                                  startAction: (() -> Void)?) -> UIViewController {
        switch self {
        case .modal(let nav):
            let viewModel = LGSmokeTestOnBoardingViewModel(feature: feature,
                                                           startAction: startAction)
            let viewController = LGSmokeTestOnBoardingViewController(viewModel: viewModel)
            viewModel.navigator = nav
            return viewController
        }
    }
    
    func buildSmokeTestDetail(withFeature feature: LGSmokeTestFeature,
                              userAvatarInfo: UserAvatarInfo?,
                              openFeedbackAction: (() -> Void)?,
                              openThankYouAction: (() -> Void)?) -> UIViewController {
        switch self {
        case .modal(let nav):
            let viewModel = LGSmokeTestDetailViewModel(feature: feature,
                                                       userAvatarInfo: userAvatarInfo,
                                                       openFeedbackAction: openFeedbackAction,
                                                       openThankYouAction: openThankYouAction)
            viewModel.navigator = nav
            return LGSmokeTestDetailViewController(viewModel: viewModel)
        }
    }
    
    func buildSmokeTestFeedback(withFeature feature: LGSmokeTestFeature,
                                openThankYouAction: (() -> Void)?) -> UIViewController {
        switch self {
        case .modal(let nav):
            let viewModel = LGSmokeTestFeedbackViewModel(feature: feature,
                                                         openThankYouAction: openThankYouAction)
            viewModel.navigator = nav
            return LGSmokeTestFeedbackViewController(viewModel: viewModel)
        }
    }
    
    func buildSmokeTestThankYou(withFeature feature: LGSmokeTestFeature) -> UIViewController {
        switch self {
        case .modal:
            let viewModel = LGSmokeTestThankYouViewModel(feature: feature)
            return LGSmokeTestThankYouViewController(viewModel: viewModel)
        }
    }
    
}
