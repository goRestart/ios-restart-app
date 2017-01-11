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
    DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(50)) {
        guard let result = result else { return }
        completion?(result)
    }
}
