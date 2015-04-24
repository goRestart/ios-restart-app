//
//  ChatViewController.swift
//  LetGo
//
//  Created by Ignacio Nieto Carvajal on 05/02/15.
//  Copyright (c) 2015 Ignacio Nieto Carvajal. All rights reserved.
//

import UIKit

private let kLetGoConversationMyMessagesCell = "MyMessagesCell"
private let kLetGoConversationOthersMessagesCell = "OthersMessagesCell"
private let kLetGoChatBubbleCornerRadius: CGFloat = 4.0

private let kLetGoConversationProductImageTag = 1
private let kLetGoConversationProductUserNameTag = 2
private let kLetGoConversationProductProductNameTag = 3
private let kLetGoConversationProductRelativeDateTag = 4
private let kLetGoConversationProductPriceTag = 5

private let kLetGoConversationCellBubbleTag = 1
private let kLetGoConversationCellTextTag = 2
private let kLetGoConversationCellRelativeTimeTag = 3
private let kLetGoConversationCellAvatarTag = 4


enum LetGoConversationCellTypes: Int {
    case MyMessages = 0, OtherMessages = 1
}

class ChatViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate {
    // outlets & buttons
    @IBOutlet weak var productImageView: UIImageView!
    @IBOutlet weak var productNameLabel: UILabel!
    @IBOutlet weak var usernameLabel: UILabel!
    @IBOutlet weak var publishedDateLabel: UILabel!
    @IBOutlet weak var priceLabel: UILabel!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var bottomView: UIView!
    @IBOutlet weak var messageTextfield: UITextField!
    @IBOutlet weak var sendButton: UIButton!
    @IBOutlet weak var loadingMessageActivityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var loadingMessagesLabel: UILabel!
    @IBOutlet weak var topView: UIView!
    @IBOutlet weak var topViewTopConstraint: NSLayoutConstraint!
    @IBOutlet weak var bottomViewBottomConstraint: NSLayoutConstraint!
    
    // data
    var letgoConversation: LetGoConversation?
    var messages: [PFObject]?
    var otherUser: PFUser?
    var productObject: PFObject?
    var otherUserImage: UIImage?
    var isSendingMessage: Bool = false {
        didSet {
            self.sendButton.tintColor = isSendingMessage ? UIColor.lightGrayColor() : UIColor.blackColor()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // appearance.
        usernameLabel.text = ""
        productNameLabel.text = ""
        publishedDateLabel.text = ""
        priceLabel.text = ""
        productImageView.clipsToBounds = true
        productImageView.contentMode = .ScaleAspectFill
        
        // tap the messages table view to restore frame.
        let restoreTapGestureRecognizer = UITapGestureRecognizer(target: self, action: "resignRespondingTextfield")
        self.tableView.addGestureRecognizer(restoreTapGestureRecognizer)
        
        // internationalization
        sendButton.setTitle(translate("send"), forState: .Normal)
        messageTextfield.placeholder = translate("type_your_message_here")
        loadingMessagesLabel.text = translate("loading_messages")
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)

        // track conversation update.
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "checkUpdatedConversation:", name: kLetGoUserBadgeChangedNotification, object: nil)
        
