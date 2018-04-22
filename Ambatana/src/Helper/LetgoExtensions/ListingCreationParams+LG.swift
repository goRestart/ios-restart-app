//
//  ListingCreationParams+LG.swift
//  LetGo
//
//  Created by Juan Iglesias on 18/10/2017.
//  Copyright © 2017 Ambatana. All rights reserved.
//

import LGCoreKit

extension ListingCreationParams {
    static func make(title: String?,
                     description: String,
                     currency: Currency,
                     location: LGLocationCoordinates2D,
                     postalAddress: PostalAddress,
                     postListingState: PostListingState) -> ListingCreationParams {
        
        let listingCreationParams: ListingCreationParams
        let location = postListingState.place?.location ?? location
        let postalAddress = postListingState.place?.postalAddress ?? postalAddress
        var images: [File]
        if let uploadedImages = postListingState.lastImagesUploadResult?.value {
            images = uploadedImages
        } else {
            images = []
        }
        let videos: [Video]
        if let uploadedVideo = postListingState.uploadedVideo,
            let path = uploadedVideo.videoId,
            let snapshot = uploadedVideo.snapshot,
            let snapshotId = snapshot.objectId  {
            let video = LGVideo(path: path, snapshot: snapshotId)
            videos = [video]
            images.append(snapshot)
        } else {
            videos = []
        }

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
                                                  images: images,
                                                  videos: videos,
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
                                                                images: images,
                                                                videos: videos,
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
                                                          images: images,
                                                          videos: videos)
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
                                                      images: images,
                                                      videos: videos)
            listingCreationParams = ListingCreationParams.product(productParams)
        }
        return listingCreationParams
    }
}
