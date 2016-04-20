//
//  TaplyticsABTester.swift
//  LetGo
//
//  Created by Dídac on 12/04/16.
//  Copyright © 2016 Ambatana. All rights reserved.
//

import Foundation
import Taplytics

public class TaplyticsABTester: ABTester {

    static public let sharedInstance = TaplyticsABTester()

    public func setUserData(userData: [String: AnyObject]) {
        Taplytics.setUserAttributes(userData)
    }
}
