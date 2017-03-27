//
//  WebSurveyViewModel.swift
//  LetGo
//
//  Created by Eli Kohen on 08/03/2017.
//  Copyright © 2017 Ambatana. All rights reserved.
//

import Foundation
import LGCoreKit

class WebSurveyViewModel: BaseViewModel {

    private static let submitRedirect = "letgo.com"

    weak var navigator: WebSurveyNavigator?

    var url: URL {
        var params = "?os=ios"
        if let userId = myUserRepository.myUser?.emailOrId {
            params.append("&user="+userId)
        }
        guard let fullUrl = URL(string: surveyUrl.absoluteString+params) else { return surveyUrl }
        return fullUrl
    }
    private let surveyUrl: URL

    private let tracker: Tracker
    private let myUserRepository: MyUserRepository

    convenience init(surveyUrl: URL) {
        self.init(surveyUrl: surveyUrl,
                  tracker: TrackerProxy.sharedInstance,
                  myUserRepository: Core.myUserRepository)
    }

    init(surveyUrl: URL, tracker: Tracker, myUserRepository: MyUserRepository) {
        self.tracker = tracker
        self.surveyUrl = surveyUrl
        self.myUserRepository = myUserRepository
    }

    override func didBecomeActive(_ firstTime: Bool) {
        if firstTime {
            trackVisit()
        }
    }

    func closeButtonPressed() {
        navigator?.closeWebSurvey()
    }

    func didFailNavigation() {
        navigator?.closeWebSurvey()
    }

    func shouldLoad(url: URL?) -> Bool {
        guard let urlHost = url?.host else { return false }
        if urlHost.contains(WebSurveyViewModel.submitRedirect) {
            trackComplete()
            navigator?.webSurveyFinished()
            return false
        }
        return true
    }

    private func trackVisit() {
        let event = TrackerEvent.surveyStart(userId: myUserRepository.myUser?.emailOrId,
                                             surveyUrl: surveyUrl.absoluteString)
        tracker.trackEvent(event)
    }

    private func trackComplete() {
        let event = TrackerEvent.surveyCompleted(userId: myUserRepository.myUser?.emailOrId,
                                             surveyUrl: surveyUrl.absoluteString)
        tracker.trackEvent(event)
    }
}
