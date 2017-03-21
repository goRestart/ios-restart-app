//
//  LocalProduct.swift
//  LetGo
//
//  Created by Eli Kohen on 02/11/2016.
//  Copyright © 2016 Ambatana. All rights reserved.
//

import LGCoreKit

struct LocalProduct: Product {
    let objectId: String?
    let name: String?
    let nameAuto: String?
    let descr: String?
    let price: ProductPrice
    let currency: Currency

    let location: LGLocationCoordinates2D
    let postalAddress: PostalAddress

    let languageCode: String?

    let category: ListingCategory
    let status: ListingStatus

    let thumbnail: File?
    let thumbnailSize: LGSize?
    let images: [File]

    let user: UserListing

    let updatedAt : Date?
    let createdAt : Date?

    let featured: Bool?
    let favorite: Bool


    init?(chatConversation: ChatConversation, myUser: MyUser?) {
        guard let chatListing = chatConversation.product else { return nil }
        if chatConversation.amISelling {
            guard let myUser = myUser, let localUser = LocalUser(user: myUser) else { return nil }
            self.user = localUser
        } else {
            guard let interlocutor = chatConversation.interlocutor else { return nil }
            self.user = LocalUser(chatInterlocutor: interlocutor)
        }
        self.objectId = chatListing.objectId
        self.name = chatListing.name
        self.nameAuto = nil
        self.descr = nil
        self.price = chatListing.price
        self.currency = chatListing.currency
        self.location = LGLocationCoordinates2D(latitude: 0, longitude: 0)
        self.postalAddress = PostalAddress.emptyAddress()
        self.languageCode = nil
        self.category = .other
        self.status = chatListing.status
        self.thumbnail = chatListing.image
        self.thumbnailSize = nil
        self.images = [chatListing.image].flatMap{ $0 }
        self.updatedAt = nil
        self.createdAt = nil
        self.featured = false
        self.favorite = false
    }
}
