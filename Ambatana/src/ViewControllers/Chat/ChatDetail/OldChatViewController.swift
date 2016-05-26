//
//  OldChatViewController.swift
//  LetGo
//
//  Created by Isaac Roldan on 23/11/15.
//  Copyright © 2015 Ambatana. All rights reserved.
//

import UIKit
import SlackTextViewController
import LGCoreKit

class OldChatViewController: SLKTextViewController {
    
    let productViewHeight: CGFloat = 80
    let navBarHeight: CGFloat = 64
    let inputBarHeight: CGFloat = 44
    var productView: ChatProductView
    var selectedCellIndexPath: NSIndexPath?
    var viewModel: OldChatViewModel
    var keyboardShown: Bool = false
    var showingStickers = false
    let stickersView: ChatStickersView
    let stickersCloseButton: UIButton
    var activityIndicator = UIActivityIndicatorView(activityIndicatorStyle: .Gray)
    var relationInfoView = RelationInfoView.relationInfoView()   // informs if the user is blocked, or the product sold or inactive
    var directAnswersPresenter: DirectAnswersPresenter
    private let chatBlockedMessageView: ChatBlockedMessageView?
    let keyboardHelper: KeyboardHelper

    var blockedToastOffset: CGFloat {
        return relationInfoView.hidden ? 0 : RelationInfoView.defaultHeight
    }
    
    
    // MARK: - View lifecycle
    required init(viewModel: OldChatViewModel, keyboardHelper: KeyboardHelper = KeyboardHelper.sharedInstance) {
        self.viewModel = viewModel
        self.productView = ChatProductView.chatProductView()
        self.directAnswersPresenter = DirectAnswersPresenter()
        self.chatBlockedMessageView = viewModel.chatBlockedViewVisible ? ChatBlockedMessageView(frame: CGRect.zero) : nil
        self.stickersView = ChatStickersView()
        self.stickersCloseButton = UIButton(frame: CGRect.zero)
        self.keyboardHelper = keyboardHelper
        super.init(tableViewStyle: .Plain)
        self.viewModel.delegate = self
        setReachabilityEnabled(true)
        hidesBottomBarWhenPushed = true
    }
    
    required init!(coder decoder: NSCoder!) {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit {
        stickersView.removeFromSuperview()
        stickersCloseButton.removeFromSuperview()
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        ChatCellDrawerFactory.registerCells(tableView)
        setupUI()
        setupToastView()
        setupDirectAnswers()
        setupChatBlockedMessageView()
        setupStickersView()
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(menuControllerWillShow(_:)),
                                                         name: UIMenuControllerWillShowMenuNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(menuControllerWillHide(_:)),
                                                         name: UIMenuControllerWillHideMenuNotification, object: nil)
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        UIApplication.sharedApplication().setStatusBarStyle(.Default, animated: true)
        updateReachableAndToastViewVisibilityIfNeeded()
        viewModel.active = true
        viewModel.retrieveUsersRelation()
        updateChatInteraction(viewModel.chatEnabled)
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        viewModel.active = false
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        viewModel.didAppear()
    }
    
    override func textView(textView: UITextView, shouldChangeTextInRange range: NSRange, replacementText text: String) -> Bool {
        guard !text.hasEmojis() else { return false }
        return super.textView(textView, shouldChangeTextInRange: range, replacementText: text)
    }
    
    
    // MARK: - Public methods
    
    func isMatchingConversationData(data: ConversationData) -> Bool {
        return viewModel.isMatchingConversationData(data)
    }
    
    
    // MARK: > Slack methods
    
    override func didPressRightButton(sender: AnyObject!) {
        let message = textView.text
        textView.text = ""
        viewModel.sendText(message, isQuickAnswer: false)
    }
    
    override func didPressLeftButton(sender: AnyObject!) {
        showingStickers ? hideStickers() : showStickers()
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
        return directAnswersPresenter.height
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
        
        drawer.draw(cell, message: message, delegate: self)
        cell.transform = tableView.transform
        
        viewModel.setCurrentIndex(indexPath.row)
        
        return cell
    }
    
    override func tableView(tableView: UITableView, estimatedHeightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return UITableViewAutomaticDimension
    }
    
