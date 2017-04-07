//
//  LGCarsMake.swift
//  LGCoreKit
//
//  Created by Dídac on 04/04/17.
//  Copyright © 2017 Ambatana Inc. All rights reserved.
//

class LGCarsMake: CarsMake {
    var makeId: String
    var makeName: String

    init(makeId: String, makeName: String) {
        self.makeId = makeId
        self.makeName = makeName
    }
}
