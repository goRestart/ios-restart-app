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
    let isFree = Variable<Bool>(false)
    let title = Variable<String>("")
    let description = Variable<String>("")

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
    let postingSource: PostingSource
    
    var freeOptionAvailable: Bool {
        switch FeatureFlags.freePostingMode {
        case .Disabled:
            return false
        case .SplitButton, .OneButton:
            return true
        }
    }

    private let disposeBag = DisposeBag()

    convenience  init(source: PostingSource) {
        var currencySymbol: String? = nil
        if let countryCode = Core.locationManager.currentPostalAddress?.countryCode {
            currencySymbol = Core.currencyHelper.currencyWithCountryCode(countryCode).symbol
        }
        self.init(currencySymbol: currencySymbol, source: source)
    }

    init(currencySymbol: String?, source: PostingSource) {
        self.currencySymbol = currencySymbol
        self.postingSource = source
        super.init()
    }

    func doneButtonPressed() {
        delegate?.postProductDetailDone(self)
    }
}
