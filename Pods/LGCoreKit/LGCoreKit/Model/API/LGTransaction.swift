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
        let init1 = curry(LGTransaction.init)
            <^> j <| "transaction_id"
            <*> j <| "closed"
        
        if let error = init1.error {
            logMessage(.error, type: CoreLoggingOptions.parsing, message: "LGTransaction parse error: \(error)")
        }
        
        return init1
    }
}
