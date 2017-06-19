//
//  MockCarsInfoRepository.swift
//  LGCoreKit
//
//  Created by Juan Iglesias on 27/04/2017.
//  Copyright © 2017 Ambatana Inc. All rights reserved.
//


open class MockCarsInfoRepository: CarsInfoRepository {
    
    public var carsMakeRetrieved: [CarsMake] = []
    public var carsModelRetrieved: [CarsModel] = []
    public var yearRetrieved: [Int] = []
    public var modelNameRetrieved: String? = nil
    public var makeNameRetrieved: String? = nil
    
    // MARK: - Lifecycle
    
    required public init() {}
    
    
    public func loadFirstRunCacheIfNeeded(jsonURL: URL) { }
    public func refreshCarsInfoFile() { }
    public func retrieveCarsMakes() -> [CarsMake] { return carsMakeRetrieved }
    public func retrieveCarsModelsFormake(makeId: String) -> [CarsModel] { return  carsModelRetrieved }
    public func retrieveValidYears(withFirstYear firstYear: Int?, ascending: Bool) -> [Int] { return yearRetrieved }
    public func retrieveModelName(with makeId: String?, modelId: String?) -> String? { return modelNameRetrieved }
    public func retrieveMakeName(with makeId: String?) -> String? { return makeNameRetrieved }
   
}
