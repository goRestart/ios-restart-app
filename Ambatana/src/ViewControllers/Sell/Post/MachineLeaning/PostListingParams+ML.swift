//
//  PostListingParams+ML.swift
//  LetGo
//
//  Created by Nestor on 12/03/2018.
//  Copyright © 2018 Ambatana. All rights reserved.
//

import Foundation
import LGCoreKit

extension ListingCreationParams {
    static func make(title: String?,
                     description: String,
                     currency: Currency,
                     location: LGLocationCoordinates2D,
                     postalAddress: PostalAddress,
                     postListingState: MLPostListingState) -> ListingCreationParams {
        
        let listingCreationParams: ListingCreationParams
        let location = postListingState.place?.location ?? location
        let postalAddress = postListingState.place?.postalAddress ?? postalAddress
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
                                                  videos: [],
                                                  carAttributes: postListingState.verticalAttributes?.carAttributes ?? CarAttributes.emptyCarAttributes())
                listingCreationParams = ListingCreationParams.car(carParams)
            case .realEstate:
                let realEstateParams = RealEstateCreationParams(name: title,
                                                                description: description,
                                                                price: postListingState.price ?? Constants.defaultPrice,
                                                                category: .realEstate,
                                                                currency: currency,
                                                                location: location,
                                                                postalAddress: postalAddress,
                                                                images: postListingState.lastImagesUploadResult?.value ?? [],
                                                                videos: [],
                                                                realEstateAttributes: postListingState.verticalAttributes?.realEstateAttributes ?? RealEstateAttributes.emptyRealEstateAttributes())
                listingCreationParams = ListingCreationParams.realEstate(realEstateParams)
            case .motorsAndAccessories, .otherItems:
                let productParams = ProductCreationParams(name: title,
                                                          description: description,
                                                          price: postListingState.price ?? Constants.defaultPrice,
                                                          category: category.listingCategory,
                                                          currency: currency,
                                                          location: location,
                                                          postalAddress: postalAddress,
                                                          images: postListingState.lastImagesUploadResult?.value ?? [],
                                                          videos: [])
                listingCreationParams = ListingCreationParams.product(productParams)
            }
        } else {
            let productParams = ProductCreationParams(name: title,
                                                      description: description,
                                                      price: postListingState.price ?? Constants.defaultPrice,
                                                      category: postListingState.category?.listingCategory ?? .unassigned,
                                                      currency: currency,
                                                      location: location,
                                                      postalAddress: postalAddress,
                                                      images: postListingState.lastImagesUploadResult?.value ?? [],
                                                      videos: [])
            listingCreationParams = ListingCreationParams.product(productParams)
        }
        return listingCreationParams
    }
}
