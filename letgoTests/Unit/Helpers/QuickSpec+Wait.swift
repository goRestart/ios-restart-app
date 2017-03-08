//
//  QuickSpec+Wait.swift
//  LetGo
//
//  Created by Eli Kohen on 06/03/2017.
//  Copyright © 2017 Ambatana. All rights reserved.
//

import Foundation
import Quick

extension QuickSpec {
    func waitFor(timeout: TimeInterval, completion: (() -> Void)? = nil) {
        let _ = self.expectation(description: "Wait for")
        self.waitForExpectations(timeout: timeout) { _ in
            completion?()
        }
    }
}
