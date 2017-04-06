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
    func closePostProductAndPostInBackground(params: ProductCreationParams, showConfirmation: Bool,
                                             trackingInfo: PostProductTrackingInfo)
    func closePostProductAndPostLater(params: ProductCreationParams, images: [UIImage],
                                      trackingInfo: PostProductTrackingInfo)
    func openLoginIfNeededFromProductPosted(from: EventParameterLoginSourceValue, loggedInAction: @escaping (() -> Void))
}

protocol ProductPostedNavigator: class {
    func cancelProductPosted()
    func closeProductPosted(_ product: Product)
    func closeProductPostedAndOpenEdit(_ product: Product)
    func closeProductPostedAndOpenPost()
}
