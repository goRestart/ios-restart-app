//
//  MockCommercializerRepository.swift
//  LetGo
//
//  Created by Eli Kohen on 07/02/2017.
//  Copyright © 2017 Ambatana. All rights reserved.
//

import LGCoreKit

class MockCommercializerRepository: CommercializerRepository {

    var commercializersResult: CommercializersResult?
    var commercializerResult: CommercializerResult?
    var productsResult: CommercializerProductsResult?
    var templates: [CommercializerTemplate] = []

    func index(_ productId: String, completion: CommercializersCompletion?) {
        performAfterDelayWithCompletion(completion, result: commercializersResult)
    }
    func create(_ productId: String, templateId: String, completion: CommercializerCompletion?) {
        performAfterDelayWithCompletion(completion, result: commercializerResult)
    }
    func indexAvailableProducts(_ completion: CommercializerProductsCompletion?) {
        performAfterDelayWithCompletion(completion, result: productsResult)
    }
    func templatesForCountryCode(_ countryCode: String) -> [CommercializerTemplate] {
        return templates.filter { $0.countryCode == countryCode }
    }
    func availableTemplatesFor(_ commercializers: [Commercializer], countryCode: String) -> [CommercializerTemplate] {
        return templates
    }
}
