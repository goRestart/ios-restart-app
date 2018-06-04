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
    var bottomNotifications: Variable<[BubbleNotificationView]> { get }
    
    func showBubble(data: BubbleNotificationData,
                    duration: TimeInterval,
                    view: UIView,
                    alignment: BubbleNotificationView.Alignment,
                    style: BubbleNotificationView.Style)
    func hideBottomBubbleNotifications()
}