    override func scrollViewWillBeginDragging(scrollView: UIScrollView) {
        showKeyboard(false, animated: true)
    }
    
    
    // MARK: - Private methods
    
    // MARK: > UI
    
    private func setupUI() {
        view.backgroundColor = StyleHelper.chatTableViewBgColor
        
        setupNavigationBar()
        
        tableView.clipsToBounds = true
        tableView.estimatedRowHeight = 120
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.separatorStyle = .None
        tableView.backgroundColor = StyleHelper.chatTableViewBgColor
        tableView.allowsSelection = false
        textView.placeholder = LGLocalizedString.chatMessageFieldHint
        textView.backgroundColor = UIColor.whiteColor()
        textInputbar.backgroundColor = UIColor.whiteColor()
        textInputbar.clipsToBounds = true
        textInputbar.translucent = false
        textInputbar.rightButton.setTitle(LGLocalizedString.chatSendButton, forState: .Normal)
        rightButton.tintColor = StyleHelper.chatSendButtonTintColor
        rightButton.titleLabel?.font = StyleHelper.chatSendButtonFont
        
        if FeatureFlags.chatStickers {
            leftButton.setImage(UIImage(named: "ic_stickers"), forState: .Normal)
            leftButton.tintColor = StyleHelper.chatLeftButtonColor
        }

        addSubviews()
        setupFrames()
        setupConstraints()

        relationInfoView.setupUIForStatus(viewModel.chatStatus, otherUserName: viewModel.otherUserName)
        textInputbarHidden = !viewModel.chatEnabled
        
        // chat info view setup
        keyboardPanningEnabled = false
        
        if let patternBackground = StyleHelper.emptyViewBackgroundColor {
            tableView.backgroundColor = UIColor.clearColor()
            view.backgroundColor = patternBackground
        }
        
        updateProductView()
    }
    
    private func setupNavigationBar() {
        productView.height = navigationBarHeight
        productView.layoutIfNeeded()
        
        setLetGoNavigationBarStyle(productView)
        setLetGoRightButtonWith(imageName: "ic_more_options", selector: "optionsBtnPressed")
    }
    
    private func addSubviews() {
        relationInfoView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(relationInfoView)
        view.addSubview(activityIndicator)
        if let chatBlockedMessageView = chatBlockedMessageView {
            chatBlockedMessageView.translatesAutoresizingMaskIntoConstraints = false
            view.addSubview(chatBlockedMessageView)
        }
    }
    
    private func setupFrames() {
        tableView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 128 + blockedToastOffset, right: 0)
        tableView.frame = CGRectMake(0, productViewHeight + blockedToastOffset, tableView.width,
                                          tableView.height - productViewHeight - blockedToastOffset)
        
