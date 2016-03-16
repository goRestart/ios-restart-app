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

public typealias CommercializerResult = Result<[Commercializer], RepositoryError>
public typealias CommercializerCompletion = CommercializerResult -> Void


public final class CommercializerRepository {

    var templates: CommercializerTemplatesByCountry?
    let dataSource: CommercializerDataSource
   

    // MARK: - Lifecycle
    
    init(dataSource: CommercializerDataSource) {
        self.dataSource = dataSource
    }
    
    
    // MARK: - Public methods
    
    public func show(productId: String, completion: CommercializerCompletion?) {
        dataSource.show(productId) { result in
            handleApiResult(result, completion: completion)
        }
    }
    
    public func create(productId: String, templateId: String, completion: CommercializerCompletion?) {
        dataSource.create(productId, templateId: templateId) { result in
            handleApiResult(result, completion: completion)
        }
    }

    public func templatesForCountryCode(countryCode: String) -> [CommercializerTemplate] {
        guard let actualTemplates = templates else { return [] }
        return actualTemplates[countryCode] ?? []
    }


    // MARK: - Internal Methods

    func indexTemplates(completion: CommercializerTemplateCompletion?) {
        if let _ = templates { return }
        dataSource.indexTemplates { result in
            if let value = result.value {
                self.templates = value
            }
            handleApiResult(result, completion: completion)
        }
    }
}
