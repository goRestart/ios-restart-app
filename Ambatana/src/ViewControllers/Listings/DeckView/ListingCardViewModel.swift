//
//  ListingCardViewModel.swift
//  LetGo
//
//  Created by Facundo Menzella on 09/11/2017.
//  Copyright © 2017 Ambatana. All rights reserved.
//

import Foundation
import LGCoreKit

struct ListingCardViewModel {
    let listing: Listing
    var userName: String? { return listing.user.name }
    let isMine: Bool
    var images: [URL] { get { return listing.images.compactMap { $0.fileURL } } }
    var avatar: URL? { get { return listing.user.avatar?.fileURL } }

    init(listing: Listing, isMine: Bool) {
        self.listing = listing
        self.isMine = isMine
    }

    init?(cellModel: ListingCellModel, isMine: Bool) {
        switch cellModel {
        case .listingCell(let listing):
            self.init(listing: listing, isMine: isMine)
        default:
            return nil
        }
    }
}
