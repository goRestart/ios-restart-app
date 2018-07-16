@testable import LetGoGodMode
import LGCoreKit

extension ListingFilters: MockFactory {
    public static func makeMock() -> ListingFilters {
        let place = Place(postalAddress: nil,
                          location: LGLocationCoordinates2D(latitude: 41.123, longitude: 2.123))
        return ListingFilters(place: place,
                              distanceRadius: 10,
                              distanceType: DistanceType.km,
                              selectedCategories: [ListingCategory.electronics, ListingCategory.motorsAndAccessories],
                              selectedTaxonomyChildren: [],
                              selectedTaxonomy: nil,
                              selectedWithin: ListingTimeCriteria.day,
                              selectedOrdering: ListingSortCriteria.distance,
                              priceRange: FilterPriceRange.priceRange(min: 5, max: 100),
                              verticalFilters: VerticalFilters.makeMock())
    }
}

extension VerticalFilters: MockFactory {
    
    public static func makeMock() -> VerticalFilters {
        return VerticalFilters(cars: CarFilters.makeMock(),
                               services: ServicesFilters.makeMock(),
                               realEstate: RealEstateFilters.makeMock())
    }
}

extension CarFilters: MockFactory {
    
    public static func makeMock() -> CarFilters {
        return CarFilters(sellerTypes: [UserType.pro],
                          makeId: nil,
                          makeName: "make",
                          modelId: nil,
                          modelName: "model",
                          yearStart: 1990,
                          yearEnd: 2000,
                          bodyTypes: [CarBodyType.convertible, CarBodyType.coupe],
                          driveTrainTypes: [CarDriveTrainType.awd],
                          fuelTypes: [CarFuelType.diesel, CarFuelType.hybrid],
                          transmissionTypes: [CarTransmissionType.automatic],
                          mileageStart: 90,
                          mileageEnd: 40000,
                          numberOfSeatsStart: 1,
                          numberOfSeatsEnd: 5)
    }
}

extension ServicesFilters: MockFactory {
    
    public static func makeMock() -> ServicesFilters {
        return ServicesFilters(type: MockServiceType.makeMock(),
                               subtypes: MockServiceSubtype.makeMocks())
    }
}

extension RealEstateFilters: MockFactory {
    
    public static func makeMock() -> RealEstateFilters {
        return RealEstateFilters(propertyType: RealEstatePropertyType.flat,
                                 offerTypes: [RealEstateOfferType.sale],
                                 numberOfBedrooms: NumberOfBedrooms.two,
                                 numberOfBathrooms: NumberOfBathrooms.three,
                                 numberOfRooms: NumberOfRooms(numberOfBedrooms: 2,
                                                              numberOfLivingRooms: 1),
                                 sizeRange: SizeRange(min: 1, max: nil))
    }
}
