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

class ChatViewController: SLKTextViewController {

    let productViewHeight: CGFloat = 80
    let navBarHeight: CGFloat = 64
    var productView = ChatProductView()
    var selectedCellIndexPath: NSIndexPath?
    var viewModel: ChatViewModel
    var keyboardShown: Bool = false
    var activityIndicator = UIActivityIndicatorView(activityIndicatorStyle: .Gray)
    
    required init(viewModel: ChatViewModel) {
        self.viewModel = viewModel
        super.init(tableViewStyle: .Plain)
        self.viewModel.delegate = self
        setReachabilityEnabled(true)
        hidesBottomBarWhenPushed = true
    }
    
    required init!(coder decoder: NSCoder!) {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit {
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        ChatCellDrawerFactory.registerCells(tableView)
        setupUI()
        setupToastView()

        view.addSubview(ChatProductView())

        NSNotificationCenter.defaultCenter().addObserver(self, selector: "menuControllerWillShow:",
            name: UIMenuControllerWillShowMenuNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "menuControllerWillHide:",
            name: UIMenuControllerWillHideMenuNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "keyboardWillShow:",
            name: UIKeyboardWillShowNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "keyboardWillHide:",
            name: UIKeyboardWillHideNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "didReceiveUserInteraction:",
            name: PushManager.Notification.DidReceiveUserInteraction.rawValue, object: nil)
    }

    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        updateReachableAndToastViewVisibilityIfNeeded()
        if !viewModel.isNewChat { refreshMessages() }
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)

