//
//  CommercializerListing.swift
//  LGCoreKit
//
//  Created by Isaac Roldan on 5/4/16.
//  Copyright © 2016 Ambatana Inc. All rights reserved.
//

public protocol CommercializerListing: BaseModel {
    var thumbnailURL: String? { get }
    var countryCode: String? { get }
}
