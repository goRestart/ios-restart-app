//
//  ListingFavourite.swift
//  LGCoreKit
//
//  Created by Albert Hernández López on 18/08/15.
//  Copyright (c) 2015 Ambatana Inc. All rights reserved.
//

public protocol ListingFavourite: BaseModel {
    var product: Product { get }
    var user: UserListing { get }
}
