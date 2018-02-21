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

    private let phoneNumber = Variable<String>("")
    let sendPhoneButtonEnabled = Variable<Bool>(false)
    private let disposeBag = DisposeBag()

    weak var navigator: ListingDetailNavigator?
    private let listing: Listing
    private let tracker: Tracker

    convenience init(listing: Listing) {
        self.init(listing: listing, tracker: TrackerProxy.sharedInstance)
    }

    init(listing: Listing, tracker: Tracker) {
        self.listing = listing
        self.tracker = tracker
        super.init()
        setupRx()
    }

    override func didBecomeActive(_ firstTime: Bool) {
        super.didBecomeActive(firstTime)
        tracker.trackEvent(TrackerEvent.phoneNumberRequest(typePage: .listingDetail))
    }

    func setupRx() {
        phoneNumber.asObservable()
            .map { $0.isPhoneNumber }
            .bind(to: sendPhoneButtonEnabled)
            .disposed(by: disposeBag)
    }

    func updatePhoneNumberFrom(text: String) {
        let noDashesText = text.replacingOccurrences(of: "-", with: "")
        phoneNumber.value = noDashesText
    }
    
    func sendPhonePressed() {
        navigator?.closeAskPhoneFor(listing: listing,
                                    openChat: true,
                                    withPhoneNum: phoneNumber.value,
                                    source: .listingDetail)
        tracker.trackEvent(TrackerEvent.phoneNumberSent(typePage: .listingDetail))
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
        tracker.trackEvent(TrackerEvent.phoneNumberNotNow(typePage: .listingDetail))
    }
}
