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
    var userFrom: User
    var userTo: User
    var msgUnreadCount = 0
    var messages: [Message] = []
    var updatedAt: Date? = nil
    var forbidden = false
    var archivedStatus = ChatArchivedStatus.Active

    var requiresLogin: Bool {
        return userFrom.objectId == nil
    }

    init(product: Product, myUser: User?) {
        self.product = product
        self.userTo = product.user
        self.userFrom = myUser ?? EmptyUser()
    }
}


private struct EmptyUser: User {
    let objectId: String? = nil
    let name: String? = nil
    let avatar: File? = nil
    let postalAddress: PostalAddress = PostalAddress.emptyAddress()
    let accounts: [Account]? = nil
    var ratingAverage: Float? = nil
    var ratingCount: Int? = nil
    let status: UserStatus = .Inactive

    var isDummy: Bool = false
}
