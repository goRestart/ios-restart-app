//
//  SellNavigator.swift
//  LetGo
//
//  Created by Albert Hernández López on 20/06/16.
//  Copyright © 2016 Ambatana. All rights reserved.
//

import LGCoreKit
import Foundation

protocol PostProductNavigator: class {
    func cancelPostProduct()
    func closePostProductAndPostInBackground(product: Product, images: [File], showConfirmation: Bool,
                                             trackingInfo: PostProductTrackingInfo)
    func closePostProductAndPostLater(product: Product, image: UIImage, trackingInfo: PostProductTrackingInfo)
}

protocol ProductPostedNavigator: class {
    func cancelProductPosted()
    func closeProductPosted(product: Product)
    func closeProductPostedAndOpenEdit(product: Product)
    func closeProductPostedAndOpenPost(postingSource: PostingSource)
}
