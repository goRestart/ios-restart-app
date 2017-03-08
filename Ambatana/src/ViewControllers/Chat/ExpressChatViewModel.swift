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
    private var productList: [Product]
    private var sourceProductId: String
    fileprivate var manualOpen: Bool
    var productListCount: Int {
        return productList.count
    }

    let selectedProducts = Variable<[Product]>([])
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

    convenience init(productList: [Product], sourceProductId: String, manualOpen: Bool) {
        self.init(productList: productList, sourceProductId: sourceProductId, manualOpen: manualOpen,
                  keyValueStorage: KeyValueStorage.sharedInstance, trackerProxy: TrackerProxy.sharedInstance,
                  featureFlags: FeatureFlags.sharedInstance, chatWrapper: LGChatWrapper())
    }

    init(productList: [Product], sourceProductId: String, manualOpen: Bool, keyValueStorage: KeyValueStorage,
         trackerProxy: TrackerProxy, featureFlags: FeatureFlags, chatWrapper: ChatWrapper) {
        self.productList = productList
        self.sourceProductId = sourceProductId
        self.manualOpen = manualOpen
        self.selectedProducts.value = productList
        self.keyValueStorage = keyValueStorage
        self.trackerProxy = trackerProxy
        self.featureFlags = featureFlags
        self.chatWrapper = chatWrapper
    }

    override func didBecomeActive(_ firstTime: Bool) {
        setupRx()
        selectedItemsCount.value = productListCount
        trackExpressChatStart()
    }


    // MARK: - Public methods

    func titleForItemAtIndex(_ index: Int) -> String {
        guard index < productListCount else { return "" }
        return productList[index].title ?? ""
    }

    func imageURLForItemAtIndex(_ index: Int) -> URL? {
        guard index < productListCount else { return nil }
        guard let imageUrl = productList[index].thumbnail?.fileURL else { return nil }
        return imageUrl
    }

    func priceForItemAtIndex(_ index: Int) -> String {
        guard index < productListCount else { return "" }
        return productList[index].priceString()
    }

    func sendMessage() {
        let tracker = trackerProxy
        let freePostingModeAllowed = featureFlags.freePostingModeAllowed

        for product in selectedProducts.value {
            chatWrapper.sendMessageForProduct(product, type:.expressChat(messageText.value)) { result in
                if let value = result.value {
                    ExpressChatViewModel.singleMessageExtraTrackings(tracker, shouldSendAskQuestion: value, product: product,
                                                                     freePostingModeAllowed: freePostingModeAllowed)
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
        let product = productList[index]
        let selectedIndex = selectedProductsContains(product)
        guard selectedIndex >= selectedItemsCount.value else { return }
        selectedProducts.value.insert(product, at: 0)
    }

    func deselectItemAtIndex(_ index: Int) {
        guard index < productListCount else { return }
        let product = productList[index]
        let selectedIndex = selectedProductsContains(product)
        guard selectedIndex < selectedItemsCount.value else { return }
        selectedProducts.value.remove(at: selectedIndex)
    }

    private func selectedProductsContains(_ product: Product) -> Int {
        var index = 0
        for selectedProduct in selectedProducts.value {
            if selectedProduct.objectId == product.objectId { return index }
            index += 1
        }
        return index
    }


    // MARK: - Private methods

    func setupRx() {

        selectedProducts.asObservable().subscribeNext { [weak self] products in
            self?.selectedItemsCount.value = products.count
        }.addDisposableTo(disposeBag)

        selectedItemsCount.asObservable().subscribeNext { [weak self] numSelected in
            self?.sendMessageTitle.value = numSelected > 1 ?
                LGLocalizedString.chatExpressContactVariousButtonText(String(numSelected)) :
                LGLocalizedString.chatExpressContactOneButtonText
        }.addDisposableTo(disposeBag)

        selectedItemsCount.asObservable().subscribeNext { [weak self] selectedCount in
            self?.sendButtonEnabled.value = selectedCount > 0
        }.addDisposableTo(disposeBag)
    }
}


// MARK: - Tracking

extension ExpressChatViewModel {
    static func singleMessageExtraTrackings(_ tracker: Tracker, shouldSendAskQuestion: Bool, product: Product,
                                            freePostingModeAllowed: Bool) {
        if shouldSendAskQuestion {
            let askQuestionEvent = TrackerEvent.firstMessage(product, messageType: .text, quickAnswerType: nil, typePage: .expressChat,
                                                             freePostingModeAllowed: freePostingModeAllowed,
                                                             isBumpedUp: .falseParameter)
            tracker.trackEvent(askQuestionEvent)
        }

        let messageSentEvent = TrackerEvent.userMessageSent(product, userTo: product.user, messageType: .text, quickAnswerType: nil,
                                                            typePage: .expressChat, freePostingModeAllowed: freePostingModeAllowed)
        tracker.trackEvent(messageSentEvent)
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
