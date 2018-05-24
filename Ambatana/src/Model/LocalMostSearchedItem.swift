import LGCoreKit
import LGComponents

enum LocalMostSearchedItem: Int {
    case iPhone = 1
    case atv
    case smartphone
    case sedan
    case scooter
    case computer
    case coupe
    case tablet
    case motorcycle
    case truck
    case gadget
    case trailer
    case controller
    case dresser
    case subwoofer
    
    static var allValues: [LocalMostSearchedItem] {
        return [iPhone, atv, smartphone, sedan, scooter, computer, coupe, tablet, motorcycle, truck, gadget, trailer,
                controller, dresser, subwoofer]
    }
    
    var name: String {
        switch self {
        case .iPhone:
            return R.Strings.trendingItemIPhone
        case .atv:
            return R.Strings.trendingItemAtv
        case .smartphone:
            return R.Strings.trendingItemSmartphone
        case .sedan:
            return R.Strings.trendingItemSedan
        case .scooter:
            return R.Strings.trendingItemScooter
        case .computer:
            return R.Strings.trendingItemComputer
        case .coupe:
            return R.Strings.trendingItemCoupe
        case .tablet:
            return R.Strings.trendingItemTablet
        case .motorcycle:
            return R.Strings.trendingItemMotorcycle
        case .truck:
            return R.Strings.trendingItemTruck
        case .gadget:
            return R.Strings.trendingItemGadget
        case .trailer:
            return R.Strings.trendingItemTrailer
        case .controller:
            return R.Strings.trendingItemController
        case .dresser:
            return R.Strings.trendingItemDresser
        case .subwoofer:
            return R.Strings.trendingItemSubwoofer
        }
    }
    
    private var weekdaysCount: Int {
        return 7
    }
    var baseSearchCount: Int {
        switch self {
        case .iPhone:
            return 7938*weekdaysCount
        case .atv:
            return 4004*weekdaysCount
        case .smartphone:
            return 2145*weekdaysCount
        case .sedan:
            return 6711*weekdaysCount
        case .scooter:
            return 1758*weekdaysCount
        case .computer:
            return 2967*weekdaysCount
        case .coupe:
            return 6711*weekdaysCount
        case .tablet:
            return 1248*weekdaysCount
        case .motorcycle:
            return 6053*weekdaysCount
        case .truck:
            return 6711*weekdaysCount
        case .gadget:
            return 5686*weekdaysCount
        case .trailer:
            return 5062*weekdaysCount
        case .controller:
            return 1456*weekdaysCount
        case .dresser:
            return 11014*weekdaysCount
        case .subwoofer:
            return 1531*weekdaysCount
        }
    }
    
    var searchCount: String? {
        return DailyCountIncrementer.randomizeSearchCount(baseSearchCount: baseSearchCount,
                                                          itemIndex: self.rawValue)
    }
    
    var category: PostCategory {
        switch self {
        case .iPhone:
            return .otherItems(listingCategory: .electronics)
        case .atv:
            return .car
        case .smartphone:
            return .otherItems(listingCategory: .electronics)
        case .sedan:
            return .car
        case .scooter:
            return .motorsAndAccessories
        case .computer:
            return .otherItems(listingCategory: .electronics)
        case .coupe:
            return .car
        case .tablet:
            return .otherItems(listingCategory: .electronics)
        case .motorcycle:
            return .motorsAndAccessories
        case .truck:
            return .car
        case .gadget:
            return .otherItems(listingCategory: .electronics)
        case .trailer:
            return .motorsAndAccessories
        case .controller:
            return .otherItems(listingCategory: .sportsLeisureAndGames)
        case .dresser:
            return .otherItems(listingCategory: .homeAndGarden)
        case .subwoofer:
            return .otherItems(listingCategory: .electronics)
        }
    }
}
