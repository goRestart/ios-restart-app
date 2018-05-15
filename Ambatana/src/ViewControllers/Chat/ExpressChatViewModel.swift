//
//  ExpressChatViewModel.swift
//  LetGo
//
//  Created by Dídac on 09/08/16.
//  Copyright © 2016 Ambatana. All rights reserved.
//

import Foundation
import LGCoreKit
import RxSwift

protocol ExpressChatViewModelDelegate: class {
    func sendMessageSuccess()
}

class ExpressChatViewModel: BaseViewModel {

    private var keyValueStorage: KeyValueStorage
    fileprivate var featureFlags: FeatureFlaggeable
    fileprivate var trackerProxy: TrackerProxy
    private var listings: [Listing]
    private var sourceProductId: String
    fileprivate var manualOpen: Bool
    var productListCount: Int {
        return listings.count
    }

    let selectedListings = Variable<[Listing]>([])
    let messageText = Variable<String>(LGLocalizedString.chatExpressTextFieldText)
    let sendButtonEnabled = Variable<Bool>(false)

    weak var navigator: ExpressChatNavigator?

    weak var delegate: ExpressChatViewModelDelegate?

    private let chatWrapper: ChatWrapper


    // Rx Vars
    let selectedItemsCount = Variable<Int>(4)
    let sendMessageTitle = Variable<String>("")
    let disposeBag = DisposeBag()


    // MARK: - Lifecycle

    convenience init(listings: [Listing], sourceProductId: String, manualOpen: Bool) {
        self.init(listings: listings, sourceProductId: sourceProductId, manualOpen: manualOpen,
                  keyValueStorage: KeyValueStorage.sharedInstance, trackerProxy: TrackerProxy.sharedInstance,
                  featureFlags: FeatureFlags.sharedInstance, chatWrapper: LGChatWrapper())
    }

    init(listings: [Listing], sourceProductId: String, manualOpen: Bool, keyValueStorage: KeyValueStorage,
         trackerProxy: TrackerProxy, featureFlags: FeatureFlags, chatWrapper: ChatWrapper) {
        self.listings = listings
        self.sourceProductId = sourceProductId
        self.manualOpen = manualOpen
        self.selectedListings.value = listings
        self.keyValueStorage = keyValueStorage
        self.trackerProxy = trackerProxy
        self.featureFlags = featureFlags
        self.chatWrapper = chatWrapper
    }

    override func didBecomeActive(_ firstTime: Bool) {
        if firstTime {
            setupRx()
            selectedItemsCount.value = productListCount
            trackExpressChatStart()
        }
    }


    // MARK: - Public methods

    func titleForItemAtIndex(_ index: Int) -> String {
        guard index < productListCount else { return "" }
        return listings[index].title ?? ""
    }

    func imageURLForItemAtIndex(_ index: Int) -> URL? {
        guard index < productListCount else { return nil }
        guard let imageUrl = listings[index].thumbnail?.fileURL else { return nil }
        return imageUrl
    }

    func priceForItemAtIndex(_ index: Int) -> String {
        guard index < productListCount else { return "" }
        return listings[index].priceString(freeModeAllowed: featureFlags.freePostingModeAllowed)
    }

    func sendMessage() {
        let tracker = trackerProxy
        let freePostingModeAllowed = featureFlags.freePostingModeAllowed

        for listing in selectedListings.value {
            chatWrapper.sendMessageFor(listing: listing, type:.expressChat(messageText.value)) { [weak self] result in
                guard let strongSelf = self else { return }
                if let value = result.value {
                    ExpressChatViewModel.singleMessageTrackings(tracker,
                                                                shouldSendAskQuestion: value,
                                                                listing: listing,
                                                                freePostingModeAllowed: freePostingModeAllowed,
                                                                containsEmoji: strongSelf.messageText.value.containsEmoji)
                } else if let error = result.error {
                    ExpressChatViewModel.singleMessageTrackingError(tracker,
                                                                    listing: listing,
                                                                    freePostingModeAllowed: freePostingModeAllowed,
                                                                    containsEmoji: strongSelf.messageText.value.containsEmoji,
                                                                    error: error)
                }
            }
        }

        trackExpressChatComplete(selectedItemsCount.value)
        navigator?.sentMessage(sourceProductId, count: selectedItemsCount.value)
    }

    func closeExpressChat(_ showAgain: Bool) {
        if !showAgain {
            trackExpressChatDontAsk()
        }
        navigator?.closeExpressChat(showAgain, forProduct: sourceProductId)
    }

