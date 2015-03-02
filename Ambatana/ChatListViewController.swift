//
//  ChatListViewController.swift
//  Ambatana
//
//  Created by Ignacio Nieto Carvajal on 20/2/15.
//  Copyright (c) 2015 Ignacio Nieto Carvajal. All rights reserved.
//

import UIKit

private let kAmbatanaConversationCellImageTag = 1
private let kAmbatanaConversationCellUserNameTag = 2
private let kAmbatanaConversationCellProductNameTag = 3
private let kAmbatanaConversationCellRelativeDateTag = 4

private let kAmbatanaConversationsRefreshTimeout: NSTimeInterval = 300 // seconds.

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
    
    // data
    var conversations: [AmbatanaConversation]?
    var lastTimeConversationsWhereRetrieved: NSDate?
    var selectedAmbatanaConversation: AmbatanaConversation?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // appearance
        setAmbatanaNavigationBarStyle(title: translate("conversations"), includeBackArrow: true)
        
        // internationalization
        noConversationsYet.text = translate("no_conversations_yet")
        startSellingOrBuyingLabel.text = translate("start_selling_or_buying")
        loadingConversationsLabel.text = translate("loading_conversations")
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        // update conversations
        updateConversations()
    }
    
    // MARK: - Conversation management
    
    func updateConversations() {
        // retrieve conversations
        if conversations == nil || itsAboutTimeToRefreshConversations() {
            enableLoadingConversationsInterface()
            ChatManager.sharedInstance.retrieveMyConversationsWithCompletion({ (success, conversations) -> Void in
                if success && conversations?.count > 0 {
                    self.conversations = conversations
                    self.enableConversationsInterface()
                } else { self.enableNoConversationsInterface() }
                // register that we have updated our conversation records.
                self.lastTimeConversationsWhereRetrieved = NSDate()
            })
        } else { // we already tried to load some conversations.
            if conversations!.count > 0 { // we do have some conversations
                enableConversationsInterface()
            } else { // no conversations.
                enableNoConversationsInterface()
            }
        }
        
    }
    
    // Determines if we should refresh the conversations.
    func itsAboutTimeToRefreshConversations() -> Bool {
        if lastTimeConversationsWhereRetrieved == nil { return true }
        else { return NSDate().timeIntervalSinceDate(lastTimeConversationsWhereRetrieved!) > kAmbatanaConversationsRefreshTimeout }
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
            cvc.ambatanaConversation = self.selectedAmbatanaConversation
        }
    }

    // MARK: - UITableViewDelegate & DataSource methods
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return conversations?.count ?? 0
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("ConversationCell", forIndexPath: indexPath) as UITableViewCell
        cell.selectionStyle = .None
        
        // configure cell
        if var conversation = conversations?[indexPath.row] {
            // 1.image
            if let imageView = cell.viewWithTag(kAmbatanaConversationCellImageTag) as? UIImageView {
                // do we have an image downloaded yet?
                if conversation.userAvatarImage != nil {
                    imageView.image = conversation.userAvatarImage
                    // configure image appearance (circle)
                    imageView.layer.cornerRadius = imageView.frame.size.width / 2.0
                    imageView.clipsToBounds = true
                } else { // download the image and set it also in the conversation record when
                    ImageManager.sharedInstance.retrieveImageFromURLString(conversation.userAvatarURL, completion: { (success, image) -> Void in
                        if success {
                            conversation.userAvatarImage = image
                            imageView.image = image
                            // configure image appearance (circle)
                            imageView.layer.cornerRadius = imageView.frame.size.width / 2.0
                            imageView.clipsToBounds = true
                        }
                    }, andAddToCache: true)
                }
            }

            // 2. product name
            if let productNameLabel = cell.viewWithTag(kAmbatanaConversationCellProductNameTag) as? UILabel {
                productNameLabel.text = conversation.productName
            }
            
            // 3. user name
            if let userNameLabel = cell.viewWithTag(kAmbatanaConversationCellUserNameTag) as? UILabel {
                userNameLabel.text = translate("by") + " " + conversation.userName
            }
            
            // 4. relative time
            if let relativeTimeLabel = cell.viewWithTag(kAmbatanaConversationCellRelativeDateTag) as? UILabel {
                relativeTimeLabel.text = translate("published") + " " + conversation.lastUpdated.relativeTimeString()
            }
            
        }
        
        
        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        if let ambatanaConversation = self.conversations?[indexPath.row] {
            self.selectedAmbatanaConversation = ambatanaConversation
            self.performSegueWithIdentifier("OpenChat", sender: nil)
        }
    }
}
