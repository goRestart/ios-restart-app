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

class ChatListViewController: BaseViewController, ChatListViewModelDelegate, UITableViewDataSource, UITableViewDelegate,
ScrollableToTop {

    // UI
    // Constants
    private static let chatListCellId = "ConversationCell"
    private static let defaultErrorButtonHeight: CGFloat = 44

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
    var chatListStatus: ChatListStatus = .NoConversations

    // View Model
    var viewModel: ChatListViewModel

    // Edit mode toolbar
    @IBOutlet weak var editModeToolbar: UIToolbar!
    var archiveBarButton: UIBarButtonItem = UIBarButtonItem()


    // MARK: - Lifecycle

    convenience init() {
        self.init(viewModel: ChatListViewModel())
    }

    init(viewModel: ChatListViewModel) {
        self.viewModel = viewModel
        super.init(viewModel: viewModel, nibName: "ChatListViewController")

        self.viewModel.delegate = self

        hidesBottomBarWhenPushed = false
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    deinit {
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        setupUI()

        // register cell
        let cellNib = UINib(nibName: ChatListViewController.chatListCellId, bundle: nil)
        tableView.registerNib(cellNib, forCellReuseIdentifier: ChatListViewController.chatListCellId)

        // NSNotificationCenter, observe for user interactions (msgs & offers)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "refreshConversations",
            name: PushManager.Notification.DidReceiveUserInteraction.rawValue, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "clearChatList:",
            name: SessionManager.Notification.Logout.rawValue, object: nil)
    }


    // MARK: Public Methods

    func refreshConversations() {
        viewModel.updateConversations()
    }

    /**
    Clears the table view
    */
    func clearChatList(notification: NSNotification) {
        viewModel.clearChatList()
        tableView.reloadData()
    }


    // MARK: ChatListViewModelDelegate Methods

    func didStartRetrievingChatList(viewModel: ChatListViewModel, isFirstLoad: Bool) {
        if isFirstLoad {
            chatListStatus = .LoadingConversations
            resetUI()
        }
    }

    func didSucceedRetrievingChatList(viewModel: ChatListViewModel, nonEmptyChatList: Bool) {
        refreshControl.endRefreshing()
        chatListStatus = nonEmptyChatList ? .Conversations : .NoConversations
        resetUI()
    }

    func didFailRetrievingChatList(viewModel: ChatListViewModel, error: ErrorData) {
        refreshControl.endRefreshing()

        if error.isScammer {
            // logout the scammer!
            showAutoFadingOutMessageAlert(LGLocalizedString.logInErrorSendErrorGeneric) { (completion) -> Void in
                Core.sessionManager.logout()
            }
        } else {
            guard viewModel.chatCount <= 0 else { return }

            chatListStatus = .Error
            generateErrorViewWithErrorData(error)
            resetUI()
        }
    }

    func didFailArchivingChat(viewModel: ChatListViewModel, atPosition: Int, ofTotal: Int) {
        // didFail and didSucceed both do the same by now, but kept separate for code consistency reasons
        archiveConversationsFinishedWithTotal(ofTotal)
    }

    func didSucceedArchivingChat(viewModel: ChatListViewModel, atPosition: Int, ofTotal: Int) {
        // didFail and didSucceed both do the same by now, but kept separate for code consistency reasons
        archiveConversationsFinishedWithTotal(ofTotal)
    }


    // MARK: Button actions

    @IBAction func searchProducts(sender: AnyObject) {
        guard let tabBarCtl = tabBarController as? TabBarController else { return }
        tabBarCtl.switchToTab(.Home)
    }

    @IBAction func sellProducts(sender: AnyObject) {
        SellProductControllerFactory.presentSellProductOn(viewController: self)
    }


    // MARK: UITableViewDelegate & DataSource methods

    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.chatCount
    }

    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {

        let cell = tableView.dequeueReusableCellWithIdentifier(ChatListViewController.chatListCellId,
            forIndexPath: indexPath) as! ConversationCell

        cell.tag = indexPath.hash // used for cell reuse on "setupCellWithChat"
        if  let chat = viewModel.chatAtIndex(indexPath.row), let myUser = Core.myUserRepository.myUser {
            cell.setupCellWithChat(chat, myUser: myUser, indexPath: indexPath)
        }

        return cell
    }

    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        if tableView.editing {
            archiveBarButton.enabled = tableView.indexPathsForSelectedRows?.count > 0
        } else {
            guard let chat = viewModel.chatAtIndex(indexPath.row), let chatViewModel = ChatViewModel(chat: chat) else {
                return
            }
            navigationController?.pushViewController(ChatViewController(viewModel: chatViewModel), animated: true)
        }
    }

    func tableView(tableView: UITableView, didDeselectRowAtIndexPath indexPath: NSIndexPath) {
        if tableView.editing {
            archiveBarButton.enabled = tableView.indexPathsForSelectedRows?.count > 0
        }
    }

    override func setEditing(editing: Bool, animated: Bool) {
        super.setEditing(editing, animated: animated)
        tableView.setEditing(editing, animated: animated)

        tabBarController?.setTabBarHidden(editing, animated: true) { [weak self] completed in
            self?.setToolbarHidden(!editing, animated: true)
        }

        if editing {
            // hide tabbar and show toolbar
            tabBarController?.setTabBarHidden(editing, animated: true) { [weak self] completed in
                self?.setToolbarHidden(!editing, animated: true)
            }

        } else {
            // hide toolbar and show tabbar
            self.setToolbarHidden(!editing, animated: true) { completed in
                tabBarController?.setTabBarHidden(editing, animated: true)
            }
        }
        archiveBarButton.enabled = tableView.indexPathsForSelectedRows?.count > 0
    }

    func archiveChats() {
        showArchiveAlert()
    }


    // MARK: - ScrollableToTop

    func scrollToTop() {
        tableView.setContentOffset(CGPointZero, animated: true)
    }

    // MARK: Private Methods

    private func setupUI() {
        // appearance
        setLetGoNavigationBarStyle(LGLocalizedString.chatListTitle)

        // ⚠️ TODO: uncomment lines when Archive Chats functionality has to be enabled again
//        self.navigationItem.rightBarButtonItem = editButtonItem()
        self.tableView.allowsMultipleSelectionDuringEditing = true

        // setup toolbar for edit mode
        let flexibleSpace = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.FlexibleSpace, target: self,
            action: nil)
        self.archiveBarButton = UIBarButtonItem(title: LGLocalizedString.chatListArchive, style: .Plain, target: self,
            action: "archiveChats")
        self.archiveBarButton.enabled = false

        self.editModeToolbar.setItems([flexibleSpace, self.archiveBarButton], animated: false)
        self.editModeToolbar.tintColor = StyleHelper.primaryColor
        self.setToolbarHidden(true, animated: false)

        // internationalization
        noConversationsYet.text = LGLocalizedString.chatListEmptyLabel
        startSellingOrBuyingLabel.text = LGLocalizedString.chatListStartSellingOrBuyingLabel

        // add a pull to refresh control
        refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: "refreshConversations", forControlEvents: UIControlEvents.ValueChanged)
        tableView.addSubview(refreshControl)

        // Error View
        errorButtonHeightConstraint.constant = ChatListViewController.defaultErrorButtonHeight
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

        archiveBarButton.enabled = tableView.indexPathsForSelectedRows?.count > 0
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
            errorButtonHeightConstraint.constant = ChatListViewController.defaultErrorButtonHeight
        } else {
            errorButtonHeightConstraint.constant = 0
        }
        errorView.updateConstraintsIfNeeded()
    }

    private func setToolbarHidden(hidden: Bool, animated: Bool, completion: ((Bool) -> (Void))? = nil) {

        // bail if the current state matches the desired state
        if ((editModeToolbar.frame.origin.y >= CGRectGetMaxY(self.view.frame)) == hidden) { return }

        // get a frame calculation ready
        let frame = editModeToolbar.frame
        let height = frame.size.height
        let offsetY = (hidden ? height : -height)

        // zero duration means no animation
        let duration : NSTimeInterval = (animated ? NSTimeInterval(UINavigationControllerHideShowBarDuration) : 0.0)

        //  animate the tabBar
        UIView.animateWithDuration(duration, animations: { [weak self] in
            self?.editModeToolbar.frame = CGRectOffset(frame, 0, offsetY)
            self?.view.layoutIfNeeded()
            }, completion: completion)
    }

    private func showArchiveAlert() {

        let alert = UIAlertController(title: LGLocalizedString.chatListArchiveAlertTitle,
            message: LGLocalizedString.chatListArchiveAlertText,
            preferredStyle: .Alert)

        let noAction = UIAlertAction(title: LGLocalizedString.commonCancel, style: .Cancel, handler: nil)
        let yesAction = UIAlertAction(title: LGLocalizedString.chatListArchive, style: .Default,
            handler: { [weak self] (_) -> Void in
                if let strongSelf = self, indexArray = strongSelf.tableView.indexPathsForSelectedRows {
                    strongSelf.showLoadingMessageAlert()
                    strongSelf.viewModel.archiveChatsAtIndexes(indexArray)
                }
            })
        alert.addAction(noAction)
        alert.addAction(yesAction)

        presentViewController(alert, animated: true, completion: nil)
    }

    private func archiveConversationsFinishedWithTotal(totalChats: Int) {

        guard viewModel.archivedChats == totalChats else { return }

        var message: String
        var completion: (() -> ())? = nil

        if viewModel.failedArchivedChats > 0  {
            if totalChats > 1 {
                message = LGLocalizedString.chatListArchiveErrorMultiple
            } else {
                message = LGLocalizedString.chatListArchiveErrorOne
            }
            completion = { [weak self] in
                self?.showAutoFadingOutMessageAlert(message)
            }
        }
        
        dismissLoadingMessageAlert(completion)
        refreshConversations()
    }
}