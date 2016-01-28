//
//  ChatListViewModel.swift
//  LetGo
//
//  Created by Dídac on 21/12/15.
//  Copyright © 2015 Ambatana. All rights reserved.
//

import LGCoreKit
import Result

public protocol ChatListViewModelDelegate: class {
    func didStartRetrievingChatList(viewModel: ChatListViewModel, isFirstLoad: Bool)
    func didFailRetrievingChatList(viewModel: ChatListViewModel, error: ErrorData)
    func didSucceedRetrievingChatList(viewModel: ChatListViewModel, nonEmptyChatList: Bool)
    func didFailArchivingChat(viewModel: ChatListViewModel, atPosition: Int, ofTotal: Int)
    func didSucceedArchivingChat(viewModel: ChatListViewModel, atPosition: Int, ofTotal: Int)
}

public class ChatListViewModel : BaseViewModel {

    public weak var delegate : ChatListViewModelDelegate?

    public var chats: [Chat]?
    var chatRepository: ChatRepository
    var retrievingChats: Bool

    public var archivedChats = 0
    public var failedArchivedChats = 0

    // computed iVars
    public var chatCount : Int {
        return chats?.count ?? 0
    }

    // MARK: - Lifecycle

    public override convenience init() {
        self.init(chatRepository: Core.chatRepository, chats: [])
    }

    public required init(chatRepository: ChatRepository, chats: [Chat]) {
        self.chatRepository = chatRepository
        self.chats = chats
        self.retrievingChats = false
        super.init()
    }

    override func didSetActive(active: Bool) {
        if active {
            updateConversations()
        }
    }

    // MARK: public methods

    public func updateConversations() {
        retrievingChats = true
        delegate?.didStartRetrievingChatList(self, isFirstLoad: chatCount < 1)

        //TODO: THIS MUST BE UPDATED WHEN APPLYING CHAT PAGINATION BRANCH
        chatRepository.index(.All, page: 1) { [weak self] result in
            guard let strongSelf = self else { return }
            strongSelf.retrievingChats = false
            if let chats = result.value {
                strongSelf.chats = chats
                strongSelf.delegate?.didSucceedRetrievingChatList(strongSelf, nonEmptyChatList: chats.count > 0)
            } else if let actualError = result.error {

                var errorData = ErrorData()
                switch actualError {
                case .Network:
                    errorData.errImage = UIImage(named: "err_network")
                    errorData.errTitle = LGLocalizedString.commonErrorTitle
                    errorData.errBody = LGLocalizedString.commonErrorNetworkBody
                    errorData.errButTitle = LGLocalizedString.commonErrorRetryButton
                case .Internal, .NotFound, .Unauthorized:
                    break
                }

                strongSelf.delegate?.didFailRetrievingChatList(strongSelf, error: errorData)
            }
        }
        updateUnreadMessagesCount()
    }

    public func updateUnreadMessagesCount() {
        PushManager.sharedInstance.updateUnreadMessagesCount()
    }

    public func chatAtIndex(index: Int) -> Chat? {
        guard let chats = chats where index < chatCount else { return nil }
        return chats[index]
    }

    public func clearChatList() {
        chats = []
    }

    public func archiveChatsAtIndexes(indexes: [NSIndexPath]) {
        archivedChats = 0
        failedArchivedChats = 0
        for index in indexes {
            guard let chat = chats?[index.row] else { continue }
            chatRepository.archiveChatWithId(chat) { [weak self] result in

                guard let strongSelf = self else { return }
                strongSelf.archivedChats++
                if let _ = result.error {
                    strongSelf.failedArchivedChats++
                    strongSelf.delegate?.didFailArchivingChat(strongSelf, atPosition: index.row,
                        ofTotal: indexes.count)
                } else {
                    strongSelf.delegate?.didSucceedArchivingChat(strongSelf, atPosition: index.row,
                        ofTotal: indexes.count)
                }
            }
        }
    }
    
}