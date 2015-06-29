//
//  CommonDataTypes.swift
//  LetGo
//
//  Created by Ignacio Nieto Carvajal on 12/2/15.
//  Copyright (c) 2015 Ignacio Nieto Carvajal. All rights reserved.
//

import Foundation

// constants
let kLetGoDefaultCategoriesLanguage = "en"
let kLetGoFullScreenWidth = UIScreen.mainScreen().bounds.size.width
let kLetGoProductCellSpan: CGFloat = 10.0
let kLetGoProductListOffsetLoadingOffsetInc = 20 // Load 20 products each time.
let kLetGoProductListMaxKmDistance = 10000
let kLetGoDefaultUserImageName = "no_photo"
let kLetGoContentScrollingDownThreshold: CGFloat = 20.0
let kLetGoContentScrollingUpThreshold: CGFloat = -20.0
let kLetGoMaxProductImageSide: CGFloat = 1024
let kLetGoMaxProductImageJPEGQuality: CGFloat = 0.9
let kLetGoProductImageKeys = ["image_0", "image_1", "image_2", "image_3", "image_4"]
let kLetGoProductFirstImageKey = kLetGoProductImageKeys.first!
let kLetGoWebsiteURL = "http://letgo.com"

/** Product status */
//- Status: 0 si el producto está pendiente de aprobación, 1 si está aprobado, 2 si está descartado, 3 si está vendido.
@objc enum LetGoProductStatus: Int, Printable {
    case Pending = 0, Approved = 1, Discarded = 2, Sold = 3
    var description: String { return "\(self.rawValue)" }
}

