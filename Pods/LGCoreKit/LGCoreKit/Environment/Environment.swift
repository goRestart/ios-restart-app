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

    // Config
    var configURL: String { get }
}
