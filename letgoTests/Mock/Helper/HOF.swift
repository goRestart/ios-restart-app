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

func performAfterDelayWithCompletion<T, U>(_ completion: ((Result<T, U>) -> Void)?, result: Result<T, U>?) {
    let delay = DispatchTime.now() + Double(Int64(0.05 * Double(NSEC_PER_SEC))) / Double(NSEC_PER_SEC)
    DispatchQueue.main.asyncAfter(deadline: delay) {
        guard let result = result else { return }
        completion?(result)
    }
}
