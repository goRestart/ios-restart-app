//
//  RateBuyersViewModel.swift
//  LetGo
//
//  Created by Eli Kohen on 03/02/2017.
//  Copyright © 2017 Ambatana. All rights reserved.
//

import LGCoreKit
import RxSwift

enum VisibilityFormat {
    case compact(with: Int)
    case full
}

class RateBuyersViewModel: BaseViewModel {
    
    static let itemsOnCompactFormat = 3

    weak var navigator: RateBuyersNavigator?

    let possibleBuyers: [UserListing]
    let listingId: String
    let listingRepository: ListingRepository
    let visibilityFormat = Variable<VisibilityFormat>(.compact(with: RateBuyersViewModel.itemsOnCompactFormat))

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
    
    func showMoreLessPressed() {
        switch visibilityFormat.value {
        case .compact:
            visibilityFormat.value = .full
        case .full:
            visibilityFormat.value = .compact(with: RateBuyersViewModel.itemsOnCompactFormat)
        }
    }

    
    // MARK: - Transactions methods
    
    func createTransaction(listingId: String, buyerId: String?, soldIn: SoldIn?) {
        let createTransactionParams = CreateTransactionParams(listingId: listingId, buyerId: buyerId, soldIn: soldIn)
        listingRepository.createTransactionOf(createTransactionParams: createTransactionParams) { _ in }
    }

    // MARK: - Info 

    var buyersToShow: Int {
        switch visibilityFormat.value {
        case let .compact(value):
            return value
        case .full:
            return possibleBuyers.count
        }
    }

    func imageAt(index: Int) -> URL? {
        guard let buyer = buyerAt(index: index) else { return nil }
        return buyer.avatar?.fileURL
    }

    func nameAt(index: Int) -> String? {
        guard let buyer = buyerAt(index: index) else { return nil }
        return buyer.name
    }
    
    func textForSeeMoreLabel() -> String {
        switch visibilityFormat.value {
        case .compact:
            return LGLocalizedString.rateBuyersSeeXMore
        case .full:
            return LGLocalizedString.rateBuyersSeeLess
        }
        
    }

    private func buyerAt(index: Int) -> UserListing? {
        guard 0..<possibleBuyers.count ~= index else { return nil }
        return possibleBuyers[index]
    }

    

}
