import Result

open class MockCommercializerRepository: CommercializerRepository {
    public var indexResult: CommercializersResult
    public var createResult: CommercializerResult
    public var indexProductsResult: CommercializerProductsResult
    public var countryCodeToTemplates: [String: [CommercializerTemplate]]
    

    // MARK: - Lifecycle

    public init() {
        self.indexResult = CommercializersResult(value: MockCommercializer.makeMocks(count: Int.makeRandom(min: 0, max: 10)))
        self.createResult = CommercializerResult(value: MockCommercializer.makeMock())
        self.indexProductsResult = CommercializerProductsResult(value: MockCommercializerProduct.makeMocks(count: Int.makeRandom(min: 0, max: 10)))
        self.countryCodeToTemplates = [:]
    }


    // MARK: - CommercializerRepository

    public func index(_ productId: String, completion: CommercializersCompletion?) {
        delay(result: indexResult, completion: completion)
    }

    public func create(_ productId: String, templateId: String, completion: CommercializerCompletion?) {
        delay(result: createResult, completion: completion)
    }

    public func indexAvailableProducts(_ completion: CommercializerProductsCompletion?) {
        delay(result: indexProductsResult, completion: completion)
    }

    public func templatesForCountryCode(_ countryCode: String) -> [CommercializerTemplate] {
        return countryCodeToTemplates[countryCode] ?? []
    }

    public func availableTemplatesFor(_ commercializers: [Commercializer], countryCode: String) -> [CommercializerTemplate] {
        let allTemplates = templatesForCountryCode(countryCode)
        return allTemplates.availableTemplates(commercializers)
    }

}
