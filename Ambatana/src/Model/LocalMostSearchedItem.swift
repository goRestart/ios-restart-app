//
//  LocalMostSearchedItem.swift
//  LetGo
//
//  Created by Raúl de Oñate Blanco on 15/01/2018.
//  Copyright © 2018 Ambatana. All rights reserved.
//

import LGCoreKit

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
    
    var category: PostCategory {
        switch self {
        case .iPhone:
            return .unassigned(listingCategory: .electronics)
        case .atv:
            return .car
        case .smartphone:
            return .unassigned(listingCategory: .electronics)
        case .sedan:
            return .car
        case .scooter:
            return .car
        case .computer:
            return .unassigned(listingCategory: .electronics)
        case .coupe:
            return .car
        case .tablet:
            return .unassigned(listingCategory: .electronics)
        case .motorcycle:
            return .car
        case .truck:
            return .motorsAndAccessories
        case .gadget:
            return .unassigned(listingCategory: .electronics)
        case .trailer:
            return .motorsAndAccessories
        case .controller:
            return .unassigned(listingCategory: .sportsLeisureAndGames)
        case .dresser:
            return .unassigned(listingCategory: .homeAndGarden)
        case .subwoofer:
            return .unassigned(listingCategory: .electronics)
        }
    }
}
