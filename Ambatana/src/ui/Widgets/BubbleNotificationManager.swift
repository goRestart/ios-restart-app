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

    private var taggedNotifications: [String : [BubbleNotification]] = [:]


    // Showing Methods

    /**
     Adds bubble to the view and shows it
     
     - text: text of the notification
     - action: the action associated with the notification button
     - duration: for how long the notification should be shown
        . no duration: default duration
        . duration <= 0 : notification stays there until the user interacts with it.
     */

    func showBubble(data: BubbleNotificationData, duration: NSTimeInterval?) {

        guard let appDelegate = UIApplication.sharedApplication().delegate as? AppDelegate else { return }
        guard let window = appDelegate.window else { return }

        let frame = CGRect(x: 0, y: 0, width: window.frame.width, height: BubbleNotification.initialHeight)
        let bubble = BubbleNotification(frame: frame, data: data)
        bubble.delegate = self

        bubble.translatesAutoresizingMaskIntoConstraints = false
        window.addSubview(bubble)
        bubble.setupOnView(window)

        if let tag = data.tagGroup {
            if taggedNotifications[tag] == nil {
                taggedNotifications[tag] = []
            }
            taggedNotifications[tag]?.append(bubble)
        }

        guard let duration = duration else {
            // if no duration is defined, we set the default for bubbles with no buttons
            bubble.showBubble(autoDismissTime: BubbleNotificationManager.defaultDuration)
            return
        }

        let finalDuration = (data.action == nil && duration <= 0) ? BubbleNotificationManager.defaultDuration : duration
        bubble.showBubble(autoDismissTime: finalDuration)
    }

    private func clearTagNotifications(tag: String?) {
        guard let tag = tag, notifications = taggedNotifications[tag] else { return }
        taggedNotifications[tag] = nil
        notifications.forEach{ $0.closeBubble() }
    }
}


// MARK: - BubbleNotificationDelegate

extension BubbleNotificationManager: BubbleNotificationDelegate {

    func bubbleNotificationSwiped(notification: BubbleNotification) {
        notification.closeBubble()
    }

    func bubbleNotificationTimedOut(notification: BubbleNotification) {
        notification.closeBubble()
    }

    func bubbleNotificationActionPressed(notification: BubbleNotification) {
        notification.data.action?.action()
        notification.closeBubble()
        clearTagNotifications(notification.data.tagGroup)
    }
}
