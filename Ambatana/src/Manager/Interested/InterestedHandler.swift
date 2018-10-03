import LGComponents
import LGCoreKit
import RxSwift

enum InterestedAction {
    case askPhoneProUser
    case openChatProUser
    case openChatNonProUser
    case triggerInterestedAction
}

final class InterestedHandler: InterestedHandleable {
    
    static let undoTimeout: TimeInterval = 5
    
    let interestedStateUpdater: InterestedStateUpdater
    private let tracker: Tracker
    private let keyValueStorage: KeyValueStorage
    private let featureFlags: FeatureFlaggeable
    private let chatWrapper: ChatWrapper
    private let sessionManager: SessionManager
    private let disposeBag = DisposeBag()

    
    // MARK: - Lifecycle
    
    convenience init() {
        self.init(interestedStateUpdater: LGInterestedStateUpdater.sharedInstance,
                  tracker: TrackerProxy.sharedInstance,
                  keyValueStorage: KeyValueStorage.sharedInstance,
                  featureFlags: FeatureFlags.sharedInstance,
                  chatWrapper: LGChatWrapper(),
                  sessionManager: Core.sessionManager)
    }
    
    init(interestedStateUpdater: InterestedStateUpdater,
         tracker: TrackerProxy,
         keyValueStorage: KeyValueStorage,
         featureFlags: FeatureFlaggeable,
         chatWrapper: ChatWrapper,
         sessionManager: SessionManager) {
        self.interestedStateUpdater = interestedStateUpdater
        self.tracker = tracker
        self.keyValueStorage = keyValueStorage
        self.featureFlags = featureFlags
        self.chatWrapper = chatWrapper
        self.sessionManager = sessionManager
    }
    
    
    // MARK: - Interested actions
    
    func retrieveInterestedActionFor(_ listing: Listing, userListing: LocalUser?) -> InterestedAction  {
        let isProUser = userListing?.isProfessional ?? false
        let hasContactedProListing = interestedStateUpdater.hasContactedProListing(listing)
        let hasContactedNonProListing = interestedStateUpdater.hasContactedListing(listing)
        
        if isProUser && hasContactedProListing {
            return .openChatProUser
        } else if isProUser && !hasContactedNonProListing {
            return .askPhoneProUser
        } else if !isProUser && hasContactedNonProListing {
            return .openChatNonProUser
        } else {
            return .triggerInterestedAction
        }
    }
    
    func interestedActionFor(_ listing: Listing,
                             userListing: LocalUser?,
                             stateCompletion: @escaping (InterestedState) -> Void,
                             actionCompletion: @escaping (InterestedAction) -> Void) {
        let interestedAction = retrieveInterestedActionFor(listing, userListing: userListing)
        switch interestedAction {
        case .openChatProUser:
            trackChatWithSeller(listing: listing)
        case .openChatNonProUser:
            stateCompletion(.seeConversation)
        case .askPhoneProUser, .triggerInterestedAction:
            break
        }
        actionCompletion(interestedAction)
    }
    
    func handleCancellableInterestedAction(_ listing: Listing,
                                           timer: Observable<Any>,
                                           typePage: EventParameterTypePage,
                                           completion: @escaping (InterestedState) -> Void) {
        timer.subscribe { [weak self] (event) in
            guard event.error == nil else {
                completion(.seeConversation)
                self?.sendMessage(forListing: listing, typePage: typePage)
                return
            }
            completion(.send(enabled: true))
            self?.trackUndoSendingInterestedMessage()
        }.disposed(by: disposeBag)
    }
    
    private func sendMessage(forListing listing: Listing, typePage: EventParameterTypePage) {
        interestedStateUpdater.addInterestedState(forListing: listing, completion: nil)
        let type: ChatWrapperMessageType
        if featureFlags.randomImInterestedMessages.isActive {
            type = ChatWrapperMessageType.interested(QuickAnswer.dynamicInterested(
                interestedMessage: QuickAnswer.InterestedMessage.makeRandom()).textToReply)
        } else {
            type = ChatWrapperMessageType.interested(QuickAnswer.interested.textToReply)
        }
        let trackingInfo = makeSendMessageTrackingInfo(type: type, listing: listing, typePage: typePage)
        trackUserMessageSent(trackingInfo: trackingInfo)
        chatWrapper.sendMessageFor(listing: listing, type: type) { [weak self] isFirstMessage in
            guard let isFirstMessage = isFirstMessage.value, isFirstMessage else { return }
            self?.trackFirstMessage(trackingInfo: trackingInfo, listing: listing)
        }
    }
    
    
    // MARK - Tracking
    
    private func trackChatWithSeller(listing: Listing) {
        let trackHelper = ProductVMTrackHelper(tracker: tracker,
                                               listing: listing,
                                               featureFlags: featureFlags)
        trackHelper.trackChatWithSeller(.feed)
    }
    
    private func trackUndoSendingInterestedMessage() {
        tracker.trackEvent(TrackerEvent.undoSentMessage())
    }
    
    private func makeSendMessageTrackingInfo(type: ChatWrapperMessageType,
                                             listing: Listing,
                                             typePage: EventParameterTypePage) -> SendMessageTrackingInfo {
        let trackingInfo = SendMessageTrackingInfo
            .makeWith(type: type, listing: listing, freePostingAllowed: featureFlags.freePostingModeAllowed)
            .set(typePage: .listingList)
            .set(isBumpedUp: .falseParameter)
            .set(containsEmoji: false)
            .set(typePage: typePage)
        return trackingInfo
    }
    
    private func trackUserMessageSent(trackingInfo: SendMessageTrackingInfo) {
        tracker.trackEvent(.userMessageSent(info: trackingInfo, isProfessional: nil))
    }
    
    private func trackFirstMessage(trackingInfo: SendMessageTrackingInfo, listing: Listing) {
        let event = TrackerEvent.firstMessage(info: trackingInfo,
                                              listingVisitSource: .listingList,
                                              feedPosition: .none,
                                              sectionPosition: .none,
                                              userBadge: .noBadge,
                                              containsVideo: EventParameterBoolean(bool: listing.containsVideo()),
                                              isProfessional: nil,
                                              sectionName: nil)
        tracker.trackEvent(event)
    }
}

