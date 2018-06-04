//
//  BubbleNotificationManager.swift
//  LetGo
//
//  Created by Eli Kohen on 07/02/2017.
//  Copyright © 2017 Ambatana. All rights reserved.
//

import Foundation
import RxSwift

protocol BubbleNotificationManager {
    var bottomNotifications: Variable<[BubbleNotification]> { get }
    
    func showBubble(data: BubbleNotificationData,
                    duration: TimeInterval?,
                    view: UIView,
                    alignment: BubbleNotification.Alignment,
                    style: BubbleNotification.Style)
    func hideBottomNotifications()
}
