//
//  LGPaymentItem.swift
//  LGCoreKit
//
//  Created by Dídac on 10/01/17.
//  Copyright © 2017 Ambatana Inc. All rights reserved.
//

import Argo
import Curry
import Runes


public struct LGPaymentItem: PaymentItem {
    public let provider: PaymentProvider
    public let itemId: String
    public let providerItemId: String

    init(provider: PaymentProvider, itemId: String, providerItemId: String) {
        self.provider = provider
        self.itemId = itemId
        self.providerItemId = providerItemId
    }
}


extension LGPaymentItem: Decodable {

    /**
     Expects a json in the form:

     {
     "provider": "free",  // string, possible values ["letgo", "apple", "google"]
     "item_id": "4c72134c5-6586-798" // string, uuid4
     "provider_item_id": "com.letgo.tier1" // string, external provider ID, depending on google, apple, etc.
     }

     */

    public static func decode(_ j: JSON) -> Decoded<LGPaymentItem> {
        let result = curry(LGPaymentItem.init)
            <^> j <| "provider"
            <*> j <| "item_id"
            <*> j <| "provider_item_id"
        if let error = result.error {
            logMessage(.error, type: CoreLoggingOptions.parsing, message: "LGPaymentItem parse error: \(error)")
        }
        return result
    }
}
