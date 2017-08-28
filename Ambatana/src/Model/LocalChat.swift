//
//  LocalChat.swift
//  LetGo
//
//  Created by Eli Kohen on 20/06/16.
//  Copyright © 2016 Ambatana. All rights reserved.
//

import LGCoreKit

struct LocalChat: Chat {
    var objectId: String?
    var listing: Listing
    var userFrom: UserListing
    var userTo: UserListing
    var msgUnreadCount = 0
    var messages: [Message] = []
    var updatedAt: Date? = nil
    var forbidden = false
    var archivedStatus = ChatArchivedStatus.active

    var requiresLogin: Bool {
        return userFrom.objectId == nil
    }

    init(listing: Listing, myUserListing: UserListing?) {
        self.listing = listing
        self.userTo = listing.user
        self.userFrom = myUserListing ?? EmptyUserListing()
    }
}


private struct EmptyUserListing: UserListing {
    let objectId: String? = nil
    let name: String? = nil
    let avatar: File? = nil
    let postalAddress: PostalAddress = PostalAddress.emptyAddress()
    let status: UserStatus = .inactive
    var isDummy: Bool = false
    let banned: Bool? = nil
}
