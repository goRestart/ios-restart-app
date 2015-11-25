//
//  ChatViewController.swift
//  LetGo
//
//  Created by Isaac Roldan on 23/11/15.
//  Copyright © 2015 Ambatana. All rights reserved.
//

import UIKit
import SlackTextViewController
import LGCoreKit

class ChatViewController: SLKTextViewController, ChatViewModelDelegate, ChatSafeTipsViewDelegate {

    
    // outlets & buttons
    @IBOutlet weak var productImageView: UIImageView!
    @IBOutlet weak var productNameLabel: UILabel!
    @IBOutlet weak var usernameLabel: UILabel!
    @IBOutlet weak var priceLabel: UILabel!
    @IBOutlet weak var loadingMessageActivityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var topView: UIView!
    @IBOutlet weak var topViewTopConstraint: NSLayoutConstraint!

    let productViewHeight: CGFloat = 80
    let navBarHeight: CGFloat = 64
    var productView = ChatProductView()
    private var selectedCellIndexPath: NSIndexPath?
    var viewModel: ChatViewModel
    var keyboardShown: Bool = false
    
    required init(viewModel: ChatViewModel) {
        self.viewModel = viewModel
        super.init(tableViewStyle: .Plain)
        self.viewModel.delegate = self
        hidesBottomBarWhenPushed = true
    }
    
    required init!(coder decoder: NSCoder!) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        registerNibs()
        setupUI()
        viewModel.loadMessages()
        view.addSubview(ChatProductView())
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "menuControllerWillShow:", name: UIMenuControllerWillShowMenuNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "menuControllerWillHide:", name: UIMenuControllerWillHideMenuNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "keyboardWillShow:", name: UIKeyboardWillShowNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "keyboardWillHide:", name: UIKeyboardWillHideNotification, object: nil)
    }
    
    
    // MARK: UI
    
    func setupUI() {
        view.backgroundColor = UIColor.whiteColor()
        tableView.clipsToBounds = true
        tableView.estimatedRowHeight = 120
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.separatorStyle = .None
        tableView.backgroundColor = StyleHelper.chatTableViewBgColor
        tableView.allowsSelection = false
        tableView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 128, right: 0)
        textView.placeholder = LGLocalizedString.chatMessageFieldHint
        textView.backgroundColor = UIColor.whiteColor()
        textInputbar.backgroundColor = UIColor.whiteColor()
        textInputbar.clipsToBounds = true
        textInputbar.translucent = false
        rightButton.tintColor = UIColor.blackColor()
        rightButton.titleLabel?.font = StyleHelper.chatSendButtonFont
        self.setLetGoNavigationBarStyle(viewModel.chat.product.name)
        updateSafetyTipBarButton()
        
        productView.frame = CGRect(x: 0, y: 64, width: view.width, height: 80)
        updateProductView()
        view.addSubview(productView)
        self.tableView.frame = CGRectMake(0, 80, tableView.width, tableView.height - 80)

    }
    
    func updateProductView() {
        productView.nameLabel.text = viewModel.chat.product.name
        productView.userLabel.text = viewModel.chat.product.user.publicUsername
        productView.priceLabel.text = viewModel.chat.product.formattedPrice()
        if let thumbURL = viewModel.chat.product.thumbnail?.fileURL {
            productView.imageButton.sd_setImageWithURL(thumbURL)
        }
    }
   
    func registerNibs() {
        let myMessageCellNib = UINib(nibName: ChatMyMessageCell.cellID(), bundle: nil)
        tableView.registerNib(myMessageCellNib, forCellReuseIdentifier: ChatMyMessageCell.cellID())
        let othersMessageCellNib = UINib(nibName: ChatOthersMessageCell.cellID(), bundle: nil)
        tableView.registerNib(othersMessageCellNib, forCellReuseIdentifier: ChatOthersMessageCell.cellID())
    }
    
    
    // MARK: Slack methods
    
    override func didPressRightButton(sender: AnyObject!) {
        let message = textView.text
        textView.text = ""
        viewModel.sendMessage(message)
    }

    
    // MARK: TableView Delegate
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.chat.messages.count
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let message = viewModel.chat.messages[indexPath.row]
        let drawer = ChatCellDrawerFactory.drawerForMessage(message)
        let cell = drawer.cell(tableView, atIndexPath: indexPath)
        drawer.draw(cell, message: message, avatar: viewModel.otherUser?.avatar)
        cell.transform = tableView.transform
        return cell
    }
    
    override func tableView(tableView: UITableView, estimatedHeightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return UITableViewAutomaticDimension
    }

    
    // MARK: ChatViewModelDelegate
    
    func didFailRetrievingChatMessages(error: ChatRetrieveServiceError) {
        switch (error) {
        case .Internal, .Network, .NotFound, .Unauthorized:
            showAutoFadingOutMessageAlert(LGLocalizedString.chatMessageLoadGenericError, completionBlock: { [weak self] () -> Void in
                self?.popBackViewController()
            })
        case .Forbidden:
            // logout the scammer!
            showAutoFadingOutMessageAlert(LGLocalizedString.logInErrorSendErrorGeneric, completionBlock: { (completion) -> Void in
                MyUserManager.sharedInstance.logout(nil)
            })
        }
    }
    
    func didSucceedRetrievingChatMessages() {
        tableView.reloadData()
    }

    func didFailSendingMessage(error: ChatSendMessageServiceError) {
        switch (error) {
        case .Internal, .Network, .NotFound, .Unauthorized:
            showAutoFadingOutMessageAlert(LGLocalizedString.chatMessageLoadGenericError)
        case .Forbidden:
            showAutoFadingOutMessageAlert(LGLocalizedString.logInErrorSendErrorGeneric, completionBlock: { (completion) -> Void in
                MyUserManager.sharedInstance.logout(nil)
            })
        }
    }
    
    func didSucceedSendingMessage() {
        tableView.beginUpdates()
        let indexPath = NSIndexPath(forRow: 0, inSection: 0)
        tableView.insertRowsAtIndexPaths([indexPath], withRowAnimation: .Automatic)
        tableView.endUpdates()
    }
}


