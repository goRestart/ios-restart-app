//
//  LGSuggestiveSearch.swift
//  LGCoreKit
//
//  Created by Raúl de Oñate Blanco on 12/07/2017.
//  Copyright © 2017 Ambatana Inc. All rights reserved.
//

import Argo
import Curry
import Runes

extension SuggestiveSearch: Decodable {
    
    /*private static func makeCategory(categoryId: Int) -> SuggestiveSearch? {
        guard let category = ListingCategory(rawValue: categoryId) else { return nil }
        return SuggestiveSearch.category(category: category)
    }
    
    private static func makeTermWithCategory(name: String, categoryId: Int) -> SuggestiveSearch? {
        guard let category = ListingCategory(rawValue: categoryId) else { return nil }
        return SuggestiveSearch.termWithCategory(name: name, category: category)
    }*/
    
    /**
     Expects a json in the form:
     {
     "items": [
     
     // Category suggestions (may be empty)
     {
        "name": String (required),
        "type": "category" (required),
        "attributes": {
            "category": String (required),
            "categoryId": Integer (required),
            "weight": Integer (optional)
        }
     } ...,
     
     // Term with filter suggestions (may be empty)
     {
        "name": String (required),
        "type": "filterSuggestion" (required),
        "attributes": {
            "category": String (required),
            "categoryId": Integer (required),
            "hits": Long (optional),
            "score": Integer (optional),
            "counts": Long (Optional)
        }, ...,
     
     // Term suggestions (may be empty)
     {
        "name": String (required),
        "type": "suggestion" (required),
        "attributes": {
            "hits": Long (optional),
            "score": Integer (optional),
            "counts": Long (Optional)
        }
     }, ...
     ]
     }
     */
    public static func decode(_ j: JSON) -> Decoded<SuggestiveSearch> {
        guard let type: String = j.decode("type") else {
            return Decoded<SuggestiveSearch>.failure(.missingKey("type"))
        }
        
        let result: Decoded<SuggestiveSearch>
        switch type {
        case "suggestion":
            result = SuggestiveSearch.decodeTerm(json: j)
        case "category":
            result = SuggestiveSearch.decodeCategory(json: j)
        case "filterSuggestion":
            result = SuggestiveSearch.decodeTermWithCategory(json: j)
        default:
            result = Decoded<SuggestiveSearch>.failure(.custom("unknown type"))
        }
        
        if let error = result.error {
            logMessage(.error, type: CoreLoggingOptions.parsing, message: "SuggestiveSearch parse error: \(error)")
        }
        return result
    }
    
    private static func decodeTerm(json: JSON) -> Decoded<SuggestiveSearch> {
        let result1 = curry(SuggestiveSearch.term)
        let result  = result1 <^> json <| "name"
        return result
    }
    
    private static func decodeCategory(json: JSON) -> Decoded<SuggestiveSearch> {
        guard let attributes: JSON = json.decode("attributes"),
              let categoryId: Int = attributes.decode("categoryId") else {
            return Decoded<SuggestiveSearch>.failure(.missingKey("attributes/categoryId"))
        }
        guard let category = ListingCategory(rawValue: categoryId) else {
            return Decoded<SuggestiveSearch>.failure(.custom("categoryId not found"))
        }
        return Decoded<SuggestiveSearch>.success(SuggestiveSearch.category(category: category))
    }
    
    private static func decodeTermWithCategory(json: JSON) -> Decoded<SuggestiveSearch> {
        guard let name: String = json.decode("name") else {
            return Decoded<SuggestiveSearch>.failure(.missingKey("name"))
        }
        guard let attributes: JSON = json.decode("attributes"),
              let categoryId: Int = attributes.decode("categoryId") else {
            return Decoded<SuggestiveSearch>.failure(.missingKey("attributes/categoryId"))
        }
        guard let category = ListingCategory(rawValue: categoryId) else {
            return Decoded<SuggestiveSearch>.failure(.custom("categoryId not found"))
        }
        return Decoded<SuggestiveSearch>.success(SuggestiveSearch.termWithCategory(name: name, category: category))
    }
}
