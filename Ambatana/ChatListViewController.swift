//
//  ChatListViewController.swift
//  LetGo
//
//  Created by Ignacio Nieto Carvajal on 20/2/15.
//  Copyright (c) 2015 Ignacio Nieto Carvajal. All rights reserved.
//

import LGCoreKit
import Result
import UIKit

class ChatListViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
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
    
    // Data
    var chats: [Chat]?
    
    // MARK: - Lifecycle
    
    init() {
        super.init(nibName: "ChatListViewController", bundle: nil)
        
        hidesBottomBarWhenPushed = false
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    deinit {
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // appearance
        setLetGoNavigationBarStyle(LGLocalizedString.chatListTitle)
        
        // internationalization
        noConversationsYet.text = LGLocalizedString.chatListEmptyLabel
        startSellingOrBuyingLabel.text = LGLocalizedString.chatListStartSellingOrBuyingLabel
       
        // add a pull to refresh control
        self.refreshControl = UIRefreshControl()
        self.refreshControl.addTarget(self, action: "updateConversations", forControlEvents: UIControlEvents.ValueChanged)
        self.tableView.addSubview(refreshControl)
                
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
        updateConversations()
        
        // Update unread messages
        PushManager.sharedInstance.updateUnreadMessagesCount()

        NSNotificationCenter.defaultCenter().addObserver(self, selector: Selector("applicationWillEnterForeground:"),
            name: UIApplicationWillEnterForegroundNotification, object: nil)
    }

    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)

        NSNotificationCenter.defaultCenter().removeObserver(self,
            name: UIApplicationWillEnterForegroundNotification, object: nil)
    }

    dynamic private func applicationWillEnterForeground(notification: NSNotification) {
        updateConversations()
    }

    // MARK: - Conversation management
    
    func updateConversations() {
        
        let firstLoad: Bool
        if let actualChats = chats {
            firstLoad = actualChats.isEmpty
        }
        else {
            firstLoad = true
        }
        
        if firstLoad {
            enableLoadingConversationsInterface()
        }
        tableView.userInteractionEnabled = false
        
        ChatManager.sharedInstance.retrieveChatsWithCompletion({
            [weak self] (result: Result<[Chat], ChatsRetrieveServiceError>) -> Void in

            if let strongSelf = self {
                // Success
                if let chats = result.value {
                    if chats.count > 0 {
                        strongSelf.chats = chats
                        strongSelf.enableConversationsInterface()
                    }
                    else {
                        strongSelf.enableNoConversationsInterface()
                    }
                } else if let actualError = result.error {
                    if actualError == .Forbidden {
                        // logout the scammer!
                        self?.showAutoFadingOutMessageAlert(LGLocalizedString.logInErrorSendErrorGeneric,
                            completionBlock: { (completion) -> Void in
                                MyUserManager.sharedInstance.logout(nil)
                        })
                    }
                }
                
                // allow interaction
                strongSelf.tableView.userInteractionEnabled = true
                
                // release pull to refresh
                strongSelf.refreshControl.endRefreshing()
            }
        })
    }
    
    // MARK: - Appearance & different contexts interfaces
    
    func enableLoadingConversationsInterface() {
        disableNoConversationsInterface()
        disableConversationsInterface()
        
        activityIndicator.startAnimating()
        activityIndicator.hidden = false
    }
    
    func enableNoConversationsInterface() {
        disableLoadingConversationsInterface()
        disableConversationsInterface()
        
        noConversationsYet.hidden = false
        startSellingOrBuyingLabel.hidden = false
        searchButton.hidden = false
        sellButton.hidden = false
        separatorView.hidden = false
        messageImageView.hidden = false
    }
    
    func enableConversationsInterface() {
        disableLoadingConversationsInterface()
        disableNoConversationsInterface()
        
        tableView.hidden = false
        self.tableView.reloadData()
    }
    
    func disableLoadingConversationsInterface() {
        activityIndicator.hidden = true
        activityIndicator.stopAnimating()
    }
    
    func disableNoConversationsInterface() {
        noConversationsYet.hidden = true
        startSellingOrBuyingLabel.hidden = true
        searchButton.hidden = true
        sellButton.hidden = true
        separatorView.hidden = true
        messageImageView.hidden = true
    }
    
    func disableConversationsInterface() {
        tableView.hidden = true
    }
    
    // MARK: - Button actions
    
    @IBAction func searchProducts(sender: AnyObject) {
        if let tabBarCtl = tabBarController as? TabBarController {
            tabBarCtl.switchToTab(.Home)
        }
    }

    @IBAction func sellProducts(sender: AnyObject) {
        let vc = NewSellProductViewController()
        let navCtl = UINavigationController(rootViewController: vc)
        presentViewController(navCtl, animated: true, completion: nil)
    }

    // MARK: - UITableViewDelegate & DataSource methods
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return chats?.count ?? 0
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCellWithIdentifier("ConversationCell",
            forIndexPath: indexPath) as! ConversationCell
        
        cell.tag = indexPath.hash
        if let chat = chats?[indexPath.row], let myUser = MyUserManager.sharedInstance.myUser() {
            cell.setupCellWithChat(chat, myUser: myUser, indexPath: indexPath)
        }
        return cell

    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        if let chat = chats?[indexPath.row], let chatViewModel = ChatViewModel(chat: chat) {
            navigationController?.pushViewController(ChatViewController(viewModel: chatViewModel), animated: true)
        }
    }
    
    // MARK: - NSNotificationCenter
    
    func didReceiveUserInteraction(notification: NSNotification) {
        updateConversations()
    }
}