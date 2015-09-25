//
//  ChatViewController.swift
//  LetGo
//
//  Created by Ignacio Nieto Carvajal on 05/02/15.
//  Copyright (c) 2015 Ignacio Nieto Carvajal. All rights reserved.
//

import LGCoreKit
import Result
import UIKit

class ChatViewController: UIViewController, ChatSafeTipsViewDelegate, UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate {
    
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
    var chat: Chat
    var otherUser: User!
    var buyer: User!
    
    var newChat: Bool
    var isSendingMessage: Bool {
        didSet {
            self.sendButton.tintColor = isSendingMessage ? UIColor.lightGrayColor() : UIColor.blackColor()
        }
    }
    var alreadyAskedForRating: Bool
    
    init?(chat: Chat) {
        self.chat = chat

        // Figure out who's the other user and who's the buyer
        if let myUser = MyUserManager.sharedInstance.myUser(), let myUserId = myUser.objectId {
            if let userFrom = chat.userFrom, let userFromId = userFrom.objectId, let userTo = chat.userTo, let userToId = userTo.objectId {
                if myUserId == userFromId {
                    self.otherUser = userTo
                }
                else if myUserId == userToId {
                    self.otherUser = userFrom
                }
                
                if let productOwner = chat.product?.user, let productOwnerId = productOwner.objectId {
                    if productOwnerId == userFromId {
                        self.buyer = userTo
                    }
                    else if productOwnerId == userToId {
                        self.buyer = userFrom
                    }
                }
            }
        }
        self.newChat = false
        self.isSendingMessage = false
        self.alreadyAskedForRating = false

        super.init(nibName: "ChatViewController", bundle: nil)
        
        if self.otherUser == nil || self.buyer == nil {
            return nil
        }
        
        automaticallyAdjustsScrollViewInsets = false
        hidesBottomBarWhenPushed = true
    }
    
    convenience init?(product: Product) {
        // TODO: Refactor!
        var chat = LGChat()
        chat.product = product
        chat.userFrom = MyUserManager.sharedInstance.myUser()
        chat.userTo = product.user
        chat.msgUnreadCount = 0
        chat.messages = []
        self.init(chat: chat)

        self.newChat = true
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
        
        // navigation bar
        updateNavigationBarButtons()
        
        // appearance
        self.productImageView.image = nil
        self.tableView.transform = CGAffineTransformMakeRotation(CGFloat(M_PI)) // 180 º
        
        if let product = chat.product {
            // Load product info
            loadInformationFromProductObject(product)
            
            // Load messages
            enableLoadingMessagesInterface()
            
            // ... if needed
            if !newChat {
                loadMessages()
            }
            else {
                disableLoadingMessagesInterface()
                tableView.reloadData()
            }
        }
        else { // no conversation object? notify the error and get back.
            self.showAutoFadingOutMessageAlert(NSLocalizedString("chat_message_load_generic_error", comment: ""), completionBlock: { () -> Void in
                self.popBackViewController()
            })
        }
    }

    func loadMessages() {
        if let product = chat.product {
            ChatManager.sharedInstance.retrieveChatWithProduct(product, buyer: buyer) { [weak self] (result: Result<Chat, ChatRetrieveServiceError>) -> Void in
                if let strongSelf = self {
                    // Success
                    if let chat = result.value {
                        strongSelf.chat = chat
                    }
                    // Error
                    else if let error = result.error {
                        strongSelf.showAutoFadingOutMessageAlert(NSLocalizedString("chat_message_load_generic_error", comment: ""), completionBlock: { () -> Void in
                            strongSelf.popBackViewController()
                        })
                    }
                    strongSelf.disableLoadingMessagesInterface()
                    strongSelf.tableView.reloadData()
                    // scroll to the last message.
                    strongSelf.scrollToTopOfMessagesList(false)
                    strongSelf.tableView.reloadData()
                }
            }
        }
    }
    