        if viewModel.fromMakeOffer &&
            PushPermissionsManager.sharedInstance.shouldShowPushPermissionsAlertFromViewController(self,
                prePermissionType: .Chat){
                    viewModel.fromMakeOffer = false
                    PushPermissionsManager.sharedInstance.showPushPermissionsAlertFromViewController(self,
                        prePermissionType: .Chat)
        } else {
            textView.becomeFirstResponder()
        }
    }

    func showActivityIndicator(show: Bool) {
        show ? activityIndicator.startAnimating() : activityIndicator.stopAnimating()
    }
    
    func refreshMessages() {
        showActivityIndicator(true)
        viewModel.retrieveFirstPage()
    }

    
    // MARK: > UI
    
    func setupUI() {
        view.backgroundColor = StyleHelper.chatTableViewBgColor
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
        rightButton.tintColor = StyleHelper.chatSendButtonTintColor
        rightButton.titleLabel?.font = StyleHelper.chatSendButtonFont
        self.setLetGoNavigationBarStyle(viewModel.chat.product.name)
        updateSafetyTipBarButton()
        
        let tap = UITapGestureRecognizer(target: self, action: "openProductDetail")
        productView.frame = CGRect(x: 0, y: 64, width: view.width, height: 80)
        productView.addGestureRecognizer(tap)
        updateProductView()
        view.addSubview(productView)
        self.tableView.frame = CGRectMake(0, 80, tableView.width, tableView.height - 80)
        
        view.addSubview(activityIndicator)
        activityIndicator.frame = CGRect(x: 0, y: 0, width: 100, height: 100)
        activityIndicator.center = view.center
        keyboardPanningEnabled = false
    }
    
    func updateProductView() {
        productView.nameLabel.text = viewModel.chat.product.name
        productView.userLabel.text = viewModel.chat.product.user.name
        productView.priceLabel.text = viewModel.chat.product.priceString()
        if let thumbURL = viewModel.chat.product.thumbnail?.fileURL {
            switch viewModel.chat.product.status {
            case .Pending, .Approved, .Discarded, .Sold, .SoldOld:
                productView.imageButton.alpha = 1.0
            case .Deleted:
                productView.imageButton.alpha = 0.2
            }
            productView.imageButton.sd_setImageWithURL(thumbURL)
        }
    }

    
    // MARK: > Navigation
    
    func openProductDetail() {
        switch viewModel.chat.product.status {
        case .Deleted:
            productView.showProductRemovedError(LGLocalizedString.commonProductNotAvailable)
            let delayTime = dispatch_time(DISPATCH_TIME_NOW, Int64(2.5 * Double(NSEC_PER_SEC)))
            dispatch_after(delayTime, dispatch_get_main_queue()) {
                self.productView.hideError()
            }
        case .Sold, .SoldOld:
            productView.showProductSoldError(LGLocalizedString.commonProductSold)
            let delayTime = dispatch_time(DISPATCH_TIME_NOW, Int64(2.5 * Double(NSEC_PER_SEC)))
            dispatch_after(delayTime, dispatch_get_main_queue()) {
                self.productView.hideError()
            }
        case .Pending, .Approved, .Discarded:
            let vc = ProductViewController(viewModel: viewModel.productViewModel)
            self.navigationController?.pushViewController(vc, animated: true)
        }
    }
    
    
    // MARK: > Interaction from push
    // This method will be called when the user interacts with a chat push notification
    // or a message push is received while watching a chat
    func didReceiveUserInteraction(notification: NSNotification) {
        guard let userInfo = notification.object as? [NSObject: AnyObject] else { return }
        viewModel.didReceiveUserInteractionWithInfo(userInfo)
    }

    
    // MARK: > Slack methods
    
    override func didPressRightButton(sender: AnyObject!) {
        let message = textView.text
        textView.text = ""
        viewModel.sendMessage(message)
    }

    
    // MARK: > TableView Delegate
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.objectCount
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        guard indexPath.row < viewModel.objectCount else {
            return UITableViewCell()
        }
        let message = viewModel.messageAtIndex(indexPath.row)
        let drawer = ChatCellDrawerFactory.drawerForMessage(message)
        let cell = drawer.cell(tableView, atIndexPath: indexPath)
        
        drawer.draw(cell, message: message, avatar: viewModel.avatarForMessage(), delegate: self)
        cell.transform = tableView.transform

        viewModel.setCurrentIndex(indexPath.row)
        
        return cell
    }
    
    override func tableView(tableView: UITableView, estimatedHeightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return UITableViewAutomaticDimension
    }
    
    override func scrollViewWillBeginDragging(scrollView: UIScrollView) {
        textView.resignFirstResponder()
    }
    
    /**
    Slack Caches the text in the textView if you close the view before sending
    Need to override this method to set the cache key to the product id
    so the cache is not shared between products chats
    
    - returns: Cache key String
    */
    override func keyForTextCaching() -> String! {
        return "\(viewModel.chat.product.objectId) + \(viewModel.chat.userTo.objectId)"
    }

    
    // MARK: > Rating
    
    func askForRating() {
        viewModel.alreadyAskedForRating = true
        let delay = Int64(1.0 * Double(NSEC_PER_SEC))
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, delay), dispatch_get_main_queue()) { [weak self] in
            self?.textView.resignFirstResponder()
            guard let tabBarCtrl = self?.tabBarController as? TabBarController else { return }
            tabBarCtrl.showAppRatingViewIfNeeded()
        }
    }
}


// MARK: - ChatViewModelDelegate

extension ChatViewController: ChatViewModelDelegate {
    
    
    // MARK: > Retrieve Messages
    
    func didFailRetrievingChatMessages() {
        showActivityIndicator(false)
        showAutoFadingOutMessageAlert(LGLocalizedString.chatMessageLoadGenericError) { [weak self] in
            self?.popBackViewController()
        }
    }

    func didSucceedRetrievingChatMessages() {
        showActivityIndicator(false)
        if viewModel.shouldShowSafetyTipes { showSafetyTips() }
        tableView.reloadData()
    }

    func updateAfterReceivingMessagesAtPositions(positions: [Int]) {

        guard positions.count > 0 else { return }

        if viewModel.shouldShowSafetyTipes { showSafetyTips() }

        let newPositions: [NSIndexPath] = positions.map({NSIndexPath(forRow: $0, inSection: 0)})

        tableView.beginUpdates()
        tableView.insertRowsAtIndexPaths(newPositions, withRowAnimation: .Automatic)
        tableView.endUpdates()
    }


