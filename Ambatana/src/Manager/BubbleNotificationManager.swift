//
//  BubbleNotificationManager.swift
//  LetGo
//
//  Created by Eli Kohen on 07/02/2017.
//  Copyright © 2017 Ambatana. All rights reserved.
//

import Foundation

protocol BubbleNotificationManager {
    func showBubble(_ data: BubbleNotificationData, duration: TimeInterval?, view: UIView)
}
