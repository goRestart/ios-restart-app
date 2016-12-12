//
//  EscrowEnviroment.swift
//  LGCoreKit
//
//  Created by Juan Iglesias on 30/11/16.
//  Copyright © 2016 Ambatana Inc. All rights reserved.
//

import Foundation

struct EscrowEnvironment: Environment {
    // API
    let apiBaseURL = "https://api.escrowverification.com"
    let bouncerBaseURL = "https://bouncer.escrowverification.com"
    let commercializerBaseURL = "https://commercializer.escrowverification.com/"
    let userRatingsBaseURL = "http://rating.escrowverification.com"
    let chatBaseURL = "chat.escrowverification.com"
    let webSocketURL = "wss://chat.escrowverification.com/socket"
    let notificationsBaseURL = "https://notifications.escrowverification.com"
}
