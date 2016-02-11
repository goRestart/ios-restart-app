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

    func chatListViewShouldUpdateNavigationBarButtons(chatListView: ChatListView)

    func chatListView(chatListView: ChatListView, showArchiveConfirmationWithTitle title: String, message: String,
        cancelText: String, actionText: String, action: () -> ())
    func chatListViewDidStartArchiving(chatListView: ChatListView)
    func chatListView(chatListView: ChatListView, didFinishArchivingWithMessage message: String?)
}

class ChatListView: BaseView, ChatListViewModelDelegate, UITableViewDataSource, UITableViewDelegate,
                    ScrollableToTop {
    // Constants
    private static let chatListCellId = "ConversationCell"
    private static let tabBarBottomInset: CGFloat = 44

    // UI
    @IBOutlet weak private var contentView: UIView!
    @IBOutlet weak var tableView: UITableView!
    var refreshControl: UIRefreshControl!
    @IBOutlet weak var toolbar: UIToolbar!
    var archiveButton: UIBarButtonItem = UIBarButtonItem()

    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!

    @IBOutlet weak var emptyView: LGEmptyView!

    // > Insets
    @IBOutlet weak var tableViewBottomInset: NSLayoutConstraint!
    @IBOutlet weak var activityIndicatorBottomInset: NSLayoutConstraint!
    @IBOutlet weak var emptyViewBottomInset: NSLayoutConstraint!

    var bottomInset: CGFloat = ChatListView.tabBarBottomInset {
        didSet {
            tableViewBottomInset.constant = bottomInset
            activityIndicatorBottomInset.constant = bottomInset/2
            emptyViewBottomInset.constant = bottomInset
            updateConstraints()
        }
    }

    // Data
    var viewModel: ChatListViewModel
    weak var delegate: ChatListViewDelegate?


    // MARK: - Lifecycle

    convenience init(viewModel: ChatListViewModel) {
        self.init(viewModel: viewModel, frame: CGRectZero)
    }

    init(viewModel: ChatListViewModel, frame: CGRect) {
        self.viewModel = viewModel
        super.init(viewModel: viewModel, frame: frame)

        viewModel.delegate = self
        setupUI()
        resetUI()
    }

    init?(viewModel: ChatListViewModel, coder aDecoder: NSCoder) {
        self.viewModel = viewModel
        super.init(viewModel: viewModel, coder: aDecoder)

        viewModel.delegate = self
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
            NSNotificationCenter.defaultCenter().addObserver(self, selector: "refreshConversations",
                name: PushManager.Notification.DidReceiveUserInteraction.rawValue, object: nil)
            NSNotificationCenter.defaultCenter().addObserver(self, selector: "clearChatList:",
                name: SessionManager.Notification.Logout.rawValue, object: nil)

            viewModel.retrieveFirstPage()
        }
    }


    // MARK: - Public Methods
    // MARK: > Chats

    func refreshConversations() {
        viewModel.reloadCurrentPagesWithCompletion(nil)
    }

    func clearChatList(notification: NSNotification) {
        viewModel.clearChatList()
        tableView.reloadData()
    }


    // MARK: > Edit

    func setEditing(editing: Bool, animated: Bool) {
        tableView.setEditing(editing, animated: animated)
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

    func chatListViewModelDidFailArchivingChat(viewModel: ChatListViewModel, atPosition: Int, ofTotal: Int) {
        // didFail and didSucceed both do the same by now, but kept separate for code consistency reasons
        archiveConversationsFinishedWithTotal(ofTotal)
    }

    func chatListViewModelDidSucceedArchivingChat(viewModel: ChatListViewModel, atPosition: Int, ofTotal: Int) {
        // didFail and didSucceed both do the same by now, but kept separate for code consistency reasons
        archiveConversationsFinishedWithTotal(ofTotal)
    }


    // MARK: - UITableViewDelegate & DataSource methods

    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.objectCount
    }

    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {

        let cell = tableView.dequeueReusableCellWithIdentifier(ChatListView.chatListCellId,
            forIndexPath: indexPath) as! ConversationCell

        cell.tag = indexPath.hash // used for cell reuse on "setupCellWithChat"
        if  let chat = viewModel.chatAtIndex(indexPath.row), let myUser = Core.myUserRepository.myUser {
            cell.setupCellWithChat(chat, myUser: myUser, indexPath: indexPath)
        }
        
        viewModel.setCurrentIndex(indexPath.row)

        return cell
    }

    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        if tableView.editing {
            archiveButton.enabled = tableView.indexPathsForSelectedRows?.count > 0
        } else {
            guard let chat = viewModel.chatAtIndex(indexPath.row), let chatViewModel = ChatViewModel(chat: chat) else {
                return
            }
            delegate?.chatListView(self, didSelectChatWithViewModel: chatViewModel)
        }
    }

    func tableView(tableView: UITableView, didDeselectRowAtIndexPath indexPath: NSIndexPath) {
        if tableView.editing {
            archiveButton.enabled = tableView.indexPathsForSelectedRows?.count > 0
        }
    }


    // MARK: - ScrollableToTop

    func scrollToTop() {
        guard let tableView = tableView else { return }
        tableView.setContentOffset(CGPointZero, animated: true)
    }

    
    // MARK: - Private Methods
    // MARK: > UI

    private func setupUI() {
        // Load the view, and add it as Subview
        NSBundle.mainBundle().loadNibNamed("ChatListView", owner: self, options: nil)
        contentView.frame = bounds
        contentView.autoresizingMask = [.FlexibleHeight, .FlexibleWidth]
        contentView.backgroundColor = StyleHelper.backgroundColor
        addSubview(contentView)

        // Empty view
        emptyView.backgroundColor = StyleHelper.backgroundColor

        // Table view
        let cellNib = UINib(nibName: ChatListView.chatListCellId, bundle: nil)
        tableView.registerNib(cellNib, forCellReuseIdentifier: ChatListView.chatListCellId)
        tableView.allowsMultipleSelectionDuringEditing = true
        tableView.rowHeight = ConversationCell.defaultHeight

        refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: "refreshConversations", forControlEvents: UIControlEvents.ValueChanged)
        tableView.addSubview(refreshControl)

        // Toolbar
        let flexibleSpace = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.FlexibleSpace, target: self,
            action: nil)
        archiveButton = UIBarButtonItem(title: LGLocalizedString.chatListArchive, style: .Plain, target: self,
            action: "archiveSelectedChats")
        archiveButton.enabled = false

        toolbar.setItems([flexibleSpace, archiveButton], animated: false)
        toolbar.tintColor = StyleHelper.primaryColor
        setToolbarHidden(true, animated: false)
    }

    private func resetUI() {
        if viewModel.activityIndicatorAnimating {
            activityIndicator.startAnimating()
        } else {
            activityIndicator.stopAnimating()
        }
        if let emptyViewModel = viewModel.emptyViewModel {
            emptyView.setupWithModel(emptyViewModel)
        }
        emptyView.hidden = viewModel.emptyViewHidden
        tableView.hidden = viewModel.tableViewHidden
        tableView.reloadData()
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

    private dynamic func archiveSelectedChats() {
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

    private func archiveConversationsFinishedWithTotal(totalChats: Int) {
        guard viewModel.archivedChats == totalChats else { return }

        var message: String? = nil
        if viewModel.failedArchivedChats > 0  {
            if totalChats > 1 {
                message = LGLocalizedString.chatListArchiveErrorMultiple
            } else {
                message = LGLocalizedString.chatListArchiveErrorOne
            }
        }

        viewModel.reloadCurrentPagesWithCompletion { [weak self] in
            guard let strongSelf = self else { return }
            strongSelf.delegate?.chatListView(strongSelf, didFinishArchivingWithMessage: message)
        }
    }
}
