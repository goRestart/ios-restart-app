//
//  Environment.swift
//  LetGo
//
//  Created by AHL on 28/4/15.
//  Copyright (c) 2015 Ambatana. All rights reserved.
//

import Foundation

protocol Environment {
    // API
    var apiBaseURL: String { get }
    var bouncerBaseURL: String { get }
    var commercializerBaseURL: String { get }
    var userRatingsBaseURL: String { get }
    var chatBaseURL: String { get }
    var webSocketURL: String { get }
    var notificationsBaseURL: String { get }
    var passiveBuyersBaseURL: String { get }
}
