//
//  GlobalFunctions.swift
//  LetGo
//
//  Created by Eli Kohen on 27/04/16.
//  Copyright © 2016 Ambatana. All rights reserved.
//

import Foundation

func delay(time: Double, completion: (() -> Void)) {
    let delayTime = dispatch_time(DISPATCH_TIME_NOW, Int64(time * Double(NSEC_PER_SEC)))
    dispatch_after(delayTime, dispatch_get_main_queue()) {
        completion()
    }
}

func onMainThread(completion: (() -> Void)) {
    dispatch_async(dispatch_get_main_queue()) {
        completion()
    }
}
