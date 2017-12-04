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
    func recaptchaFinishedWithToken(_ token: String)
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

    override func didBecomeActive(_ firstTime: Bool) {
        super.didBecomeActive(firstTime)
        if firstTime {
            trackVisit()
        }
    }

    var url: URL? {
        return LetgoURLHelper.buildRecaptchaURL()
    }

    func closeButtonPressed() {
        navigator?.recaptchaClose()
    }

    func startedLoadingURL(_ url: URL) {
        guard let token = tokenFromURL(url) else { return }
        navigator?.recaptchaFinishedWithToken(token)
    }

    func urlLoaded(_ url: URL) { }


    // MARK: - Private methods

    private func tokenFromURL(_ url: URL) -> String? {
        let queryParams = url.queryParameters
        return queryParams["token"]
    }

    private func trackVisit() {
        let event = TrackerEvent.signupCaptcha()
        tracker.trackEvent(event)
    }
}
