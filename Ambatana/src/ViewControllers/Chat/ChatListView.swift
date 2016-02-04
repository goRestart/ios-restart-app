//
//  ChatListViewController.swift
//  LetGo
//
//  Created by Dídac on 21/12/15.
//  Copyright © 2015 Ambatana. All rights reserved.
//

import Foundation
import LGCoreKit

enum ChatListStatus {
    case NoConversations
    case LoadingConversations
    case Conversations
    case Error
}

protocol ChatListViewDelegate: class {
    func chatListView(chatListView: ChatListView, didSelectChatWithViewModel chatViewModel: ChatViewModel)

    func chatListView(chatListView: ChatListView, didUpdateStatus status: ChatListStatus)

    func chatListView(chatListView: ChatListView, showArchiveConfirmationWithAction action: () -> ())
    func chatListViewDidStartArchiving(chatListView: ChatListView)
    func chatListView(chatListView: ChatListView, didFinishArchivingWithMessage message: String?)
}

class ChatListView: BaseView, ChatListViewModelDelegate, UITableViewDataSource, UITableViewDelegate,
                    ScrollableToTop {

    // UI
    // Constants
    private static let chatListCellId = "ConversationCell"
    private static let defaultErrorButtonHeight: CGFloat = 44

    @IBOutlet weak private var contentView: UIView!

    // no conversations interface
    @IBOutlet weak var noConversationsView: UIView!
    @IBOutlet weak var noConversationsYet: UILabel!
    @IBOutlet weak var startSellingOrBuyingLabel: UILabel!
    @IBOutlet weak var searchButton: UIButton!
    @IBOutlet weak var sellButton: UIButton!
    @IBOutlet weak var separatorView: UIView!
    @IBOutlet weak var messageImageView: UIImageView!

    // table of conversations
    @IBOutlet weak var tableView: UITableView!

    // loading conversations
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    var refreshControl: UIRefreshControl!

    // error loading conversations
    @IBOutlet weak var errorView: UIView!
    @IBOutlet weak var errorContentView: UIView!
    @IBOutlet weak var errorImageView: UIImageView!
    @IBOutlet weak var errorImageViewHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var errorTitleLabel: UILabel!
    @IBOutlet weak var errorBodyLabel: UILabel!
    @IBOutlet weak var errorButton: UIButton!
    @IBOutlet weak var errorButtonHeightConstraint: NSLayoutConstraint!

    // View Status
    var chatListStatus: ChatListStatus = .NoConversations {
        didSet {
            delegate?.chatListView(self, didUpdateStatus: chatListStatus)
        }
    }

    // View Model
    var viewModel: ChatListViewModel

    // Edit mode toolbar
    @IBOutlet weak var toolbar: UIToolbar!
    var archiveButton: UIBarButtonItem = UIBarButtonItem()

    // Delegate
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
    }

    init?(viewModel: ChatListViewModel, coder aDecoder: NSCoder) {
        self.viewModel = viewModel
        super.init(viewModel: viewModel, coder: aDecoder)

        viewModel.delegate = self
        setupUI()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    deinit {
        NSNotificationCenter.defaultCenter().removeObserver(self,
            name: PushManager.Notification.DidReceiveUserInteraction.rawValue, object: nil)
        NSNotificationCenter.defaultCenter().removeObserver(self,
            name: SessionManager.Notification.Logout.rawValue, object: nil)
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

    func refreshConversations() {
        viewModel.reloadCurrentPages()
    }

    /**
    Clears the table view
    */
    func clearChatList(notification: NSNotification) {
        viewModel.clearChatList()
        tableView.reloadData()
    }

    func setToolbarHidden(hidden: Bool, animated: Bool, completion: ((Bool) -> (Void))? = nil) {

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


    // MARK: - ChatListViewModelDelegate Methods

    func didStartRetrievingChatList(viewModel: ChatListViewModel, isFirstLoad: Bool, page: Int) {
        if isFirstLoad {
            chatListStatus = .LoadingConversations
            resetUI()
        }
    }

    func didSucceedRetrievingChatList(viewModel: ChatListViewModel, page: Int, nonEmptyChatList: Bool) {
        refreshControl.endRefreshing()
        chatListStatus = nonEmptyChatList ? .Conversations : .NoConversations
        resetUI()
    }

    func didFailRetrievingChatList(viewModel: ChatListViewModel, page: Int, error: ErrorData) {
        refreshControl.endRefreshing()

        guard viewModel.objectCount == 0 else { return }

        chatListStatus = .Error
        generateErrorViewWithErrorData(error)
        resetUI()
    }

    func didFailArchivingChat(viewModel: ChatListViewModel, atPosition: Int, ofTotal: Int) {
        // didFail and didSucceed both do the same by now, but kept separate for code consistency reasons
        archiveConversationsFinishedWithTotal(ofTotal)
    }

    func didSucceedArchivingChat(viewModel: ChatListViewModel, atPosition: Int, ofTotal: Int) {
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

    func setEditing(editing: Bool, animated: Bool) {
        tableView.setEditing(editing, animated: animated)
        archiveButton.enabled = tableView.indexPathsForSelectedRows?.count > 0
    }

    private dynamic func archiveSelectedChats() {
        delegate?.chatListView(self, showArchiveConfirmationWithAction: { [weak self] in
            guard let strongSelf = self else { return }
            guard let delegate = strongSelf.delegate else { return }
            guard let indexes = strongSelf.tableView.indexPathsForSelectedRows else { return }

            delegate.chatListViewDidStartArchiving(strongSelf)
            strongSelf.viewModel.archiveChatsAtIndexes(indexes)
        })
    }


    // MARK: - ScrollableToTop

    func scrollToTop() {
        guard let tableView = tableView else { return }
        tableView.setContentOffset(CGPointZero, animated: true)
    }

    
    // MARK: Private Methods

    private func setupUI() {
        // Load the view, and add it as Subview
        NSBundle.mainBundle().loadNibNamed("ChatListView", owner: self, options: nil)
        contentView.frame = bounds
        contentView.autoresizingMask = [.FlexibleHeight, .FlexibleWidth]
        addSubview(contentView)

        // register cell
        let cellNib = UINib(nibName: ChatListView.chatListCellId, bundle: nil)
        tableView.registerNib(cellNib, forCellReuseIdentifier: ChatListView.chatListCellId)
        tableView.allowsMultipleSelectionDuringEditing = true
        tableView.rowHeight = ConversationCell.defaultHeight
        
        // setup toolbar for edit mode
        let flexibleSpace = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.FlexibleSpace, target: self,
            action: nil)
        archiveButton = UIBarButtonItem(title: LGLocalizedString.chatListArchive, style: .Plain, target: self,
            action: "archiveSelectedChats")
        archiveButton.enabled = false

        toolbar.setItems([flexibleSpace, archiveButton], animated: false)
        toolbar.tintColor = StyleHelper.primaryColor
        setToolbarHidden(true, animated: false)

        // internationalization
        noConversationsYet.text = LGLocalizedString.chatListEmptyLabel
        startSellingOrBuyingLabel.text = LGLocalizedString.chatListStartSellingOrBuyingLabel

        // add a pull to refresh control
        refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: "refreshConversations", forControlEvents: UIControlEvents.ValueChanged)
        tableView.addSubview(refreshControl)

        // Error View
        errorButtonHeightConstraint.constant = ChatListView.defaultErrorButtonHeight
        errorButton.layer.cornerRadius = StyleHelper.defaultCornerRadius
        errorButton.setBackgroundImage(errorButton.backgroundColor?.imageWithSize(CGSize(width: 1, height: 1)),
            forState: .Normal)
        errorButton.addTarget(self, action: "refreshConversations", forControlEvents: .TouchUpInside)
    }

    private func resetUI() {
        if chatListStatus == .LoadingConversations {
            activityIndicator.startAnimating()
        } else {
            activityIndicator.stopAnimating()
        }
        activityIndicator.hidden = chatListStatus != .LoadingConversations

        noConversationsView.hidden = chatListStatus != .NoConversations

        tableView.hidden = chatListStatus != .Conversations
        if chatListStatus == .Conversations { tableView.reloadData() }

        errorView.hidden = chatListStatus != .Error

        archiveButton.enabled = tableView.indexPathsForSelectedRows?.count > 0
    }

    private func generateErrorViewWithErrorData(errorData: ErrorData) {
        errorView.backgroundColor = errorData.errBgColor
        errorContentView.layer.borderColor = errorData.errBorderColor?.CGColor
        errorContentView.layer.borderWidth = errorData.errBorderColor != nil ? 0.5 : 0
        errorContentView.layer.cornerRadius = StyleHelper.defaultCornerRadius

        errorImageView.image = errorData.errImage
        // If there's no image then hide it
        if let actualErrImage = errorData.errImage {
            errorImageViewHeightConstraint.constant = actualErrImage.size.height
        } else {
            errorImageViewHeightConstraint.constant = 0
        }
        errorTitleLabel.text = errorData.errTitle
        errorBodyLabel.text = errorData.errBody
        errorButton.setTitle(errorData.errButTitle, forState: .Normal)
        // If there's no button title or action then hide it
        if errorData.errButTitle != nil {
            errorButtonHeightConstraint.constant = ChatListView.defaultErrorButtonHeight
        } else {
            errorButtonHeightConstraint.constant = 0
        }
        errorView.updateConstraintsIfNeeded()
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

        delegate?.chatListView(self, didFinishArchivingWithMessage: message)
        refreshConversations()
    }
}
