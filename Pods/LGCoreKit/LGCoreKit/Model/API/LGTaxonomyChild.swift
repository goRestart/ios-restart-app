//
//  LGTaxonomyChild.swift
//  LGCoreKit
//
//  Created by Dídac on 17/07/2017.
//  Copyright © 2017 Ambatana Inc. All rights reserved.
//

public struct LGTaxonomyChild: TaxonomyChild, Decodable {
    public let id: Int
    public let type: TaxonomyChildType
    public let name: String
    public let highlightOrder: Int?
    public let highlightIcon: URL?
    public let image: URL?

    
    // MARK: - Lifecycle
    
    init(id: Int,
         type: String,
         name: String,
         highlightOrder: Int?,
         highlightIcon: String?,
         image: String?) {
        self.id = id
        self.type = TaxonomyChildType(rawValue: type) ?? .superKeyword
        self.name = name
        self.highlightOrder = highlightOrder
        if let icon = highlightIcon {
            self.highlightIcon = URL(string: icon)
        } else {
            self.highlightIcon = nil
        }
        if let actualImage = image {
            self.image = URL(string: actualImage)
        } else {
            self.image = nil
        }
    }
    
    
    // MARK: Decodable
    
    /**
     Expects a json in the form:
     {
         "id": 2,
         "type": "superkeyword",
         "name": "Phones",
         "highlight_order": 1,
         "highlight_icon": "https://static.letgo.com/category-icons/phones_superkw.png",
         "image": "https://static.letgo.com/superkeyword_images/Tools&Machinery.jpg"
     }
     */
    public init(from decoder: Decoder) throws {
        let keyedContainer = try decoder.container(keyedBy: CodingKeys.self)
        
        self.id = try keyedContainer.decode(Int.self, forKey: .id)
        let typeString = try keyedContainer.decode(String.self, forKey: .type)
        if let type = TaxonomyChildType(rawValue: typeString) {
            self.type = type
        } else {
            throw DecodingError.valueNotFound(Int.self, DecodingError.Context(codingPath: [CodingKeys.type],
                                                                              debugDescription: "\(typeString)"))
        }
        self.name = try keyedContainer.decode(String.self, forKey: .name)
        self.highlightOrder =  try keyedContainer.decodeIfPresent(Int.self, forKey: .highlightOrder)
        if let highlightString = try keyedContainer.decodeIfPresent(String.self, forKey: .highlightIcon),
            let highLightURL = URL(string: highlightString) {
            self.highlightIcon = highLightURL
        } else {
            self.highlightIcon = nil
        }
        if let imageString = try keyedContainer.decodeIfPresent(String.self, forKey: .image),
            let imageURL = URL(string: imageString) {
            self.image = imageURL
        } else {
            self.image = nil
        }
    }
    
    enum CodingKeys: String, CodingKey {
        case id             = "id"
        case type           = "type"
        case name           = "name"
        case highlightOrder = "highlight_order"
        case highlightIcon  = "highlight_icon"
        case image          = "image"
    }
}
