//
//  NPSViewModel.swift
//  LetGo
//
//  Created by Isaac Roldan on 29/8/16.
//  Copyright © 2016 Ambatana. All rights reserved.
//

import Foundation

class NPSViewModel: BaseViewModel {
    private let tracker: Tracker
    
    convenience override init() {
        let tracker = TrackerProxy.sharedInstance
        self.init(tracker: tracker)
    }
    
    init(tracker: Tracker) {
        self.tracker = tracker
    }
    
    override func didBecomeActive(_ firstTime: Bool) {
        let event = TrackerEvent.npsStart()
        tracker.trackEvent(event)
    }
    
    func vmDidFinishSurvey(_ score: Int) {
        let event = TrackerEvent.npsComplete(score)
        tracker.trackEvent(event)
    }
}
