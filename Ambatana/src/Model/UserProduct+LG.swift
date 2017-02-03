//
//  UserProduct+LG.swift
//  LetGo
//
//  Created by Juan Iglesias on 30/01/17.
//  Copyright © 2017 Ambatana. All rights reserved.
//

import LGCoreKit


extension UserProduct {
    var shortName: String? {
        return name?.trunc(18)
    }
}
