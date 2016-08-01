//
//  TabNavigator.swift
//  LetGo
//
//  Created by Albert Hernández López on 01/08/16.
//  Copyright © 2016 Ambatana. All rights reserved.
//

import LGCoreKit

protocol TabNavigator: class {
    func openUser(user user: User)
    func openUser(userId userId: String)
    func openProduct(product product: Product)
    func openProduct(productId productId: String)
}
