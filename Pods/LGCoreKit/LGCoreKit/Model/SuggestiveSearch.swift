//
//  SuggestiveSearch.swift
//  LGCoreKit
//
//  Created by Raúl de Oñate Blanco on 12/07/2017.
//  Copyright © 2017 Ambatana Inc. All rights reserved.
//

public enum SuggestiveSearch: Decodable, Equatable {
    case term(name: String)
    case category(category: ListingCategory)
    case termWithCategory(name: String, category: ListingCategory)
    
    public var name: String? {
        switch self {
        case let .term(name):
            return name
        case .category:
            return nil
        case let .termWithCategory(name, _):
            return name
        }
    }
    
    public var category: ListingCategory? {
        switch self {
        case .term:
            return nil
        case let .category(category):
            return category
        case let .termWithCategory(_, category):
            return category
        }
    }

    
    // MARK: - Decodable
    
    /**
     Expects a json in the form:
     
     // Category suggestions (may be empty)
     {
         "name": String (required),
         "type": "category" (required),
         "attributes": {
             "category": String (required),
             "categoryId": Integer (required),
             "weight": Integer (optional)
         }
     }
     
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
     }
     
     // Term suggestions (may be empty)
     {
         "name": String (required),
         "type": "suggestion" (required),
         "attributes": {
             "hits": Long (optional),
             "score": Integer (optional),
             "counts": Long (Optional)
         }
     }
     */
    public init(from decoder: Decoder) throws {
        let keyedContainer = try decoder.container(keyedBy: CodingKeys.self)
        
        let typeValue = try keyedContainer.decode(String.self, forKey: .type)
        switch typeValue {
        case "suggestion":
            let name = try keyedContainer.decode(String.self, forKey: .name)
            self = .term(name: name)
        case "category":
            let attributesKeyedContainer = try keyedContainer.nestedContainer(keyedBy: AttributesCodingKeys.self,
                                                                              forKey: .attributes)
            let categoryId = try attributesKeyedContainer.decode(Int.self, forKey: .categoryId)
            if let category = ListingCategory(rawValue: categoryId) {
                self = .category(category: category)
            } else {
                throw DecodingError.valueNotFound(Int.self, DecodingError.Context(codingPath: [CodingKeys.type, AttributesCodingKeys.categoryId],
                                                                                  debugDescription: "\(categoryId)"))
            }
        case "filterSuggestion":
            let name = try keyedContainer.decode(String.self, forKey: .name)
            let attributesKeyedContainer = try keyedContainer.nestedContainer(keyedBy: AttributesCodingKeys.self,
                                                                              forKey: .attributes)
            let categoryId = try attributesKeyedContainer.decode(Int.self, forKey: .categoryId)
            if let category = ListingCategory(rawValue: categoryId) {
                self = .termWithCategory(name: name, category: category)
            } else {
                throw DecodingError.valueNotFound(Int.self, DecodingError.Context(codingPath: [CodingKeys.type, AttributesCodingKeys.categoryId],
                                                                                  debugDescription: "\(categoryId)"))
            }
        default:
            throw DecodingError.valueNotFound(Int.self, DecodingError.Context(codingPath: [CodingKeys.type],
                                                                              debugDescription: "\(typeValue)"))
        }
    }
    
    enum CodingKeys: String, CodingKey {
        case name
        case type
        case attributes
    }
    
    enum AttributesCodingKeys: String, CodingKey {
        case categoryId
    }
    
    
    // MARK: - Equatable
    
    public static func ==(lhs: SuggestiveSearch, rhs: SuggestiveSearch) -> Bool {
        switch (lhs, rhs) {
        case (let .term(lName), let .term(rName)):
            return lName == rName
        case (let .category(lCategory), let .category(rCategory)):
            return lCategory == rCategory
        case (let .termWithCategory(lName, lCategory), let .termWithCategory(rName, rCategory)):
            return lName == rName && lCategory == rCategory
        default:
            return false
        }
    }
}