        activityIndicator.frame = CGRect(x: 0, y: 0, width: 100, height: 100)
        activityIndicator.center = view.center
    }

    private func setupConstraints() {
        var views: [String: AnyObject] = ["relationInfoView": relationInfoView]
        view.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("H:|-0-[relationInfoView]-0-|", options: [],
            metrics: nil, views: views))
        view.addConstraint(NSLayoutConstraint(item: relationInfoView, attribute: .Top, relatedBy: .Equal,
                                              toItem: topLayoutGuide, attribute: .Bottom, multiplier: 1, constant: 0))

        if let chatBlockedMessageView = chatBlockedMessageView {
            views = ["cbmv": chatBlockedMessageView]
            let cbmvHConstraints = NSLayoutConstraint.constraintsWithVisualFormat("H:|-8-[cbmv]-8-|", options: [],
                                                                                  metrics: nil, views: views)
            let cbmvBottomConstraint = NSLayoutConstraint(item: chatBlockedMessageView, attribute: .Bottom,
                                                          relatedBy: .Equal, toItem: view, attribute: .Bottom,
                                                          multiplier: 1, constant: -8)
            view.addConstraints(cbmvHConstraints + [cbmvBottomConstraint])
        }
    }

    private func setupChatBlockedMessageView() {
        guard let chatBlockedMessageView = chatBlockedMessageView else { return }

        if let message = viewModel.chatBlockedViewMessage {
            chatBlockedMessageView.setMessage(message)
        }
        if let action = viewModel.chatBlockedViewAction {
            chatBlockedMessageView.setButton(title: LGLocalizedString.chatBlockedDisclaimerSafetyTipsButton)
            chatBlockedMessageView.setButton(action: action)
        }
        let recognizer = UITapGestureRecognizer(target: viewModel,
                                                action: #selector(OldChatViewModel.chatBlockedViewPressed))
        chatBlockedMessageView.addGestureRecognizer(recognizer)
    }
    
    private func setupDirectAnswers() {
        directAnswersPresenter.hidden = !viewModel.shouldShowDirectAnswers
        directAnswersPresenter.setupOnTopOfView(textInputbar)
        directAnswersPresenter.setDirectAnswers(viewModel.directAnswers)
        directAnswersPresenter.delegate = viewModel
    }
    
    private func updateProductView() {
        productView.delegate = self
        productView.userName.text = viewModel.otherUserName
        productView.productName.text = viewModel.productName
        productView.productPrice.text = viewModel.productPrice
        
        if let thumbURL = viewModel.productImageUrl {
            productView.productImage.lg_setImageWithURL(thumbURL)
        }
        
        let placeholder = LetgoAvatar.avatarWithID(viewModel.otherUserID, name: viewModel.otherUserName)
        productView.userAvatar.image = placeholder
        if let avatar = viewModel.otherUserAvatarUrl {
            productView.userAvatar.lg_setImageWithURL(avatar, placeholderImage: placeholder)
        }
        
        if viewModel.chatStatus == .ProductDeleted {
            productView.disableProductInteraction()
        }
        
        if viewModel.chatStatus == .Forbidden {
            productView.disableUserProfileInteraction()
            productView.disableProductInteraction()
        }
    }
    
    private func showActivityIndicator(show: Bool) {
        show ? activityIndicator.startAnimating() : activityIndicator.stopAnimating()
    }
    
    private func updateChatInteraction(enabled: Bool) {
        setTextInputbarHidden(!enabled, animated: true)
        textView.userInteractionEnabled = enabled
    }
    
    func showKeyboard(show: Bool, animated: Bool) {
        if !show { hideStickers() }
        guard viewModel.chatEnabled else { return }
        if show {
            presentKeyboard(animated)
        } else {
            dismissKeyboard(animated)
        }
    }
    
    // MARK: > Navigation
    
    dynamic private func productInfoPressed() {
        viewModel.productInfoPressed()
    }
    
    dynamic private func optionsBtnPressed() {
        viewModel.optionsBtnPressed()
    }
    
    // MARK: > Rating
    
    private func askForRating() {
        let delay = Int64(1.0 * Double(NSEC_PER_SEC))
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, delay), dispatch_get_main_queue()) { [weak self] in
            self?.showKeyboard(false, animated: true)
            guard let tabBarCtrl = self?.tabBarController as? TabBarController else { return }
            tabBarCtrl.showAppRatingViewIfNeeded(.Chat)
        }
    }
}


// MARK: - OldChatViewModelDelegate

