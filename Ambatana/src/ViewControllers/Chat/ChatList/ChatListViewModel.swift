//
//  ChatListViewModel.swift
//  LetGo
//
//  Created by Dídac on 21/12/15.
//  Copyright © 2015 Ambatana. All rights reserved.
//

import LGCoreKit

protocol ChatListViewModelDelegate: class {
    func vmDeleteSelectedChats()
    func chatListViewModelDidFailArchivingChats(_ viewModel: ChatListViewModel)
    func chatListViewModelDidSucceedArchivingChats(_ viewModel: ChatListViewModel)
    func chatListViewModelDidFailUnarchivingChats(_ viewModel: ChatListViewModel)
    func chatListViewModelDidSucceedUnarchivingChats(_ viewModel: ChatListViewModel)
}

protocol ChatListViewModel: class, ChatGroupedListViewModel {
    weak var delegate: ChatListViewModelDelegate? { get set }
    weak var tabNavigator: TabNavigator? { get set }

    var titleForDeleteButton: String { get }
    var hasMessagesToRead: Bool { get }
    var shouldRefreshConversations: Bool { get set }

    func deleteConfirmationTitle(_ itemCount: Int) -> String
    func deleteConfirmationMessage(_ itemCount: Int) -> String
    func deleteConfirmationCancelTitle() -> String
    func deleteConfirmationSendButton() -> String

    func deleteChatsAtIndexes(_ indexes: [Int])
    func deleteButtonPressed()

    func conversationDataAtIndex(_ index: Int) -> ConversationCellData?
    func conversationSelectedAtIndex(_ index: Int)
}
