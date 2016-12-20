//
//  BumpUpPayViewModel.swift
//  LetGo
//
//  Created by Dídac on 19/12/16.
//  Copyright © 2016 Ambatana. All rights reserved.
//

import Foundation
import LGCoreKit


protocol BumpUpPayViewModelDelegate: BaseViewModelDelegate {
    func viewControllerShouldClose()
}

protocol BumpUpDelegate: class {
    func vmBumpUpProduct()
}

class BumpUpPayViewModel: BaseViewModel {

    var product: Product
    var price: String
    var bumpsLeft: Int

    weak var delegate: BumpUpPayViewModelDelegate?
    weak var bumpDelegate: BumpUpDelegate?

    // MARK: - Lifecycle

    init(product: Product, price: String, bumpsLeft: Int, bumpDelegate: BumpUpDelegate?) {
        self.price = price
        self.product = product
        self.bumpsLeft = bumpsLeft
        self.bumpDelegate = bumpDelegate
    }

    func bumpUpPressed() {
        bumpDelegate?.vmBumpUpProduct()
        delegate?.viewControllerShouldClose()
    }

    func closeActionPressed() {
        delegate?.viewControllerShouldClose()
    }
}
