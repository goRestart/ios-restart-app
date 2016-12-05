//
//  CommercializerRepository.swift
//  LGCoreKit
//
//  Created by Isaac Roldan on 2/3/16.
//  Copyright © 2016 Ambatana Inc. All rights reserved.
//

import Result

public typealias CommercializerResult = Result<Commercializer, RepositoryError>
public typealias CommercializerCompletion = CommercializerResult -> Void

public typealias CommercializersResult = Result<[Commercializer], RepositoryError>
public typealias CommercializersCompletion = CommercializersResult -> Void

public typealias CommercializerProductsResult = Result<[CommercializerProduct], RepositoryError>
public typealias CommercializerProductsCompletion = CommercializerProductsResult -> Void

public protocol CommercializerRepository {
    
    func index(productId: String, completion: CommercializersCompletion?)
    func create(productId: String, templateId: String, completion: CommercializerCompletion?)
    func indexAvailableProducts(completion: CommercializerProductsCompletion?)
    func templatesForCountryCode(countryCode: String) -> [CommercializerTemplate]
    func availableTemplatesFor(commercializers: [Commercializer], countryCode: String) -> [CommercializerTemplate]
}


typealias CommercializerTemplatesByCountry = [String: [CommercializerTemplate]]
typealias CommercializerTemplateResult = Result<CommercializerTemplatesByCountry, RepositoryError>
typealias CommercializerTemplateCompletion = CommercializerTemplateResult -> Void


protocol InternalCommercializerRepository: CommercializerRepository {
     func indexTemplates(completion: CommercializerTemplateCompletion?)
}
