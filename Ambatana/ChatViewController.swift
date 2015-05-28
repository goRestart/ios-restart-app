//
//  ChatViewController.swift
//  LetGo
//
//  Created by Ignacio Nieto Carvajal on 05/02/15.
//  Copyright (c) 2015 Ignacio Nieto Carvajal. All rights reserved.
//

import LGCoreKit
import Parse
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


class ChatViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate {
    
    // Constants
    private static let myMessageCellIdentifier = "ChatMyMessageCell"
    private static let othersMessageCellIdentifier = "ChatOthersMessageCell"
    
    // outlets & buttons
    @IBOutlet weak var productImageView: UIImageView!

    @IBOutlet weak var productNameLabel: UILabel!
    @IBOutlet weak var usernameLabel: UILabel!
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
    var askQuestion: Bool = false
    
    init() {
        super.init(nibName: "ChatViewController", bundle: nil)
        automaticallyAdjustsScrollViewInsets = false
        hidesBottomBarWhenPushed = true
    }

    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // appearance.
        usernameLabel.text = ""
        productNameLabel.text = ""
        priceLabel.text = ""
        productImageView.clipsToBounds = true
        productImageView.contentMode = .ScaleAspectFill
        topView.addBottomBorderWithWidth(1, color: StyleHelper.lineColor)

        // FIXME: Esto es automatico con el scrollvview
        // tap the messages table view to restore frame.
        let restoreTapGestureRecognizer = UITapGestureRecognizer(target: self, action: "resignRespondingTextfield")
        self.tableView.addGestureRecognizer(restoreTapGestureRecognizer)
        
        tableView.estimatedRowHeight = 120
        tableView.rowHeight = UITableViewAutomaticDimension
        
        let myMessageCellNib = UINib(nibName: "ChatMyMessageCell", bundle: nil)
        tableView.registerNib(myMessageCellNib, forCellReuseIdentifier: ChatViewController.myMessageCellIdentifier)
        let othersMessageCellNib = UINib(nibName: "ChatOthersMessageCell", bundle: nil)
        tableView.registerNib(othersMessageCellNib, forCellReuseIdentifier: ChatViewController.othersMessageCellIdentifier)
        
