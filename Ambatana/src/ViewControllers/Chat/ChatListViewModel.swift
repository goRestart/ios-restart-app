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
    func didStartRetrievingChatList(viewModel: ChatListViewModel, isFirstLoad: Bool, page: Int)
    func didFailRetrievingChatList(viewModel: ChatListViewModel, page: Int, error: ErrorData)
    func didSucceedRetrievingChatList(viewModel: ChatListViewModel, page: Int, nonEmptyChatList: Bool)
    
    func didFailArchivingChat(viewModel: ChatListViewModel, atPosition: Int, ofTotal: Int)
    func didSucceedArchivingChat(viewModel: ChatListViewModel, atPosition: Int, ofTotal: Int)
}

public class ChatListViewModel : BaseViewModel {

    public weak var delegate : ChatListViewModelDelegate?

    public var chats: [Chat] = []
    var chatRepository: ChatRepository
    var retrievingChats: Bool

    public var archivedChats = 0
    public var failedArchivedChats = 0
    public var chatsType: ChatsType
    private static let itemsPagingThresholdPercentage: Float = 0.7    // when we should start ask for a new page

    
    // MARK: - Lifecycle
    
    public convenience init(chatsType: ChatsType) {
        self.init()
        self.chatsType = chatsType
    }

    public override convenience init() {
        self.init(chatRepository: Core.chatRepository, chats: [])
    }

    public required init(chatRepository: ChatRepository, chats: [Chat]) {
        self.chatRepository = chatRepository
        self.chats = chats
        self.retrievingChats = false
        self.chatsType = .All
        super.init()
    }

    override func didSetActive(active: Bool) {
        if active {
            loadFirstPage()
        }
    }

    // MARK: public methods
    
    public func setCurrentItemIndex(index: Int) {
        let threshold = Int(Float(chats.count) * ChatListViewModel.itemsPagingThresholdPercentage)
        let shouldRetrieveNextPage = index >= threshold
        if shouldRetrieveNextPage {
            loadNextPage()
        }
    }
    
    public func loadFirstPage() {
        if canRetrieve {
            retrieveConversations(1)
        }
    }
    
    public func loadNextPage() {
        if canRetrieveNextPage {
            retrieveConversations(nextPage)
        }
    }
    
    public func updateUnreadMessagesCount() {
        PushManager.sharedInstance.updateUnreadMessagesCount()
    }

    public func chatAtIndex(index: Int) -> Chat? {
        guard index < chats.count else { return nil }
        return chats[index]
    }

    public func clearChatList() {
        chats = []
    }

    public func archiveChatsAtIndexes(indexes: [NSIndexPath]) {
        archivedChats = 0
        failedArchivedChats = 0
        for index in indexes {
            let chat = chats[index.row]
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
    
    
    // MARK: Private
    
    private func retrieveConversations(page: Int) {
        isLoading = true
        retrievingChats = true
        delegate?.didStartRetrievingChatList(self, isFirstLoad: chats.count < 1, page: page)
        
        chatRepository.index(chatsType, page: page) { [weak self] result in
            guard let strongSelf = self else { return }
            strongSelf.retrievingChats = false
            if let chats = result.value {
                
                if page == 1 {
                    strongSelf.chats = chats
                } else {
                    strongSelf.chats += chats
                }
                
                strongSelf.isLastPage = chats.isEmpty
                strongSelf.nextPage = page + 1
                strongSelf.delegate?.didSucceedRetrievingChatList(strongSelf, page: page, nonEmptyChatList: !strongSelf.chats.isEmpty)
            } else if let actualError = result.error {
                
                var errorData = ErrorData()
                switch actualError {
                case .Network:
                    errorData = strongSelf.networkError()
                case .Internal, .NotFound, .Unauthorized:
                    break
                }
                
                strongSelf.delegate?.didFailRetrievingChatList(strongSelf, page: page, error: errorData)
            }
            strongSelf.isLoading = false
        }
        
        updateUnreadMessagesCount()
    }
    
    private func networkError() -> ErrorData {
        var errorData = ErrorData()
        errorData.errImage = UIImage(named: "err_network")
        errorData.errTitle = LGLocalizedString.commonErrorTitle
        errorData.errBody = LGLocalizedString.commonErrorNetworkBody
        errorData.errButTitle = LGLocalizedString.commonErrorRetryButton
        return errorData
    }
}