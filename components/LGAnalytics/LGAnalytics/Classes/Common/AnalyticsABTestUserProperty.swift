//
//  AnalyticsABTestUserProperty.swift
//  LGAnalytics
//
//  Created by Albert Hernández López on 29/03/2018.
//

public struct AnalyticsABTestUserProperty {
    let identifier: String
    let groupIdentifier: AnalyticsABTestGroupIdentifier

    public init<T>(key: String,
                   value: T,
                   groupIdentifier: AnalyticsABTestGroupIdentifier) {
        self.init(identifier: "\(key)-\(value)",
                  groupIdentifier: groupIdentifier)
    }

    public init(identifier: String,
                groupIdentifier: AnalyticsABTestGroupIdentifier) {
        self.identifier = identifier
        self.groupIdentifier = groupIdentifier
    }
}
