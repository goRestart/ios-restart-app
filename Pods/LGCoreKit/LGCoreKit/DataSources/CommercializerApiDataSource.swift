//
//  CommercializerApiDataSource.swift
//  LGCoreKit
//
//  Created by Isaac Roldan on 2/3/16.
//  Copyright © 2016 Ambatana Inc. All rights reserved.
//

import Foundation
import Argo


class CommercializerApiDataSource: CommercializerDataSource {
    
    let apiClient: ApiClient
    
    
    // MARK: - Lifecycle
    
    init(apiClient: ApiClient) {
        self.apiClient = apiClient
    }

    func index(_ productId: String, completion: CommercializersDataSourceCompletion?) {
        let request = CommercializerRouter.index(productId: productId)
        apiClient.request(request, decoder: CommercializerApiDataSource.decoderArray, completion: completion)
    }
    

    // MARK: - Decoder
    
    private static func decoderArray(_ object: Any) -> [Commercializer]? {
        guard let dict = object as? [String : Any] else { return nil }
        guard let videosArray = dict["videos"] else { return nil }

        guard let theCommercializer : [LGCommercializer] = decode(videosArray) else { return nil }
        return theCommercializer.map{$0}
    }
}
