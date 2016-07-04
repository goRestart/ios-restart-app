//
//  ChatProduct+title.swift
//  LetGo
//
//  Created by Dídac on 29/06/16.
//  Copyright © 2016 Ambatana. All rights reserved.
//


import LGCoreKit

extension ChatProduct {

    var title: String? {
        if let name = name?.trim where !name.isEmpty {
            return name.capitalizedFirstLetterOnly
        }
        return nil
    }
}
