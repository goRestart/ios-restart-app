//
//  LGPaymentItem.swift
//  LGCoreKit
//
//  Created by Dídac on 10/01/17.
//  Copyright © 2017 Ambatana Inc. All rights reserved.
//


public protocol PaymentItem {
    var provider: PaymentProvider { get }
    var itemId: String { get }
    var providerItemId: String { get }
}

public struct LGPaymentItem: PaymentItem, Decodable {
    public let provider: PaymentProvider
    public let itemId: String
    public let providerItemId: String

    // MARK: Decodable
    
    /*
     {
     "provider": "letgo",  // string, possible values, "letgo.apple" is used for hidden items ["letgo", "apple", "google", "letgo.apple"]
     "item_id": "4c72134c5-6586-798" // string, uuid4
     "provider_item_id": "com.letgo.tier1" // string, external provider ID, depending on google, apple, etc.
     }
     */

    public init(from decoder: Decoder) throws {
        let keyedContainer = try decoder.container(keyedBy: CodingKeys.self)
        let providerString = try keyedContainer.decode(String.self, forKey: .provider)
        guard let providerValue = PaymentProvider(rawValue: providerString) else {
            throw DecodingError.valueNotFound(AccountProvider.self,
                                              DecodingError.Context(codingPath: [],
                                                                    debugDescription: "\(providerString)"))
        }
        provider = providerValue
        itemId = try keyedContainer.decode(String.self, forKey: .itemId)
        providerItemId = try keyedContainer.decode(String.self, forKey: .providerItemId)
    }

    enum CodingKeys: String, CodingKey {
        case provider = "provider"
        case itemId = "item_id"
        case providerItemId = "provider_item_id"
    }
}
