//
//  ChatListViewModel.swift
//  LetGo
//
//  Created by Dídac on 21/12/15.
//  Copyright © 2015 Ambatana. All rights reserved.
//

protocol ChatListViewModelDelegate: class {
    func vmDeleteSelectedChats()
    func chatListViewModelDidFailArchivingChats(viewModel: ChatListViewModel)
    func chatListViewModelDidSucceedArchivingChats(viewModel: ChatListViewModel)
    func chatListViewModelDidFailUnarchivingChats(viewModel: ChatListViewModel)
    func chatListViewModelDidSucceedUnarchivingChats(viewModel: ChatListViewModel)
}

protocol ChatListViewModel: class, ChatGroupedListViewModel {
    var delegate: ChatListViewModelDelegate? { get set }

    var titleForDeleteButton: String { get }

    func deleteConfirmationTitle(itemCount: Int) -> String
    func deleteConfirmationMessage(itemCount: Int) -> String
    func deleteConfirmationCancelTitle() -> String
    func deleteConfirmationSendButton() -> String

    func deleteChatsAtIndexes(indexes: [Int])
    func deleteButtonPressed()

    func conversationDataAtIndex(index: Int) -> ConversationCellData?

    func oldChatViewModelForIndex(index: Int) -> OldChatViewModel?
    func chatViewModelForIndex(index: Int) -> ChatViewModel?
}
