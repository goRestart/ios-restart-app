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

    private var chatRepository: ChatRepository
    private var keyValueStorage: KeyValueStorage
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


    // Rx Vars
    let selectedItemsCount = Variable<Int>(4)
    let sendMessageTitle = Variable<String>("")
    let disposeBag = DisposeBag()


    // MARK: - Lifecycle

    convenience init(productList: [Product], sourceProductId: String, manualOpen: Bool) {
        self.init(productList: productList, sourceProductId: sourceProductId, manualOpen: manualOpen,
                  chatRepository: Core.chatRepository, keyValueStorage: KeyValueStorage.sharedInstance,
                  trackerProxy: TrackerProxy.sharedInstance)
    }

    init(productList: [Product], sourceProductId: String, manualOpen: Bool, chatRepository: ChatRepository,
         keyValueStorage: KeyValueStorage, trackerProxy: TrackerProxy) {
        self.productList = productList
        self.sourceProductId = sourceProductId
        self.manualOpen = manualOpen
        self.selectedProducts.value = productList
        self.chatRepository = chatRepository
        self.keyValueStorage = keyValueStorage
        self.trackerProxy = trackerProxy
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

    func imageURLForItemAtIndex(_ index: Int) -> URL {
        guard index < productListCount else { return URL() }
        guard let imageUrl = productList[index].thumbnail?.fileURL else { return URL() }
        return imageUrl
    }

    func priceForItemAtIndex(_ index: Int) -> String {
        guard index < productListCount else { return "" }
        return productList[index].priceString()
    }

    func sendMessage() {
        let wrapper = ChatWrapper()
        for product in selectedProducts.value {
            wrapper.sendMessageForProduct(product, type:.ExpressChat(messageText.value)) { [weak self] result in
                if let value = result.value {
                    self?.singleMessageExtraTrackings(value, product: product)
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
    func trackExpressChatStart() {
        let trigger: EventParameterExpressChatTrigger = manualOpen ? .Manual : .Automatic
        let event = TrackerEvent.expressChatStart(trigger)
        trackerProxy.trackEvent(event)
    }

    func singleMessageExtraTrackings(_ shouldAskAskQuestion: Bool, product: Product) {
        if shouldAskAskQuestion {
            let askQuestionEvent = TrackerEvent.firstMessage(product, messageType: .text, typePage: .expressChat)
            trackerProxy.trackEvent(askQuestionEvent)
        }
        
        let messageSentEvent = TrackerEvent.userMessageSent(product, userTo: product.user, messageType: .text,
                                                            isQuickAnswer: .falseParameter, typePage: .ExpressChat)
        trackerProxy.trackEvent(messageSentEvent)
    }

    func trackExpressChatComplete(_ numChats: Int) {
        let trigger: EventParameterExpressChatTrigger = manualOpen ? .Manual : .Automatic
        let event = TrackerEvent.expressChatComplete(numChats, trigger: trigger)
        trackerProxy.trackEvent(event)
    }

    func trackExpressChatDontAsk() {
        let trigger: EventParameterExpressChatTrigger = manualOpen ? .Manual : .Automatic
        let event = TrackerEvent.expressChatDontAsk(trigger)
        trackerProxy.trackEvent(event)
    }
}
