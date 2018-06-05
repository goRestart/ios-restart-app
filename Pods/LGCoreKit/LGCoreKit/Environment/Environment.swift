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
    var realEstateBaseURL: String { get }
    var carsBaseURL: String { get }
    var servicesBaseURL: String { get }
    var bouncerBaseURL: String { get }
    var userRatingsBaseURL: String { get }
    var chatBaseURL: String { get }
    var webSocketURL: String { get }
    var notificationsBaseURL: String { get }
    var paymentsBaseURL: String { get }
    var suggestiveSearchBaseURL: String { get }
    var searchProductsBaseURL: String { get }
    var searchRealEstateBaseURL: String { get }
    var searchCarsBaseURL: String { get }
    var searchServicesBaseURL: String { get }
    var niordBaseURL: String { get }
    var spellCorrectorBaseURL: String { get }
    var meetingsBaseURL: String { get }
    var searchAlertsBaseURL: String { get }
    var customFeedBaseURL: String { get }
}
