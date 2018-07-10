
import LGComponents
import LGCoreKit

struct CarAttributeItem: ListingAttributeGridItem {
    let typeName: String
    let title: String
    let value: String
    let icon: UIImage?
}

extension CarAttributeItem {
    
    static func newMileageInstance(withMileage mileage: Int?,
                                   mileageType: DistanceType?) -> CarAttributeItem? {
        
        guard let mileage = mileage,
            let title = NumberFormatter.formattedMileage(forValue: mileage,
                                                         distanceUnit: mileageType?.localizedUnitType()) else {
                                                            return nil
        }
        return CarAttributeItem(typeName: R.Strings.filtersMileageSliderTitle,
                                title: title,
                                value: String(mileage),
                                icon: R.Asset.IconsButtons.FiltersCarExtrasIcons.mileage.image)
    }
    
    static func newSeatNumberInstance(withSeatNumber seatNumber: Int?) -> CarAttributeItem? {
        guard let seatNumber = seatNumber else { return nil }
        let title = "\(seatNumber) " + R.Strings.filtersNumberOfSeatsSliderTitle
        return CarAttributeItem(typeName: R.Strings.filterCarsSeatsTitle,
                                title: title,
                                value: String(seatNumber),
                                icon: R.Asset.IconsButtons.FiltersCarExtrasIcons.seats.image)
    }
}
