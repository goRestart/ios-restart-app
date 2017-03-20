//
//  SurveysCoordinator.swift
//  LetGo
//
//  Created by Eli Kohen on 09/03/2017.
//  Copyright © 2017 Ambatana. All rights reserved.
//

import Foundation
import LGCoreKit

final class SurveysCoordinator: Coordinator {
    var child: Coordinator?
    var viewController = UIViewController()
    weak var coordinatorDelegate: CoordinatorDelegate?
    weak var presentedAlertController: UIAlertController?
    let bubbleNotificationManager: BubbleNotificationManager
    let sessionManager: SessionManager
    private var parentViewController: UIViewController?

    private let keyValueStorage: KeyValueStorageable

    weak var delegate: CoordinatorDelegate?


    // MARK: - Lifecycle

    convenience init?() {
        self.init(featureFlags: FeatureFlags.sharedInstance,
                  keyValueStorage: KeyValueStorage.sharedInstance,
                  bubbleNotificationManager: LGBubbleNotificationManager.sharedInstance,
                  sessionManager: Core.sessionManager)
    }

    init?(featureFlags: FeatureFlaggeable,
          keyValueStorage: KeyValueStorageable,
          bubbleNotificationManager: BubbleNotificationManager,
          sessionManager: SessionManager) {

        if let lastShownDate = keyValueStorage[.lastShownSurveyDate],
            abs(lastShownDate.timeIntervalSinceNow) < Constants.surveysMinGapTime {
            return nil
        }

        self.bubbleNotificationManager = bubbleNotificationManager
        self.sessionManager = sessionManager
        self.keyValueStorage = keyValueStorage

        if featureFlags.surveyEnabled {
            guard !featureFlags.surveyUrl.isEmpty, let surveyUrl = URL(string: featureFlags.surveyUrl) else { return nil }
            let vm = WebSurveyViewModel(surveyUrl: surveyUrl)
            vm.navigator = self
            let vc = WebSurveyViewController(viewModel: vm)
            self.viewController = vc
        } else if featureFlags.showNPSSurvey {
            let vm = NPSViewModel()
            vm.navigator = self
            let vc = NPSViewController(viewModel: vm)
            self.viewController = vc
        } else {
            return nil
        }
    }

    func presentViewController(parent: UIViewController, animated: Bool, completion: (() -> Void)?) {
        guard viewController.parent == nil else { return }

        parentViewController = parent
        parent.present(viewController, animated: animated) { [weak self] in
            self?.keyValueStorage[.lastShownSurveyDate] = Date()
            completion?()
        }
    }

    func dismissViewController(animated: Bool, completion: (() -> Void)?) {
        viewController.dismissWithPresented(animated: animated, completion: completion)
    }


    // MARK: - Private

    fileprivate func closeSurvey(animated: Bool, messageToShow: String?, completion: (() -> Void)?) {
        let parentViewController = self.parentViewController
        closeCoordinator(animated: animated) {
            guard let message = messageToShow else { return }
            parentViewController?.vmShowAutoFadingMessage(message, completion: nil)
        }
    }
}


// MARK: - WebSurveyNavigator

extension SurveysCoordinator: WebSurveyNavigator {
    func closeWebSurvey() {
        closeSurvey(animated: true, messageToShow: nil, completion: nil)
    }

    func webSurveyFinished() {
        closeSurvey(animated: true, messageToShow: LGLocalizedString.surveyConfirmation, completion: nil)
    }
}


// MARK: - NpsSurveyNavigator

extension SurveysCoordinator: NpsSurveyNavigator {
    func closeNpsSurvey() {
        closeSurvey(animated: true, messageToShow: nil, completion: nil)
    }

    func npsSurveyFinished() {
        closeSurvey(animated: true, messageToShow: nil, completion: nil)
    }
}
