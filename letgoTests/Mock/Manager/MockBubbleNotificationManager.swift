//
//  File.swift
//  LetGo
//
//  Created by Eli Kohen on 07/02/2017.
//  Copyright © 2017 Ambatana. All rights reserved.
//

@testable import LetGoGodMode
import RxSwift

class MockBubbleNotificationManager: BubbleNotificationManager {
    var bottomNotifications = Variable<[BubbleNotification]>([])
    
    var lastShownData: BubbleNotificationData?
    var lastDuration: TimeInterval?

    func showBubble(data: BubbleNotificationData, duration: TimeInterval?, view: UIView, alignment: BubbleNotification.Alignment, style: BubbleNotification.Style) {
        lastShownData = data
        lastDuration = duration
    }
    
    func hideBottomNotifications() { }
}
