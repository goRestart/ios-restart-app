//
//  ChatViewController.swift
//  Ambatana
//
//  Created by Ignacio Nieto Carvajal on 05/02/15.
//  Copyright (c) 2015 Ignacio Nieto Carvajal. All rights reserved.
//

import UIKit

private let kAmbatanaConversationMyMessagesCell = "MyMessagesCell"
private let kAmbatanaConversationOthersMessagesCell = "OthersMessagesCell"
private let kAmbatanaEstimatedHeightForChatCells: CGFloat = 120.0
private let kAmbatanaChatScrollingOffsetSpan: CGFloat = 72 // 20 (status bar height) + 44 (navigation controller height) + 8 (small span to leave some space)
private let kAmbatanaChatBubbleCornerRadius: CGFloat = 4.0

private let kAmbatanaConversationProductImageTag = 1
private let kAmbatanaConversationProductUserNameTag = 2
private let kAmbatanaConversationProductProductNameTag = 3
private let kAmbatanaConversationProductRelativeDateTag = 4
private let kAmbatanaConversationProductPriceTag = 5

private let kAmbatanaConversationCellBubbleTag = 1
private let kAmbatanaConversationCellTextTag = 2
private let kAmbatanaConversationCellRelativeTimeTag = 3
private let kAmbatanaConversationCellAvatarTag = 4


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
    
    // data
    var ambatanaConversation: AmbatanaConversation?
    var messages: [PFObject]?
    var otherUser: PFUser?
    var productObject: PFObject?
    var otherUserImage: UIImage?
    var isSendingMessage: Bool = false {
        didSet {
            self.messageTextfield.userInteractionEnabled = !isSendingMessage
            self.sendButton.tintColor = isSendingMessage ? UIColor.lightGrayColor() : UIColor.blackColor()
            self.sendButton.userInteractionEnabled = !isSendingMessage
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // internationalization
        sendButton.setTitle(translate("send"), forState: .Normal)
        messageTextfield.placeholder = translate("type_your_message_here")
        loadingMessagesLabel.text = translate("loading_messages")
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)

        // track keyboard appearance and size change
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "keyboardWillShow:", name: UIKeyboardWillShowNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "keyboardWillShow:", name: UIKeyboardDidShowNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "keyboardWillHide:", name: UIKeyboardWillHideNotification, object: nil)
        
        // appearance
        self.productImageView.image = UIImage.randomImageGradientOfSize(self.productImageView.frame.size)
        
        if ambatanaConversation != nil {
            let conversationObject = ambatanaConversation!.conversationObject
            enableLoadingMessagesInterface()
            // load previous messages
            ChatManager.sharedInstance.loadMessagesFromConversation(conversationObject, completion: { (success, messages) -> Void in
                if success {
                    self.messages = messages!
                } else { // no messages yet. Empty conversation view.
                    self.messages = []
                }
                self.disableLoadingMessagesInterface()
                self.tableView.reloadData()
                // scroll to the last message.
                self.scrollToBottomOfMessagesList(false)
            })
            
            // load the other user.
            // According to specification, if I am selling the product, I am the user_to, and the other user is the user_from
            var otherUserField = self.ambatanaConversation!.amISellingTheProduct ? "user_from" : "user_to"
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
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
    
    // Loads the fields referred to the product object in view's header.
    func loadInformationFromProductObject(retrievedObject: PFObject!) {
        // product image
        if let imageFile = retrievedObject?[kAmbatanaProductFirstImageKey] as? PFFile {
            // try to retrieve image from thumbnail first.
            let thumbnailURL = ImageManager.sharedInstance.calculateThumnbailImageURLForProductImage(retrievedObject.objectId, imageURL: imageFile.url)
            ImageManager.sharedInstance.retrieveImageFromURLString(thumbnailURL, completion: { (success, image) -> Void in
                if success {
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
        self.setAmbatanaNavigationBarStyle(title: self.productNameLabel.text, includeBackArrow: true)
        
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
                    self.usernameLabel.text = translate("by") + " " + (retrievedOwner!["username_public"] as? String ?? translate("user"))
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
        if countElements(self.messageTextfield.text) < 1 { return }
        if self.otherUser == nil || self.ambatanaConversation?.conversationObject == nil || self.productObject == nil { showAutoFadingOutMessageAlert(translate("unable_send_message")); return }
        
        // enable loading interface.
        self.isSendingMessage = true
        
        // send message
        ChatManager.sharedInstance.addTextMessage(self.messageTextfield.text, toUser: self.otherUser!, inConversation: ambatanaConversation!.conversationObject, fromProduct: self.productObject!) { (success, newlyCreatedMessageObject) -> Void in
            if success {
                self.messages!.append(newlyCreatedMessageObject!)
                
                // update UI and scroll to the bottom of the messages list
                self.tableView.reloadData()
                self.scrollToBottomOfMessagesList(false)
                self.messageTextfield.text = ""
            } else {
                self.showAutoFadingOutMessageAlert(translate("unable_send_message"))
            }
            // disable loading interface
            self.isSendingMessage = false
        }
    }
    
    // MARK: - UITableViewDelegate & DataSource methods
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return messages != nil ? messages!.count : 0
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        // data
        let msgObject = messages![indexPath.row]
        let userFrom = msgObject["user_from"] as PFUser
        
        // cell elements
        var cell: UITableViewCell?
        
        if userFrom.objectId == PFUser.currentUser().objectId { // message from me
            cell = tableView.dequeueReusableCellWithIdentifier(kAmbatanaConversationMyMessagesCell, forIndexPath: indexPath) as? UITableViewCell
        } else {
            cell = tableView.dequeueReusableCellWithIdentifier(kAmbatanaConversationOthersMessagesCell, forIndexPath: indexPath) as? UITableViewCell

            // configure other user's avatar.
            if let userAvatarView = cell?.viewWithTag(kAmbatanaConversationCellAvatarTag) as? UIImageView {
                userAvatarView.image = self.otherUserImage
                if self.otherUserImage == nil { // lazily load the other user's pic, only when needed!
                    userFrom.fetchIfNeededInBackgroundWithBlock({ (retrievedUserFrom, error) -> Void in
                        if let avatarFile = retrievedUserFrom["avatar"] as? PFFile {
                            ImageManager.sharedInstance.retrieveImageFromParsePFFile(avatarFile, completion: { (success, image) -> Void in
                                if success { userAvatarView.image = image; self.otherUserImage = image }
                                else { userAvatarView.image = UIImage(named: "no_photo"); self.otherUserImage = userAvatarView.image }
                                // image appearance
                                userAvatarView.layer.cornerRadius = userAvatarView.frame.size.width / 2.0
                                userAvatarView.clipsToBounds = true
                                }, andAddToCache: true)
                        }
                    })
                }
                
            }
        }
        
        // configure common cell elements
        
        // bubble appearance
        if let bubbleLabel = cell?.viewWithTag(kAmbatanaConversationCellBubbleTag) {
            bubbleLabel.layer.cornerRadius = kAmbatanaChatBubbleCornerRadius
        }
        // message
        if let msgLabel = cell?.viewWithTag(kAmbatanaConversationCellTextTag) as? UILabel {
            msgLabel.text = msgObject["message"] as? String ?? ""
        }
        // configure date
        if let dateLabel = cell?.viewWithTag(kAmbatanaConversationCellRelativeTimeTag) as? UILabel {
            dateLabel.text = msgObject.createdAt.relativeTimeString()
        }
            
        // adjust cell size to fit the contents
        cell?.setNeedsUpdateConstraints()
        cell?.updateConstraintsIfNeeded()
        
        // adjust multi-line labels
        if let multilineLabel = cell?.viewWithTag(kAmbatanaConversationCellTextTag) as? UILabel {
            multilineLabel.preferredMaxLayoutWidth = CGRectGetWidth(tableView.bounds)
        }
        
        return cell ?? UITableViewCell()

    }
    
    /*
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        
    }
    */

    func tableView(tableView: UITableView, estimatedHeightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return kAmbatanaEstimatedHeightForChatCells
    }
    
    // MARK: - UI/UX Scrolling responding to UITextField edition
    
    var originalTableViewFrame = CGRectZero
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        originalTableViewFrame = self.tableView.frame
    }
    
    func scrollToBottomOfMessagesList(animated: Bool) {
        self.tableView.scrollRectToVisible(CGRectMake(0, self.tableView.contentSize.height - self.tableView.bounds.size.height, self.tableView.bounds.size.width, self.tableView.bounds.size.height), animated: animated)
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        if countElements(textField.text) > 0 { self.sendMessage(self.sendButton) }
        return true
    }
    
    func keyboardWillShow(notification: NSNotification) {
        moveViewInResponseToKeyboardAppearing(true, withNotification: notification)
    }
 
    func keyboardWillHide(notification: NSNotification) {
        moveViewInResponseToKeyboardAppearing(false, withNotification: notification)
    }
    
    func moveViewInResponseToKeyboardAppearing(appearing: Bool, withNotification notification: NSNotification) {
        if !appearing {
            UIView.animateWithDuration(0.5, animations: { () -> Void in
                self.bottomView.transform = CGAffineTransformIdentity
                self.tableView.frame = self.originalTableViewFrame
            })
            println("restoring frame!")
        } else {
            let userInfo = notification.userInfo!
            var keyboardSize = (userInfo[UIKeyboardFrameEndUserInfoKey] as? NSValue ?? NSValue(CGRect: CGRectZero)).CGRectValue().size
            UIView.animateWithDuration(0.5, animations: { () -> Void in
                self.bottomView.transform = CGAffineTransformMakeTranslation(0, -keyboardSize.height)
                self.tableView.frame.size.height -= keyboardSize.height
            }, completion: { (success) -> Void in
                self.scrollToBottomOfMessagesList(false)
            })
        }
        
    }

    override func touchesBegan(touches: NSSet, withEvent event: UIEvent) {
        self.view.resignFirstResponder()
        self.view.endEditing(true)
    }
}









