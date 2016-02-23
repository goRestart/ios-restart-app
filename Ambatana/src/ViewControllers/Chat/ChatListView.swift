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
    func chatListView(chatListView: ChatListView, didSelectChatWithViewModel chatViewModel: ChatViewModel)

    func chatListView(chatListView: ChatListView, showArchiveConfirmationWithTitle title: String, message: String,
        cancelText: String, actionText: String, action: () -> ())
    func chatListViewDidStartArchiving(chatListView: ChatListView)
    func chatListView(chatListView: ChatListView, didFinishArchivingWithMessage message: String?)
    func chatListView(chatListView: ChatListView, didFinishUnarchivingWithMessage message: String?)
}

class ChatListView: ChatGroupedListView<Chat>, ChatListViewModelDelegate {
    // Constants
    private static let chatListCellId = "ConversationCell"
    private static let tabBarBottomInset: CGFloat = 44

    // UI
    var archiveButton: UIBarButtonItem = UIBarButtonItem()

    // Data
    var viewModel: ChatListViewModel
    weak var chatListViewDelegate: ChatListViewDelegate?


    // MARK: - Lifecycle

    convenience init(viewModel: ChatListViewModel) {
        self.init(viewModel: viewModel, frame: CGRectZero)
    }

    init(viewModel: ChatListViewModel, frame: CGRect) {
        self.viewModel = viewModel
        super.init(viewModel: viewModel, frame: frame)

        viewModel.chatListViewModelDelegate = self
        setupUI()
        resetUI()
    }

