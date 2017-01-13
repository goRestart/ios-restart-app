//
//  LGCommercializerRepository.swift
//  LGCoreKit
//
//  Created by Eli Kohen on 18/11/2016.
//  Copyright © 2016 Ambatana Inc. All rights reserved.
//


final class LGCommercializerRepository: InternalCommercializerRepository {

    var templates: CommercializerTemplatesByCountry?
    let dataSource: CommercializerDataSource
    let myUserRepository: MyUserRepository

    // MARK: - Lifecycle

    init(dataSource: CommercializerDataSource, myUserRepository: MyUserRepository) {
        self.dataSource = dataSource
        self.myUserRepository = myUserRepository
    }


    // MARK: - Public methods

    func index(_ productId: String, completion: CommercializersCompletion?) {
        dataSource.index(productId) { result in
            handleApiResult(result, completion: completion)
        }
    }

    func create(_ productId: String, templateId: String, completion: CommercializerCompletion?) {
        dataSource.create(productId, templateId: templateId) { result in
            handleApiResult(result, completion: completion)
        }
    }

    func indexAvailableProducts(_ completion: CommercializerProductsCompletion?) {

        guard let userId = myUserRepository.myUser?.objectId else {
            completion?(CommercializerProductsResult(error: .internalError(message: "Missing UserId")))
            return
        }

        dataSource.indexAvailableProducts(userId) { result in
            handleApiResult(result, completion: completion)
        }
    }

    func templatesForCountryCode(_ countryCode: String) -> [CommercializerTemplate] {
        guard let actualTemplates = templates else { return [] }
        return actualTemplates[countryCode] ?? []
    }

    func availableTemplatesFor(_ commercializers: [Commercializer], countryCode: String) -> [CommercializerTemplate] {
        let allTemplates = templatesForCountryCode(countryCode)
        return allTemplates.availableTemplates(commercializers)
    }


    // MARK: - Internal Methods

    func indexTemplates(_ completion: CommercializerTemplateCompletion?) {
        dataSource.indexTemplates { result in
            if let value = result.value {
                self.templates = value
            }
            handleApiResult(result, completion: completion)
        }
    }
}
