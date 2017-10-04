//
//  NetworkDefaultsDAO.swift
//  LGCoreKit
//
//  Created by Facundo Menzella on 02/10/2017.
//  Copyright © 2017 Ambatana Inc. All rights reserved.
//

import Foundation

public final class NetworkDefaultsDAO: NetworkDAO {
    internal struct Keys {
        static let networkTimeout = "NetworkTimeout"
    }

    private let userDefaults: UserDefaultable

    public var timeoutIntervalForRequests: TimeInterval? {
        get {
            guard let timeout = userDefaults.object(forKey: Keys.networkTimeout) as? TimeInterval
                else { return nil }
            return TimeInterval(timeout)
        }
        set {
            userDefaults.set(newValue, forKey: Keys.networkTimeout)
        }
    }

    // MARK: Inits
    public convenience init() {
        self.init(userDefaults: UserDefaults.standard)
    }

    init(userDefaults: UserDefaultable) {
        self.userDefaults = userDefaults
    }

}
