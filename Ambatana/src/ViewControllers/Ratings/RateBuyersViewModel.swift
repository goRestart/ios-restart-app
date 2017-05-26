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
    let sourceRateBuyers: SourceRateBuyers?
    let visibilityFormat = Variable<VisibilityFormat>(.compact(with: RateBuyersViewModel.itemsOnCompactFormat))

    init(buyers: [UserListing], listingId: String, sourceRateBuyers: SourceRateBuyers?, listingRepository: ListingRepository) {
        self.possibleBuyers = buyers
        self.listingId = listingId
        self.sourceRateBuyers = sourceRateBuyers
        self.listingRepository = listingRepository
    }
    
    convenience init(buyers: [UserListing], listingId: String, source: SourceRateBuyers?) {
        self.init(buyers: buyers, listingId: listingId, sourceRateBuyers: source, listingRepository: Core.listingRepository)
    }
    
    var shouldShowSeeMoreOption: Bool {
        return RateBuyersViewModel.itemsOnCompactFormat < possibleBuyers.count
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
        guard buyersToShow > index else { return nil }
        guard let buyer = buyerAt(index: index) else { return nil }
        return buyer.avatar?.fileURL
    }

    func titleAt(index: Int) -> String? {
        guard buyersToShow > index else { return textForSeeMoreLabel() }
        guard let buyer = buyerAt(index: index) else { return nil }
        return buyer.name
    }
    
    func bottomBorderAt(index: Int) -> Bool {
        guard index == buyersToShow else { return buyersToShow - 1 > index }
        return true
        
    }
    
    func topBorderAt(index: Int) -> Bool {
        guard buyersToShow > index else { return true }
        return index == 0
    }
    
    func secondaryActionsbottomBorderAt(index: Int) -> Bool {
        return true
    }
    
    func secondaryActionstopBorderAt(index: Int) -> Bool {
        guard index == 0 else { return false }
        return true
        
    }
    
    func disclosureDirectionAt(index: Int) -> DisclosureDirection {
        guard buyersToShow > index else { return visibilityFormat.value.disclouseDirection }
        return .right
    }
    
    func cellTypeAt(index: Int) -> RateBuyerCellType {
        return index < buyersToShow ? .userCell : .otherCell
    }
    
    
    func secondaryOptionsTitleAt(index: Int) -> String? {
        switch index {
        case 0:
            return LGLocalizedString.rateBuyersNotOnLetgoTitleButton
        case 1:
            return LGLocalizedString.rateBuyersWillDoLaterTitle
        default:
            return nil
        }
    }
    
    
    func secondaryOptionsSubtitleAt(index: Int) -> String? {
        switch index {
        case 0:
            return LGLocalizedString.rateBuyersNotOnLetgoButton
        case 1:
            return LGLocalizedString.rateBuyersWillDoLaterSubtitle
        default:
            return nil
       }
    }
    
    private func textForSeeMoreLabel() -> String {
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
