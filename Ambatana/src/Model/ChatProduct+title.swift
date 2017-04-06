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
        return ProductHelper.titleWith(name: name, nameAuto: nil)
    }
}
