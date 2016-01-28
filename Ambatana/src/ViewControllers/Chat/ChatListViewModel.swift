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

public class ChatListViewModel : BaseViewModel, Paginable {
    public weak var delegate : ChatListViewModelDelegate?

    public var chats: [Chat] = []
    var chatRepository: ChatRepository

    public var archivedChats = 0
    public var failedArchivedChats = 0
    public var chatsType: ChatsType
    
    
    // MARK: Paginable
    
    var nextPage: Int = 1
    var isLastPage: Bool = false
    var isLoading: Bool = false
    
    var objectCount: Int {
        return chats.count
    }
    
    
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
        self.chatsType = .All
        super.init()
    }
    
    override func didSetActive(active: Bool) {
        if active {
            reloadCurrentPages()
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
    
    func synchronize<ResultType>(asynchClosure: (completion: (ResultType) -> ()) -> Void, timeout: UInt64 = DISPATCH_TIME_FOREVER, @autoclosure timeoutWith: () -> ResultType) -> ResultType {
        let sem = dispatch_semaphore_create(0)
        
        var result: ResultType?
        
        asynchClosure { (r: ResultType) -> () in
            result = r
            dispatch_semaphore_signal(sem)
        }
        dispatch_semaphore_wait(sem, timeout)
        if result == nil {
            result = timeoutWith()
        }
        return result!
    }
    
    
    // MARK: - Paginable
    
    internal func reloadCurrentPages() {
        isLoading = true
        var reloadedChats: [Chat] = []
        let chatReloadQueue = dispatch_queue_create("ChatReloadQueue", DISPATCH_QUEUE_SERIAL)

        dispatch_async(chatReloadQueue, { [weak self] in
            guard let strongSelf = self else { return }
            for page in strongSelf.firstPage..<strongSelf.nextPage {
                let result = strongSelf.synchronize({ completion in
                    self?.chatRepository.index(chatsType, page: page, numResults: resultsPerPage) { result in
                        completion(result)
                    }
                    }, timeoutWith: ChatsResult(error: RepositoryError.Network))
                
                if let value = result.value {
                    reloadedChats += value
                } else if let _ = result.error {
                    if !reloadedChats.isEmpty {
                        break
                    }
                    dispatch_async(dispatch_get_main_queue()) {
                        strongSelf.delegate?.didFailRetrievingChatList(strongSelf, page: strongSelf.nextPage, error: strongSelf.networkError())
                    }
                    return
                }
            }
            strongSelf.isLoading = false
            dispatch_async(dispatch_get_main_queue()) {
                strongSelf.chats = reloadedChats
                strongSelf.delegate?.didSucceedRetrievingChatList(strongSelf, page: strongSelf.nextPage, nonEmptyChatList: !strongSelf.chats.isEmpty)
                strongSelf.updateUnreadMessagesCount()
            }
        })
    }
    
    internal func retrievePage(page: Int) {
        isLoading = true
        delegate?.didStartRetrievingChatList(self, isFirstLoad: chats.count < 1, page: page)
        
        chatRepository.index(chatsType, page: page, numResults: resultsPerPage) { [weak self] result in
            guard let strongSelf = self else { return }
            if let value = result.value {
                
                if page == 1 {
                    strongSelf.chats = value
                } else {
                    strongSelf.chats += value
                }
                
                strongSelf.isLastPage = value.count < strongSelf.resultsPerPage
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
