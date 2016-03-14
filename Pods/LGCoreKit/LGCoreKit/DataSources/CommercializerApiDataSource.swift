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
        let request = CommercializerRouter.Index
        apiClient.request(request, decoder: CommercializerApiDataSource.decoderTemplate, completion: completion)
    }
    
    func show(productId: String, completion: CommercializerDataSourceCompletion?) {
        let request = CommercializerRouter.Show(productId: productId)
        apiClient.request(request, decoder: CommercializerApiDataSource.decoder, completion: completion)
    }
    
    func create(productId: String, templateId: String, completion: CommercializerDataSourceCompletion?) {
        let request = CommercializerRouter.Create(productId: productId, parameters: ["template_id" : templateId])
        apiClient.request(request, decoder: CommercializerApiDataSource.decoder, completion: completion)
    }
    

    // MARK: - Decoder
    
    private static func decoderTemplate(object: AnyObject) -> CommercializerTemplatesByCountry? {
        guard let theTemplates : [LGCommercializerTemplate] = decode(object) else { return nil }
        let templates: [CommercializerTemplate] = theTemplates.map { $0 }
        let templatesByCountry = templates.categorise { $0.countryCode }
        return templatesByCountry
    }
    
    private static func decoder(object: AnyObject) -> [Commercializer]? {
        guard let theCommercializer : [LGCommercializer] = decode(object) else { return nil }
        return theCommercializer.map{$0}
    }
}
