//
//  PostIncentiviserItem.swift
//  LetGo
//
//  Created by Dídac on 05/07/16.
//  Copyright © 2016 Ambatana. All rights reserved.
//


enum PostIncentiviserItem: Int {
    case PS4 = 1, TV, Bike, Motorcycle, Dresser, Car, KidsClothes, Furniture, Toys

    static func incentiviserPack(freePosting: Bool) -> [PostIncentiviserItem] {
        guard !freePosting else { return [.KidsClothes, .Furniture, .Toys] }
        let pack = Int.random(0, 1)
        guard pack == 0 else { return [.Motorcycle, .Dresser, .Car] }
        return [.PS4, .TV, .Bike]
    }

    var name: String {
        switch self {
        case .PS4:
            return LGLocalizedString.productPostIncentivePs4
        case .TV:
            return LGLocalizedString.productPostIncentiveTv
        case .Bike:
            return LGLocalizedString.productPostIncentiveBike
        case .Motorcycle:
            return LGLocalizedString.productPostIncentiveMotorcycle
        case .Dresser:
            return LGLocalizedString.productPostIncentiveDresser
        case .Car:
            return LGLocalizedString.productPostIncentiveCar
        case .KidsClothes:
            return LGLocalizedString.productPostIncentiveKidsClothes
        case .Furniture:
            return LGLocalizedString.productPostIncentiveFurniture
        case .Toys:
            return LGLocalizedString.productPostIncentiveToys
        }
    }

    var image: UIImage? {
        switch self {
        case .PS4:
            return UIImage(named: "ps4")
        case .TV:
            return UIImage(named: "tv")
        case .Bike:
            return UIImage(named: "bike")
        case .Motorcycle:
            return UIImage(named: "motorcycle")
        case .Dresser:
            return UIImage(named: "dresser")
        case .Car:
            return UIImage(named: "cars")
        case .KidsClothes:
            return UIImage(named: "kids_clothes")
        case .Furniture:
            return UIImage(named: "furniture")
        case .Toys:
            return UIImage(named: "toys")
        }
    }

    var baseSearchCount: Int {
        switch self {
        case .PS4:
            return 82801
        case .TV:
            return 71715
        case .Bike:
            return 56687
        case .Motorcycle:
            return 74661
        case .Dresser:
            return 50559
        case .Car:
            return 77296
        case .KidsClothes:
            return 74111
        case .Furniture:
            return 50297
        case .Toys:
            return 76985
        }
    }

    var searchCount: String? {
        let calendar = NSCalendar.currentCalendar()
        return searchCount(calendar)
    }

    func searchCount(calendar: NSCalendar) -> String? {
        let fmt = NSNumberFormatter()
        fmt.numberStyle = .DecimalStyle
        fmt.locale = NSLocale.currentLocale()
        guard let stringNumber = fmt.stringFromNumber(self.baseSearchCount + searchCountIncrement(calendar)) else { return nil }
        return stringNumber
    }


    // MARK: private methods

    private func searchCountIncrement(calendar: NSCalendar) -> Int {
        let components = calendar.components([.Month,.Day], fromDate: NSDate())
        let dailyIncrement = baseSearchCount/200
        let monthDivision = max(components.month / self.rawValue, 1)
        let increment = dailyIncrement + (self.rawValue * components.day) / monthDivision // "randomizing" like a baws
        return increment
    }
}
