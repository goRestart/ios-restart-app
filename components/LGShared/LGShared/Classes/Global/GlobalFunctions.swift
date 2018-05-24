//
//  GlobalFunctions.swift
//  LetGo
//
//  Created by Eli Kohen on 27/04/16.
//  Copyright © 2016 Ambatana. All rights reserved.
//

import Foundation

func delay(_ time: Double, completion: @escaping (() -> Void)) {
    let delayTime = DispatchTime.now() + Double(Int64(time * Double(NSEC_PER_SEC))) / Double(NSEC_PER_SEC)
    DispatchQueue.main.asyncAfter(deadline: delayTime) {
        completion()
    }
}

func onMainThread(_ completion: @escaping (() -> Void)) {
    DispatchQueue.main.async {
        completion()
    }
}
