//
//  File.swift
//  LetGo
//
//  Created by Eli Kohen on 07/02/2017.
//  Copyright © 2017 Ambatana. All rights reserved.
//

@testable import LetGo

class MockBubbleNotificationManager: BubbleNotificationManager {
    var lastShownData: BubbleNotificationData?
    var lastDuration: TimeInterval?

    func showBubble(_ data: BubbleNotificationData, duration: TimeInterval?, view: UIView) {
        lastShownData = data
        lastDuration = duration
    }
}
