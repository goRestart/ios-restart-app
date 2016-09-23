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

    func showBubble(style: BubbleStyle, text: String?, icon: UIImage?, action: UIAction?, duration: NSTimeInterval?) {

        guard let appDelegate = UIApplication.sharedApplication().delegate as? AppDelegate else { return }
        guard let window = appDelegate.window else { return }

        bubble = BubbleNotification(style: style, text: text, icon: icon, action: action)

        guard let bubble = bubble else { return }
        bubble.translatesAutoresizingMaskIntoConstraints = false

        window.addSubview(bubble)
        bubble.setupOnView(window)
        bubble.showBubble()

        if let duration = duration where duration > 0 {
            NSTimer.scheduledTimerWithTimeInterval(duration ?? BubbleNotificationManager.defaultDuration, target: self,
                                                   selector: #selector(hideBubble), userInfo: nil, repeats: false)
        } else {
            // if no duration is defined, we set the default for bubbles with no buttons
            switch style {
            case .Interested:
                NSTimer.scheduledTimerWithTimeInterval(BubbleNotificationManager.defaultDuration, target: self,
                                                       selector: #selector(hideBubble), userInfo: nil, repeats: false)
            case .Action:
                break
            }
        }
    }

    dynamic func hideBubble() {
        guard let bubble = bubble else { return }
        bubble.closeBubble()
        self.bubble = nil
    }


    // Interested bubble logic methods

    private var interestedBubbleShownForProducts: [String] = []

    func showInterestedBubbleForProduct(id: String) {
        interestedBubbleShownForProducts.append(id)
    }

    func shouldShowInterestedBubbleForProduct(id: String) -> Bool {
        return interestedBubbleShownForProducts.count < Constants.maxInterestedBubblesPerSession &&
            !interestedBubbleAlreadyShownForProduct(id)
    }

    private func interestedBubbleAlreadyShownForProduct(id: String) -> Bool {
        return interestedBubbleShownForProducts.contains(id)
    }
}
