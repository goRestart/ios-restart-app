//
//  BaseNavigator.swift
//  LetGo
//
//  Created by Nestor Garcia on 05/12/2016.
//  Copyright © 2016 Ambatana. All rights reserved.
//

import UIKit

protocol BaseNavigator: class {
    func showBubble(with bubbleData: BubbleNotificationData, duration: NSTimeInterval)
}