    func refreshMessages() {
        var shouldEnabledLoadingInterface: Bool = true
        if chat.messages?.count > 0 {
            shouldEnabledLoadingInterface = false
        }
        if shouldEnabledLoadingInterface {
            enableLoadingMessagesInterface()
        }
        loadMessages()
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
        switch product.status {
        case .Pending, .Approved, .Discarded, .Sold, .SoldOld:
            productImageView.alpha = 1.0
        case .Deleted:
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
    
    func updateNavigationBarButtons() {
        let idxLastPageSeen = UserDefaultsManager.sharedInstance.loadChatSafetyTipsLastPageSeen() ?? 0
        let safetyTipsCompleted = idxLastPageSeen >= (ChatSafetyTipsView.tipsCount - 1)
        let tipsImageName = safetyTipsCompleted ? "ic_tips_black" : "ic_tips_alert"
        setLetGoRightButtonsWithImageNames([tipsImageName], andSelectors: ["showSafetyTips"])
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
        
        if let product = chat.product {
            
            // Update flag
            self.isSendingMessage = true
            
            // Send the message
            let message = self.messageTextfield.text.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceAndNewlineCharacterSet())
            ChatManager.sharedInstance.sendText(message, product: product, recipient: otherUser) { [weak self] (result: Result<Message, ChatSendMessageServiceError>) -> Void in
                if let strongSelf = self {
                    // Success
                    if let sentMessage = result.value {
                        // Update the data
                        var messages = strongSelf.chat.messages ?? []
                        messages.insert(sentMessage, atIndex: 0)
                        strongSelf.chat.messages = messages
                        
                        // Update UI and scroll to the bottom of the messages list
                        strongSelf.tableView.reloadData()
                        strongSelf.scrollToTopOfMessagesList(false)
                        //self.tableView.reloadData()
                        strongSelf.messageTextfield.text = ""
                        
                        // Since there's a 1 sec delay, we have to add an extra control here to avoid showing the rating view more than once
                        if !UserDefaultsManager.sharedInstance.loadAlreadyRated() && !strongSelf.alreadyAskedForRating {
                            strongSelf.alreadyAskedForRating = true
                            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, Int64(1.0 * Double(NSEC_PER_SEC))), dispatch_get_main_queue()) {
                                
                                // Hide message field keyboard
                                strongSelf.messageTextfield.resignFirstResponder()
                                
                                // Show app rating view
                                if let tabBarCtrl = strongSelf.tabBarController as? TabBarController {
                                    tabBarCtrl.showAppRatingViewIfNeeded()
                                }
                            }
                        }
                        
                        // Tracking
                        let myUser = MyUserManager.sharedInstance.myUser()
                        if let product = strongSelf.chat.product {
                            let trackerEvent = TrackerEvent.userMessageSent(product, user: myUser)
                            TrackerProxy.sharedInstance.trackEvent(trackerEvent)
                        }
                    }
                    // Error
                    else {
                        strongSelf.showAutoFadingOutMessageAlert(NSLocalizedString("chat_message_load_generic_error", comment: ""))
                    }
                    
                    // Update flag
                    strongSelf.isSendingMessage = false
                }
            }
        }
    }
    
    @IBAction func productButtonPressed(sender: AnyObject) {
        if let actualProduct = chat.product {
            switch actualProduct.status {
            
            // If product is deleted, then show a message
            case .Deleted:
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
                
            // Otherwise, push the product detail
            case .Pending, .Approved, .Discarded, .Sold, .SoldOld:

                // TODO: Refactor: this VM should be returned by ChatVC's VM where refactored to MVVM
                let productVM = ProductViewModel(product: actualProduct, tracker: TrackerProxy.sharedInstance)
                let vc = ProductViewController(viewModel: productVM)
                self.navigationController?.pushViewController(vc, animated: true)
            }
        }
    }
    
    // MARK: - ChatSafeTipsViewDelegate
    
    func chatSafeTipsViewDelegate(chatSafeTipsViewDelegate: ChatSafetyTipsView, didShowPage page: Int) {
        // Update the last page seen
        updateChatSafetyTipsLastPageSeen(page)
        
        // Update navigation bar buttons
        updateNavigationBarButtons()
    }
    
    // MARK: - UITableViewDelegate & DataSource methods
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let messages = chat.messages {
            return messages.count
        }
        return 0
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        // data
        let message = chat.messages?[indexPath.row]
        let messageUserId = message?.userId ?? ""
        
        var cell: UITableViewCell?
        if messageUserId == MyUserManager.sharedInstance.myUser()?.objectId { // message from me
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
        if let message = chat.messages?[indexPath.row] {
            cell.messageLabel.text = message.text ?? ""
            cell.dateLabel.text = message.updatedAt?.relativeTimeString() ?? ""
        }
    }
    
    func configureOthersMessageCell(cell: ChatOthersMessageCell, atIndexPath indexPath: NSIndexPath) {
        if let message = chat.messages?[indexPath.row] {
            cell.messageLabel.text = message.text ?? ""
            cell.dateLabel.text = message.updatedAt?.relativeTimeString() ?? ""
            
            if let avatar = otherUser.avatar {
                cell.avatarImageView.sd_setImageWithURL(avatar.fileURL, placeholderImage: UIImage(named: "no_photo"))
            }
            else {
                cell.avatarImageView.image = UIImage(named: "no_photo")
            }
            
            cell.avatarButtonPressed = { [weak self] in
                if let user = self?.otherUser {
                    let vc = EditProfileViewController(user: user)
                    self?.navigationController?.pushViewController(vc, animated: true)
                }
            }
        }
    }

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
        if let userInfo = notification.object as? [NSObject: AnyObject], let productId = userInfo["p"] as? String {
            // It's the current conversation (same product) then refresh
            if chat.product?.objectId == productId {
                refreshMessages()
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
    
    // MARK: - Private methods
    
    // MARK: > Safety tips
    
    /**
        Shows the safety tips.
    */
    @objc private func showSafetyTips() {
        if let navCtlView = navigationController?.view, let chatSafetyTipsView = ChatSafetyTipsView.chatSafetyTipsView() {
           
            // Delay is needed in order not to mess with the kb show/hide animation
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, Int64(0.5 * Double(NSEC_PER_SEC))), dispatch_get_main_queue()) {
                
                // Hide keyboard
                self.messageTextfield.resignFirstResponder()
                
                // Tips setup
                chatSafetyTipsView.delegate = self
                chatSafetyTipsView.dismissBlock = {
                    // Fade out
                    UIView.animateWithDuration(0.4, animations: { () -> Void in
                        chatSafetyTipsView.alpha = 0
                    }) { (_) -> Void in
                        // Remove from superview
                        chatSafetyTipsView.removeFromSuperview()
                            
                        // Show keyboard
                        self.messageTextfield.becomeFirstResponder()
                    }
                }
                
                // Add it w/o alpha
                let navCtlFrame = navCtlView.frame
                chatSafetyTipsView.frame = navCtlFrame
                chatSafetyTipsView.alpha = 0
                navCtlView.addSubview(chatSafetyTipsView)
                
                // Show safety tips
                self.updateChatSafetyTipsLastPageSeen(0)
                
                // Fade it in
                UIView.animateWithDuration(0.4, animations: { () -> Void in
                    chatSafetyTipsView.alpha = 1
                })
            }
        }
    }
    
    /**
        Updates the chat safety tips last page seen to the given one, if possible.
    
        :param: page The page.
    */
    private func updateChatSafetyTipsLastPageSeen(page: Int) {
        let idxLastPageSeen = UserDefaultsManager.sharedInstance.loadChatSafetyTipsLastPageSeen() ?? 0
        let maxPageSeen = max(idxLastPageSeen, page)
        UserDefaultsManager.sharedInstance.saveChatSafetyTipsLastPageSeen(maxPageSeen)
    }
}
