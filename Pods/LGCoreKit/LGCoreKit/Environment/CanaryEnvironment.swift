//
//  CanaryEnvironment.swift
//  LGCoreKit
//
//  Created by Eli Kohen on 21/01/16.
//  Copyright © 2016 Ambatana Inc. All rights reserved.
//

struct CanaryEnvironment: Environment {
    let apiBaseURL = "http://canary.api.letgo.com"
    let realEstateBaseURL = "https://listingrealestate.origin.canary.letgo.com"
    let bouncerBaseURL = "http://bouncerv2.canary.letgo.com/api"
    let userRatingsBaseURL = "http://rating.canary.letgo.com/api"
    let chatBaseURL = "https://chat.letgo.com"
    let webSocketURL = "wss://chat.letgo.com/socket"
    let notificationsBaseURL = "http://notifications.canary.letgo.com/api"
    let passiveBuyersBaseURL = "http://passivebuyers.letgo.com/api"
    let paymentsBaseURL = "https://payment.canary.letgo.com/payment"
    let suggestiveSearchBaseURL = "https://suggestivesearch.letgo.com"
    let searchProductsBaseURL = "http://search-products.canary.letgo.com"
    let niordBaseURL = "https://niord.letgo.com"
}
