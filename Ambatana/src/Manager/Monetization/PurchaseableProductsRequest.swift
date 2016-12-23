//
//  PurchaseableProductsRequest.swift
//  LetGo
//
//  Created by Dídac on 21/12/16.
//  Copyright © 2016 Ambatana. All rights reserved.
//

protocol PurchaseableProductsRequest {
    func start()
    func cancel()
    weak var delegate: PurchaseableProductsRequestDelegate? { get set }
}
