//
//  LGTransaction.swift
//  LGCoreKit
//
//  Created by Juan Iglesias on 22/05/2017.
//  Copyright © 2017 Ambatana Inc. All rights reserved.
//

import Argo
import Curry
import Runes

struct LGTransaction: Transaction {
    
    // Global iVars
    let transactionId: String
    let closed: Bool
    
    init(transactionId: String, closed: Bool) {
        self.transactionId = transactionId
        self.closed = closed
    }
}

extension LGTransaction : Decodable {
    
    /**
     "transaction": {
     "transaction_id": "DCOefspN3I"
     "closed": false
     }     */
    
    static func decode(_ j: JSON) -> Decoded<LGTransaction> {
        let result1 = curry(LGTransaction.init)
        let result2 = result1 <^> j <| "transaction_id"
        let result  = result2 <*> j <| "closed"
        if let error = result.error {
            logMessage(.error, type: CoreLoggingOptions.parsing, message: "LGTransaction parse error: \(error)")
        }
        return result
    }
}
