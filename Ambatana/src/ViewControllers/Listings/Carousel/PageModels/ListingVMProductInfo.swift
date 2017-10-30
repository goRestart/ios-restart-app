//
//  ListingVMProductInfo.swift
//  LetGo
//
//  Created by Eli Kohen on 28/02/2017.
//  Copyright © 2017 Ambatana. All rights reserved.
//

import Foundation
import LGCoreKit

struct ListingVMProductInfo {
    let title: String?
    let titleAuto: String?
    let linkedTitle: NSAttributedString?
    let titleAutoGenerated: Bool
    let titleAutoTranslated: Bool
    let price: String
    let description: NSAttributedString?
    let address: String?
    let location: LGLocationCoordinates2D?
    let distance: String?
    let creationDate: Date?
    let category: ListingCategory?

    init(listing: Listing, isAutoTranslated: Bool, distance: String?, freeModeAllowed: Bool) {
        self.title = listing.title
        self.titleAuto = listing.nameAuto
        self.linkedTitle = listing.title?.attributedHiddenTagsLinks
        self.titleAutoGenerated = listing.isTitleAutoGenerated
        self.titleAutoTranslated = isAutoTranslated
        self.price = listing.priceString(freeModeAllowed: freeModeAllowed)
        self.description = listing.description?.trim.attributedHiddenTagsLinks
        self.address = listing.postalAddress.zipCodeCityString
        self.location = listing.location
        self.distance = distance
        self.creationDate = listing.createdAt
        self.category = listing.category
    }
}
