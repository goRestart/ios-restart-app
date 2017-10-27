//
//  ListingCreationParams+LG.swift
//  LetGo
//
//  Created by Juan Iglesias on 18/10/2017.
//  Copyright © 2017 Ambatana. All rights reserved.
//

import LGCoreKit

extension ListingCreationParams {
    static func make(title: String,
                     description: String,
                     currency: Currency,
                     location: LGLocationCoordinates2D,
                     postalAddress: PostalAddress,
                     postListingState: PostListingState) -> ListingCreationParams {
        
        let listingCreationParams: ListingCreationParams
        
        if let category = postListingState.category {
            switch category {
            case .car:
                let carParams = CarCreationParams(name: title,
                                                  description: description,
                                                  price: postListingState.price ?? Constants.defaultPrice,
                                                  category: .cars,
                                                  currency: currency,
                                                  location: location,
                                                  postalAddress: postalAddress,
                                                  images: postListingState.lastImagesUploadResult?.value ?? [],
                                                  carAttributes: postListingState.verticalAttributes?.carAttributes ?? CarAttributes.emptyCarAttributes())
                listingCreationParams = ListingCreationParams.car(carParams)
            case .realEstate:
                let realEstateParams = RealEstateCreationParams(name: title,
                                                                description: description,
                                                                price: Constants.defaultPrice,
                                                                category: .realEstate,
                                                                currency: currency,
                                                                location: location,
                                                                postalAddress: postalAddress,
                                                                images: postListingState.lastImagesUploadResult?.value ?? [],
                                                                realEstateAttributes: postListingState.verticalAttributes?.realEstateAttributes ?? RealEstateAttributes.emptyRealEstateAttributes())
                listingCreationParams = ListingCreationParams.realEstate(realEstateParams)
            case .motorsAndAccessories, .unassigned:
                let productParams = ProductCreationParams(name: title,
                                                          description: description,
                                                          price: Constants.defaultPrice,
                                                          category: category.listingCategory,
                                                          currency: currency,
                                                          location: location,
                                                          postalAddress: postalAddress,
                                                          images: postListingState.lastImagesUploadResult?.value ?? [])
                listingCreationParams = ListingCreationParams.product(productParams)
            }
        } else {
            let productParams = ProductCreationParams(name: title,
                                                      description: description,
                                                      price: Constants.defaultPrice,
                                                      category: .unassigned,
                                                      currency: currency,
                                                      location: location,
                                                      postalAddress: postalAddress,
                                                      images: postListingState.lastImagesUploadResult?.value ?? [])
            listingCreationParams = ListingCreationParams.product(productParams)
        }
        return listingCreationParams
    }
}
