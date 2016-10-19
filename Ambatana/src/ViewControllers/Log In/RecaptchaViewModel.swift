//
//  RecaptchaViewModel.swift
//  LetGo
//
//  Created by Eli Kohen on 19/10/2016.
//  Copyright © 2016 Ambatana. All rights reserved.
//

import LGCoreKit

protocol RecaptchaNavigator: class {
    func recaptchaClose()
    func recaptchaFinishedWithToken(token: String)
}

class RecaptchaViewModel: BaseViewModel {

    weak var navigator: RecaptchaNavigator?
    private let tracker: Tracker

    convenience override init() {
        self.init(tracker: TrackerProxy.sharedInstance)
    }

    init(tracker: Tracker) {
        self.tracker = tracker
    }

    override func didBecomeActive(firstTime: Bool) {
        super.didBecomeActive(firstTime)
        if firstTime {
            trackVisit()
        }
    }

    var url: NSURL? {
        return LetgoURLHelper.buildRecaptchaURL()
    }

    func closeButtonPressed() {
        navigator?.recaptchaClose()
    }

    func startedLoadingURL(url: NSURL) {
        if let token = tokenFromURL(url) {
            navigator?.recaptchaFinishedWithToken(token)
        }
    }

    func urlLoaded(url: NSURL) { }


    // MARK: - Private methods

    private func tokenFromURL(url: NSURL) -> String? {
        let queryParams = url.queryParameters
        return queryParams["token"]
    }

    private func trackVisit() {
        let event = TrackerEvent.SignupCaptcha()
        tracker.trackEvent(event)
    }
}
