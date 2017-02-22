//
//  PurchasesShopper.swift
//  LetGo
//
//  Created by Eli Kohen on 07/02/2017.
//  Copyright © 2017 Ambatana. All rights reserved.
//

protocol PurchasesShopper: class {
    var delegate: PurchasesShopperDelegate? { get set }

    /**
     Sets itself as the payment transactions observer
     */
    func startObservingTransactions()

    /**
     Removes itself as the payment transactions observer
     */
    func stopObservingTransactions()
    
    /**
     Checks purchases available on appstore

     - parameter productId: ID of the listing for wich will request the appstore products
     - parameter ids: array of ids of the appstore products
     */
    func productsRequestStartForProduct(_ productId: String, withIds ids: [String])

    /**
     Request a payment to the appstore

     - parameter product: info of the product to purchase on the appstore
     */
    func requestPaymentForProduct(_ productId: String, appstoreProduct: PurchaseableProduct, paymentItemId: String)

    func requestFreeBumpUpForProduct(productId: String, withPaymentItemId paymentItemId: String, shareNetwork: EventParameterShareNetwork)
}