// MARK: - Animate ProductView with keyboard Extension
extension ChatViewController {
    
    func keyboardWillShow(notification: NSNotification) {
        showProductView(false)
    }
    
    func keyboardWillHide(notification: NSNotification) {
        showProductView(true)
    }
    
    func showProductView(show: Bool) {
        UIView.animateWithDuration(0.25) {
            self.productView.top = show ? 64 : -80
        }
        keyboardShown = !show
        view.setNeedsLayout()
        view.layoutIfNeeded()
    }
    
    // Need to override this to fix the position of the Slack tableView
    // if you have a "header" view below the navBar
    // It is an open issue in the Library https://github.com/slackhq/SlackTextViewController/issues/137
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        let bottomInset = keyboardShown ? navBarHeight : productViewHeight + navBarHeight
        self.tableView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: bottomInset, right: 0)
    }
}


// MARK: > Copy/Paste feature Extension

extension ChatViewController {
    
    // MARK: UIMenuController observer
    
    /**
    Listen to UIMenuController Will Show notification and update the menu position if needed.
    By default, the menu is shown in the middle of the tableView, this method repositions it to the middle of the bubble
    
    - parameter notification: NSNotification received
    */
    func menuControllerWillShow(notification: NSNotification) {
        guard let indexPath = selectedCellIndexPath else { return }
        guard let cell = tableView.cellForRowAtIndexPath(indexPath) as? ChatBubbleCell else { return }
        selectedCellIndexPath = nil
        NSNotificationCenter.defaultCenter().removeObserver(self, name: UIMenuControllerWillShowMenuNotification, object: nil)
        let menu = UIMenuController.sharedMenuController()
        menu.setMenuVisible(false, animated: false)
        let newFrame = tableView.convertRect(cell.bubbleView.frame, fromView: cell)
        menu.setTargetRect(newFrame, inView: tableView)
        menu.setMenuVisible(true, animated: true)
    }
    
    
    func menuControllerWillHide(notification: NSNotification) {
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "menuControllerWillShow:", name: UIMenuControllerWillShowMenuNotification, object: nil)
    }
    
    override func tableView(tableView: UITableView, shouldShowMenuForRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        selectedCellIndexPath = indexPath //Need to save the currently selected cell to reposition the menu later
        return true
    }
    
    override func tableView(tableView: UITableView, canPerformAction action: Selector, forRowAtIndexPath indexPath: NSIndexPath, withSender sender: AnyObject?) -> Bool {
        if action == "copy:" {
            guard let cell = tableView.cellForRowAtIndexPath(indexPath) else { return false }
            cell.setSelected(true, animated: true)
            return true
        }
        return false
    }
    
    override  func tableView(tableView: UITableView, performAction action: Selector, forRowAtIndexPath indexPath: NSIndexPath, withSender sender: AnyObject?) {
        if action == "copy:" {
            UIPasteboard.generalPasteboard().string = viewModel.chat.messages[indexPath.row].text
        }
    }

}


// MARK: > SafetyTips Extension

extension ChatViewController {
 
    func updateSafetyTipBarButton() {
        let tipsImageName = viewModel.safetyTypesCompleted ? "ic_tips_black" : "ic_tips_alert"
        setLetGoRightButtonsWithImageNames([tipsImageName], andSelectors: ["showSafetyTips"])
    }
    
    func chatSafeTipsViewDelegate(chatSafeTipsViewDelegate: ChatSafetyTipsView, didShowPage page: Int) {
        viewModel.updateChatSafetyTipsLastPageSeen(page)
        updateSafetyTipBarButton()
    }
    
   
    @objc private func showSafetyTips() {
        guard let navCtlView = navigationController?.view else { return }
        guard let chatSafetyTipsView = ChatSafetyTipsView.chatSafetyTipsView() else { return }
        
        // Delay is needed in order not to mess with the kb show/hide animation
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, Int64(0.5 * Double(NSEC_PER_SEC))), dispatch_get_main_queue()) {
            
            self.textView.resignFirstResponder()
            chatSafetyTipsView.delegate = self
            chatSafetyTipsView.dismissBlock = {
                // Fade out
                UIView.animateWithDuration(0.4, animations: { () -> Void in
                    chatSafetyTipsView.alpha = 0
                    }) { (_) -> Void in
                        chatSafetyTipsView.removeFromSuperview()
                        self.textView.becomeFirstResponder()
                }
            }
            
            // Add it w/o alpha
            let navCtlFrame = navCtlView.frame
            chatSafetyTipsView.frame = navCtlFrame
            chatSafetyTipsView.alpha = 0
            navCtlView.addSubview(chatSafetyTipsView)
            
            self.viewModel.updateChatSafetyTipsLastPageSeen(0)
            
            UIView.animateWithDuration(0.4, animations: { () -> Void in
                chatSafetyTipsView.alpha = 1
            })
        }
    }
}
