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
    
    private struct Keys {
        static let type = "type"
        static let name = "name"
        static let attributes = "attributes"
        static let categoryId = "categoryId"
        
        struct TypeValues {
            static let term = "suggestion"
            static let category = "category"
            static let termWithCategory = "filterSuggestion"
        }
    }
    
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
        guard let type: String = j.decode(Keys.type) else {
            return Decoded<SuggestiveSearch>.failure(.missingKey(Keys.type))
        }
        
        let result: Decoded<SuggestiveSearch>
        switch type {
        case Keys.TypeValues.term:
            result = SuggestiveSearch.decodeTerm(json: j)
        case Keys.TypeValues.category:
            result = SuggestiveSearch.decodeCategory(json: j)
        case Keys.TypeValues.termWithCategory:
            result = SuggestiveSearch.decodeTermWithCategory(json: j)
        default:
            result = Decoded<SuggestiveSearch>.failure(.custom("unknown \(Keys.type)"))
        }
        
        if let error = result.error {
            logMessage(.error, type: CoreLoggingOptions.parsing, message: "SuggestiveSearch parse error: \(error)")
        }
        return result
    }
    
    private static func decodeTerm(json: JSON) -> Decoded<SuggestiveSearch> {
        let result1 = curry(SuggestiveSearch.term)
        let result  = result1 <^> json <| Keys.name
        return result
    }
    
    private static func decodeCategory(json: JSON) -> Decoded<SuggestiveSearch> {
        guard let attributes: JSON = json.decode(Keys.attributes),
              let categoryId: Int = attributes.decode(Keys.categoryId) else {
            return Decoded<SuggestiveSearch>.failure(.missingKey("\(Keys.attributes)/\(Keys.categoryId)"))
        }
        guard let category = ListingCategory(rawValue: categoryId) else {
            return Decoded<SuggestiveSearch>.failure(.custom("unknown \(Keys.categoryId)"))
        }
        return Decoded<SuggestiveSearch>.success(SuggestiveSearch.category(category: category))
    }
    
    private static func decodeTermWithCategory(json: JSON) -> Decoded<SuggestiveSearch> {
        guard let name: String = json.decode(Keys.name) else {
            return Decoded<SuggestiveSearch>.failure(.missingKey(Keys.name))
        }
        guard let attributes: JSON = json.decode(Keys.attributes),
              let categoryId: Int = attributes.decode(Keys.categoryId) else {
            return Decoded<SuggestiveSearch>.failure(.missingKey("\(Keys.attributes)/\(Keys.categoryId)"))
        }
        guard let category = ListingCategory(rawValue: categoryId) else {
            return Decoded<SuggestiveSearch>.failure(.custom("unknown \(Keys.categoryId)"))
        }
        return Decoded<SuggestiveSearch>.success(SuggestiveSearch.termWithCategory(name: name, category: category))
    }
}