    func selectItemAtIndex(_ index: Int) {
        guard index < productListCount else { return }
        let listing = listings[index]
        let selectedIndex = selectedProductsContains(listing)
        guard selectedIndex >= selectedItemsCount.value else { return }
        selectedListings.value.insert(listing, at: 0)
    }

    func deselectItemAtIndex(_ index: Int) {
        guard index < productListCount else { return }
        let listing = listings[index]
        let selectedIndex = selectedProductsContains(listing)
        guard selectedIndex < selectedItemsCount.value else { return }
        selectedListings.value.remove(at: selectedIndex)
    }

    private func selectedProductsContains(_ listing: Listing) -> Int {
        var index = 0
        for selectedListing in selectedListings.value {
            if selectedListing.objectId == listing.objectId { return index }
            index += 1
        }
        return index
    }


    // MARK: - Private methods

    func setupRx() {

        selectedListings.asObservable().subscribeNext { [weak self] listings in
            self?.selectedItemsCount.value = listings.count
        }.disposed(by: disposeBag)

        selectedItemsCount.asObservable().subscribeNext { [weak self] numSelected in
            self?.sendMessageTitle.value = numSelected > 1 ?
                LGLocalizedString.chatExpressContactVariousButtonText(String(numSelected)) :
                LGLocalizedString.chatExpressContactOneButtonText
        }.disposed(by: disposeBag)

        selectedItemsCount.asObservable().subscribeNext { [weak self] selectedCount in
            self?.sendButtonEnabled.value = selectedCount > 0
        }.disposed(by: disposeBag)
    }
}


// MARK: - Tracking

extension ExpressChatViewModel {
    static func singleMessageTrackings(_ tracker: Tracker,
                                       shouldSendAskQuestion: Bool,
                                       listing: Listing,
                                       freePostingModeAllowed: Bool,
                                       containsEmoji: Bool) {
        guard let info = buildSendMessageInfo(withListing: listing,
                                              freePostingModeAllowed: freePostingModeAllowed,
                                              containsEmoji: containsEmoji,
                                              error: nil) else { return }
        let containsVideo = EventParameterBoolean(bool: listing.containsVideo())
        if shouldSendAskQuestion {
            let containsVideo = EventParameterBoolean(bool: listing.containsVideo())
            tracker.trackEvent(TrackerEvent.firstMessage(info: info,
                                                         listingVisitSource: .unknown,
                                                         feedPosition: .none,
                                                         userBadge: .noBadge,
                                                         containsVideo: containsVideo,
                                                         isProfessional: nil))
        }
        tracker.trackEvent(TrackerEvent.userMessageSent(info: info, isProfessional: nil))
    }

    static func singleMessageTrackingError(_ tracker: Tracker,
                                           listing: Listing,
                                           freePostingModeAllowed: Bool,
                                           containsEmoji: Bool,
                                           error: RepositoryError) {
        guard let info = buildSendMessageInfo(withListing: listing,
                                              freePostingModeAllowed: freePostingModeAllowed,
                                              containsEmoji: containsEmoji,
                                              error: error) else { return }
        tracker.trackEvent(TrackerEvent.userMessageSentError(info: info))
    }

    private static func buildSendMessageInfo(withListing listing: Listing,
                                             freePostingModeAllowed: Bool,
                                             containsEmoji: Bool,
                                             error: RepositoryError?) -> SendMessageTrackingInfo? {
        let sendMessageInfo = SendMessageTrackingInfo()
            .set(listing: listing, freePostingModeAllowed: freePostingModeAllowed)
            .set(messageType: .text)
            .set(quickAnswerTypeParameter: nil)
            .set(typePage: .expressChat)
            .set(isBumpedUp: .falseParameter)
            .set(containsEmoji: containsEmoji)

        if let error = error {
            sendMessageInfo.set(error: error.chatError)
        }
        return sendMessageInfo
    }

    func trackExpressChatStart() {
        let trigger: EventParameterExpressChatTrigger = manualOpen ? .manual : .automatic
        let event = TrackerEvent.expressChatStart(trigger)
        trackerProxy.trackEvent(event)
    }

    func trackExpressChatComplete(_ numChats: Int) {
        let trigger: EventParameterExpressChatTrigger = manualOpen ? .manual : .automatic
        let event = TrackerEvent.expressChatComplete(numChats, trigger: trigger)
        trackerProxy.trackEvent(event)
    }

    func trackExpressChatDontAsk() {
        let trigger: EventParameterExpressChatTrigger = manualOpen ? .manual : .automatic
        let event = TrackerEvent.expressChatDontAsk(trigger)
        trackerProxy.trackEvent(event)
    }
}
