//
//  LGPaymentProvider.swift
//  LGCoreKit
//
//  Created by Dídac on 28/12/16.
//  Copyright © 2016 Ambatana Inc. All rights reserved.
//

import Argo

public enum PaymentProvider: String {
    case letgo = "letgo"
    case apple = "apple"

    public static let allValues: [PaymentProvider] = [.letgo, .apple]
}

extension PaymentProvider: Decodable {}
