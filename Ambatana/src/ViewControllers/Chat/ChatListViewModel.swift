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

    public var archivedChats = 0
    public var failedArchivedChats = 0

    // computed iVars
    public var chatCount : Int {
        return chats?.count ?? 0
    }

    // MARK: - Lifecycle

    public override convenience init() {
        self.init(chatRepository: ChatRepository.sharedInstance, chats: [])
    }

    public required init(chatRepository: ChatRepository, chats: [Chat]) {
        self.chatRepository = chatRepository
        self.chats = chats
        super.init()
    }

    override func didSetActive(active: Bool) {
        if active {
            updateConversations()
        }
    }

    // MARK: public methods

    public func updateConversations() {

        delegate?.didStartRetrievingChatList(self, isFirstLoad: chatCount < 1)

        chatRepository.retrieveChatsWithCompletion { [weak self] (result) in

            if let strongSelf = self {
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
            if let chat = chats?[index.row] {
                chatRepository.archiveChatWithId(chat) { [weak self] (result: Result<Void, RepositoryError>) -> () in

                    if let strongSelf = self {
                        strongSelf.archivedChats++
                        if let _ = result.error {
                            strongSelf.failedArchivedChats++
                            strongSelf.delegate?.didFailArchivingChat(strongSelf, atPosition: index.row, ofTotal: indexes.count)
                        } else {
                            strongSelf.delegate?.didSucceedArchivingChat(strongSelf, atPosition: index.row, ofTotal: indexes.count)
                        }
                    }
                }
            }
        }
    }

}