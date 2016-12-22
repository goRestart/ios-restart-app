//
//  PurchaseableProductsResponse.swift
//  LetGo
//
//  Created by Dídac on 21/12/16.
//  Copyright © 2016 Ambatana. All rights reserved.
//

protocol PurchaseableProductsResponse {
    var purchaseableProducts: [PurchaseableProduct] { get }
    var invalidProductIdentifiers: [String] { get }
}
