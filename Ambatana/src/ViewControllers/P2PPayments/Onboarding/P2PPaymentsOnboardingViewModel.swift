import Foundation
import LGCoreKit
import LGComponents

final class P2PPaymentsOnboardingViewModel: BaseViewModel {
    var navigator: P2PPaymentsMakeAnOfferNavigator?
    private let chatConversation: ChatConversation
    private let myUserRepository: MyUserRepository
    private let tracker: Tracker

    init(chatConversation: ChatConversation,
         myUserRepository: MyUserRepository = Core.myUserRepository,
         tracker: Tracker = TrackerProxy.sharedInstance) {
        self.chatConversation = chatConversation
        self.myUserRepository = myUserRepository
        self.tracker = tracker
    }

    // MARK: - Public methods

    func closeButtonPressed() {
        trackMakeAnOfferAbandon()
        navigator?.closeOnboarding()
    }

    func makeAnOfferButtonPressed() {
        trackMakeAnOfferStart()
        navigator?.openMakeAnOffer()
    }

    private func trackMakeAnOfferStart() {
        guard let userId = myUserRepository.myUser?.objectId else { return }
        let trackerEvent = TrackerEvent.p2pPaymentsMakeAnOfferStart(userId: userId,
                                                                    chatConversation: chatConversation)
        tracker.trackEvent(trackerEvent)
    }

    private func trackMakeAnOfferAbandon() {
        guard let userId = myUserRepository.myUser?.objectId else { return }
        let trackerEvent = TrackerEvent.p2pPaymentsMakeAnOfferOnboardingAbandon(userId: userId,
                                                                                chatConversation: chatConversation)
        tracker.trackEvent(trackerEvent)
    }
}
