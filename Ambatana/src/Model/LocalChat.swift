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
    var product: Product
    var userFrom: UserProduct
    var userTo: UserProduct
    var msgUnreadCount = 0
    var messages: [Message] = []
    var updatedAt: Date? = nil
    var forbidden = false
    var archivedStatus = ChatArchivedStatus.active

    var requiresLogin: Bool {
        return userFrom.objectId == nil
    }

    init(product: Product, myUserProduct: UserProduct?) {
        self.product = product
        self.userTo = product.user
        self.userFrom = myUserProduct ?? EmptyUserProduct()
    }
}


private struct EmptyUserProduct: UserProduct {
    let objectId: String? = nil
    let name: String? = nil
    let avatar: File? = nil
    let postalAddress: PostalAddress = PostalAddress.emptyAddress()
    let status: UserStatus = .inactive
    var isDummy: Bool = false
    let banned: Bool? = nil
}
