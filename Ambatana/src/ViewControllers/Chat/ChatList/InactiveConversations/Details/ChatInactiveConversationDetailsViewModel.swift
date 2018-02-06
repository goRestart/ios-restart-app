//
//  ChatInactiveConversationDetailsViewModel.swift
//  LetGo
//
//  Created by Nestor on 18/01/2018.
//  Copyright © 2018 Ambatana. All rights reserved.
//

import LGCoreKit
import RxSwift

protocol ChatInactiveConversationsViewModelDelegate: BaseViewModelDelegate {
    func vmDidNotifyMessage(_ message: String, completion: (() -> ())?)
}

class ChatInactiveConversationDetailsViewModel: BaseViewModel {
    
    weak var delegate: ChatInactiveConversationsViewModelDelegate?
    weak var navigator: ChatInactiveDetailNavigator?
    
    private let chatRepository: ChatRepository
    private let chatViewMessageAdapter: ChatViewMessageAdapter
    private let featureFlags: FeatureFlaggeable
    private let tracker: Tracker
    
    private let conversation: ChatInactiveConversation
    private var messages: [ChatViewMessage] = []
    
    private var isDeleted = false
    
    private let disposeBag = DisposeBag()
    
    var messagesCount: Int {
        return messages.count
    }
    var listingName: String? {
        return conversation.listing?.title
    }
    var listingPrice: String? {
        return conversation.listing?.priceString(freeModeAllowed: featureFlags.freePostingModeAllowed)
    }
    var listingImageURL: URL? {
        return conversation.listing?.image?.fileURL
    }
    var interlocutorName: String? {
        return conversation.interlocutor?.name
    }
    var interlocutorAvatarURL: URL? {
        return conversation.interlocutor?.avatar?.fileURL
    }
    var interlocutorAvatarPlaceholder: UIImage? {
        return LetgoAvatar.avatarWithID(conversation.interlocutor?.objectId,
                                        name: conversation.interlocutor?.name)
    }
    
    // MARK: - Lifecycle
    
    convenience init(conversation: ChatInactiveConversation) {
        self.init(conversation: conversation,
                  chatRepository: Core.chatRepository,
                  chatViewMessageAdapter: ChatViewMessageAdapter(),
                  featureFlags: FeatureFlags.sharedInstance,
                  tracker: TrackerProxy.sharedInstance)
    }
    
    init(conversation: ChatInactiveConversation,
         chatRepository: ChatRepository,
         chatViewMessageAdapter: ChatViewMessageAdapter,
         featureFlags: FeatureFlaggeable,
         tracker: Tracker) {
        self.conversation = conversation
        self.chatRepository = chatRepository
        self.chatViewMessageAdapter = chatViewMessageAdapter
        self.featureFlags = featureFlags
        self.tracker = tracker
        super.init()
        messages = chatViewMessages(fromConversation: conversation)
    }
    
    override func didBecomeActive(_ firstTime: Bool) {
        super.didBecomeActive(firstTime)
        
        if firstTime {
            tracker.trackEvent(TrackerEvent.chatInactiveConversationsShown())
        }
    }
    
    // MARK: - Messages
    
    func messageAtIndex(_ index: Int) -> ChatViewMessage? {
        guard 0..<messagesCount ~= index else { return nil }
        return messages[index]
    }
    
    func textOfMessageAtIndex(_ index: Int) -> String? {
        return messageAtIndex(index)?.value
    }
    
    private func chatViewMessages(fromConversation conversation: ChatInactiveConversation) -> [ChatViewMessage] {
        var chatViewMessages = [ChatViewMessage]()
        conversation.messages.forEach { [weak self] message in
            guard let strongSelf = self else { return }
            let chatViewMessage = strongSelf.chatViewMessageAdapter.adapt(message)
            chatViewMessages.append(chatViewMessage)
        }
        let disclaimerMessage = chatViewMessageAdapter.createMessageSuspiciousDisclaimerMessage(nil)
        chatViewMessages = chatViewMessageAdapter.addDisclaimers(chatViewMessages, disclaimerMessage: disclaimerMessage)
        return chatViewMessages
    }
    
    // MARK: - Options Menu
    
    func openOptionsMenu() {
        var actions: [UIAction] = []
        if !isDeleted {
            let delete = UIAction(interface: UIActionInterface.text(LGLocalizedString.chatListDelete),
                                  action: deleteAction)
            actions.append(delete)
        }
        delegate?.vmShowActionSheet(LGLocalizedString.commonCancel, actions: actions)
    }
    
    private func deleteAction() {
        guard !isDeleted else { return }
        let action = UIAction(interface: .styledText(LGLocalizedString.chatListDeleteAlertSend, .destructive), action: {
            [weak self] in
            self?.delete() { [weak self] success in
                if success {
                    self?.isDeleted = true
                    self?.tracker.trackEvent(TrackerEvent.chatDeleteComplete(numberOfConversations: 1,
                                                                             isInactiveConversation: true))
                }
                let message = success ? LGLocalizedString.chatListDeleteOkOne : LGLocalizedString.chatListDeleteErrorOne
                self?.delegate?.vmDidNotifyMessage(message) { [weak self] in
                    self?.navigator?.closeChatInactiveDetail()
                }
            }
        })
        delegate?.vmShowAlert(LGLocalizedString.chatListDeleteAlertTitleOne,
                              message: LGLocalizedString.chatListDeleteAlertTextOne,
                              cancelLabel: LGLocalizedString.commonCancel,
                              actions: [action])
    }
    
    private func delete(_ completion: @escaping (_ success: Bool) -> ()) {
        guard let chatId = conversation.objectId else {
            completion(false)
            return
        }
        self.chatRepository.archiveInactiveConversations([chatId]) { result in
            completion(result.value != nil)
        }
    }
}
