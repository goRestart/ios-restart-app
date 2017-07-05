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
    func chatListView(_ chatListView: ChatListView, showDeleteConfirmationWithTitle title: String, message: String,
                      cancelText: String, actionText: String, action: @escaping () -> ())
    func chatListViewDidStartArchiving(_ chatListView: ChatListView)
    func chatListView(_ chatListView: ChatListView, didFinishArchivingWithMessage message: String?)
    func chatListView(_ chatListView: ChatListView, didFinishUnarchivingWithMessage message: String?)
}

class ChatListView: ChatGroupedListView, ChatListViewModelDelegate {

    // Constants
    private static let tabBarBottomInset: CGFloat = 44

    // Data
    fileprivate var shouldReloadTableViewWhenActive = false
    var viewModel: ChatListViewModel
    weak var delegate: ChatListViewDelegate?


    // MARK: - Lifecycle

    convenience init<T: BaseViewModel>(viewModel: T) where T: ChatListViewModel {
        self.init(viewModel: viewModel, sessionManager: Core.sessionManager, frame: CGRect.zero)
    }

    override init<T: BaseViewModel>(viewModel: T, sessionManager: SessionManager, frame: CGRect) where T: ChatListViewModel {
        self.viewModel = viewModel
        super.init(viewModel: viewModel, sessionManager: sessionManager, frame: frame)

        viewModel.delegate = self
    }

    override init?<T: BaseViewModel>(viewModel: T, sessionManager: SessionManager, coder aDecoder: NSCoder) where T: ChatListViewModel {
        self.viewModel = viewModel
        super.init(viewModel: viewModel, sessionManager: sessionManager, coder: aDecoder)

        viewModel.delegate = self
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func didBecomeActive(_ firstTime: Bool) {
        super.didBecomeActive(firstTime)
        if shouldReloadTableViewWhenActive {
            shouldReloadTableViewWhenActive = false
            tableView.reloadData()
        }
    }

    override func setupUI() {
        super.setupUI()

        let cellNib = UINib(nibName: "ConversationCell", bundle: nil)
        tableView.register(cellNib, forCellReuseIdentifier: ConversationCell.reusableID)
        tableView.allowsMultipleSelectionDuringEditing = true
        tableView.rowHeight = ConversationCell.defaultHeight

        footerButton.setTitle(viewModel.titleForDeleteButton, for: .normal)
        footerButton.addTarget(self, action: #selector(ChatListView.deleteButtonPressed), for: .touchUpInside)
    }


    // MARK: - ChatListViewModelDelegate Methods

    func vmDeleteSelectedChats() {
        guard let indexPaths = tableView.indexPathsForSelectedRows else { return }
        let indexes: [Int] = indexPaths.map({ $0.row })
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

    func chatListViewModelDidFailArchivingChats(_ viewModel: ChatListViewModel) {
        viewModel.refresh { [weak self] in
            guard let strongSelf = self else { return }
            strongSelf.delegate?.chatListView(strongSelf,
                didFinishArchivingWithMessage: LGLocalizedString.chatListArchiveErrorMultiple)
        }
    }

    func chatListViewModelDidSucceedArchivingChats(_ viewModel: ChatListViewModel) {
        viewModel.refresh { [weak self] in
            guard let strongSelf = self else { return }
            strongSelf.delegate?.chatListView(strongSelf, didFinishArchivingWithMessage: nil)
        }
    }

    func chatListViewModelDidFailUnarchivingChats(_ viewModel: ChatListViewModel) {
        viewModel.refresh { [weak self] in
            guard let strongSelf = self else { return }
            strongSelf.delegate?.chatListView(strongSelf, didFinishUnarchivingWithMessage: LGLocalizedString.chatListUnarchiveErrorMultiple)
        }
    }

    func chatListViewModelDidSucceedUnarchivingChats(_ viewModel: ChatListViewModel) {
        viewModel.refresh { [weak self] in
            guard let strongSelf = self else { return }
            strongSelf.delegate?.chatListView(strongSelf, didFinishUnarchivingWithMessage: nil)
        }
    }
    
    func chatListViewModelShouldReloadData() {
        if active {
            tableView.reloadData()
        } else {
            shouldReloadTableViewWhenActive = true
        }
    }

    
    // MARK: - UITableViewDataSource

    override func cellForRowAtIndexPath(_ indexPath: IndexPath) -> UITableViewCell {
        let cell = super.cellForRowAtIndexPath(indexPath)

        guard let chatData = viewModel.conversationDataAtIndex(indexPath.row) else { return cell }
        guard let chatCell = tableView.dequeueReusableCell(withIdentifier: ConversationCell.reusableID,
            for: indexPath) as? ConversationCell else { return cell }

        chatCell.tag = (indexPath as NSIndexPath).hash // used for cell reuse on "setupCellWithData"
        chatCell.setupCellWithData(chatData, indexPath: indexPath)
        return chatCell
    }


    // MARK: - UITableViewDelegate

    override func didSelectRowAtIndex(_ index: Int, editing: Bool) {
        super.didSelectRowAtIndex(index, editing: editing)

        guard !editing else { return }
        viewModel.conversationSelectedAtIndex(index)
    }


    // MARK: - Private Methods

    dynamic func deleteButtonPressed() {
        viewModel.deleteButtonPressed()
    }
}
