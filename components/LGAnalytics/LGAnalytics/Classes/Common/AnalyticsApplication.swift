//
//  AnalyticsApplication.swift
//  LGComponents
//
//  Created by Albert Hernández López on 18/04/2018.
//

import Foundation

public protocol AnalyticsApplication: class {
    var isRegisteredForRemoteNotifications: Bool { get }
    func open(url: URL,
              options: [String: Any],
              completion: ((Bool) -> Void)?)
}
