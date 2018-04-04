//
//  LGMachineLearningStats.swift
//  LGCoreKit
//
//  Created by Nestor on 06/03/2018.
//  Copyright © 2018 Ambatana Inc. All rights reserved.
//

public protocol MachineLearningStats {
    var keyword: String { get }
    var hits: Int { get }
    var prices: [Double] { get }
    var usersSearching: Int { get }
    var category: ListingCategory { get }
    var medianDaysToSell: Double { get }
    
    var confidence: Double? { get }
    var description: String { get }
    
    init(keyword: String,
         hits: Int,
         prices: [Double],
         usersSearching: Int,
         category: ListingCategory,
         medianDaysToSell: Double,
         confidence: Double?)
    
    func updating(confidence: Double) -> MachineLearningStats
}

struct LGMachineLearningStats: MachineLearningStats, Decodable {
    let keyword: String
    let hits: Int
    let prices: [Double]
    let usersSearching: Int
    let category: ListingCategory
    let medianDaysToSell: Double
    
    let confidence: Double?
    var description: String {
        return """
        keyword:\t\t \(keyword)
        confidence:\t \(confidence ?? 0)
        hits:\t\t \(hits)
        prices:\t\t \(prices)
        userSearches:\t \(usersSearching)
        category:\t\t \(category)
        daysToSell:\t \(medianDaysToSell)
        """
    }
    
    init(keyword: String,
         hits: Int,
         prices: [Double],
         usersSearching: Int,
         category: ListingCategory,
         medianDaysToSell: Double,
         confidence: Double?) {
        self.keyword = keyword
        self.hits = hits
        self.prices = prices
        self.usersSearching = usersSearching
        self.category = category
        self.medianDaysToSell = medianDaysToSell
        self.confidence = confidence
    }
    
    func updating(confidence: Double) -> MachineLearningStats {
        return type(of: self).init(keyword: keyword,
                                   hits: hits,
                                   prices: prices,
                                   usersSearching: usersSearching,
                                   category: category,
                                   medianDaysToSell: medianDaysToSell,
                                   confidence: confidence)
    }
    
    /*
    {
     "keyword": "3ds",
     "hits": 96,
     "prices": [15.0, 40.0, 97.5, 150.0, 160.9],
     "category_id": "1",
     "median_days_to_sell": 8.618281364440918,
     "users_searching": 0
     }
     */
    
    // MARK: Decodable
    
    public init(from decoder: Decoder) throws {
        let keyedContainer = try decoder.container(keyedBy: CodingKeys.self)
        keyword = try keyedContainer.decode(String.self, forKey: .keyword)
        hits = try keyedContainer.decode(Int.self, forKey: .hits)
        prices = try keyedContainer.decode([Double].self, forKey: .prices)
        usersSearching = try keyedContainer.decode(Int.self, forKey: .usersSearching)
        let categoryRawValue = try keyedContainer.decode(String.self, forKey: .categoryId)
        category = ListingCategory(rawValue: Int(categoryRawValue) ?? 0) ?? .unassigned
        medianDaysToSell = try keyedContainer.decode(Double.self, forKey: .medianDaysToSell)
        confidence = nil
    }
    
    enum CodingKeys: String, CodingKey {
        case keyword
        case hits
        case prices
        case usersSearching = "users_searching"
        case categoryId = "category_id"
        case medianDaysToSell = "median_days_to_sell"
    }
}