extension OldChatViewController: OldChatViewModelDelegate {
    
    
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
        tableView.scrollToRowAtIndexPath(indexPath, atScrollPosition: UITableViewScrollPosition.Top, animated: true)
    }
    
    
    // MARK: > Direct answers related
    
    func vmDidUpdateDirectAnswers() {
        directAnswersPresenter.hidden = !viewModel.shouldShowDirectAnswers
        tableView.reloadData()
    }
    
    func vmDidUpdateProduct(messageToShow message: String?) {
        updateProductView()
        guard let message = message else { return }
        showAutoFadingOutMessageAlert(message)
    }
    
    
    // MARK: > Product
    
    func vmShowProduct(productVC: UIViewController) {
        showKeyboard(false, animated: false)
        self.navigationController?.pushViewController(productVC, animated: true)
    }
    
    func vmShowProductRemovedError() {
        // productView.showProductRemovedError(LGLocalizedString.commonProductNotAvailable)
        // let delayTime = dispatch_time(DISPATCH_TIME_NOW, Int64(2.5 * Double(NSEC_PER_SEC)))
        // dispatch_after(delayTime, dispatch_get_main_queue()) {
        //     self.productView.hideError()
        // }
    }
    
    func vmShowProductSoldError() {
        // productView.showProductSoldError(LGLocalizedString.commonProductSold)
        // let delayTime = dispatch_time(DISPATCH_TIME_NOW, Int64(2.5 * Double(NSEC_PER_SEC)))
        // dispatch_after(delayTime, dispatch_get_main_queue()) {
        //     self.productView.hideError()
        // }
    }
    
    func vmShowUser(userVM: UserViewModel) {
        showKeyboard(false, animated: false)
        let vc = UserViewController(viewModel: userVM)
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    
    // MARK: > Report user
    
    func vmShowReportUser(reportUserViewModel: ReportUsersViewModel) {
        let vc = ReportUsersViewController(viewModel: reportUserViewModel)
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    func vmUpdateRelationInfoView(status: ChatInfoViewStatus) {
        relationInfoView.setupUIForStatus(status, otherUserName: viewModel.otherUserName)
    }
    
    func vmUpdateChatInteraction(enabled: Bool) {
        updateChatInteraction(enabled)
    }
    
    
    // MARK: > Alerts and messages
    
    func vmShowSafetyTips() {
        showSafetyTips()
    }
    
    func vmAskForRating() {
        showKeyboard(false, animated: true)
        askForRating()
    }
    
    func vmShowPrePermissions(type: PrePermissionType) {
        showKeyboard(false, animated: true)
        PushPermissionsManager.sharedInstance.showPrePermissionsViewFrom(self, type: type, completion: nil)
    }
    
    func vmShowKeyboard() {
        showKeyboard(true, animated: true)
    }
    
    func vmHideKeyboard() {
        showKeyboard(false, animated: true)
    }
    
    func vmShowMessage(message: String, completion: (() -> ())?) {
        showAutoFadingOutMessageAlert(message, completion:  completion)
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
                              positiveAction: (()->Void)?, positiveActionStyle: UIAlertActionStyle?, negativeText: String,
                              negativeAction: (()->Void)?, negativeActionStyle: UIAlertActionStyle?) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .Alert)
        let cancelAction = UIAlertAction(title: negativeText, style: negativeActionStyle ?? .Cancel,
                                         handler: { _ in negativeAction?() })
        let goAction = UIAlertAction(title: positiveText, style: positiveActionStyle ?? .Default,
                                     handler: { _ in positiveAction?() })
        alert.addAction(cancelAction)
        alert.addAction(goAction)
        
        showKeyboard(false, animated: true)
        presentViewController(alert, animated: true, completion: nil)
    }
    
    func vmClose() {
        navigationController?.popViewControllerAnimated(true)
    }
}


// MARK: - Animate ProductView with keyboard

extension OldChatViewController {
    // Need to override this to fix the position of the Slack tableView
    // if you have a "header" view below the navBar
    // It is an open issue in the Library https://github.com/slackhq/SlackTextViewController/issues/137
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        let bottomInset = keyboardShown ? navBarHeight : productViewHeight + navBarHeight
        self.tableView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: bottomInset + blockedToastOffset, right: 0)
    }
}


// MARK: - Copy/Paste feature

extension OldChatViewController {
    
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
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(OldChatViewController.menuControllerWillShow(_:)),
                                                         name: UIMenuControllerWillShowMenuNotification, object: nil)
    }
    
    override func tableView(tableView: UITableView, shouldShowMenuForRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        selectedCellIndexPath = indexPath //Need to save the currently selected cell to reposition the menu later
        return true
    }
    
    override func tableView(tableView: UITableView, canPerformAction action: Selector, forRowAtIndexPath
        indexPath: NSIndexPath, withSender sender: AnyObject?) -> Bool {
        if action == #selector(NSObject.copy(_:)) {
            guard let cell = tableView.cellForRowAtIndexPath(indexPath) else { return false }
            cell.setSelected(true, animated: true)
            return true
        }
        return false
    }
    
    override  func tableView(tableView: UITableView, performAction action: Selector, forRowAtIndexPath
        indexPath: NSIndexPath, withSender sender: AnyObject?) {
        if action == #selector(NSObject.copy(_:)) {
            UIPasteboard.generalPasteboard().string =  viewModel.textOfMessageAtIndex(indexPath.row)
        }
    }
}


