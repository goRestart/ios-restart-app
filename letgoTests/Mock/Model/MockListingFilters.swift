//
//  MockListingFilters.swift
//  letgoTests
//
//  Created by Tomas Cobo on 15/05/2018.
//  Copyright © 2018 Ambatana. All rights reserved.
//

@testable import LetGoGodMode
import LGCoreKit

extension ListingFilters: MockFactory {
    public static func makeMock() -> ListingFilters {
        let place = Place(postalAddress: nil,
                          location: LGLocationCoordinates2D(latitude: 41.123, longitude: 2.123))
        return ListingFilters(place: place, distanceRadius: 10, distanceType: .km,
                              selectedCategories: [.electronics, .motorsAndAccessories],
                              selectedTaxonomyChildren: [], selectedTaxonomy: nil,
                              selectedWithin: .day, selectedOrdering: ListingSortCriteria.distance,
                              priceRange: .priceRange(min: 5, max: 100), carSellerTypes: [.pro],
                              carMakeId: nil, carMakeName: "make", carModelId: nil, carModelName: "model",
                              carYearStart: RetrieveListingParam(value: 1990, isNegated: false),
                              carYearEnd: RetrieveListingParam(value: 2000, isNegated: false),
                              realEstatePropertyType: .flat, realEstateOfferType: [.sale],
                              realEstateNumberOfBedrooms: .two, realEstateNumberOfBathrooms: .three,
                              realEstateNumberOfRooms: NumberOfRooms(numberOfBedrooms: 2, numberOfLivingRooms: 1),
                              realEstateSizeRange: SizeRange(min: 1, max: nil))
    }
}
