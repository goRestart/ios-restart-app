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
        if let name = name?.trim, !name.isEmpty {
            return name.capitalizedFirstLetterOnly
        }
        return nil
    }
}
