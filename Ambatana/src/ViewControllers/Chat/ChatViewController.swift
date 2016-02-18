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

    var directAnswersController: DirectAnswersPresenter

    // MARK: - View lifecycle
    
    required init(viewModel: ChatViewModel) {
        self.viewModel = viewModel
        self.directAnswersController = DirectAnswersPresenter()
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
        setupDirectAnswers()

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
        viewModel.active = true
    }

    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        viewModel.active = false
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)

        viewModel.didAppear()
    }


    // MARK: - Public methods

    // This method will be called when the user interacts with a chat push notification
    // or a message push is received while watching a chat
    func didReceiveUserInteraction(notification: NSNotification) {
        guard let userInfo = notification.object as? [NSObject: AnyObject] else { return }
        viewModel.didReceiveUserInteractionWithInfo(userInfo)
    }

    func isMatchingDeepLink(deepLink: DeepLink) -> Bool {
        return viewModel.isMatchingDeepLink(deepLink)
    }


    // MARK: > Slack methods
    
    override func didPressRightButton(sender: AnyObject!) {
        let message = textView.text
        textView.text = ""
        viewModel.sendMessage(message)
    }

    /**
     Slack Caches the text in the textView if you close the view before sending
     Need to override this method to set the cache key to the product id
     so the cache is not shared between products chats

     - returns: Cache key String
     */
    override func keyForTextCaching() -> String! {
        return viewModel.keyForTextCaching
    }
    
    // MARK: > TableView Delegate
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.objectCount
    }

    override func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        // Just to reserve the space for directAnswersView
        return directAnswersController.height
    }

    override func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        // Empty transparent header just below directAnswersView
        return UIView(frame: CGRect())
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

    // MARK: - Private methods

    // MARK: > UI

    private func setupUI() {
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
        self.setLetGoNavigationBarStyle(viewModel.title)
        updateRightBarButtons()

        let tap = UITapGestureRecognizer(target: self, action: "productInfoPressed")
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

    private func setupDirectAnswers() {
        directAnswersController.hidden = !viewModel.shouldShowDirectAnswers
        directAnswersController.setupOnTopOfView(textInputbar)
        directAnswersController.setDirectAnswers(viewModel.directAnswers)
        directAnswersController.delegate = viewModel
    }

    private func updateRightBarButtons() {
        setLetGoRightButtonsWith(imageNames: [safetyTipImageName, "ic_more_options"],
            renderingMode: [.AlwaysOriginal, .AlwaysTemplate], selectors: ["safetyTipsBtnPressed","optionsBtnPressed"])
    }

    private func updateProductView() {
        productView.nameLabel.text = viewModel.productName
        productView.userLabel.text = viewModel.productUserName
        productView.priceLabel.text = viewModel.productPrice
        if let thumbURL = viewModel.productImageUrl {
            switch viewModel.productStatus {
            case .Pending, .Approved, .Discarded, .Sold, .SoldOld:
                productView.imageButton.alpha = 1.0
            case .Deleted:
                productView.imageButton.alpha = 0.2
            }
            productView.imageButton.sd_setImageWithURL(thumbURL)
        }
    }

    func showActivityIndicator(show: Bool) {
        show ? activityIndicator.startAnimating() : activityIndicator.stopAnimating()
    }

    // MARK: > Navigation

    private func productInfoPressed() {
        viewModel.productInfoPressed()
    }

    dynamic private func safetyTipsBtnPressed() {
        viewModel.safetyTipsBtnPressed()
    }

    dynamic private func optionsBtnPressed() {
        viewModel.optionsBtnPressed()
    }

    // MARK: > Rating

    private func askForRating() {
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


    // MARK: > Messages list

    func vmDidStartRetrievingChatMessages(hasData hasData: Bool) {
        if !hasData {
            showActivityIndicator(true)
        }
    }

    func vmDidFailRetrievingChatMessages() {
        showActivityIndicator(false)
        showAutoFadingOutMessageAlert(LGLocalizedString.chatMessageLoadGenericError) { [weak self] in
            self?.popBackViewController()
        }
    }

    func vmDidSucceedRetrievingChatMessages() {
        showActivityIndicator(false)
        tableView.reloadData()
    }

    func vmUpdateAfterReceivingMessagesAtPositions(positions: [Int]) {
        showActivityIndicator(false)

        guard positions.count > 0 else { return }

        let newPositions: [NSIndexPath] = positions.map({NSIndexPath(forRow: $0, inSection: 0)})

        tableView.beginUpdates()
        tableView.insertRowsAtIndexPaths(newPositions, withRowAnimation: .Automatic)
        tableView.endUpdates()
    }


    // MARK: > Send Message
    
    func vmDidFailSendingMessage() {
        showAutoFadingOutMessageAlert(LGLocalizedString.chatMessageLoadGenericError)
    }
    
    func vmDidSucceedSendingMessage() {
        tableView.beginUpdates()
        let indexPath = NSIndexPath(forRow: 0, inSection: 0)
        tableView.insertRowsAtIndexPaths([indexPath], withRowAnimation: .Automatic)
        tableView.endUpdates()
    }


    // MARK: > Direct answers related

    func vmDidUpdateDirectAnswers() {
        directAnswersController.hidden = !viewModel.shouldShowDirectAnswers
        tableView.reloadData()
    }

    func vmDidUpdateProduct(messageToShow message: String?) {
        updateProductView()
        guard let message = message else { return }
        showAutoFadingOutMessageAlert(message)
    }


    // MARK: > Product

    func vmShowProduct(productVieWmodel: ProductViewModel) {
        let vc = ProductViewController(viewModel: productVieWmodel)
        self.navigationController?.pushViewController(vc, animated: true)
    }

    func vmShowProductRemovedError() {
        productView.showProductRemovedError(LGLocalizedString.commonProductNotAvailable)
        let delayTime = dispatch_time(DISPATCH_TIME_NOW, Int64(2.5 * Double(NSEC_PER_SEC)))
        dispatch_after(delayTime, dispatch_get_main_queue()) {
            self.productView.hideError()
        }
    }

    func vmShowProductSoldError() {
        productView.showProductSoldError(LGLocalizedString.commonProductSold)
        let delayTime = dispatch_time(DISPATCH_TIME_NOW, Int64(2.5 * Double(NSEC_PER_SEC)))
        dispatch_after(delayTime, dispatch_get_main_queue()) {
            self.productView.hideError()
        }
    }


    // MARK: > Report user

    func vmShowReportUser(reportUserViewModel: ReportUsersViewModel) {
        let vc = ReportUsersViewController(viewModel: reportUserViewModel)
        pushViewController(vc, animated: true, completion: nil)
    }


    // MARK: > Alerts and messages

    func vmShowSafetyTips() {
        showSafetyTips()
    }

    func vmAskForRating() {
        textView.resignFirstResponder()
        askForRating()
    }

    func vmShowPrePermissions() {
        textView.resignFirstResponder()
        PushPermissionsManager.sharedInstance.showPrePermissionsViewFrom(self, type: .Chat, completion: nil)
    }

    func vmShowKeyboard() {
        textView.becomeFirstResponder()
    }

    func vmShowMessage(message: String) {
        showAutoFadingOutMessageAlert(message)
    }

    func vmShowOptionsList(options: [String], actions: [()->Void]) {
        guard options.count == actions.count else { return }
        let alert = UIAlertController(title: nil, message: nil, preferredStyle: .ActionSheet)

        for i in 0..<options.count {
            alert.addAction(UIAlertAction(title: options[i], style: .Default, handler: { _ in actions[i]() } ))
        }

        alert.addAction(UIAlertAction(title: LGLocalizedString.commonCancel, style: .Cancel, handler: nil))
        self.presentViewController(alert, animated: true, completion: nil)
    }

    func vmShowQuestion(title title: String, message: String, positiveText: String,
        positiveAction: (()->Void)?, negativeText: String, negativeAction: (()->Void)?) {
            let alert = UIAlertController(title: title, message: message, preferredStyle: .Alert)
            let cancelAction = UIAlertAction(title: negativeText, style: .Cancel, handler: { _ in negativeAction?() })
            let markAsSold = UIAlertAction(title: positiveText, style: .Default, handler: { _ in positiveAction?() })
            alert.addAction(cancelAction)
            alert.addAction(markAsSold)

            textView.resignFirstResponder()
            presentViewController(alert, animated: true, completion: nil)
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

    var safetyTipImageName: String {
        return viewModel.safetyTipsCompleted ? "ic_tips_black" : "ic_tips_alert"
    }

    func chatSafeTipsViewDelegate(chatSafeTipsViewDelegate: ChatSafetyTipsView, didShowPage page: Int) {
        viewModel.updateChatSafetyTipsLastPageSeen(page)
        updateRightBarButtons()
    }
   
    dynamic private func showSafetyTips() {
        guard let navCtlView = navigationController?.view else { return }
        guard let chatSafetyTipsView = ChatSafetyTipsView.chatSafetyTipsView() else { return }
        
        // Delay is needed in order not to mess with the kb show/hide animation
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, Int64(0.5 * Double(NSEC_PER_SEC))), dispatch_get_main_queue()) {
            
            self.textView.resignFirstResponder()
            chatSafetyTipsView.delegate = self
            chatSafetyTipsView.dismissBlock = { [weak self] in
                // Fade out
                UIView.animateWithDuration(0.4, animations: { () -> Void in
                    chatSafetyTipsView.alpha = 0
                    }) { _ in
                        chatSafetyTipsView.removeFromSuperview()
                        self?.textView.becomeFirstResponder()
                }
            }

            // Add it w/o alpha
            let navCtlFrame = navCtlView.frame
            chatSafetyTipsView.frame = navCtlFrame
            chatSafetyTipsView.alpha = 0
            navCtlView.addSubview(chatSafetyTipsView)

            UIView.animateWithDuration(0.4, animations: { () -> Void in
                chatSafetyTipsView.alpha = 1
            })
        }
    }
}
