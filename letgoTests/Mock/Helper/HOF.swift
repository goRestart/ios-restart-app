//
//  HOF.swift
//  LetGo
//
//  Created by Eli Kohen on 21/11/2016.
//  Copyright © 2016 Ambatana. All rights reserved.
//

/**
 High Order Functions
 */

import Result

func performAfterDelayWithCompletion<T, U>(completion: (Result<T, U> -> Void)?, result: Result<T, U>?) {
    let delay = dispatch_time(DISPATCH_TIME_NOW, Int64(0.05 * Double(NSEC_PER_SEC)))
    dispatch_after(delay, dispatch_get_main_queue()) {
        guard let result = result else { return }
        completion?(result)
    }
}