    // MARK: > Send Message
    
    func didFailSendingMessage() {
        showAutoFadingOutMessageAlert(LGLocalizedString.chatMessageLoadGenericError)
    }
    
    func didSucceedSendingMessage() {
        if viewModel.shouldAskForRating { askForRating() }

        if UserDefaultsManager.sharedInstance.loadAlreadyRated() &&
            PushPermissionsManager.sharedInstance.shouldShowPushPermissionsAlertFromViewController(self,
                prePermissionType: .Chat){
                    textView.resignFirstResponder()
                    PushPermissionsManager.sharedInstance.showPushPermissionsAlertFromViewController(self,
                        prePermissionType: .Chat)
        }

        tableView.beginUpdates()
        let indexPath = NSIndexPath(forRow: 0, inSection: 0)
        tableView.insertRowsAtIndexPaths([indexPath], withRowAnimation: .Automatic)
        tableView.endUpdates()
    }
}


// MARK: - ChatOthersMessageCellDelegate

extension ChatViewController: ChatOthersMessageCellDelegate {
    
    func didTapOnUserAvatar() {
        guard let user = viewModel.otherUser else { return }
        let vc = EditProfileViewController(user: user, source: .Chat)
        self.navigationController?.pushViewController(vc, animated: true)
    }
}


// MARK: - Animate ProductView with keyboard

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


// MARK: - Copy/Paste feature

extension ChatViewController {
    
    /**
    Listen to UIMenuController Will Show notification and update the menu position if needed.
    By default, the menu is shown in the middle of the tableView, this method repositions it to the middle of the bubble
    
    - parameter notification: NSNotification received
    */
    func menuControllerWillShow(notification: NSNotification) {
        guard let indexPath = selectedCellIndexPath else { return }
        guard let cell = tableView.cellForRowAtIndexPath(indexPath) as? ChatBubbleCell else { return }
        selectedCellIndexPath = nil
        NSNotificationCenter.defaultCenter().removeObserver(self,
            name: UIMenuControllerWillShowMenuNotification, object: nil)
        
        let menu = UIMenuController.sharedMenuController()
        menu.setMenuVisible(false, animated: false)
        let newFrame = tableView.convertRect(cell.bubbleView.frame, fromView: cell)
        menu.setTargetRect(newFrame, inView: tableView)
        menu.setMenuVisible(true, animated: true)
    }
    
    
    func menuControllerWillHide(notification: NSNotification) {
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "menuControllerWillShow:",
            name: UIMenuControllerWillShowMenuNotification, object: nil)
    }
    
    override func tableView(tableView: UITableView, shouldShowMenuForRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        selectedCellIndexPath = indexPath //Need to save the currently selected cell to reposition the menu later
        return true
    }
    
    override func tableView(tableView: UITableView, canPerformAction action: Selector, forRowAtIndexPath
        indexPath: NSIndexPath, withSender sender: AnyObject?) -> Bool {
        if action == "copy:" {
            guard let cell = tableView.cellForRowAtIndexPath(indexPath) else { return false }
            cell.setSelected(true, animated: true)
            return true
        }
        return false
    }
    
    override  func tableView(tableView: UITableView, performAction action: Selector, forRowAtIndexPath
        indexPath: NSIndexPath, withSender sender: AnyObject?) {
        if action == "copy:" {
            UIPasteboard.generalPasteboard().string =  viewModel.textOfMessageAtIndex(indexPath.row)
        }
    }
}


// MARK: - ChatSafeTipsViewDelegate

extension ChatViewController: ChatSafeTipsViewDelegate {
 
    func updateSafetyTipBarButton() {
        let tipsImageName = viewModel.safetyTipsCompleted ? "ic_tips_black" : "ic_tips_alert"
        setLetGoRightButtonWith(imageName: tipsImageName, renderingMode: .AlwaysOriginal, selector: "showSafetyTips")
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
