//
//  BubbleNotificationManager.swift
//  LetGo
//
//  Created by Dídac on 22/08/16.
//  Copyright © 2016 Ambatana. All rights reserved.
//

import Foundation

class BubbleNotificationManager {

    static let defaultDuration: NSTimeInterval = 3

    static let sharedInstance: BubbleNotificationManager = BubbleNotificationManager()

    private var bubble: BubbleNotification?


    // Showing Methods

    /**
     Adds bubble to the view and shows it
     
     - text: text of the notification
     - action: the action associated with the notification button
     - duration: for how long the notification should be shown
        . no duration: default duration
        . duration <= 0 : notification stays there until the user interacts with it.
     */

    func showBubble(text: String?, action: UIAction?, duration: NSTimeInterval?) {

        guard let appDelegate = UIApplication.sharedApplication().delegate as? AppDelegate else { return }
        guard let window = appDelegate.window else { return }

        bubble = BubbleNotification(text: text, action: action)

        guard let bubble = bubble else { return }
        bubble.translatesAutoresizingMaskIntoConstraints = false

        window.addSubview(bubble)
        bubble.setupOnView(window)
        bubble.showBubble()

        guard let duration = duration else {
            // if no duration is defined, we set the default for bubbles with no buttons
            NSTimer.scheduledTimerWithTimeInterval(BubbleNotificationManager.defaultDuration, target: self,
                                                   selector: #selector(hideBubble), userInfo: nil, repeats: false)
            return
        }

        let finalDuration = (action == nil && duration <= 0) ? BubbleNotificationManager.defaultDuration : duration

        if finalDuration > 0 {
            NSTimer.scheduledTimerWithTimeInterval(finalDuration, target: self, selector: #selector(hideBubble),
                                                   userInfo: nil, repeats: false)
        }
    }

    dynamic func hideBubble() {
        guard let bubble = bubble else { return }
        bubble.closeBubble()
        self.bubble = nil
    }
}
