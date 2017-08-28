//
//  LGCommercializerListing.swift
//  LGCoreKit
//
//  Created by Isaac Roldan on 5/4/16.
//  Copyright © 2016 Ambatana Inc. All rights reserved.
//

import Argo
import Curry
import Runes

public struct LGCommercializerListing: CommercializerListing {
    public let objectId: String?
    public let thumbnailURL: String?
    public let countryCode: String?
}

extension LGCommercializerListing: Decodable {
    public static func decode(_ j: JSON) -> Decoded<LGCommercializerListing> {
        let result1 = curry(LGCommercializerListing.init)
        let result2 = result1 <^> j <|? "id"
        let result3 = result2 <*> j <|? ["thumb", "url"]
        let result  = result3 <*> j <|? "country_code"
        if let error = result.error {
            logMessage(.error, type: CoreLoggingOptions.parsing, message: "LGCommercializerListing parse error: \(error)")
        }
        return result
    }
}
