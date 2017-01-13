//
//  PostIncentiviserItem.swift
//  LetGo
//
//  Created by Dídac on 05/07/16.
//  Copyright © 2016 Ambatana. All rights reserved.
//


enum PostIncentiviserItem: Int {
    case ps4 = 1, tv, bike, motorcycle, dresser, car, kidsClothes, furniture, toys

    static func incentiviserPack(_ freePosting: Bool) -> [PostIncentiviserItem] {
        guard !freePosting else { return [.kidsClothes, .furniture, .toys] }
        let pack = Int.random(0, 1)
        guard pack == 0 else { return [.motorcycle, .dresser, .car] }
        return [.ps4, .tv, .bike]
    }

    var name: String {
        switch self {
        case .ps4:
            return LGLocalizedString.productPostIncentivePs4
        case .tv:
            return LGLocalizedString.productPostIncentiveTv
        case .bike:
            return LGLocalizedString.productPostIncentiveBike
        case .motorcycle:
            return LGLocalizedString.productPostIncentiveMotorcycle
        case .dresser:
            return LGLocalizedString.productPostIncentiveDresser
        case .car:
            return LGLocalizedString.productPostIncentiveCar
        case .kidsClothes:
            return LGLocalizedString.productPostIncentiveKidsClothes
        case .furniture:
            return LGLocalizedString.productPostIncentiveFurniture
        case .toys:
            return LGLocalizedString.productPostIncentiveToys
        }
    }

    var image: UIImage? {
        switch self {
        case .ps4:
            return UIImage(named: "ps4")
        case .tv:
            return UIImage(named: "tv")
        case .bike:
            return UIImage(named: "bike")
        case .motorcycle:
            return UIImage(named: "motorcycle")
        case .dresser:
            return UIImage(named: "dresser")
        case .car:
            return UIImage(named: "cars")
        case .kidsClothes:
            return UIImage(named: "kids_clothes")
        case .furniture:
            return UIImage(named: "furniture")
        case .toys:
            return UIImage(named: "toys")
        }
    }

    var baseSearchCount: Int {
        switch self {
        case .ps4:
            return 82801
        case .tv:
            return 71715
        case .bike:
            return 56687
        case .motorcycle:
            return 74661
        case .dresser:
            return 50559
        case .car:
            return 77296
        case .kidsClothes:
            return 74111
        case .furniture:
            return 50297
        case .toys:
            return 76985
        }
    }

    var searchCount: String? {
        return searchCount(Date())
    }

    func searchCount(_ date: Date) -> String? {
        let fmt = NumberFormatter()
        fmt.numberStyle = .decimal
        fmt.locale = Locale.current
        let value = NSNumber(value: baseSearchCount + searchCountIncrement(date))
        guard let stringNumber = fmt.string(from:value) else { return nil }
        return stringNumber
    }


    // MARK: private methods

    private func searchCountIncrement(_ date: Date) -> Int {
        let calendar = Calendar.current
        let components = (calendar as NSCalendar).components([.month,.day], from: date)
        let month = components.month ?? 1
        let day = components.day ?? 1
        let dailyIncrement = baseSearchCount/200
        let monthDivision = max(month / self.rawValue, 1)
        let increment = dailyIncrement + (self.rawValue * day) / monthDivision // "randomizing" like a baws
        return increment
    }
}