// MARK: - ChatSafeTips

extension OldChatViewController {
    
    private func showSafetyTips() {
        guard let navCtlView = navigationController?.view else { return }
        guard let chatSafetyTipsView = ChatSafetyTipsView.chatSafetyTipsView() else { return }
        
        // Delay is needed in order not to mess with the kb show/hide animation
        delay(0.5) { [weak self] in
            self?.showKeyboard(false, animated: true)
            chatSafetyTipsView.dismissBlock = { [weak self] in
                self?.viewModel.safetyTipsDismissed()
                guard let chatEnabled = self?.viewModel.chatEnabled where chatEnabled else { return }
                self?.textView.becomeFirstResponder()
            }
            chatSafetyTipsView.frame = navCtlView.frame
            navCtlView.addSubview(chatSafetyTipsView)
            chatSafetyTipsView.show()
        }
    }
}


// MARK: - ChatProductViewDelegate

extension OldChatViewController: ChatProductViewDelegate {  
    func productViewDidTapProductImage() {
        viewModel.productInfoPressed()
    }
    
    func productViewDidTapUserAvatar() {
        viewModel.userInfoPressed()
    }
}


// MARK: - Stickers

extension OldChatViewController {
    
    private func setupStickersView() {
        let height = keyboardHelper.keyboardHeight
        let frame = CGRectMake(0, view.frame.height - height, view.frame.width, height)
        stickersView.frame = frame
        stickersView.delegate = self
        vmDidUpdateStickers()
        stickersView.hidden = true
        singleTapGesture.addTarget(self, action: #selector(hideStickers))
        stickersCloseButton.addTarget(self, action: #selector(hideStickers), forControlEvents: .TouchUpInside)
        stickersCloseButton.backgroundColor = UIColor.clearColor()
    }
    
    func vmDidUpdateStickers() {
        stickersView.reloadStickers(viewModel.stickers)
    }
    
    func showStickers() {
        guard FeatureFlags.chatStickers else { return }

        let shouldAnimate = keyboardHelper.keyboardOrigin < view.frame.height
        leftButton.setImage(UIImage(named: "ic_keyboard"), forState: .Normal)
        showKeyboard(true, animated: true)
        
        // Get the keyboard window, we can only add stickers to that specific window
        guard let keyboardWindow = UIApplication.sharedApplication().windows.last else { return }
        
        // Add the stickers view as subview of the first view in the window
        let firstView = keyboardWindow.subviews.first
        let height = keyboardHelper.keyboardHeight
        let frame = CGRectMake(0, view.frame.height, view.frame.width, height)
        stickersView.frame = frame
        
        firstView?.addSubview(stickersView)
        let newFrame = CGRectMake(0, view.frame.height - height, view.frame.width, height)
        
        if shouldAnimate {
            let duration = Double(keyboardHelper.animationTime)
            let curve = UIViewAnimationCurve(rawValue: keyboardHelper.animationCurve)
            UIView.beginAnimations("showStickers", context: nil)
            UIView.setAnimationDuration(duration)
            UIView.setAnimationCurve(curve!)
            stickersView.frame = newFrame
            UIView.commitAnimations()
        } else {
            stickersView.frame = newFrame
        }
        
        // Add transparent button on top of the textView -> Tap to close stickers
        let buttonFrame = CGRect(x: inputBarHeight,
                                 y: view.frame.height - height - inputBarHeight,
                                 width: view.frame.width - inputBarHeight,
                                 height: inputBarHeight)
        stickersCloseButton.frame = buttonFrame
        firstView?.addSubview(stickersCloseButton)
        stickersView.hidden = false
        showingStickers = true
    }
    
    func hideStickers() {
        guard FeatureFlags.chatStickers else { return }
        leftButton.setImage(UIImage(named: "ic_stickers"), forState: .Normal)
        stickersView.removeFromSuperview()
        stickersCloseButton.removeFromSuperview()
        showingStickers = false
    }
}

extension OldChatViewController: ChatStickersViewDelegate {
    func stickersViewDidSelectSticker(sticker: Sticker) {
        viewModel.sendSticker(sticker)
    }
}
