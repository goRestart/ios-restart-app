//
//  ChatListViewController.swift
//  LetGo
//
//  Created by Dídac on 21/12/15.
//  Copyright © 2015 Ambatana. All rights reserved.
//

import Foundation
import LGCoreKit

class ChatListViewController: BaseViewController, ChatListViewModelDelegate {

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

//        hidesBottomBarWhenPushed = false
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
        viewModel.updateConversations()

        // Update unread messages
        PushManager.sharedInstance.updateUnreadMessagesCount()
    }

    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)

        NSNotificationCenter.defaultCenter().removeObserver(self,
            name: UIApplicationWillEnterForegroundNotification, object: nil)
    }


    // MARK - ChatListViewModelDelegate Methods

    func didStartRetrievingChatList(viewModel: ChatListViewModel, isFirstLoad: Bool) {
        if isFirstLoad {
            enableLoadingConversationsInterface()
        }
    }

    func didSucceedRetrievingChatList(viewModel: ChatListViewModel, nonEmptyChatList: Bool) {
        tableView.userInteractionEnabled = true
        refreshControl.endRefreshing()
        if nonEmptyChatList {
            enableConversationsInterface()
        } else {
            enableNoConversationsInterface()
        }
        
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


    // MARK - Private Methods

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

    private func enableLoadingConversationsInterface() {
        disableNoConversationsInterface()
        disableConversationsInterface()

        activityIndicator.startAnimating()
        activityIndicator.hidden = false
    }

    private func enableNoConversationsInterface() {
        disableLoadingConversationsInterface()
        disableConversationsInterface()

        noConversationsYet.hidden = false
        startSellingOrBuyingLabel.hidden = false
        searchButton.hidden = false
        sellButton.hidden = false
        separatorView.hidden = false
        messageImageView.hidden = false
    }

    private func enableConversationsInterface() {
        disableLoadingConversationsInterface()
        disableNoConversationsInterface()

        tableView.hidden = false
        self.tableView.reloadData()
    }

    private func disableLoadingConversationsInterface() {
        activityIndicator.hidden = true
        activityIndicator.stopAnimating()
    }

    private func disableNoConversationsInterface() {
        noConversationsYet.hidden = true
        startSellingOrBuyingLabel.hidden = true
        searchButton.hidden = true
        sellButton.hidden = true
        separatorView.hidden = true
        messageImageView.hidden = true
    }

    private func disableConversationsInterface() {
        tableView.hidden = true
    }
}