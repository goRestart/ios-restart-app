//
//  AppEventsManager.swift
//  LetGo
//
//  Created by Álvaro Murillo del Puerto on 9/5/18.
//  Copyright © 2018 Ambatana. All rights reserved.
//

import Foundation

final class AppEventsManager {

    static let sharedInstance: AppEventsManager = AppEventsManager()

    private let tracker: Tracker

    convenience init() {
         self.init(tracker: TrackerProxy.sharedInstance)
    }

    init(tracker: Tracker) {
        self.tracker = tracker
        NotificationCenter.default.addObserver(self, selector: #selector(userDidTakeScreenshot),
                                               name:NSNotification.Name.UIApplicationUserDidTakeScreenshot, object: nil)
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    @objc func userDidTakeScreenshot(_ notification: Notification) {
        let event = TrackerEvent.userDidTakeScreenshot()
        tracker.trackEvent(event)
    }
}
