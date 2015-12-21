//
//  ChatListViewController.swift
//  LetGo
//
//  Created by Dídac on 21/12/15.
//  Copyright © 2015 Ambatana. All rights reserved.
//

import Foundation
import LGCoreKit

enum ChatListStatus: Int {
    case NoConversations
    case LoadingConversations
    case Conversations
}

class ChatListViewController: BaseViewController, ChatListViewModelDelegate, UITableViewDataSource, UITableViewDelegate {

    // UI
    // > no conversations interface
    @IBOutlet weak var noConversationsYet: UILabel!
    @IBOutlet weak var startSellingOrBuyingLabel: UILabel!
    @IBOutlet weak var searchButton: UIButton!
    @IBOutlet weak var sellButton: UIButton!
    @IBOutlet weak var separatorView: UIView!
    @IBOutlet weak var messageImageView: UIImageView!

    // > table of conversations
    @IBOutlet weak var tableView: UITableView!

    // > loading conversations
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    var refreshControl: UIRefreshControl!

    // > View Status
    var chatListStatus: ChatListStatus = .NoConversations
    // > View Model
    var viewModel: ChatListViewModel!


    // MARK: - Lifecycle

    convenience init() {
        self.init(viewModel: ChatListViewModel())
    }

    init(viewModel: ChatListViewModel) {
        super.init(viewModel: viewModel, nibName: "ChatListViewController")

        self.viewModel = viewModel
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
        let cellNib = UINib(nibName: "ConversationCell", bundle: nil)
        tableView.registerNib(cellNib, forCellReuseIdentifier: "ConversationCell")

        // NSNotificationCenter, observe for user interactions (msgs & offers)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "didReceiveUserInteraction:",
            name: PushManager.Notification.DidReceiveUserInteraction.rawValue, object: nil)
    }

    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)

        // Update conversations (always forced, so the badges are updated)
        tableView.userInteractionEnabled = false
        updateConversations()
    }

    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)

        NSNotificationCenter.defaultCenter().removeObserver(self,
            name: UIApplicationWillEnterForegroundNotification, object: nil)
    }


    // MARK: Public Methods

    func updateConversations() {
        viewModel.updateConversations()
        viewModel.updateUnreadMessagesCount()
    }


    // MARK: ChatListViewModelDelegate Methods

    func didStartRetrievingChatList(viewModel: ChatListViewModel, isFirstLoad: Bool) {
        if isFirstLoad {
            chatListStatus = .LoadingConversations
            refreshUI()
        }
    }

    func didSucceedRetrievingChatList(viewModel: ChatListViewModel, nonEmptyChatList: Bool) {
        tableView.userInteractionEnabled = true
        refreshControl.endRefreshing()
        if nonEmptyChatList {
            chatListStatus = .Conversations
        } else {
            chatListStatus = .NoConversations
        }
        refreshUI()        
    }

    func didFailRetrievingChatList(viewModel: ChatListViewModel, error: ChatsRetrieveServiceError) {
        tableView.userInteractionEnabled = true
        refreshControl.endRefreshing()
        
        if error == .Forbidden {
            // logout the scammer!
            showAutoFadingOutMessageAlert(LGLocalizedString.logInErrorSendErrorGeneric) { (completion) -> Void in
                MyUserManager.sharedInstance.logout(nil)
            }
        }
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

        let cell = tableView.dequeueReusableCellWithIdentifier("ConversationCell",
            forIndexPath: indexPath) as! ConversationCell

        cell.tag = indexPath.hash // used for cell reuse on "setupCellWithChat"
        guard let chat = viewModel.chatAtIndex(indexPath.row), let myUser = MyUserManager.sharedInstance.myUser() else {
            return cell
        }

        cell.setupCellWithChat(chat, myUser: myUser, indexPath: indexPath)
        return cell
    }

    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        guard let chat = viewModel.chatAtIndex(indexPath.row), let chatViewModel = ChatViewModel(chat: chat) else {
            return
        }
        navigationController?.pushViewController(ChatViewController(viewModel: chatViewModel), animated: true)
    }


    // MARK: NSNotificationCenter

    func didReceiveUserInteraction(notification: NSNotification) {
        updateConversations()
    }


    // MARK: Private Methods

    private func setupUI() {
        // appearance
        setLetGoNavigationBarStyle(LGLocalizedString.chatListTitle)

        // internationalization
        noConversationsYet.text = LGLocalizedString.chatListEmptyLabel
        startSellingOrBuyingLabel.text = LGLocalizedString.chatListStartSellingOrBuyingLabel

        // add a pull to refresh control
        self.refreshControl = UIRefreshControl()
        self.refreshControl.addTarget(self, action: "updateConversations", forControlEvents: UIControlEvents.ValueChanged)
        self.tableView.addSubview(refreshControl)
    }

    private func refreshUI() {

        if chatListStatus == .LoadingConversations {
            activityIndicator.startAnimating()
        } else {
            activityIndicator.stopAnimating()
        }

        activityIndicator.hidden = chatListStatus != .LoadingConversations

        noConversationsYet.hidden = chatListStatus != .NoConversations
        startSellingOrBuyingLabel.hidden = chatListStatus != .NoConversations
        searchButton.hidden = chatListStatus != .NoConversations
        sellButton.hidden = chatListStatus != .NoConversations
        separatorView.hidden = chatListStatus != .NoConversations
        messageImageView.hidden = chatListStatus != .NoConversations

        tableView.hidden = chatListStatus != .Conversations

        if chatListStatus == .Conversations { self.tableView.reloadData() }
    }
}