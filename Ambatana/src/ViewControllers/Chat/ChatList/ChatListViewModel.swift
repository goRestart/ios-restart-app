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
    func chatListViewModelDidFailArchivingChats(viewModel: ChatListViewModel)
    func chatListViewModelDidSucceedArchivingChats(viewModel: ChatListViewModel)
    func chatListViewModelDidFailUnarchivingChats(viewModel: ChatListViewModel)
    func chatListViewModelDidSucceedUnarchivingChats(viewModel: ChatListViewModel)
}

protocol ChatListViewModel: class, ChatGroupedListViewModel {
    weak var delegate: ChatListViewModelDelegate? { get set }
    weak var tabNavigator: TabNavigator? { get set }

    var titleForDeleteButton: String { get }

    var hasMessagesToRead: Bool { get }

    func deleteConfirmationTitle(itemCount: Int) -> String
    func deleteConfirmationMessage(itemCount: Int) -> String
    func deleteConfirmationCancelTitle() -> String
    func deleteConfirmationSendButton() -> String

    func deleteChatsAtIndexes(indexes: [Int])
    func deleteButtonPressed()

    func conversationDataAtIndex(index: Int) -> ConversationCellData?
    func conversationSelectedAtIndex(index: Int)
}
