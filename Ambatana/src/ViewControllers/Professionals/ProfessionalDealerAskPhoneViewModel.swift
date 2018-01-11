//
//  ProfessionalDealerAskPhoneViewModel.swift
//  LetGo
//
//  Created by Dídac on 09/01/2018.
//  Copyright © 2018 Ambatana. All rights reserved.
//

import Foundation
import LGCoreKit
import RxSwift

class ProfessionalDealerAskPhoneViewModel: BaseViewModel {

    let phoneNum = Variable<String>("")
    let sendPhoneButtonEnabled = Variable<Bool>(false)
    private let disposeBag = DisposeBag()

    weak var navigator: ListingDetailNavigator?
    private let listing: Listing

    init(listing: Listing) {
        self.listing = listing
        super.init()
        setupRx()
    }

    func setupRx() {
        phoneNum.asObservable().bind { [weak self] phone in
            self?.sendPhoneButtonEnabled.value = phone.isPhoneNumber
        }.disposed(by: disposeBag)
    }

    func updatePhoneNumberFrom(text: String) {
        phoneNum.value = text
    }
    
    func sendPhonePressed() {
        navigator?.closeAskPhoneFor(listing: listing,
                                    openChat: true,
                                    withPhoneNum: phoneNum.value,
                                    source: .listingDetail)
    }

    func closePressed() {
        navigator?.closeAskPhoneFor(listing: listing,
                                    openChat: false,
                                    withPhoneNum: nil,
                                    source: .listingDetail)
    }

    func notNowPressed() {
        navigator?.closeAskPhoneFor(listing: listing,
                                    openChat: true,
                                    withPhoneNum: nil,
                                    source: .listingDetail)
    }
}