    init?(viewModel: ChatListViewModel, coder aDecoder: NSCoder) {
        self.viewModel = viewModel
        super.init(viewModel: viewModel, coder: aDecoder)

        viewModel.chatListViewModelDelegate = self
        setupUI()
        resetUI()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    deinit {
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }

    internal override func didBecomeActive(firstTime: Bool) {
        super.didBecomeActive(firstTime)

        if firstTime {
            NSNotificationCenter.defaultCenter().addObserver(self, selector: "refresh",
                name: PushManager.Notification.DidReceiveUserInteraction.rawValue, object: nil)
        }
    }


    // MARK: > Edit

    override func setEditing(editing: Bool, animated: Bool) {
        super.setEditing(editing, animated: animated)
        archiveButton.enabled = tableView.indexPathsForSelectedRows?.count > 0
        setToolbarHidden(!editing, animated: animated)
        bottomInset = editing ? toolbar.frame.height : ChatListView.tabBarBottomInset
    }


    // MARK: - ChatListViewModelDelegate Methods

    func chatListViewModelShouldUpdateStatus(viewModel: ChatListViewModel) {
        delegate?.chatListViewShouldUpdateNavigationBarButtons(self)
        resetUI()
    }

    func chatListViewModel(viewModel: ChatListViewModel, setEditing editing: Bool, animated: Bool) {
        setEditing(editing, animated: animated)
    }

    func chatListViewModelDidStartRetrievingChatList(viewModel: ChatListViewModel) {

    }

    func chatListViewModelDidSucceedRetrievingChatList(viewModel: ChatListViewModel, page: Int) {
        refreshControl.endRefreshing()
    }

    func chatListViewModelDidFailRetrievingChatList(viewModel: ChatListViewModel, page: Int) {
        refreshControl.endRefreshing()
    }

    func vmArchiveSelectedChats() {
        let title = viewModel.archiveConfirmationTitle
        let message = viewModel.archiveConfirmationMessage
        let cancelText = viewModel.archiveConfirmationCancelTitle
        let actionText = viewModel.archiveConfirmationArchiveTitle

        delegate?.chatListView(self, showArchiveConfirmationWithTitle: title, message: message, cancelText: cancelText,
            actionText: actionText, action: { [weak self] in
                guard let strongSelf = self else { return }
                guard let delegate = strongSelf.delegate else { return }
                guard let indexPaths = strongSelf.tableView.indexPathsForSelectedRows else { return }

                delegate.chatListViewDidStartArchiving(strongSelf)

                let indexes: [Int] = indexPaths.map({ $0.row })
                strongSelf.viewModel.archiveChatsAtIndexes(indexes)
            })
    }

    func vmUnarchiveSelectedChats() {
        guard let delegate = delegate else { return }
        guard let indexPaths = tableView.indexPathsForSelectedRows else { return }

        delegate.chatListViewDidStartArchiving(self)

        let indexes: [Int] = indexPaths.map({ $0.row })
        viewModel.unarchiveChatsAtIndexes(indexes)
    }

    func chatListViewModelDidFailArchivingChats(viewModel: ChatListViewModel) {
        // didFail and didSucceed both do the same by now, but kept separate for code consistency reasons
        viewModel.reloadCurrentPagesWithCompletion { [weak self] in
            guard let strongSelf = self else { return }
            strongSelf.delegate?.chatListView(strongSelf,
                didFinishArchivingWithMessage: LGLocalizedString.chatListArchiveErrorMultiple)
        }
    }

    func chatListViewModelDidSucceedArchivingChats(viewModel: ChatListViewModel) {
        // didFail and didSucceed both do the same by now, but kept separate for code consistency reasons
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


    // MARK: - UITableViewDelegate & DataSource methods

    override func cellForRowAtIndexPath(indexPath: NSIndexPath) -> UITableViewCell {
        let cell = super.cellForRowAtIndexPath(indexPath)

        guard let chat = viewModel.objectAtIndex(indexPath.row) else { return cell }
        guard let myUser = Core.myUserRepository.myUser else { return cell }
        guard let chatCell = tableView.dequeueReusableCellWithIdentifier(ChatListView.chatListCellId,
            forIndexPath: indexPath) as? ConversationCell else { return cell }

        chatCell.tag = indexPath.hash // used for cell reuse on "setupCellWithChat"
        chatCell.setupCellWithChat(chat, myUser: myUser, indexPath: indexPath)
        return chatCell
    }

    override func didSelectRowAtIndex(index: Int, editing: Bool) {
        super.didSelectRowAtIndex(index, editing: editing)

        if editing {
            archiveButton.enabled = tableView.indexPathsForSelectedRows?.count > 0
        } else {
            guard let chat = viewModel.objectAtIndex(index), let chatViewModel = ChatViewModel(chat: chat) else {
                return
            }
            chatListViewDelegate?.chatListView(self, didSelectChatWithViewModel: chatViewModel)
        }
    }

    override func didDeselectRowAtIndex(index: Int, editing: Bool) {
        super.didDeselectRowAtIndex(index, editing: editing)
        if editing {
            archiveButton.enabled = tableView.indexPathsForSelectedRows?.count > 0
        }
    }

    // MARK: - Private Methods
    // MARK: > UI

    override func setupUI() {
        super.setupUI()

        // Table view
        let cellNib = UINib(nibName: ChatListView.chatListCellId, bundle: nil)
        tableView.registerNib(cellNib, forCellReuseIdentifier: ChatListView.chatListCellId)
        tableView.allowsMultipleSelectionDuringEditing = true
        tableView.rowHeight = ConversationCell.defaultHeight

        // Toolbar
        let flexibleSpace = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.FlexibleSpace, target: self,
            action: nil)
        archiveButton = UIBarButtonItem(title: viewModel.titleForArchiveButton, style: .Plain, target: self,
            action: "archiveButtonPressed")
        archiveButton.enabled = false

        toolbar.setItems([flexibleSpace, archiveButton], animated: false)
    }

    override func resetUI() {
        super.resetUI()
    }

    private func setToolbarHidden(hidden: Bool, animated: Bool, completion: ((Bool) -> (Void))? = nil) {

        // bail if the current state matches the desired state
        if ((toolbar.frame.origin.y >= CGRectGetMaxY(self.frame)) == hidden) { return }

        // get a frame calculation ready
        let frame = toolbar.frame
        let height = frame.size.height
        let offsetY = (hidden ? height : -height)

        // zero duration means no animation
        let duration : NSTimeInterval = (animated ? NSTimeInterval(UINavigationControllerHideShowBarDuration) : 0.0)

        //  animate the tabBar
        UIView.animateWithDuration(duration, animations: { [weak self] in
            self?.toolbar.frame = CGRectOffset(frame, 0, offsetY)
            self?.layoutIfNeeded()
        }, completion: completion)
    }


    // MARK: > Archive

    dynamic func archiveButtonPressed() {
        viewModel.archiveButtonPressed()
    }
}
