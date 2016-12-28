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
    let backgroundImage: UIImage?
    var isTransparentMode: Bool {
        return backgroundImage != nil
    }

    convenience init(backgroundImage: UIImage?) {
        self.init(tracker: TrackerProxy.sharedInstance, backgroundImage: backgroundImage)
    }

    init(tracker: Tracker, backgroundImage: UIImage?) {
        self.tracker = tracker
        self.backgroundImage = backgroundImage
    }

    override func didBecomeActive(firstTime: Bool) {
        super.didBecomeActive(firstTime)
        if firstTime {
            trackVisit()
        }
    }

    var url: NSURL? {
        return LetgoURLHelper.buildRecaptchaURL(transparent: transparentMode)
    }

    func closeButtonPressed() {
        navigator?.recaptchaClose()
    }

    func startedLoadingURL(url: NSURL) {
        guard let token = tokenFromURL(url) else { return }
        navigator?.recaptchaFinishedWithToken(token)
    }

    func urlLoaded(url: NSURL) { }


    // MARK: - Private methods

    private func tokenFromURL(url: NSURL) -> String? {
        let queryParams = url.queryParameters
        return queryParams["token"]
    }

    private func trackVisit() {
        let event = TrackerEvent.signupCaptcha()
        tracker.trackEvent(event)
    }
}
