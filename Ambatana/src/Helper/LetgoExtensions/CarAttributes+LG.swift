import LGCoreKit

extension CarAttributes {
    
    func editedFieldsTracker(newCarAttributes: CarAttributes?) -> [EventParameterEditedFields] {
        guard let newCarAttributes = newCarAttributes else { return [] }
        let stringsEquatables = [(makeId, newCarAttributes.makeId, EventParameterEditedFields.make),
                                 (modelId, newCarAttributes.modelId, EventParameterEditedFields.model),
                                 (bodyType?.rawValue, newCarAttributes.bodyType?.rawValue, EventParameterEditedFields.bodyType),
                                 (transmission?.rawValue, newCarAttributes.transmission?.rawValue, EventParameterEditedFields.transmission),
                                 (fuelType?.rawValue, newCarAttributes.fuelType?.rawValue, EventParameterEditedFields.fuelType),
                                 (driveTrain?.rawValue, newCarAttributes.driveTrain?.rawValue, EventParameterEditedFields.drivetrain)]
        let intsEquatables = [(year, newCarAttributes.year, EventParameterEditedFields.year),
                                 (mileage, newCarAttributes.mileage, EventParameterEditedFields.mileage),
                                 (seats, newCarAttributes.seats, EventParameterEditedFields.seats)]
        let diffStrings = stringsEquatables.filter { $0.0 != $0.1 }.map { $0.2 }
        let diffInts = intsEquatables.filter { $0.0 != $0.1 }.map { $0.2 }
        return diffStrings + diffInts
    }
    
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
