import Foundation
import LGCoreKit
import RxSwift
import LGComponents


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
    let sendButtonEnabled = Variable<Bool>(false)

    var navigator: ExpressChatNavigator?
    weak var delegate: BaseViewModelDelegate?

    private let chatWrapper: ChatWrapper

    var hideDontAskAgainButton: Bool {
        return featureFlags.expressChatImprovement.isActive
    }

    var dontMissLabelText: String {
        switch featureFlags.expressChatImprovement {
        case .control, .baseline, .hideDontAsk:
            return R.Strings.chatExpressDontMissLabel.uppercased()
        case .newTitleAndHideDontAsk:
            return R.Strings.chatExpressHighDemandLabel
        }
    }

    var dontMissLabelFont: UIFont {
        switch featureFlags.expressChatImprovement {
        case .control, .baseline, .hideDontAsk:
            return .systemFont(size: 17)
        case .newTitleAndHideDontAsk:
            return .systemBoldFont(size: 27)
        }
    }

    var dontMissLabelAlignment: NSTextAlignment {
        switch featureFlags.expressChatImprovement {
        case .control, .baseline, .hideDontAsk:
            return .center
        case .newTitleAndHideDontAsk:
            return .left
        }
    }

    var contactSellersLabelText: String? {
        switch featureFlags.expressChatImprovement {
        case .control, .baseline, .hideDontAsk:
            return R.Strings.chatExpressContactSellersLabel
        case .newTitleAndHideDontAsk:
            return nil
        }
    }


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

    func openMoreOptionsMenu() {
        var dontAskAgainAction: UIAction {
            return UIAction(interface: .text(R.Strings.chatExpressDontAskAgainButton),
                            action: { [weak self] in self?.closeExpressChat(false) })
        }
        delegate?.vmShowActionSheet(R.Strings.commonCancel, actions: [dontAskAgainAction])
    }

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
        return listings[index].priceString()
    }

    func sendMessage() {
        let tracker = trackerProxy
 
        for listing in selectedListings.value {
            let messageToSend: String
            if featureFlags.randomImInterestedMessages.isActive {
                messageToSend = QuickAnswer.InterestedMessage.makeRandom().string
            } else {
                messageToSend = R.Strings.chatExpressTextFieldText
            }
            
            chatWrapper.sendMessageFor(listing: listing, type:.expressChat(messageToSend)) { result in
                if let value = result.value {
                    ExpressChatViewModel.singleMessageTrackings(tracker,
                                                                shouldSendAskQuestion: value,
                                                                listing: listing,
                                                                containsEmoji: messageToSend.containsEmoji)
                } else if let error = result.error {
                    ExpressChatViewModel.singleMessageTrackingError(tracker,
                                                                    listing: listing,
                                                                    containsEmoji: messageToSend.containsEmoji,
                                                                    error: error)
                }
            }
        }

        trackExpressChatComplete(selectedItemsCount.value)
        saveProductAsExpressChatMessageSent(sourceProductId)
        saveProductAsExpressChatShown(sourceProductId)
        let message = selectedListings.value.count == 1 ?
            R.Strings.chatExpressOneMessageSentSuccessAlert :
            R.Strings.chatExpressSeveralMessagesSentSuccessAlert
        navigator?.closeExpressChat(autoFadingOutMessage: message)
    }

    func closeExpressChat(_ showAgain: Bool) {
        if !showAgain {
            trackExpressChatDontAsk()
        }
        keyValueStorage.userShouldShowExpressChat = showAgain
        saveProductAsExpressChatShown(sourceProductId)
        navigator?.closeExpressChat(autoFadingOutMessage: nil)
    }

    private func saveProductAsExpressChatShown(_ productId: String) {
        var productsExpressShown = keyValueStorage.userProductsWithExpressChatAlreadyShown
        
        for productShownId in productsExpressShown {
            if productShownId == productId { return }
        }
        productsExpressShown.append(productId)
        keyValueStorage.userProductsWithExpressChatAlreadyShown = productsExpressShown
    }
    
    private func saveProductAsExpressChatMessageSent(_ productId: String) {
        var productsExpressSent = keyValueStorage.userListingsWithExpressChatMessageSent
        
        for productSentId in productsExpressSent {
            if productSentId == productId { return }
        }
        productsExpressSent.append(productId)
        keyValueStorage.userListingsWithExpressChatMessageSent = productsExpressSent
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
            guard let strongSelf = self else { return }
            guard !strongSelf.featureFlags.expressChatImprovement.isActive else {
                strongSelf.sendMessageTitle.value = R.Strings.chatExpressContactOnlyButtonText
                return
            }
            strongSelf.sendMessageTitle.value = numSelected > 1 ?
                R.Strings.chatExpressContactVariousButtonText(String(numSelected)) :
                R.Strings.chatExpressContactOneButtonText
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
                                       containsEmoji: Bool) {
        guard let info = buildSendMessageInfo(withListing: listing,
                                              containsEmoji: containsEmoji,
                                              error: nil) else { return }
        if shouldSendAskQuestion {
            let containsVideo = EventParameterBoolean(bool: listing.containsVideo())
            tracker.trackEvent(TrackerEvent.firstMessage(info: info,
                                                         listingVisitSource: .unknown,
                                                         feedPosition: .none,
                                                         sectionPosition: .none,
                                                         userBadge: .noBadge,
                                                         containsVideo: containsVideo,
                                                         isProfessional: nil,
                                                         sectionName: nil))
        }
        tracker.trackEvent(TrackerEvent.userMessageSent(info: info, isProfessional: nil))
    }

    static func singleMessageTrackingError(_ tracker: Tracker,
                                           listing: Listing,
                                           containsEmoji: Bool,
                                           error: RepositoryError) {
        guard let info = buildSendMessageInfo(withListing: listing,
                                              containsEmoji: containsEmoji,
                                              error: error) else { return }
        tracker.trackEvent(TrackerEvent.userMessageSentError(info: info))
    }

    private static func buildSendMessageInfo(withListing listing: Listing,
                                             containsEmoji: Bool,
                                             error: RepositoryError?) -> SendMessageTrackingInfo? {
        let sendMessageInfo = SendMessageTrackingInfo()
            .set(listing: listing)
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
