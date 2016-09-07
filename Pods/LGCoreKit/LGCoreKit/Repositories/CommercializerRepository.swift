//
//  CommercializerRepository.swift
//  LGCoreKit
//
//  Created by Isaac Roldan on 2/3/16.
//  Copyright © 2016 Ambatana Inc. All rights reserved.
//

import Result


public typealias CommercializerTemplatesByCountry = [String: [CommercializerTemplate]]
public typealias CommercializerTemplateResult = Result<CommercializerTemplatesByCountry, RepositoryError>
public typealias CommercializerTemplateCompletion = CommercializerTemplateResult -> Void

public typealias CommercializerResult = Result<Commercializer, RepositoryError>
public typealias CommercializerCompletion = CommercializerResult -> Void

public typealias CommercializersResult = Result<[Commercializer], RepositoryError>
public typealias CommercializersCompletion = CommercializersResult -> Void

public typealias CommercializerProductsResult = Result<[CommercializerProduct], RepositoryError>
public typealias CommercializerProductsCompletion = CommercializerProductsResult -> Void

public final class CommercializerRepository {

    var templates: CommercializerTemplatesByCountry?
    let dataSource: CommercializerDataSource
    let myUserRepository: MyUserRepository

    // MARK: - Lifecycle
    
    init(dataSource: CommercializerDataSource, myUserRepository: MyUserRepository) {
        self.dataSource = dataSource
        self.myUserRepository = myUserRepository
    }
    
    
    // MARK: - Public methods
    
    public func index(productId: String, completion: CommercializersCompletion?) {
        dataSource.index(productId) { result in
            handleApiResult(result, completion: completion)
        }
    }
    
    public func create(productId: String, templateId: String, completion: CommercializerCompletion?) {
        dataSource.create(productId, templateId: templateId) { result in
            handleApiResult(result, completion: completion)
        }
    }
    
    public func indexAvailableProducts(completion: CommercializerProductsCompletion?) {
        
        guard let userId = myUserRepository.myUser?.objectId else {
            completion?(Result<[CommercializerProduct], RepositoryError>(error: .Internal(message: "Missing UserId")))
            return
        }
        
        dataSource.indexAvailableProducts(userId) { result in
            handleApiResult(result, completion: completion)
        }
    }

    public func templatesForCountryCode(countryCode: String) -> [CommercializerTemplate] {
        guard let actualTemplates = templates else { return [] }
        return actualTemplates[countryCode] ?? []
    }
    
    public func availableTemplatesFor(commercializers: [Commercializer], countryCode: String) -> [CommercializerTemplate] {
        let allTemplates = templatesForCountryCode(countryCode)
        return allTemplates.availableTemplates(commercializers)
    }


    // MARK: - Internal Methods

    func indexTemplates(completion: CommercializerTemplateCompletion?) {
        dataSource.indexTemplates { result in
            if let value = result.value {
                self.templates = value
            }
            handleApiResult(result, completion: completion)
        }
    }
}
