//
//  StickersApiDataSource.swift
//  LGCoreKit
//
//  Created by Isaac Roldán Armengol on 13/5/16.
//  Copyright © 2016 Ambatana Inc. All rights reserved.
//

import Argo

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
        guard let stickers = Array<LGSticker>.decode(JSON(stickersJSON)).value else { return nil }
        return stickers.map{ $0 }
    }
}
