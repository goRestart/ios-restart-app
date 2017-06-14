//
//  MockBaseService.swift
//  LGCoreKit
//
//  Created by Albert Hernández López on 20/11/15.
//  Copyright © 2015 Ambatana Inc. All rights reserved.
//

import Result

open class MockBaseService<T, E: Error> {
    var result: Result<T, E>
    var called: Bool

    // MARK: - Lifecycle
    
    public required init(value: T) {
        self.result = Result<T, E>(value: value)
        self.called = false
    }
    public required init(error: E) {
        self.result = Result<T, E>(error: error)
        self.called = false
    }
}
