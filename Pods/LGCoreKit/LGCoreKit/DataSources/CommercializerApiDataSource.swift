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
    
    func indexTemplates(_ completion: CommercializerDataSourceTemplateCompletion?) {
        let request = CommercializerRouter.indexTemplates
        apiClient.request(request, decoder: CommercializerApiDataSource.decoderTemplate, completion: completion)
    }
    
    func index(_ productId: String, completion: CommercializersDataSourceCompletion?) {
        let request = CommercializerRouter.index(productId: productId)
        apiClient.request(request, decoder: CommercializerApiDataSource.decoderArray, completion: completion)
    }
    
    func create(_ productId: String, templateId: String, completion: CommercializerDataSourceCompletion?) {
        let request = CommercializerRouter.create(productId: productId, parameters: ["template_id" : templateId])
        apiClient.request(request, decoder: CommercializerApiDataSource.decoder, completion: completion)
    }
    
    func indexAvailableProducts(_ userId: String, completion: CommercializerDataSourceProductsCompletion?) {
        let request = CommercializerRouter.indexAvailableProducts(userId: userId)
        apiClient.request(request, decoder: CommercializerApiDataSource.decoderProducts, completion: completion)
    }
    

    // MARK: - Decoder
    
    private static func decoderTemplate(_ object: Any) -> CommercializerTemplatesByCountry? {
        guard let theTemplates : [LGCommercializerTemplate] = decode(object) else { return nil }
        let templates: [CommercializerTemplate] = theTemplates.map { $0 }
        let templatesByCountry = templates.categorise { $0.countryCode }
        return templatesByCountry
    }
    
    private static func decoderArray(_ object: Any) -> [Commercializer]? {
        guard let dict = object as? [String : Any] else { return nil }
        guard let videosArray = dict["videos"] else { return nil }

        guard let theCommercializer : [LGCommercializer] = decode(videosArray) else { return nil }
        return theCommercializer.map{$0}
    }
    
    private static func decoder(_ object: Any) -> Commercializer? {
        guard let theCommercializer : LGCommercializer = decode(object) else { return nil }
        return theCommercializer
    }
    
    private static func decoderProducts(_ object: Any) -> [CommercializerProduct]? {
        guard let products: [LGCommercializerProduct] = decode(object) else { return nil }
        return products.map{$0}
    }
}
