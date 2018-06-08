import Foundation

struct MainListingsHeader: OptionSet {
    let rawValue: Int
    init(rawValue: Int) { self.rawValue = rawValue }
    
    static let PushPermissions  = MainListingsHeader(rawValue: 1)
    static let SellButton = MainListingsHeader(rawValue: 2)
    static let CategoriesCollectionBanner = MainListingsHeader(rawValue: 4)
    static let RealEstateBanner = MainListingsHeader(rawValue: 8)
    static let SearchAlerts = MainListingsHeader(rawValue: 16)
}
