//
//  LocalMostSearchedItem.swift
//  LetGo
//
//  Created by Raúl de Oñate Blanco on 15/01/2018.
//  Copyright © 2018 Ambatana. All rights reserved.
//

import LGCoreKit

enum LocalMostSearchedItem: Int {
    case iPhone = 1, atv, smartphone, sedan, scooter, computer, coupe, tablet, motorcycle, truck, gadget, trailer,
    controller, dresser, subwoofer
    
    static var all() -> [LocalMostSearchedItem] {
        return [iPhone, atv, smartphone, sedan, scooter, computer, coupe, tablet, motorcycle, truck, gadget, trailer,
                controller, dresser, subwoofer]
    }
    
    var name: String {
        switch self {
        case .iPhone:
            return LGLocalizedString.trendingItemIphone
        case .atv:
            return LGLocalizedString.trendingItemAtv
        case .smartphone:
            return LGLocalizedString.trendingItemSmartphone
        case .sedan:
            return LGLocalizedString.trendingItemSedan
        case .scooter:
            return LGLocalizedString.trendingItemScooter
        case .computer:
            return LGLocalizedString.trendingItemComputer
        case .coupe:
            return LGLocalizedString.trendingItemCoupe
        case .tablet:
            return LGLocalizedString.trendingItemTablet
        case .motorcycle:
            return LGLocalizedString.trendingItemMotorcycle
        case .truck:
            return LGLocalizedString.trendingItemTruck
        case .gadget:
            return LGLocalizedString.trendingItemGadget
        case .trailer:
            return LGLocalizedString.trendingItemTrailer
        case .controller:
            return LGLocalizedString.trendingItemController
        case .dresser:
            return LGLocalizedString.trendingItemDresser
        case .subwoofer:
            return LGLocalizedString.trendingItemSubwoofer
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
    
    var category: ListingCategory {
        switch self {
        case .iPhone:
            return .electronics
        case .atv:
            return .cars
        case .smartphone:
            return .electronics
        case .sedan:
            return .cars
        case .scooter:
            return .cars
        case .computer:
            return .electronics
        case .coupe:
            return .cars
        case .tablet:
            return .electronics
        case .motorcycle:
            return .cars
        case .truck:
            return .cars
        case .gadget:
            return .electronics
        case .trailer:
            return .cars
        case .controller:
            return .sportsLeisureAndGames
        case .dresser:
            return .homeAndGarden
        case .subwoofer:
            return .electronics
        }
    }
}
