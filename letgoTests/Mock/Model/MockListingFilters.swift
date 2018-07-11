@testable import LetGoGodMode
import LGCoreKit

extension ListingFilters: MockFactory {
    public static func makeMock() -> ListingFilters {
        let place = Place(postalAddress: nil,
                          location: LGLocationCoordinates2D(latitude: 41.123, longitude: 2.123))
        return ListingFilters(place: place, distanceRadius: 10, distanceType: DistanceType.km,
                              selectedCategories: [ListingCategory.electronics, ListingCategory.motorsAndAccessories],
                              selectedTaxonomyChildren: [], selectedTaxonomy: nil,
                              selectedWithin: ListingTimeCriteria.day, selectedOrdering: ListingSortCriteria.distance,
                              priceRange: FilterPriceRange.priceRange(min: 5, max: 100), carSellerTypes: [UserType.pro],
                              carMakeId: nil, carMakeName: "make", carModelId: nil, carModelName: "model",
                              carYearStart: 1990,
                              carYearEnd: 2000,
                              carBodyTypes: [CarBodyType.convertible, CarBodyType.coupe],
                              carFuelTypes: [CarFuelType.diesel, CarFuelType.hybrid],
                              carTransmissionTypes: [CarTransmissionType.automatic],
                              carDriveTrainTypes: [CarDriveTrainType.awd],
                              carMileageStart: 90,
                              carMileageEnd: 40000,
                              carNumberOfSeatsStart: 1,
                              carNumberOfSeatsEnd: 5,
                              realEstatePropertyType: RealEstatePropertyType.flat, realEstateOfferType: [RealEstateOfferType.sale],
                              realEstateNumberOfBedrooms: NumberOfBedrooms.two, realEstateNumberOfBathrooms: NumberOfBathrooms.three,
                              realEstateNumberOfRooms: NumberOfRooms(numberOfBedrooms: 2, numberOfLivingRooms: 1),
                              realEstateSizeRange: SizeRange(min: 1, max: nil),
                              servicesType: MockServiceType.makeMock(),
                              servicesSubtypes: MockServiceSubtype.makeMocks())
    }
}
