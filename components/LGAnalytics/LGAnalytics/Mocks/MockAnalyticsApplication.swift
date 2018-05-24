//
//  MockAnalyticsApplication.swift
//  LGAnalytics_Tests
//
//  Created by Albert Hernández López on 18/04/2018.
//  Copyright © 2018 Ambatana B.V. Holdings. All rights reserved.
//

import Foundation
import LGComponents

class MockAnalyticsApplication: AnalyticsApplication {
    var isRegisteredForRemoteNotifications: Bool = false
    var didOpenURL: Bool = false

    func open(url: URL,
              options: [String: Any],
              completion: ((Bool) -> Void)?) {
        didOpenURL = true
    }
}
