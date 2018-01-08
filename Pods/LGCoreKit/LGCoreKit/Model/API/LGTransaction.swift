//
//  LGTransaction.swift
//  LGCoreKit
//
//  Created by Juan Iglesias on 22/05/2017.
//  Copyright © 2017 Ambatana Inc. All rights reserved.
//

struct LGTransaction: Transaction, Decodable {
    
    // Global iVars
    let transactionId: String
    let closed: Bool
    
    init(transactionId: String, closed: Bool) {
        self.transactionId = transactionId
        self.closed = closed
    }

    // MARK: Decodable

    /**
     "transaction": {
     "transaction_id": "DCOefspN3I"
     "closed": false
     }
     */

    public init(from decoder: Decoder) throws {
        let keyedContainer = try decoder.container(keyedBy: CodingKeys.self)
        transactionId = try keyedContainer.decode(String.self, forKey: .transactionId)
        closed = try keyedContainer.decode(Bool.self, forKey: .closed)
    }

    enum CodingKeys: String, CodingKey {
        case transactionId = "transaction_id"
        case closed = "closed"
    }

}
