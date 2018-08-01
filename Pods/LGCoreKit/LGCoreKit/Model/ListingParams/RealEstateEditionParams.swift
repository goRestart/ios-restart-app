//
//  RealEstateEditionParams.swift
//  LGCoreKit
//
//  Created by Juan Iglesias on 19/09/2017.
//  Copyright © 2017 Ambatana Inc. All rights reserved.
//

public class RealEstateEditionParams: RealEstateCreationParams {
    let realEstateId: String
    let userId: String
    
    public convenience init?(listing: Listing) {
        let editedRealEstate: RealEstate = RealEstateEditionParams.createRealEstateParams(withListing: listing)
        self.init(realEstate: editedRealEstate)
    }
    
    public init?(realEstate: RealEstate) {
        guard let realEstateId = realEstate.objectId, let userId = realEstate.user.objectId else { return nil }
        self.realEstateId = realEstateId
        self.userId = userId
        let videos: [Video] = realEstate.media.compactMap(LGVideo.init)
        super.init(name: realEstate.name,
                   description: realEstate.descr,
                   price: realEstate.price,
                   category: realEstate.category,
                   currency: realEstate.currency,
                   location: realEstate.location,
                   postalAddress: realEstate.postalAddress,
                   images: realEstate.images,
                   videos: videos,
                   realEstateAttributes: realEstate.realEstateAttributes)
        if let languageCode = realEstate.languageCode {
            self.languageCode = languageCode
        }
    }
    
    func apiEditionEncode() -> [String: Any] {
        return super.apiCreationEncode(userId: userId)
    }
    
    static private func createRealEstateParams(withListing listing: Listing) -> RealEstate {
        let realEstate = LGRealEstate(objectId: listing.objectId,
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
                                      realEstateAttributes: listing.realEstate?.realEstateAttributes)
        return realEstate
    }
}
