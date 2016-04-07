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
    
    func indexTemplates(completion: CommercializerDataSourceTemplateCompletion?) {
        let request = CommercializerRouter.IndexTemplates
        apiClient.request(request, decoder: CommercializerApiDataSource.decoderTemplate, completion: completion)
    }
    
    func index(productId: String, completion: CommercializersDataSourceCompletion?) {
        let request = CommercializerRouter.Index(productId: productId)
        apiClient.request(request, decoder: CommercializerApiDataSource.decoderArray, completion: completion)
    }
    
    func create(productId: String, templateId: String, completion: CommercializerDataSourceCompletion?) {
        let request = CommercializerRouter.Create(productId: productId, parameters: ["template_id" : templateId])
        apiClient.request(request, decoder: CommercializerApiDataSource.decoder, completion: completion)
    }
    
    func indexAvailableProducts(userId: String, completion: CommercializerDataSourceProductsCompletion?) {
        let request = CommercializerRouter.IndexAvailableProducts(userId: userId)
        apiClient.request(request, decoder: CommercializerApiDataSource.decoderProducts, completion: completion)
    }
    

    // MARK: - Decoder
    
    private static func decoderTemplate(object: AnyObject) -> CommercializerTemplatesByCountry? {
        guard let theTemplates : [LGCommercializerTemplate] = decode(object) else { return nil }
        let templates: [CommercializerTemplate] = theTemplates.map { $0 }
        let templatesByCountry = templates.categorise { $0.countryCode }
        return templatesByCountry
    }
    
    private static func decoderArray(object: AnyObject) -> [Commercializer]? {
        guard let dict = object as? [String : AnyObject] else { return nil }
        guard let videosArray = dict["videos"] else { return nil }

        guard let theCommercializer : [LGCommercializer] = decode(videosArray) else { return nil }
        return theCommercializer.map{$0}
    }
    
    private static func decoder(object: AnyObject) -> Commercializer? {
        guard let theCommercializer : LGCommercializer = decode(object) else { return nil }
        return theCommercializer
    }
    
    private static func decoderProducts(object: AnyObject) -> [CommercializerProduct]? {
        guard let products: [LGCommercializerProduct] = decode(object) else { return nil }
        return products.map{$0}
    }
}
