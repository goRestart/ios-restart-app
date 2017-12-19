//
//  LGSticker.swift
//  LGCoreKit
//
//  Created by Isaac Roldán Armengol on 13/5/16.
//  Copyright © 2016 Ambatana Inc. All rights reserved.
//

struct LGSticker: Sticker, Decodable {
    private static let defaultType: StickerType = .chat

    let url: String
    let name: String
    let type: StickerType

    
    // MARK: - Lifecycle
    
    init(url: String,
         name: String,
         type: StickerType?) {
        self.url = url
        self.name = name
        self.type = type ?? LGSticker.defaultType
    }
    
    
    // MARK: - Decodable
    
    /*
     Expects a json in the form:
     {
         "url": "https://stickers.letgo.com/en/love_it.png",
         "name": ":love_it:",
         "type": "product"
     }
     */
    public init(from decoder: Decoder) throws {
        let keyedContainer = try decoder.container(keyedBy: CodingKeys.self)
        self.url = try keyedContainer.decode(String.self, forKey: .url)
        self.name = try keyedContainer.decode(String.self, forKey: .name)
        self.type = (try keyedContainer.decodeIfPresent(StickerType.self, forKey: .type)) ?? LGSticker.defaultType
    }
    
    enum CodingKeys: String, CodingKey {
        case url
        case name
        case type
    }
}

extension LGSticker: UserDefaultsDecodable {
    static func decode(_ dictionary: [String: Any]) -> LGSticker? {
        guard let url = dictionary[CodingKeys.url.rawValue] as? String,
            let name = dictionary[CodingKeys.name.rawValue] as? String else { return nil }
        
        let type: StickerType?
        if let typeString = dictionary[CodingKeys.type.rawValue] as? String {
            type = StickerType(rawValue: typeString)
        } else {
            type = nil
        }
        return LGSticker(url: url,
                         name: name,
                         type: type)
    }

    func encode() -> [String: Any] {
        return [CodingKeys.url.rawValue: url,
                CodingKeys.name.rawValue: name,
                CodingKeys.type.rawValue: type.rawValue]
    }
}

