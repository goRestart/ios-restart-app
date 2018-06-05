//
//  File.swift
//  LetGo
//
//  Created by Eli Kohen on 07/02/2017.
//  Copyright © 2017 Ambatana. All rights reserved.
//

@testable import LetGoGodMode
import RxSwift

final class MockBubbleNotificationManager: BubbleNotificationManager {
    let bottomNotifications = Variable<[BubbleNotificationView]>([])
    
    var lastShownData: BubbleNotificationData?
    var lastDuration: TimeInterval?

    func showBubble(data: BubbleNotificationData,
                    duration: TimeInterval,
                    view: UIView,
                    alignment: BubbleNotificationView.Alignment,
                    style: BubbleNotificationView.Style) {
        lastShownData = data
        lastDuration = duration
    }
    
    func hideBottomBubbleNotifications() { }
}