        // internationalization
        sendButton.setTitle(translate("send"), forState: .Normal)
        messageTextfield.placeholder = translate("type_your_message_here")
        loadingMessagesLabel.text = translate("loading_messages")
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)

        // track conversation update.
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "didReceiveUserInteraction:", name: PushManager.Notification.didReceiveUserInteraction.rawValue, object: nil)
        
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
    }
    
    func loadMessages(conversationObject: PFObject) {
        ChatManager.sharedInstance.loadMessagesFromConversation(conversationObject, completion: { [weak self] (success, messages) -> Void in
            if let strongSelf = self {
                if success {
                    strongSelf.messages = messages!
                } else { // no messages yet. Empty conversation view.
                    strongSelf.messages = []
                }
                strongSelf.disableLoadingMessagesInterface()
                strongSelf.tableView.reloadData()
                // scroll to the last message.
                strongSelf.scrollToTopOfMessagesList(false)
                strongSelf.tableView.reloadData()
                
                // now that we have loaded the messages (and are sure the user can read them) we can mark them as read in the conversation.
                let conversation = strongSelf.letgoConversation!.conversationObject
                ChatManager.sharedInstance.markMessagesAsReadFromUser(PFUser.currentUser()!, inConversation: conversation, completion: nil)
            }
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
        
        // Show kb
        messageTextfield.becomeFirstResponder()
    }
    
    // Loads the fields referred to the product object in view's header.
    func loadInformationFromProductObject(retrievedObject: PFObject!) {
        // product image
        if let product = retrievedObject {

            // try to retrieve image from thumbnail first.
            if let thumbnailURL = ImageHelper.thumbnailURLForProduct(product) {
                self.productImageView.sd_setImageWithURL(thumbnailURL)
            }
        }
        
        // product name
        self.productNameLabel.text = retrievedObject?["name"] as? String ?? translate("product")
        self.setLetGoNavigationBarStyle(title: self.productNameLabel.text)
                
        // price
        if let price = retrievedObject?["price"] as? Double {
            let currencyCode = retrievedObject?["currency"] as? String ?? Constants.defaultCurrencyCode
            self.priceLabel.text = CurrencyHelper.sharedInstance.formattedAmountWithCurrencyCode(currencyCode, amount: price)
        } else { self.priceLabel.hidden = true }
        
        // product owner information.
        if let storedOwner = retrievedObject?["user"] as? PFObject {
            storedOwner.fetchIfNeededInBackgroundWithBlock({ [weak self] (retrievedOwner, error) -> Void in
                if let strongSelf = self {
                    if error == nil && retrievedOwner != nil {
                        // "by you" or "by other-user-name"
                        if retrievedOwner!.objectId == PFUser.currentUser()?.objectId { // hello me!
                            translate("by") + " " + translate("you")
                        } else { // some other guy...
                            strongSelf.usernameLabel.text = translate("by") + " " + (retrievedOwner!["username_public"] as? String ?? translate("user"))
                        }
                    } else { strongSelf.usernameLabel.text = translate("user") }
                }
            })
        } else { self.usernameLabel.text = translate("user") }
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
        ChatManager.sharedInstance.addTextMessage(self.messageTextfield.text.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceAndNewlineCharacterSet()), toUser: self.otherUser!, inConversation: letgoConversation!.conversationObject, fromProduct: self.productObject!, isOffer: false) { [weak self] (success, newlyCreatedMessageObject) -> Void in
            if let strongSelf = self {
                if success {
                    strongSelf.messages!.insert(newlyCreatedMessageObject!, atIndex: 0)
                    
                    // update UI and scroll to the bottom of the messages list
                    strongSelf.tableView.reloadData()
                    strongSelf.scrollToTopOfMessagesList(false)
                    //self.tableView.reloadData()
                    strongSelf.messageTextfield.text = ""
                    
                    // Tracking
                    if strongSelf.askQuestion {
                        TrackingHelper.trackEvent(.ProductAskQuestion, parameters: strongSelf.trackingParams)
                    }
                    TrackingHelper.trackEvent(.UserMessageSent, parameters: strongSelf.trackingParams)
                }
                else {
                    strongSelf.showAutoFadingOutMessageAlert(translate("unable_send_message"))
                }
                // disable loading interface
                strongSelf.isSendingMessage = false
            }
        }
    }
    
    @IBAction func productButtonPressed(sender: AnyObject) {
        if let product = productObject {
            let vc = ShowProductViewController()
            vc.productObject = product
            self.navigationController?.pushViewController(vc, animated: true)
        }
    }
    
    // MARK: > Tracking
    
    private var trackingParams: [TrackingParameter: AnyObject] {
        get {
            var properties: [TrackingParameter: AnyObject] = [:]

            // product data
            if let product = productObject {
                if let productCity = product["city"] as? String {
                    properties[.ProductCity] = productCity
                }
                if let productCountry = product["country_code"] as? String {
                    properties[.ProductCountry] = productCountry
                }
                if let productZipCode = product["zip_code"] as? String {
                    properties[.ProductZipCode] = productZipCode
                }
                if let productCategoryId = product["category_id"] as? Int {
                    properties[.CategoryId] = String(productCategoryId)
                }
                if let productName = product["name"] as? String {
                    properties[.ProductName] = productName
                }
                if let productUserId = product["user_id"] as? String, let currentUser = PFUser.currentUser(), let currentUserId = currentUser.objectId,
                    let otherUsr = otherUser, let otherUserId = otherUsr.objectId  {
                    
                    // If the product is mine, check if i'm dummy
                    if productUserId == currentUserId {
                        if let isDummy = TrackingHelper.isDummyUser(currentUser) {
                            properties[.ItemType] = TrackingHelper.productTypeParamValue(isDummy)
                        }
                    }
                    // If the product is the other's guy, check if dummy
                    else if productUserId == otherUserId {
                        if let isDummy = TrackingHelper.isDummyUser(otherUsr) {
                            properties[.ItemType] = TrackingHelper.productTypeParamValue(isDummy)
                        }
                    }
                }
            }
            
            return properties
        }
    }
    
    // MARK: - UITableViewDelegate & DataSource methods
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return messages != nil ? messages!.count : 0
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        // data
        let msgObject = messages![indexPath.row]
        let userFrom = msgObject["user_from"] as! PFUser
        
        var cell: UITableViewCell?
        if userFrom.objectId == PFUser.currentUser()!.objectId { // message from me
            let myMessageCell = tableView.dequeueReusableCellWithIdentifier(ChatViewController.myMessageCellIdentifier, forIndexPath: indexPath) as! ChatMyMessageCell
            configureMyMessageCell(myMessageCell, atIndexPath: indexPath)
            cell = myMessageCell
        }
        else {
            let otherMessageCell = tableView.dequeueReusableCellWithIdentifier(ChatViewController.othersMessageCellIdentifier, forIndexPath: indexPath) as! ChatOthersMessageCell
            configureOthersMessageCell(otherMessageCell, atIndexPath: indexPath)
            cell = otherMessageCell
        }
        
        cell!.transform = CGAffineTransformMakeRotation(CGFloat(M_PI)) // 180 º
        return cell ?? UITableViewCell()

    }

    func tableView(tableView: UITableView, estimatedHeightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return UITableViewAutomaticDimension
    }

    func configureMyMessageCell(cell: ChatMyMessageCell, atIndexPath indexPath: NSIndexPath) {
        if let message = messages?[indexPath.row] {
            cell.messageLabel.text = message["message"] as? String ?? ""
            cell.dateLabel.text = message.createdAt!.relativeTimeString()
        }
    }
    
    func configureOthersMessageCell(cell: ChatOthersMessageCell, atIndexPath indexPath: NSIndexPath) {
        if let message = messages?[indexPath.row] {
            cell.messageLabel.text = message["message"] as? String ?? ""
            cell.dateLabel.text = message.createdAt!.relativeTimeString()
            
            if let user = message["user_from"] as? PFUser {
                
                
                if let otherUsrImage = otherUserImage {
                    cell.avatarImageView.image = otherUserImage
                }
                else {
                    cell.avatarImageView.image = UIImage(named: "no_photo")
                    user.fetchIfNeededInBackgroundWithBlock({ [weak self] (retrievedUser, error) -> Void in
                        if let strongSelf = self,
                            let avatarFile = retrievedUser?["avatar"] as? PFFile,
                            let thumbURL = NSURL(string: avatarFile.url!) {
                                
                                cell.avatarImageView.sd_setImageWithURL(thumbURL, placeholderImage: UIImage(named: "no_photo"), completed: {
                                    [weak self] (image, error, cacheType, url) -> Void in
                                    if (error == nil) {
                                        cell.avatarImageView.image = image
                                        strongSelf.otherUserImage = image
                                    }
                                })
                        }
                    })
                }
            }
        }
    }
    
    // MARK: - Cell height estimation
    
