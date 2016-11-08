//
//  ChatHeadManager.swift
//  LetGo
//
//  Created by Albert Hernández López on 08/11/16.
//  Copyright © 2016 Ambatana. All rights reserved.
//

import LGCoreKit
import RxSwift

final class ChatHeadManager {
    static let sharedInstance: ChatHeadManager = ChatHeadManager()

    private static let conversationsIndexPageSize = 20

    private let myUserRepository: MyUserRepository
    private let chatRepository: ChatRepository
    private let oldChatRepository: OldChatRepository

    private let rx_chatHeadOverlayView: Variable<ChatHeadOverlayView?>
    private let rx_chatHeadDatas: Variable<[ChatHeadData]>
    private let disposeBag: DisposeBag


    // MARK: - Lifecycle

    convenience init() {
        let myUserRepository = Core.myUserRepository
        let chatRepository = Core.chatRepository
        let oldChatRepository = Core.oldChatRepository
        self.init(myUserRepository: myUserRepository, chatRepository: chatRepository,
                  oldChatRepository: oldChatRepository)
    }

    init(myUserRepository: MyUserRepository, chatRepository: ChatRepository, oldChatRepository: OldChatRepository) {
        self.myUserRepository = myUserRepository
        self.chatRepository = chatRepository
        self.oldChatRepository = oldChatRepository
        self.rx_chatHeadOverlayView = Variable<ChatHeadOverlayView?>(nil)
        self.rx_chatHeadDatas = Variable<[ChatHeadData]>([])
        self.disposeBag = DisposeBag()

        setup()
        setupRx()

        // If logged in, retrieve chats for the first time
        if let _ = myUserRepository.myUser {
            updateChatHeadDatas()
        }
    }
}


// MARK: - Public methods

extension ChatHeadManager {
    func setChatHeadOverlayView(chatHeadOverlayView: ChatHeadOverlayView?) {
        rx_chatHeadOverlayView.value = chatHeadOverlayView
    }
}


// MARK: - Private methods

extension ChatHeadManager {
    func setup() {
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(applicationWillEnterForeground),
                                                         name: UIApplicationWillEnterForegroundNotification, object: nil)
    }

    func setupRx() {
        // Overlay is hidden while logged out or there are no conversations with unread messages
        let loggedOut = myUserRepository.rx_myUser.asObservable()
            .map { $0 == nil }
            .distinctUntilChanged()
        let chatHeadsDataEmpty = rx_chatHeadDatas.asObservable()
            .map { $0.isEmpty }
            .distinctUntilChanged()

        Observable
            .combineLatest(rx_chatHeadOverlayView.asObservable(), loggedOut, chatHeadsDataEmpty) { ($0.0, $0.1 || $0.2) }
            .subscribeNext { (overlay, hidden) in
                overlay?.hidden = hidden
            }.addDisposableTo(disposeBag)

        // Depending on chat source subscribe to chats events
        if FeatureFlags.websocketChat {
            chatRepository.chatEvents.filter { event in
                switch event.type {
                case .InterlocutorMessageSent:
                    return true
                default:
                    return false
                }
            }.bindNext { [weak self] event in
                self?.updateChatHeadDatas()
            }.addDisposableTo(disposeBag)
        } else {
            DeepLinksRouter.sharedInstance.chatDeepLinks.subscribeNext { [weak self] _ in
                self?.updateChatHeadDatas()
            }.addDisposableTo(disposeBag)
        }
    }

    func updateChatHeadDatas() {
        if FeatureFlags.websocketChat {
            chatRepository.indexConversations(ChatHeadManager.conversationsIndexPageSize, offset: 0, filter: .None) { [weak self] result in
                guard let conversations = result.value else { return }
                let datas = conversations.flatMap { (conversation: ChatConversation) -> ChatHeadData? in
                    guard conversation.unreadMessageCount > 0 else { return nil }
                    return ChatHeadData(conversation: conversation)
                }
                self?.rx_chatHeadDatas.value = datas
            }
        } else {
            oldChatRepository.index(.All, page: 1, numResults: ChatHeadManager.conversationsIndexPageSize) { [weak self] result in
                guard let myUser = self?.myUserRepository.myUser, chats = result.value else { return }
                let datas = chats.flatMap { (chat: Chat) -> ChatHeadData? in
                    guard chat.msgUnreadCount > 0 else { return nil }
                    return ChatHeadData(chat: chat, myUser: myUser)
                }
                self?.rx_chatHeadDatas.value = datas
            }
        }
    }

    dynamic private func applicationWillEnterForeground() {
        updateChatHeadDatas()
    }
}
