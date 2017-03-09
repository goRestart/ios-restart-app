//
//  WebSurveyViewModel.swift
//  LetGo
//
//  Created by Eli Kohen on 08/03/2017.
//  Copyright © 2017 Ambatana. All rights reserved.
//

import Foundation
import Amplitude_iOS

class WebSurveyViewModel: BaseViewModel {

    private static let submitRedirect = "letgo.com"

    weak var navigator: WebSurveyNavigator?

    var url: URL {
        var params = "?os=ios"
        if let userId = Amplitude.instance().userId {
            params.append("&user="+userId)
        }
        guard let fullUrl = URL(string: surveyUrl.absoluteString+params) else { return surveyUrl }
        return fullUrl
    }
    private let surveyUrl: URL

    private let tracker: Tracker

    convenience init(surveyUrl: URL) {
        self.init(surveyUrl: surveyUrl,
                  tracker: TrackerProxy.sharedInstance)
    }

    init(surveyUrl: URL, tracker: Tracker) {
        self.tracker = tracker
        self.surveyUrl = surveyUrl
    }

    override func didBecomeActive(_ firstTime: Bool) {
        if firstTime {
            trackVisit()
        }
    }

    func closeButtonPressed() {
        navigator?.closeWebSurvey()
    }

    func failedLoad() {
        navigator?.closeWebSurvey()
    }

    func shouldLoad(url: URL?) -> Bool {
        guard let url = url else { return false }
        if url.absoluteString.contains(WebSurveyViewModel.submitRedirect) {
            trackComplete()
            navigator?.webSurveyFinished()
            return false
        }
        return true
    }

    private func trackVisit() {
        let event = TrackerEvent.surveyStart(userId: Amplitude.instance().userId,
                                             surveyUrl: surveyUrl.absoluteString)
        tracker.trackEvent(event)
    }

    private func trackComplete() {
        let event = TrackerEvent.surveyCompleted(userId: Amplitude.instance().userId,
                                             surveyUrl: surveyUrl.absoluteString)
        tracker.trackEvent(event)
    }
}
