//
//  PostProductDetailViewModel.swift
//  LetGo
//
//  Created by Eli Kohen on 17/08/16.
//  Copyright © 2016 Ambatana. All rights reserved.
//

import RxSwift
import LGCoreKit

protocol PostProductDetailViewModelDelegate: class {
    func postProductDetailDone(viewModel: PostProductDetailViewModel)
}

class PostProductDetailViewModel: BaseViewModel {
    weak var delegate: PostProductDetailViewModelDelegate?

    // In variables
    let price = Variable<String>("")
    let title = Variable<String>("")
    let description = Variable<String>("")

    // In&Out variables
    let isFree = Variable<Bool>(false)
    
    // Out variables
    var productPrice: ProductPrice {
        return isFree.value ? .Free : .Normal(price.value.toPriceDouble())
    }
    var productTitle: String? {
        return title.value.isEmpty ? nil : title.value
    }
    var productDescription: String? {
        return description.value.isEmpty ? nil : description.value
    }

    let currencySymbol: String?
    
    var freeOptionAvailable: Bool {
        return FeatureFlags.freePostingMode.enabled
    }

    private let disposeBag = DisposeBag()

    override convenience  init() {
        var currencySymbol: String? = nil
        if let countryCode = Core.locationManager.currentPostalAddress?.countryCode {
            currencySymbol = Core.currencyHelper.currencyWithCountryCode(countryCode).symbol
        }
        self.init(currencySymbol: currencySymbol)
    }

    init(currencySymbol: String?) {
        self.currencySymbol = currencySymbol
        super.init()
    }

    func doneButtonPressed() {
        delegate?.postProductDetailDone(self)
    }
}
