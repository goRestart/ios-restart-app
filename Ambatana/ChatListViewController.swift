//
//  ChatListViewController.swift
//  LetGo
//
//  Created by Ignacio Nieto Carvajal on 20/2/15.
//  Copyright (c) 2015 Ignacio Nieto Carvajal. All rights reserved.
//

import LGCoreKit
import Parse
import UIKit

private let kLetGoConversationCellImageTag = 1
private let kLetGoConversationCellUserNameTag = 2
private let kLetGoConversationCellProductNameTag = 3
private let kLetGoConversationCellRelativeDateTag = 4

private let kLetGoConversationsRefreshTimeout: NSTimeInterval = 300 // seconds.

/**
 * The ChatListViewController manages all the conversations of the user. It reads the list of PFObjects
 * of the "Conversations" class and processes them to properly show them to the user.
 */
class ChatListViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    // outlets & buttons
    
    // no conversations interface
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
    
    // data
    var conversations: [LetGoConversation]?
    var lastTimeConversationsWhereRetrieved: NSDate?
    
    init() {
        super.init(nibName: "ChatListViewController", bundle: nil)
    }
    
    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // appearance
        setLetGoNavigationBarStyle(title: NSLocalizedString("chat_list_title", comment: ""))
        
        // internationalization
        noConversationsYet.text = NSLocalizedString("chat_list_empty_label", comment: "")
        startSellingOrBuyingLabel.text = NSLocalizedString("chat_list_start_selling_or_buying_label", comment: "")
       
        // add a pull to refresh control
        self.refreshControl = UIRefreshControl()
//        self.refreshControl.attributedTitle = NSAttributedString(string: NSLocalizedString("common_pull_to_refresh", comment: ""))
        self.refreshControl.addTarget(self, action: "refreshConversations", forControlEvents: UIControlEvents.ValueChanged)
        self.tableView.addSubview(refreshControl)
                
        // register cell
        let cellNib = UINib(nibName: "ConversationCell", bundle: nil)
        tableView.registerNib(cellNib, forCellReuseIdentifier: "ConversationCell")
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        // NSNotificationCenter, observe for user interactions (msgs & offers)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "didReceiveUserInteraction:", name: PushManager.Notification.didReceiveUserInteraction.rawValue, object: nil)
        
        // Update conversations (always forced, so the badges are updated)
        updateConversations(force: true)
        
        // Update unread messages
        PushManager.sharedInstance.updateUnreadMessagesCount()
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
    
    // MARK: - Conversation management
    
    func updateConversations(force: Bool = false) {
        // retrieve conversations
        if force || (conversations == nil || itsAboutTimeToRefreshConversations()) {
            if conversations == nil { enableLoadingConversationsInterface() }
            OldChatManager.sharedInstance.retrieveMyConversationsWithCompletion({ [weak self] (success, conversations) -> Void in
                if let strongSelf = self {
                    if success && conversations?.count > 0 {
                        strongSelf.conversations = conversations
                        strongSelf.enableConversationsInterface()
                    }
                    else {
                        strongSelf.enableNoConversationsInterface()
                    }
                    // release pull to refresh
                    strongSelf.refreshControl.endRefreshing()
                    // register that we have updated our conversation records.
                    strongSelf.lastTimeConversationsWhereRetrieved = NSDate()
                }
            })
        } else { // we already tried to load some conversations.
            if conversations!.count > 0 { // we do have some conversations
                enableConversationsInterface()
            }
            else { // no conversations.
                enableNoConversationsInterface()
            }
            // release pull to refresh
            self.refreshControl.endRefreshing()
        }
        
    }
    
    func refreshConversations() { updateConversations(force: true) }
    
    // Determines if we should refresh the conversations.
    func itsAboutTimeToRefreshConversations() -> Bool {
        if lastTimeConversationsWhereRetrieved == nil { return true }
        else { return NSDate().timeIntervalSinceDate(lastTimeConversationsWhereRetrieved!) > kLetGoConversationsRefreshTimeout }
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
//        println("count: \(conversations?.count)")
        return conversations?.count ?? 0
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCellWithIdentifier("ConversationCell", forIndexPath: indexPath) as! ConversationCell
        
        cell.tag = indexPath.hash
        if let conversation = conversations?[indexPath.row] {
            cell.setupCellWithConversation(conversation, indexPath: indexPath)
        }
        return cell

    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        if let letgoConversation = self.conversations?[indexPath.row] {
            let chatVC = ChatViewController()
            chatVC.letgoConversation = letgoConversation
            self.navigationController?.pushViewController(chatVC, animated: true)
        }
    }
    
    // MARK: - NSNotificationCenter
    
    func didReceiveUserInteraction(notification: NSNotification) {
        self.refreshConversations()
    }
}