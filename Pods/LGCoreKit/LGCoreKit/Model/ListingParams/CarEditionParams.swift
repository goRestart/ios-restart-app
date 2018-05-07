//
//  CarEditionParams.swift
//  LGCoreKit
//
//  Created by Juan Iglesias on 19/09/2017.
//  Copyright © 2017 Ambatana Inc. All rights reserved.
//

public class CarEditionParams: CarCreationParams {
    let carId: String
    let userId: String
    
    public convenience init?(listing: Listing) {
        let editedCar: Car = CarEditionParams.createCarParams(withListing: listing)
        self.init(car: editedCar)
    }
    
    public init?(car: Car) {
        guard let carId = car.objectId, let userId = car.user.objectId else { return nil }
        self.carId = carId
        self.userId = userId
        let videos: [Video] = car.media.flatMap(LGVideo.init)
        super.init(name: car.name,
                   description: car.descr,
                   price: car.price,
                   category: car.category,
                   currency: car.currency,
                   location: car.location,
                   postalAddress: car.postalAddress,
                   images: car.images,
                   videos: videos,
                   carAttributes: car.carAttributes)
        if let languageCode = car.languageCode {
            self.languageCode = languageCode
        }
    }
    
    func apiEditionEncode() -> [String: Any] {
        return super.apiCreationEncode(userId: userId)
    }
    
    func apiCarEditionEncode() -> [String: Any] {
        return super.apiCarCreationEncode(userId: userId)
    }
    
    static private func createCarParams(withListing listing: Listing) -> Car {
        let car = LGCar(objectId: listing.objectId,
                        updatedAt: listing.updatedAt,
                        createdAt: listing.createdAt,
                        name: listing.name,
                        nameAuto: listing.nameAuto,
                        descr: listing.descr,
                        price: listing.price,
                        currency: listing.currency,
                        location: listing.location,
                        postalAddress: listing.postalAddress,
                        languageCode: listing.languageCode,
                        category: .cars,
                        status: listing.status,
                        thumbnail: listing.thumbnail,
                        thumbnailSize: listing.thumbnailSize,
                        images: listing.images,
                        media: listing.media,
                        mediaThumbnail: listing.mediaThumbnail,
                        user: listing.user,
                        featured: listing.featured,
                        carAttributes: listing.car?.carAttributes)
        return car
    }
}
