//
//  DevelopmentEnvironment.swift
//  LetGo
//
//  Created by AHL on 28/4/15.
//  Copyright (c) 2015 Ambatana. All rights reserved.
//

struct StagingEnvironment: Environment {
    let apiBaseURL = "http://api.stg.letgo.com"
    let realEstateBaseURL = "https://listingrealestate.stg.letgo.com"
    let searchRealEstateBaseURL = "https://searchrealestate.stg.letgo.com"
    let bouncerBaseURL = "http://bouncer.stg.letgo.com/api"
    let userRatingsBaseURL = "http://rating.stg.letgo.com/api"
    let chatBaseURL = "https://chat.stg.letgo.com"
    let webSocketURL = "wss://chat.stg.letgo.com/socket"
    let notificationsBaseURL = "http://notifications.stg.letgo.com/api"
    let paymentsBaseURL = "https://payment.stg.letgo.com/payment"
    let suggestiveSearchBaseURL = "https://suggestivesearch.letgo.com"
    let searchProductsBaseURL = "https://search-products.stg.letgo.com"
    let niordBaseURL = "https://niord.stg.letgo.com"
}
