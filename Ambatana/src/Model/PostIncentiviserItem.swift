import LGComponents

enum PostIncentiviserItem: Int {
    case ps4 = 1
    case tv
    case bike
    case motorcycle
    case dresser
    case car
    case kidsClothes
    case furniture
    case toys
    case cleaning
    case lessons
    case creative

    static func incentiviserPack(_ freePosting: Bool) -> [PostIncentiviserItem] {
        guard !freePosting else { return [.kidsClothes, .furniture, .toys] }
        let pack = Int.random(0, 1)
        guard pack == 0 else { return [.motorcycle, .dresser, .car] }
        return [.ps4, .tv, .bike]
    }
    
    static func servicesIncentiviserPack() -> [PostIncentiviserItem] {
        return [.cleaning, .lessons, .creative]
    }

    var name: String {
        switch self {
        case .ps4:
            return R.Strings.productPostIncentivePs4
        case .tv:
            return R.Strings.productPostIncentiveTv
        case .bike:
            return R.Strings.productPostIncentiveBike
        case .motorcycle:
            return R.Strings.productPostIncentiveMotorcycle
        case .dresser:
            return R.Strings.productPostIncentiveDresser
        case .car:
            return R.Strings.productPostIncentiveCar
        case .kidsClothes:
            return R.Strings.productPostIncentiveKidsClothes
        case .furniture:
            return R.Strings.productPostIncentiveFurniture
        case .toys:
            return R.Strings.productPostIncentiveToys
        case .cleaning:
            return R.Strings.productPostIncentiveCleaning
        case .lessons:
            return R.Strings.productPostIncentiveLessons
        case .creative:
            return R.Strings.productPostIncentiveCreative
        }
    }

    var image: UIImage? {
        switch self {
        case .ps4:
            return R.Asset.CongratsScreenImages.ps4.image
        case .tv:
            return R.Asset.CongratsScreenImages.tv.image
        case .bike:
            return R.Asset.CongratsScreenImages.bike.image
        case .motorcycle:
            return R.Asset.CongratsScreenImages.motorcycle.image
        case .dresser:
            return R.Asset.CongratsScreenImages.dresser.image
        case .car:
            return R.Asset.CongratsScreenImages.cars.image
        case .kidsClothes:
            return R.Asset.CongratsScreenImages.kidsClothes.image
        case .furniture:
            return R.Asset.CongratsScreenImages.furniture.image
        case .toys:
            return R.Asset.CongratsScreenImages.toys.image
        case .cleaning:
            return R.Asset.CongratsScreenImages.cleaning.image
        case .lessons:
            return R.Asset.CongratsScreenImages.lessons.image
        case .creative:
            return R.Asset.CongratsScreenImages.creative.image
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
        case .cleaning:
            return 77296
        case .lessons:
            return 74354
        case .creative:
            return 72256
        }
    }

    var searchCount: String? {
        return DailyCountIncrementer.randomizeSearchCount(baseSearchCount: baseSearchCount,
                                                          itemIndex: self.rawValue)
    }
}
