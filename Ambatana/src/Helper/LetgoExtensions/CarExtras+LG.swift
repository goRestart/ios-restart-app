import LGCoreKit
import LGComponents

extension CarBodyType: ListingAttributeGridItem {

    static var allCases: [CarBodyType] {
        return [.sedan, .hybrid, .convertible, .truck, .coupe, .hatchback, .minivan, .wagon, .suv, .others]
    }
    
    var typeName: String {
        return R.Strings.filtersCarsBodytypeTitle
    }
    
    var title: String {
        switch self {
        case .coupe:
            return R.Strings.filtersCarsBodytypeCoupe
        case .sedan:
            return R.Strings.filtersCarsBodytypeSedan
        case .hybrid:
            return R.Strings.filtersCarsBodytypeHybrid
        case .hatchback:
            return R.Strings.filtersCarsBodytypeHatchback
        case .convertible:
            return R.Strings.filtersCarsBodytypeConvertible
        case .wagon:
            return R.Strings.filtersCarsBodytypeWagon
        case .minivan:
            return R.Strings.filtersCarsBodytypeMinivan
        case .suv:
            return R.Strings.filtersCarsBodytypeSuv
        case .truck:
            return R.Strings.filtersCarsBodytypeTruck
        case .others:
            return R.Strings.filtersCarsBodytypeOther
        }
    }
    
    var value: String {
        return self.rawValue
    }
    
    var icon: UIImage? {
        switch self {
        case .coupe:
            return R.Asset.IconsButtons.FiltersCarExtrasIcons.Bodytype.coupe.image
        case .sedan:
            return R.Asset.IconsButtons.FiltersCarExtrasIcons.Bodytype.sedan.image
        case .hybrid:
            return R.Asset.IconsButtons.FiltersCarExtrasIcons.Bodytype.hybrid.image
        case .hatchback:
            return R.Asset.IconsButtons.FiltersCarExtrasIcons.Bodytype.hatchback.image
        case .convertible:
            return R.Asset.IconsButtons.FiltersCarExtrasIcons.Bodytype.convertible.image
        case .wagon:
            return R.Asset.IconsButtons.FiltersCarExtrasIcons.Bodytype.wagon.image
        case .minivan:
            return R.Asset.IconsButtons.FiltersCarExtrasIcons.Bodytype.minivan.image
        case .suv:
            return R.Asset.IconsButtons.FiltersCarExtrasIcons.Bodytype.suv.image
        case .truck:
            return R.Asset.IconsButtons.FiltersCarExtrasIcons.Bodytype.truck.image
        case .others:
            return R.Asset.IconsButtons.FiltersCarExtrasIcons.Bodytype.other.image
        }
    }
}

extension CarDriveTrainType: ListingAttributeGridItem {
    
    static var allCases: [CarDriveTrainType] {
        return [.awd, .rwd, .fourWd, .fwd]
    }
    
    var typeName: String {
        return R.Strings.filtersCarsDrivetrainTitle
    }
    
    var title: String {
        switch self {
        case .awd:
            return R.Strings.filtersCarsDrivetrainAwd
        case .rwd:
            return R.Strings.filtersCarsDrivetrainRwd
        case .fourWd:
            return R.Strings.filtersCarsDrivetrain4wd
        case .fwd:
            return R.Strings.filtersCarsDrivetrainFwd
        }
    }
    
    var value: String {
        return self.rawValue
    }
    
    var icon: UIImage? {
        switch self {
        case .awd:
            return R.Asset.IconsButtons.FiltersCarExtrasIcons.Drivetrain.awd.image
        case .rwd:
            return R.Asset.IconsButtons.FiltersCarExtrasIcons.Drivetrain.rwd.image
        case .fourWd:
            return R.Asset.IconsButtons.FiltersCarExtrasIcons.Drivetrain._4wd.image
        case .fwd:
            return R.Asset.IconsButtons.FiltersCarExtrasIcons.Drivetrain.fwd.image
        }
    }
    
}

extension CarFuelType: ListingAttributeGridItem {
    
    static var allCases: [CarFuelType] {
        return [.electric, .gas, .diesel, .flex, .hybrid]
    }
    
    var typeName: String {
        return R.Strings.filtersCarsFueltypeTitle
    }
    
    var title: String {
        switch self {
        case .electric:
            return R.Strings.filtersCarsFueltypeElectric
        case .gas:
            return R.Strings.filtersCarsFueltypeGas
        case .diesel:
            return R.Strings.filtersCarsFueltypeDiesel
        case .flex:
            return R.Strings.filtersCarsFueltypeFlex
        case .hybrid:
            return R.Strings.filtersCarsFueltypeHybrid
        }
    }
    
    var value: String {
        return self.rawValue
    }
    
    var icon: UIImage? {
        switch self {
        case .electric:
            return R.Asset.IconsButtons.FiltersCarExtrasIcons.Fueltype.electric.image
        case .gas:
            return R.Asset.IconsButtons.FiltersCarExtrasIcons.Fueltype.gas.image
        case .diesel:
            return R.Asset.IconsButtons.FiltersCarExtrasIcons.Fueltype.diesel.image
        case .flex:
            return R.Asset.IconsButtons.FiltersCarExtrasIcons.Fueltype.flex.image
        case .hybrid:
            return R.Asset.IconsButtons.FiltersCarExtrasIcons.Fueltype.hybrid.image
        }
    }
}

extension CarTransmissionType: ListingAttributeGridItem {
    
    static var allCases: [CarTransmissionType] {
        return [.manual, .automatic]
    }
    
    var typeName: String {
        return R.Strings.filtersCarsTransmissionTitle
    }
    
    var title: String {
        switch self {
        case .manual:
            return R.Strings.filtersCarsTransmissionManual
        case .automatic:
            return R.Strings.filtersCarsTransmissionAutomatic
        }
    }
    
    var value: String {
        return self.rawValue
    }
    
    var icon: UIImage? {
        switch self {
        case .manual:
            return R.Asset.IconsButtons.FiltersCarExtrasIcons.Transmission.manual.image
        case .automatic:
            return R.Asset.IconsButtons.FiltersCarExtrasIcons.Transmission.automatic.image
        }
    }
}

enum CarSeat: Int, ListingAttributeGridItem {
    
    case one = 1 , two, three, four, five, six, seven, eight, nine
    
    static var allCases: [CarSeat] {
        return [.one, .two, .three, .four, .five, .six, .seven, .eight, .nine]
    }
    
    var typeName: String {
        return R.Strings.filterCarsSeatsTitle
    }
    
    var title: String {
        guard self == .nine else { return String(self.rawValue) }
        return "9+"
    }
    
    var value: String { return self.title }
    
    var icon: UIImage? { return nil }
}
