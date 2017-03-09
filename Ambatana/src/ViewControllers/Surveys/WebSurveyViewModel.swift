//
//  WebSurveyViewModel.swift
//  LetGo
//
//  Created by Eli Kohen on 08/03/2017.
//  Copyright © 2017 Ambatana. All rights reserved.
//

import Foundation

class WebSurveyViewModel: BaseViewModel {

    private static let submitRedirect = "letgo.com"

    weak var navigator: WebSurveyNavigator?

    let url: URL

    convenience init(surveyUrl: URL) {
        self.init(surveyUrl: surveyUrl,
                  tracker: TrackerProxy.sharedInstance)
    }

    init(surveyUrl: URL, tracker: Tracker) {
        self.url = surveyUrl
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
        //TODO implement
    }

    private func trackComplete() {
        //TODO implement
    }
}
