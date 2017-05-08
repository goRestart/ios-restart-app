//
//  ChatListing+title.swift
//  LetGo
//
//  Created by Dídac on 29/06/16.
//  Copyright © 2016 Ambatana. All rights reserved.
//


import LGCoreKit

extension ChatListing {

    var title: String? {
        return ListingHelper.titleWith(name: name, nameAuto: nil)
    }
}
