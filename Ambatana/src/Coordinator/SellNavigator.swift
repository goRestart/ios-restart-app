//
//  SellNavigator.swift
//  LetGo
//
//  Created by Albert Hernández López on 20/06/16.
//  Copyright © 2016 Ambatana. All rights reserved.
//

import LGCoreKit
import Foundation




protocol SellNavigator: class {
//    weak var delegate: SellNavigatorDelegate? { get }


//    func cancel()
//    func post()
}

///**
// Shared.
//*/
//protocol PostBaseNavigator: class {
//
//}

protocol PostProductNavigatorDelegate: class {
//    func post()
}

protocol PostProductNavigator: class {
//    weak var postProductNavigatorDelegate: PostProductNavigatorDelegate? { get }

    // Cancels post product flow.
    func cancel()

    // Closes post product screen, posts the product and opens product posted if `showConfirmation` is `true`
    func closeAndPost(product: Product, images: [File], showConfirmation: Bool, trackingInfo: PostProductTrackingInfo)

    // Closes post product screen and opens product posted to post the product
    func closeAndPost(priceText priceText: String?, image: UIImage, trackingInfo: PostProductTrackingInfo)
}


protocol PostProductConfirmationNavigatorDelegate: class {

}

protocol PostProductConfirmationNavigator {
    weak var postProductConfirmationNavigatorDelegate: PostProductConfirmationNavigatorDelegate? { get }

    func close()
    func openSell()
    func openEdit()
}
