import LGCoreKit

extension CarAttributes {
    
    func createListingAttributesCollection() -> [ListingAttributeGridItem] {
        let mileageAttributeItem = CarAttributeItem.newMileageInstance(withMileage: mileage,
                                                          mileageType: mileageType)
        let seatsAttributeItem = CarAttributeItem.newSeatNumberInstance(withSeatNumber: seats)
        let items: [ListingAttributeGridItem?] = [bodyType, mileageAttributeItem, transmission,
                                                  fuelType, driveTrain, seatsAttributeItem]
        return items.compactMap({ $0 })
    }
    
    var generatedTitle: String {
        let separator = " - "
        var title: String = ""
        
        var yearString: String? = nil
        if let year = year {
            yearString = String(year)
        }
        title = [make, model, yearString].compactMap{$0}.filter { $0 != CarAttributes.emptyMake && $0 != CarAttributes.emptyModel && $0 != String(CarAttributes.emptyYear) }.joined(separator: separator)
        return title
    }
}
