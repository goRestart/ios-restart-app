//
//  StickersApiDataSource.swift
//  LGCoreKit
//
//  Created by Isaac Roldán Armengol on 13/5/16.
//  Copyright © 2016 Ambatana Inc. All rights reserved.
//

class StickersApiDataSource: StickersDataSource {
    
    let apiClient: ApiClient
    
    
    // MARK: - Lifecycle
    
    init(apiClient: ApiClient) {
        self.apiClient = apiClient
    }
    
    
    // MARK: - Actions
    
    func show(_ locale: Locale, completion: StickersDataSourceCompletion?) {
        let request = StickersRouter.show(locale: locale.identifier)
        apiClient.request(request, decoder: StickersApiDataSource.decoderArray, completion: completion)
    }
    
    
    // MARK: - Decoders
    
    private static func decoderArray(_ object: Any) -> [Sticker]? {
        guard let json = object as? [String: Any] else { return nil }
        guard let stickersJSON = json["stickers"] else { return nil }
        guard let data = try? JSONSerialization.data(withJSONObject: stickersJSON, options: .prettyPrinted) else { return nil }
        
        // Ignore stickers that can't be decoded
        do {
            let stickers = try JSONDecoder().decode(FailableDecodableArray<LGSticker>.self, from: data)
            return stickers.validElements
        } catch {
            logAndReportParseError(object: object, entity: .stickers,
                                   comment: "could not parse [LGSticker]")
        }
        return nil
    }
}
