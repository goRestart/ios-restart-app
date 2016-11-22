//
//  ChatListViewController.swift
//  LetGo
//
//  Created by Dídac on 21/12/15.
//  Copyright © 2015 Ambatana. All rights reserved.
//

import Foundation
import LGCoreKit

protocol ChatListViewDelegate: class {
    func chatListView(chatListView: ChatListView, showDeleteConfirmationWithTitle title: String, message: String,
        cancelText: String, actionText: String, action: () -> ())
    func chatListViewDidStartArchiving(chatListView: ChatListView)
    func chatListView(chatListView: ChatListView, didFinishArchivingWithMessage message: String?)
    func chatListView(chatListView: ChatListView, didFinishUnarchivingWithMessage message: String?)
}

class ChatListView: ChatGroupedListView, ChatListViewModelDelegate {
    // Constants
    private static let tabBarBottomInset: CGFloat = 44

    // Data
    var viewModel: ChatListViewModel
    weak var delegate: ChatListViewDelegate?


    // MARK: - Lifecycle

    convenience init<T: BaseViewModel where T: ChatListViewModel>(viewModel: T) {
        self.init(viewModel: viewModel, sessionManager: Core.sessionManager, frame: CGRect.zero)
    }

    override init<T: BaseViewModel where T: ChatListViewModel>(viewModel: T, sessionManager: SessionManager, frame: CGRect) {
        self.viewModel = viewModel
        super.init(viewModel: viewModel, sessionManager: sessionManager, frame: frame)

        viewModel.delegate = self
    }

    override init?<T: BaseViewModel where T: ChatListViewModel>(viewModel: T, sessionManager: SessionManager, coder aDecoder: NSCoder) {
        self.viewModel = viewModel
        super.init(viewModel: viewModel, sessionManager: sessionManager, coder: aDecoder)

        viewModel.delegate = self
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    deinit {
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }

    override func setupUI() {
        super.setupUI()

        let cellNib = UINib(nibName: "ConversationCell", bundle: nil)
        tableView.registerNib(cellNib, forCellReuseIdentifier: ConversationCell.reusableID)
        tableView.allowsMultipleSelectionDuringEditing = true
        tableView.rowHeight = ConversationCell.defaultHeight

        footerButton.setTitle(viewModel.titleForDeleteButton, forState: .Normal)
        footerButton.addTarget(self, action: #selector(ChatListView.deleteButtonPressed), forControlEvents: .TouchUpInside)
    }


    // MARK: - ChatListViewModelDelegate Methods

    func vmDeleteSelectedChats() {
        guard let indexPaths = tableView.indexPathsForSelectedRows else { return }
        guard let indexes: [Int] = indexPaths.map({ $0.row }) else { return }
        guard !indexes.isEmpty else { return }

        let title = viewModel.deleteConfirmationTitle(indexPaths.count)
        let message = viewModel.deleteConfirmationMessage(indexPaths.count)
        let cancelText = viewModel.deleteConfirmationCancelTitle()
        let actionText = viewModel.deleteConfirmationSendButton()

        delegate?.chatListView(self, showDeleteConfirmationWithTitle: title, message: message, cancelText: cancelText,
            actionText: actionText, action: { [weak self] in
                guard let strongSelf = self else { return }
                guard let delegate = strongSelf.delegate else { return }

                delegate.chatListViewDidStartArchiving(strongSelf)
                strongSelf.viewModel.deleteChatsAtIndexes(indexes)
            })
    }

    func chatListViewModelDidFailArchivingChats(viewModel: ChatListViewModel) {
        viewModel.reloadCurrentPagesWithCompletion { [weak self] in
            guard let strongSelf = self else { return }
            strongSelf.delegate?.chatListView(strongSelf,
                didFinishArchivingWithMessage: LGLocalizedString.chatListArchiveErrorMultiple)
        }
    }

    func chatListViewModelDidSucceedArchivingChats(viewModel: ChatListViewModel) {
        viewModel.reloadCurrentPagesWithCompletion { [weak self] in
            guard let strongSelf = self else { return }
            strongSelf.delegate?.chatListView(strongSelf, didFinishArchivingWithMessage: nil)
        }
    }

    func chatListViewModelDidFailUnarchivingChats(viewModel: ChatListViewModel) {
        viewModel.reloadCurrentPagesWithCompletion { [weak self] in
            guard let strongSelf = self else { return }
            strongSelf.delegate?.chatListView(strongSelf, didFinishUnarchivingWithMessage: LGLocalizedString.chatListUnarchiveErrorMultiple)
        }
    }

    func chatListViewModelDidSucceedUnarchivingChats(viewModel: ChatListViewModel) {
        viewModel.reloadCurrentPagesWithCompletion { [weak self] in
            guard let strongSelf = self else { return }
            strongSelf.delegate?.chatListView(strongSelf, didFinishUnarchivingWithMessage: nil)
        }
    }


    // MARK: - UITableViewDataSource

    override func cellForRowAtIndexPath(indexPath: NSIndexPath) -> UITableViewCell {
        let cell = super.cellForRowAtIndexPath(indexPath)

        guard let chatData = viewModel.conversationDataAtIndex(indexPath.row) else { return cell }
        guard let chatCell = tableView.dequeueReusableCellWithIdentifier(ConversationCell.reusableID,
            forIndexPath: indexPath) as? ConversationCell else { return cell }

        chatCell.tag = indexPath.hash // used for cell reuse on "setupCellWithData"
        chatCell.setupCellWithData(chatData, indexPath: indexPath)
        return chatCell
    }


    // MARK: - UITableViewDelegate

    override func didSelectRowAtIndex(index: Int, editing: Bool) {
        super.didSelectRowAtIndex(index, editing: editing)

        guard !editing else { return }
        viewModel.conversationSelectedAtIndex(index)
    }


    // MARK: - Private Methods

    dynamic func deleteButtonPressed() {
        viewModel.deleteButtonPressed()
    }
}
