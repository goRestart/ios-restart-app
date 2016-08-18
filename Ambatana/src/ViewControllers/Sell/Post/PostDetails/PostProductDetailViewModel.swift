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

    // Out variables
    let descrCharactersLeft = Variable<Int>(Constants.productDescriptionMaxLength)
    var productPrice: Double {
        return price.value.toPriceDouble()
    }
    var productTitle: String? {
        return title.value.isEmpty ? nil : title.value
    }
    var productDescription: String? {
        return description.value.isEmpty ? nil : description.value
    }

    let currencySymbol: String?

    private let disposeBag = DisposeBag()

    convenience override init() {
        var currencySymbol: String? = nil
        if let countryCode = Core.locationManager.currentPostalAddress?.countryCode {
            currencySymbol = Core.currencyHelper.currencyWithCountryCode(countryCode).symbol
        }
        self.init(currencySymbol: currencySymbol)
    }

    init(currencySymbol: String?) {
        self.currencySymbol = currencySymbol
        super.init()
        setupRx()
    }

    func doneButtonPressed() {
        delegate?.postProductDetailDone(self)
    }


    // MARK: - Private

    private func setupRx() {
        description.asObservable().map { Constants.productDescriptionMaxLength - $0.characters.count }
            .filter{ $0 >= 0 }.bindTo(descrCharactersLeft).addDisposableTo(disposeBag)
    }
}