        // track keyboard appearance and size change
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "keyboardWillShow:", name: UIKeyboardWillShowNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "keyboardWillShow:", name: UIKeyboardDidShowNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "keyboardWillHide:", name: UIKeyboardWillHideNotification, object: nil)
        
        // appearance
        self.productImageView.image = nil
        self.tableView.transform = CGAffineTransformMakeRotation(CGFloat(M_PI)) // 180 º
        
        if letgoConversation != nil {
            let conversationObject = letgoConversation!.conversationObject
            enableLoadingMessagesInterface()
            // load previous messages
            loadMessages(conversationObject)
            
            // load the other user.
            // According to specification, if I am selling the product, I am the user_to, and the other user is the user_from
            var otherUserField = self.letgoConversation!.amISellingTheProduct ? "user_from" : "user_to"
            self.otherUser = conversationObject[otherUserField] as? PFUser
            // now try to fetch it in the background.
            self.otherUser?.fetchIfNeededInBackgroundWithBlock(nil)
            
            // load product information
            if let productObject = conversationObject["product"] as? PFObject {
                self.productObject = productObject
                productObject.fetchIfNeededInBackgroundWithBlock({ (retrievedObject, error) -> Void in
                    if retrievedObject != nil && error == nil { // OK, we do have a valid, filled object.
                        self.loadInformationFromProductObject(retrievedObject)
                    } else { // try our best to load the information from our currently stored object
                        self.loadInformationFromProductObject(productObject)
                    }
                })
            } else { // We don't have information about the product itself... This shouldn't happen.
                self.showAutoFadingOutMessageAlert(translate("unable_show_conversation"), completionBlock: { () -> Void in
                    self.popBackViewController()
                })
            }
                        
        } else { // no conversation object? notify the error and get back.
            self.showAutoFadingOutMessageAlert(translate("unable_show_conversation"), completionBlock: { () -> Void in
                self.popBackViewController()
            })
        }
        TrackingManager.sharedInstance.trackEvent(kLetGoTrackingEventNameScreenPrivate, eventParameters: [kLetGoTrackingParameterNameScreenName: "chat-screen"])

    }
    
    func loadMessages(conversationObject: PFObject) {
        ChatManager.sharedInstance.loadMessagesFromConversation(conversationObject, completion: { (success, messages) -> Void in
            if success {
                self.messages = messages!
            } else { // no messages yet. Empty conversation view.
                self.messages = []
            }
            self.disableLoadingMessagesInterface()
            self.tableView.reloadData()
            // scroll to the last message.
            self.scrollToTopOfMessagesList(false)
            self.tableView.reloadData()
            
            // now that we have loaded the messages (and are sure the user can read them) we can mark them as read in the conversation.
            ChatManager.sharedInstance.markMessagesAsReadFromUser(PFUser.currentUser()!, inConversation: self.letgoConversation!.conversationObject, completion: nil)
        })
    }
    
    func refreshMessages() {
        if let conversationObject = self.letgoConversation?.conversationObject {
            loadMessages(conversationObject)
        }
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        // save original table view frame for restoring later.
        originalTableViewFrame = self.tableView.frame
        originalTopViewFrame = self.topView.frame
        originalBottomViewFrame = self.bottomView.frame
        // reload data because of auto-height calculation
        tableView.reloadData()
    }
    
    // Loads the fields referred to the product object in view's header.
    func loadInformationFromProductObject(retrievedObject: PFObject!) {
        // product image
        if let imageFile = retrievedObject?[kLetGoProductFirstImageKey] as? PFFile {
            // try to retrieve image from thumbnail first.
            let thumbnailURL = ImageManager.sharedInstance.calculateThumnbailImageURLForProductImage(retrievedObject.objectId!, imageURL: imageFile.url!)
            ImageManager.sharedInstance.retrieveImageFromURLString(thumbnailURL, completion: { (success, image, fromURL) -> Void in
                if success && fromURL == thumbnailURL {
                    self.productImageView.image = image
                } else { // failure, fallback to parse PFFile for the image.
                    ImageManager.sharedInstance.retrieveImageFromParsePFFile(imageFile, completion: { (success, image) -> Void in
                        if success { self.productImageView.image = image }
                        }, andAddToCache: true)
                }
            })
            
        }
        
        // product name
        self.productNameLabel.text = retrievedObject?["name"] as? String ?? translate("product")
        self.setLetGoNavigationBarStyle(title: self.productNameLabel.text, includeBackArrow: true)
        
        // publish date
        let publishedDate = retrievedObject?.createdAt ?? retrievedObject?.updatedAt ?? NSDate()
        self.publishedDateLabel.text = translate("published") + " " + publishedDate.relativeTimeString()
        
        // price
        if let price = retrievedObject?["price"] as? Double {
            let currencyString = retrievedObject?["currency"] as? String ?? CurrencyManager.sharedInstance.defaultCurrency.iso4217Code
            if let currency = CurrencyManager.sharedInstance.currencyForISO4217Symbol(currencyString) {
                self.priceLabel.text = currency.formattedCurrency(price)
                self.priceLabel.hidden = false
            } else { // fallback to just price.
                self.priceLabel.text = "\(price)"
                self.priceLabel.hidden = false
            }
        } else { self.priceLabel.hidden = true }
        
        // product owner information.
        if let storedOwner = retrievedObject?["user"] as? PFObject {
            storedOwner.fetchIfNeededInBackgroundWithBlock({ (retrievedOwner, error) -> Void in
                if error == nil && retrievedOwner != nil {
                    // "by you" or "by other-user-name"
                    if retrievedOwner!.objectId == PFUser.currentUser()?.objectId { // hello me!
                        translate("by") + " " + translate("you")
                    } else { // some other guy...
                        self.usernameLabel.text = translate("by") + " " + (retrievedOwner!["username_public"] as? String ?? translate("user"))
                    }
                } else { self.usernameLabel.text = translate("user") }
            })
        } else { self.usernameLabel.text = translate("user") }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - Loading interface
    
    func enableLoadingMessagesInterface() {
        tableView.hidden = true
        loadingMessageActivityIndicator.startAnimating()
        loadingMessageActivityIndicator.hidden = false
        loadingMessagesLabel.hidden = false
    }

    func disableLoadingMessagesInterface() {
        tableView.hidden = false
        loadingMessageActivityIndicator.hidden = true
        loadingMessageActivityIndicator.startAnimating()
        loadingMessagesLabel.hidden = true
    }
    
    // MARK: - Button actions
    
    @IBAction func sendMessage(sender: AnyObject) {
        // safety checks
        if isSendingMessage { return }
        if count(self.messageTextfield.text.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceAndNewlineCharacterSet())) < 1 { return }
        if self.otherUser == nil || self.letgoConversation?.conversationObject == nil || self.productObject == nil { showAutoFadingOutMessageAlert(translate("unable_send_message")); return }
        
        // enable loading interface.
        self.isSendingMessage = true
        
        // send message
        ChatManager.sharedInstance.addTextMessage(self.messageTextfield.text.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceAndNewlineCharacterSet()), toUser: self.otherUser!, inConversation: letgoConversation!.conversationObject, fromProduct: self.productObject!, isOffer: false) { (success, newlyCreatedMessageObject) -> Void in
            if success {
                self.messages!.insert(newlyCreatedMessageObject!, atIndex: 0)
                
                // update UI and scroll to the bottom of the messages list
                self.tableView.reloadData()
                self.scrollToTopOfMessagesList(false)
                //self.tableView.reloadData()
                self.messageTextfield.text = ""
                
                // tracking
                TrackingManager.sharedInstance.trackEvent(kLetGoTrackingEventNameUserSentMessage, eventParameters: self.getPropertiesForUserSentMessageTracking())
            } else {
                self.showAutoFadingOutMessageAlert(translate("unable_send_message"))
            }
            // disable loading interface
            self.isSendingMessage = false
        }
    }
    
    /** Generates the properties for the user-sent-message tracking event. NOTE: This would probably change once Parse is not used anymore */
    func getPropertiesForUserSentMessageTracking() -> [String: AnyObject] {
        var properties: [String: AnyObject] = [:]
        if productObject != nil {
            if let productCity = productObject![kLetGoRestAPIParameterCity] as? String { properties[kLetGoTrackingParameterNameProductCity] = productCity }
            if let productCountry = productObject![kLetGoRestAPIParameterCountryCode] as? String { properties[kLetGoTrackingParameterNameProductCountry] = productCountry }
            if let productZipCode = productObject![kLetGoRestAPIParameterZipCode] as? String { properties[kLetGoTrackingParameterNameProductZipCode] = productZipCode }
            if let productCategoryId = productObject![kLetGoRestAPIParameterCategoryId] as? String { properties[kLetGoTrackingParameterNameCategoryId] = productCategoryId }
        }
        return properties
    }
    
    // MARK: - UITableViewDelegate & DataSource methods
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return messages != nil ? messages!.count : 0
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        // data
        let msgObject = messages![indexPath.row]
        let userFrom = msgObject["user_from"] as! PFUser
        
        // cell elements
        var cell: UITableViewCell?
        var type = LetGoConversationCellTypes.MyMessages
        
        if userFrom.objectId == PFUser.currentUser()!.objectId { // message from me
            cell = tableView.dequeueReusableCellWithIdentifier(kLetGoConversationMyMessagesCell, forIndexPath: indexPath) as? UITableViewCell
        } else {
            cell = tableView.dequeueReusableCellWithIdentifier(kLetGoConversationOthersMessagesCell, forIndexPath: indexPath) as? UITableViewCell
            type = .OtherMessages
        }
        
        // configure common cell elements
        if cell != nil { self.configureCell(cell!, fromTableView: tableView, atIndexPath: indexPath, withMessageObject: msgObject, type: type) }

        cell!.transform = CGAffineTransformMakeRotation(CGFloat(M_PI)) // 180 º
        return cell ?? UITableViewCell()

    }

    func tableView(tableView: UITableView, estimatedHeightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return UITableViewAutomaticDimension
    }

    func configureCell(cell: UITableViewCell, fromTableView tableView: UITableView, atIndexPath indexPath: NSIndexPath, withMessageObject msgObject: PFObject, type: LetGoConversationCellTypes) {
        // message
        if let msgLabel = cell.viewWithTag(kLetGoConversationCellTextTag) as? UILabel {
            msgLabel.font = UIFont.preferredFontForTextStyle(UIFontTextStyleBody)
            msgLabel.text = msgObject["message"] as? String ?? ""
        }
        // configure date
        if let dateLabel = cell.viewWithTag(kLetGoConversationCellRelativeTimeTag) as? UILabel {
            dateLabel.font = UIFont.preferredFontForTextStyle(UIFontTextStyleCaption1)
            dateLabel.text = msgObject.createdAt!.relativeTimeString()
        }
        // bubble appearance
        if let bubbleView = cell.viewWithTag(kLetGoConversationCellBubbleTag) {
            bubbleView.layer.cornerRadius = kLetGoChatBubbleCornerRadius
        }
        
        // If this is a message from the other user, we should include his/her avatar picture at the left of the message.
        if type == .OtherMessages {
            // configure other user's avatar.
            let userFrom = msgObject["user_from"] as! PFUser
            if let userAvatarView = cell.viewWithTag(kLetGoConversationCellAvatarTag) as? UIImageView {
                userAvatarView.layer.cornerRadius = userAvatarView.frame.size.width / 2.0
                userAvatarView.clipsToBounds = true
                userAvatarView.image = self.otherUserImage
                if self.otherUserImage == nil { // lazily load the other user's pic, only when needed!
                    userFrom.fetchIfNeededInBackgroundWithBlock({ (retrievedUserFrom, error) -> Void in
                        if let avatarFile = retrievedUserFrom?["avatar"] as? PFFile {
                            ImageManager.sharedInstance.retrieveImageFromParsePFFile(avatarFile, completion: { (success, image) -> Void in
                                if success { userAvatarView.image = image; self.otherUserImage = image }
                                else { userAvatarView.image = UIImage(named: "no_photo"); self.otherUserImage = userAvatarView.image }
                                // image appearance
                                }, andAddToCache: true)
                        }
                    })
                } // end if self.otherUserImage == nil...
            } // end if let userAvatarView...
        } // end if type == .OtherMessages.
    }
    
    // MARK: - Cell height estimation
    
    var prototypeCell: UITableViewCell!
    
    // Because we are supporting iOS 7, we need to perform a calculation of the cell content view size using autolayout.
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        let msgObject = messages![indexPath.row]
        // lazily instanciate the prototype cell
        if prototypeCell == nil { prototypeCell = tableView.dequeueReusableCellWithIdentifier(kLetGoConversationOthersMessagesCell) as? UITableViewCell }
        self.configureCell(prototypeCell, fromTableView: tableView, atIndexPath: indexPath, withMessageObject: msgObject, type: .MyMessages) // no need to configure the image.
        prototypeCell.layoutIfNeeded()
        let size = prototypeCell.contentView.systemLayoutSizeFittingSize(UILayoutFittingCompressedSize)
        return size.height + 1
    }

    // MARK: - Allow copying text / highlighted state in cells
    
    func tableView(tableView: UITableView, shouldShowMenuForRowAtIndexPath indexPath: NSIndexPath) -> Bool { return true }
    func tableView(tableView: UITableView, canPerformAction action: Selector, forRowAtIndexPath indexPath: NSIndexPath, withSender sender: AnyObject) -> Bool { return action == "copy:" }
    func tableView(tableView: UITableView, performAction action: Selector, forRowAtIndexPath indexPath: NSIndexPath, withSender sender: AnyObject!) {
        if action == "copy:" {
            if let cell = tableView.cellForRowAtIndexPath(indexPath) {
                if let textLabel = cell.viewWithTag(kLetGoConversationCellTextTag) as? UILabel {
                    UIPasteboard.generalPasteboard().string = textLabel.text
                }
            }
        }
    }

    // MARK: - Check changes in conversation.
    func checkUpdatedConversation(notification: NSNotification) {
        // Analyze push notification object.
        if let userInfo = notification.object as? [NSObject: AnyObject] {
            // added support for Android push notifications compatibility.
            var info = userInfo
            if let aps = info["aps"] as? [String: AnyObject] { info = aps }
            if let conversationId = info["c_id"] as? String {
                // check if we need to update the conversation.
                if self.letgoConversation?.conversationObject.objectId == conversationId {
                    self.refreshMessages()
                }
            }
        }
    }
    
    
    // MARK: - UI/UX Scrolling responding to UITextField edition
    
    var originalTableViewFrame = CGRectZero
    var originalTopViewFrame = CGRectZero
    var originalBottomViewFrame = CGRectZero
    
    func scrollToBottomOfMessagesList(animated: Bool) {
        self.tableView.scrollRectToVisible(CGRectMake(0, self.tableView.contentSize.height - self.tableView.bounds.size.height, self.tableView.bounds.size.width, self.tableView.bounds.size.height), animated: animated)
    }
    
    func scrollToTopOfMessagesList(animated: Bool) {
        self.tableView.scrollRectToVisible(CGRectMake(0, 0, 1, 1), animated: true)
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        if count(textField.text) > 0 { self.sendMessage(self.sendButton) }
        return true
    }
    
    func keyboardWillShow(notification: NSNotification) {
        moveViewInResponseToKeyboardAppearing(true, withNotification: notification)
    }
 
    func keyboardWillHide(notification: NSNotification) {
        moveViewInResponseToKeyboardAppearing(false, withNotification: notification)
    }
    
    func moveViewInResponseToKeyboardAppearing(appearing: Bool, withNotification notification: NSNotification) {
        let userInfo = notification.userInfo!
        var keyboardSize = (userInfo[UIKeyboardFrameEndUserInfoKey] as? NSValue ?? NSValue(CGRect: CGRectZero)).CGRectValue().size
        if !appearing {
            // restore autolayout.
            self.topViewTopConstraint.constant = 0
            self.bottomViewBottomConstraint.constant = 0
            self.view.setNeedsUpdateConstraints()
            UIView.animateWithDuration(0.3, animations: { () -> Void in
                self.view.layoutIfNeeded()
                }, completion: { (success) -> Void in
            })

        } else {
            // avoid autolayout messing with our animations.
            self.topViewTopConstraint.constant = -keyboardSize.height + self.topView.frame.size.height + 20 // (20 = statusbar span)
            self.bottomViewBottomConstraint.constant = keyboardSize.height
            self.view.setNeedsUpdateConstraints()
            UIView.animateWithDuration(0.3, animations: { () -> Void in
                self.view.layoutIfNeeded()
                }, completion: { (success) -> Void in
            })
        }
        
    }
    
    func resignRespondingTextfield() {
        self.view.resignFirstResponder()
        self.view.endEditing(true)
    }

    override func touchesBegan(touches: Set<NSObject>, withEvent event: UIEvent) {
        self.resignRespondingTextfield()
    }
}