//    var prototypeCell: UITableViewCell!
//    
//    // Because we are supporting iOS 7, we need to perform a calculation of the cell content view size using autolayout.
//    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
//        let msgObject = messages![indexPath.row]
//        // lazily instanciate the prototype cell
//        if prototypeCell == nil { prototypeCell = tableView.dequeueReusableCellWithIdentifier(kLetGoConversationOthersMessagesCell) as? UITableViewCell }
//        self.configureCell(prototypeCell, fromTableView: tableView, atIndexPath: indexPath, withMessageObject: msgObject, type: .MyMessages) // no need to configure the image.
//        prototypeCell.layoutIfNeeded()
//        let size = prototypeCell.contentView.systemLayoutSizeFittingSize(UILayoutFittingCompressedSize)
//        return size.height + 1
//    }

    // MARK: - Allow copying text / highlighted state in cells
    
    func tableView(tableView: UITableView, shouldShowMenuForRowAtIndexPath indexPath: NSIndexPath) -> Bool { return true }
    func tableView(tableView: UITableView, canPerformAction action: Selector, forRowAtIndexPath indexPath: NSIndexPath, withSender sender: AnyObject) -> Bool { return action == "copy:" }
//    func tableView(tableView: UITableView, performAction action: Selector, forRowAtIndexPath indexPath: NSIndexPath, withSender sender: AnyObject!) {
//        if action == "copy:" {
//            if let cell = tableView.cellForRowAtIndexPath(indexPath) {
//                if let textLabel = cell.viewWithTag(kLetGoConversationCellTextTag) as? UILabel {
//                    UIPasteboard.generalPasteboard().string = textLabel.text
//                }
//            }
//        }
//    }

    // MARK: - Check changes in conversation.
    
    func didReceiveUserInteraction(notification: NSNotification) {
        if let userInfo = notification.object as? [NSObject: AnyObject], let conversationId = userInfo["c_id"] as? String {
            // It's the current conversation then refresh
            if self.letgoConversation?.conversationObject.objectId == conversationId {
                self.refreshMessages()
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
        let kbHeight = keyboardSize.height
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
            self.topViewTopConstraint.constant = -kbHeight
            self.bottomViewBottomConstraint.constant = kbHeight
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









