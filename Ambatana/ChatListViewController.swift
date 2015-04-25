//
//  ChatListViewController.swift
//  LetGo
//
//  Created by Ignacio Nieto Carvajal on 20/2/15.
//  Copyright (c) 2015 Ignacio Nieto Carvajal. All rights reserved.
//

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
    @IBOutlet weak var loadingConversationsLabel: UILabel!
    var refreshControl: UIRefreshControl!
    
    // data
    var conversations: [LetGoConversation]?
    var lastTimeConversationsWhereRetrieved: NSDate?
    var selectedLetGoConversation: LetGoConversation?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // appearance
        setLetGoNavigationBarStyle(title: translate("conversations"), includeBackArrow: true)
        
        // internationalization
        noConversationsYet.text = translate("no_conversations_yet")
        startSellingOrBuyingLabel.text = translate("start_selling_or_buying")
        loadingConversationsLabel.text = translate("loading_conversations")
        
        // add a pull to refresh control
        self.refreshControl = UIRefreshControl()
        self.refreshControl.attributedTitle = NSAttributedString(string: translate("pull_to_refresh"))
        self.refreshControl.addTarget(self, action: "refreshConversations", forControlEvents: UIControlEvents.ValueChanged)
        self.tableView.addSubview(refreshControl)
        
        // register cell
        let cellNib = UINib(nibName: "ConversationCell", bundle: nil)
        tableView.registerNib(cellNib, forCellReuseIdentifier: "ConversationCell")
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        // update conversations
        updateConversations()
        
        // clean badge and notifications.
        PFInstallation.currentInstallation().badge = 0
        PFInstallation.currentInstallation().saveInBackgroundWithBlock({ (success, error) -> Void in
            if error != nil { PFInstallation.currentInstallation().saveEventually(nil) }
            else { NSNotificationCenter.defaultCenter().postNotificationName(kLetGoUserBadgeChangedNotification, object: nil) }
        })
        TrackingManager.sharedInstance.trackEvent(kLetGoTrackingEventNameScreenPrivate, eventParameters: [kLetGoTrackingParameterNameScreenName: "chat-list"])
    }
    
    // MARK: - Conversation management
    
    func updateConversations(force: Bool = false) {
        // retrieve conversations
        if force || (conversations == nil || itsAboutTimeToRefreshConversations()) {
            if conversations == nil { enableLoadingConversationsInterface() }
            ChatManager.sharedInstance.retrieveMyConversationsWithCompletion({ (success, conversations) -> Void in
                if success && conversations?.count > 0 {
                    self.conversations = conversations
                    self.enableConversationsInterface()
                } else { self.enableNoConversationsInterface() }
                // release pull to refresh
                self.refreshControl.endRefreshing()
                // register that we have updated our conversation records.
                self.lastTimeConversationsWhereRetrieved = NSDate()
            })
        } else { // we already tried to load some conversations.
            if conversations!.count > 0 { // we do have some conversations
                enableConversationsInterface()
            } else { // no conversations.
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
        loadingConversationsLabel.hidden = false
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
        loadingConversationsLabel.hidden = true
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
        performSegueWithIdentifier("ShowCategories", sender: sender)
    }

    @IBAction func sellProducts(sender: AnyObject) {
        performSegueWithIdentifier("SellProduct", sender: sender)
    }
    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if let cvc = segue.destinationViewController as? ChatViewController {
            cvc.letgoConversation = self.selectedLetGoConversation
        }
    }

    // MARK: - UITableViewDelegate & DataSource methods
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
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
            self.selectedLetGoConversation = letgoConversation
            self.performSegueWithIdentifier("OpenChat", sender: nil)
        }
    }
}
