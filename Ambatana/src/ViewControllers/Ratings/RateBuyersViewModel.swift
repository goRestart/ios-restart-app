//
//  RateBuyersViewModel.swift
//  LetGo
//
//  Created by Eli Kohen on 03/02/2017.
//  Copyright © 2017 Ambatana. All rights reserved.
//

import LGCoreKit
import RxSwift

class RateBuyersViewModel: BaseViewModel {

    weak var navigator: RateBuyersNavigator?

    let possibleBuyers: [UserListing]
    let listingId: String
    let listingRepository: ListingRepository

    init(buyers: [UserListing], listingId: String, listingRepository: ListingRepository) {
        self.possibleBuyers = buyers
        self.listingId = listingId
        self.listingRepository = listingRepository
    }
    
    convenience init(buyers: [UserListing], listingId: String) {
        self.init(buyers: buyers, listingId: listingId, listingRepository: Core.listingRepository)
    }
    


    // MARK: - Actions

    func closeButtonPressed() {
        createTransaction(listingId: listingId, buyerId: nil, soldIn: nil)
        navigator?.rateBuyersCancel()
    }

    func selectedBuyerAt(index: Int) {
        guard let buyer = buyerAt(index: index) else { return }
        createTransaction(listingId: listingId, buyerId: buyer.objectId, soldIn: .letgo)
        navigator?.rateBuyersFinish(withUser: buyer)
    }

    func notOnLetgoButtonPressed() {
        createTransaction(listingId: listingId, buyerId: nil, soldIn: .external)
        navigator?.rateBuyersFinishNotOnLetgo()
    }

    
    // MARK: - Transactions methods
    
    func createTransaction(listingId: String, buyerId: String?, soldIn: SoldIn?) {
        let createTransactionParams = CreateTransactionParams(listingId: listingId, buyerId: buyerId, soldIn: soldIn)
        listingRepository.createTransactionOf(createTransactionParams: createTransactionParams) { [weak self] (transaction) in
            //TODO: handle error if needed
        }
    }

    // MARK: - Info 

    var buyersCount: Int {
        return possibleBuyers.count
    }

    func imageAt(index: Int) -> URL? {
        guard let buyer = buyerAt(index: index) else { return nil }
        return buyer.avatar?.fileURL
    }

    func nameAt(index: Int) -> String? {
        guard let buyer = buyerAt(index: index) else { return nil }
        return buyer.name
    }

    private func buyerAt(index: Int) -> UserListing? {
        guard 0..<possibleBuyers.count ~= index else { return nil }
        return possibleBuyers[index]
    }
}
