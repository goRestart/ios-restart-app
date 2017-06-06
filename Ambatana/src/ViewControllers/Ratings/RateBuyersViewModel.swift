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
    case compact(visibleElements: Int)
    case full
}

protocol RateBuyersViewModelDelegate: BaseViewModelDelegate {}

class RateBuyersViewModel: BaseViewModel {
    static let itemsOnCompactFormat = 3

    weak var navigator: RateBuyersNavigator?
    weak var delegate: RateBuyersViewModelDelegate?

    let possibleBuyers: [UserListing]
    let listingId: String
    let listingRepository: ListingRepository
    let source: SourceRateBuyers?
    let tracker: Tracker
    fileprivate let trackingInfo: MarkAsSoldTrackingInfo
    let visibilityFormat = Variable<VisibilityFormat>(.compact(visibleElements: RateBuyersViewModel.itemsOnCompactFormat))
    
    
    // MARK: - Lifecycle
    
    init(buyers: [UserListing],
         listingId: String,
         trackingInfo: MarkAsSoldTrackingInfo,
         listingRepository: ListingRepository,
         source: SourceRateBuyers?,
         tracker: Tracker) {
        self.possibleBuyers = buyers
        self.listingId = listingId
        self.trackingInfo = trackingInfo
        self.listingRepository = listingRepository
        self.source = source
        self.tracker = tracker
    }
    
    convenience init(buyers: [UserListing],
                     listingId: String,
                     source: SourceRateBuyers?,
                     trackingInfo: MarkAsSoldTrackingInfo) {
        self.init(buyers: buyers,
                  listingId: listingId,
                  trackingInfo: trackingInfo,
                  listingRepository: Core.listingRepository,
                  source: source,
                  tracker: TrackerProxy.sharedInstance)
    }
    
    var shouldShowSeeMoreOption: Bool {
        return RateBuyersViewModel.itemsOnCompactFormat < possibleBuyers.count
    }

    
    // MARK: - Actions

    func closeButtonPressed() {
        navigator?.rateBuyersCancel()
    }

    func selectedBuyerAt(index: Int) {
        guard let buyer = buyerAt(index: index) else { return }
        let buyerId = buyer.objectId
        
        delegate?.vmShowLoading(nil)
        createTransaction(listingId: listingId, buyerId: buyerId, soldIn: .letgo) { [weak self] result in
            let message: String?
            let afterMessageCompletion: (() -> ())?
            
            if let _ = result.value {
                self?.trackMarkAsSoldAtLetgo(buyerId: buyerId)
                
                message = nil
                afterMessageCompletion = {
                    self?.navigator?.rateBuyersFinish(withUser: buyer)
                }
            } else {
                message = LGLocalizedString.commonError
                afterMessageCompletion = nil
            }
            self?.delegate?.vmHideLoading(message, afterMessageCompletion: afterMessageCompletion)
        }
    }

    func notOnLetgoButtonPressed() {
        delegate?.vmShowLoading(nil)
        createTransaction(listingId: listingId, buyerId: nil, soldIn: .external) { [weak self] result in
            let message: String?
            let afterMessageCompletion: (() -> ())?
            
            if let _ = result.value {
                self?.trackMarkAsSoldOutsideLetgo()
                
                message = nil
                afterMessageCompletion = {
                    self?.navigator?.rateBuyersFinishNotOnLetgo()
                }
            } else {
                message = LGLocalizedString.commonError
                afterMessageCompletion = nil
            }
            self?.delegate?.vmHideLoading(message, afterMessageCompletion: afterMessageCompletion)
        }
    }
    
    func showMoreLessPressed() {
        switch visibilityFormat.value {
        case .compact:
            visibilityFormat.value = .full
        case .full:
            visibilityFormat.value = .compact(visibleElements: RateBuyersViewModel.itemsOnCompactFormat)
        }
    }

    
    // MARK: - Transactions methods
    
    func createTransaction(listingId: String, buyerId: String?, soldIn: SoldIn?, completion: ListingTransactionCompletion?) {
        let createTransactionParams = CreateTransactionParams(listingId: listingId, buyerId: buyerId, soldIn: soldIn)
        listingRepository.createTransactionOf(createTransactionParams: createTransactionParams, completion: completion)
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
        guard 0..<buyersToShow ~= index else { return nil }
        let buyer = buyerAt(index: index)
        return buyer?.avatar?.fileURL
    }

    func titleAt(index: Int) -> String? {
        guard 0..<buyersToShow ~= index else { return textForSeeMoreLabel() }
        let buyer = buyerAt(index: index)
        return buyer?.name
    }
    
    func bottomBorderAt(index: Int) -> Bool {
        return 0..<buyersToShow ~= index
    }
    
    func topBorderAt(index: Int) -> Bool {
        return index == 0
    }
    
    func secondaryActionsbottomBorderAt(index: Int) -> Bool {
        return true
    }
    
    func secondaryActionstopBorderAt(index: Int) -> Bool {
        return index == 0
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


// MARK: - Tracking

fileprivate extension RateBuyersViewModel {
    func trackMarkAsSoldAtLetgo(buyerId: String?) {
        let event = TrackerEvent.productMarkAsSoldAtLetgo(trackingInfo: trackingInfo.updating(buyerId: buyerId))
        tracker.trackEvent(event)
    }
    
    func trackMarkAsSoldOutsideLetgo() {
        let event = TrackerEvent.productMarkAsSoldOutsideLetgo(trackingInfo: trackingInfo)
        tracker.trackEvent(event)
    }
}
