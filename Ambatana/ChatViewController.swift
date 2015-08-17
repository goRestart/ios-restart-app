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
    @IBOutlet weak var topView: UIView!
    @IBOutlet weak var topViewTopConstraint: NSLayoutConstraint!
    @IBOutlet weak var bottomViewBottomConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var messageView: UIView!
    @IBOutlet weak var messageLabel: UILabel!
    
    // data
    var letgoConversation: LetGoConversation?
    var messages: [PFObject]?
    var otherUser: PFUser?
    var product: Product?
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
        sendButton.setTitle(NSLocalizedString("chat_send_button", comment: ""), forState: .Normal)
        messageTextfield.placeholder = NSLocalizedString("chat_message_field_hint", comment: "")
        
        messageLabel.text = NSLocalizedString("common_product_not_available", comment: "")
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
            if let actualProduct = conversationObject["product"] as? PAProduct {
                product = actualProduct
                loadInformationFromProductObject(actualProduct)
            } else { // We don't have information about the product itself... This shouldn't happen.
                self.showAutoFadingOutMessageAlert(NSLocalizedString("chat_message_load_generic_error", comment: ""), completionBlock: { () -> Void in
                    self.popBackViewController()
                })
            }
            
        } else { // no conversation object? notify the error and get back.
            self.showAutoFadingOutMessageAlert(NSLocalizedString("chat_message_load_generic_error", comment: ""), completionBlock: { () -> Void in
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
    func loadInformationFromProductObject(product: Product) {
        // product image
        if let thumbURL = product.thumbnail?.fileURL {
            productImageView.sd_setImageWithURL(thumbURL)
        }
        // > if the product is deleted, add some alpha
        if product.status == .Deleted {
            productImageView.alpha = 0.2
        }
        
        // product name & navbar title
        self.productNameLabel.text = product.name ?? ""
        self.setLetGoNavigationBarStyle(title: self.productNameLabel.text)
                
        // price
        self.priceLabel.text = product.formattedPrice()
        
        // product owner
        if let user = product.user, let myUser = MyUserManager.sharedInstance.myUser() {
            usernameLabel.text = user.publicUsername ?? ""
        }
        else {
            self.usernameLabel.text = ""
        }
    }
    
    // MARK: - Loading interface
    
    func enableLoadingMessagesInterface() {
        tableView.hidden = true
        loadingMessageActivityIndicator.startAnimating()
        loadingMessageActivityIndicator.hidden = false
    }

    func disableLoadingMessagesInterface() {
        tableView.hidden = false
        loadingMessageActivityIndicator.hidden = true
        loadingMessageActivityIndicator.startAnimating()
    }
    
    // MARK: - Button actions
    
    @IBAction func sendMessage(sender: AnyObject) {
        // safety checks
        if isSendingMessage { return }
        if count(self.messageTextfield.text.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceAndNewlineCharacterSet())) < 1 { return }
        if self.otherUser == nil || self.letgoConversation?.conversationObject == nil || self.product == nil { showAutoFadingOutMessageAlert(NSLocalizedString("chat_message_load_generic_error", comment: ""))
            return
        }
        
        // enable loading interface.
        self.isSendingMessage = true
        
        // send message
        ChatManager.sharedInstance.addTextMessage(self.messageTextfield.text.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceAndNewlineCharacterSet()), toUser: self.otherUser!, inConversation: letgoConversation!.conversationObject, fromProduct: self.product!, isOffer: false) { [weak self] (success, newlyCreatedMessageObject) -> Void in
            if let strongSelf = self {
                if success {
                    strongSelf.messages!.insert(newlyCreatedMessageObject!, atIndex: 0)
                    
                    // update UI and scroll to the bottom of the messages list
                    strongSelf.tableView.reloadData()
                    strongSelf.scrollToTopOfMessagesList(false)
                    //self.tableView.reloadData()
                    strongSelf.messageTextfield.text = ""
                    
                    // Tracking
                    let myUser = MyUserManager.sharedInstance.myUser()
                    if let actualProduct = strongSelf.product {
                        if strongSelf.askQuestion {
                            let trackerEvent = TrackerEvent.productAskQuestion(actualProduct, user: myUser)
                            TrackerProxy.sharedInstance.trackEvent(trackerEvent)
                        }
                        let trackerEvent = TrackerEvent.userMessageSent(actualProduct, user: myUser)
                        TrackerProxy.sharedInstance.trackEvent(trackerEvent)
                    }
                }
                else {
                    strongSelf.showAutoFadingOutMessageAlert(NSLocalizedString("chat_message_load_generic_error", comment: ""))
                }
                // disable loading interface
                strongSelf.isSendingMessage = false
            }
        }
    }
    
    @IBAction func productButtonPressed(sender: AnyObject) {
        if let actualProduct = product {
            
            // If product is deleted, then show a message
            if actualProduct.status == .Deleted {

                // Fade it in
                self.messageView.alpha = 0
                self.messageView.hidden = false
                UIView.animateWithDuration(0.5, animations: { [weak self] () -> Void in
                    self?.messageView.alpha = 0.95
                }, completion: { (success) -> Void in
                    
                    // Fade it out after some delay
                    let delayTime = dispatch_time(DISPATCH_TIME_NOW, Int64(2 * Double(NSEC_PER_SEC)))
                    dispatch_after(delayTime, dispatch_get_main_queue()) {
                       
                        UIView.animateWithDuration(0.5, animations: { [weak self] () -> Void in
                            self?.messageView.alpha = 0
                            }, completion: { [weak self] (success) -> Void in
                                self?.messageView.hidden = true
                        })
                    }
                })
            }
            // Otherwise, push the product detail
            else {
                // TODO: Refactor: this VM should be returned by ChatVC's VM where refactored to MVVM
                let productVM = ProductViewModel(product: actualProduct, tracker: TrackerProxy.sharedInstance)
                let vc = ProductViewController(viewModel: productVM)
                self.navigationController?.pushViewController(vc, animated: true)
            }
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
            
            if let user = message["user_from"] as? User {
                if let avatar = user.avatar {
                    cell.avatarImageView.sd_setImageWithURL(avatar.fileURL, placeholderImage: UIImage(named: "no_photo"))
                }
                else {
                    cell.avatarImageView.image = UIImage(named: "no_photo")
                }
                
                cell.avatarButtonPressed = { [weak self] in
                    let vc = EditProfileViewController(user: user)
                    self?.navigationController?.pushViewController(vc, animated: true)
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









