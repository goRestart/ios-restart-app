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
import RxSwift

class OldChatViewController: SLKTextViewController {

    let navBarHeight: CGFloat = 64
    let inputBarHeight: CGFloat = 44
    let expressBannerHeight: CGFloat = 44
    var productView: ChatProductView
    var selectedCellIndexPath: NSIndexPath?
    var viewModel: OldChatViewModel
    var keyboardShown: Bool = false
    var showingStickers = false
    let stickersView: ChatStickersView
    let stickersCloseButton: UIButton
    var stickersWindow: UIWindow?
    let expressChatBanner: ChatBanner
    var bannerTopConstraint: NSLayoutConstraint = NSLayoutConstraint()
    var activityIndicator = UIActivityIndicatorView(activityIndicatorStyle: .Gray)
    var relationInfoView = RelationInfoView.relationInfoView()   // informs if the user is blocked, or the product sold or inactive
    var directAnswersPresenter: DirectAnswersPresenter
    let relatedProductsView: RelatedProductsView
    let keyboardHelper: KeyboardHelper
    let disposeBag = DisposeBag()

    var stickersTooltip: Tooltip?

    var blockedToastOffset: CGFloat {
        return relationInfoView.hidden ? 0 : RelationInfoView.defaultHeight
    }
    
    convenience init(viewModel: OldChatViewModel, hidesBottomBar: Bool) {
        self.init(viewModel: viewModel, keyboardHelper: KeyboardHelper.sharedInstance, featureFlags: FeatureFlags.sharedInstance)
        hidesBottomBarWhenPushed = hidesBottomBar
    }
    
    // MARK: - View lifecycle
    required init(viewModel: OldChatViewModel, keyboardHelper: KeyboardHelper = KeyboardHelper.sharedInstance, featureFlags: FeatureFlags = FeatureFlags.sharedInstance) {
        self.viewModel = viewModel
        self.productView = ChatProductView.chatProductView(featureFlags.userReviews)
        self.directAnswersPresenter = DirectAnswersPresenter(websocketChatActive: featureFlags.websocketChat)
        self.relatedProductsView = RelatedProductsView()
        self.stickersView = ChatStickersView()
        self.stickersCloseButton = UIButton(frame: CGRect.zero)
        self.expressChatBanner = ChatBanner()
        self.keyboardHelper = keyboardHelper
        super.init(tableViewStyle: .Plain)
        self.viewModel.delegate = self
        self.expressChatBanner.delegate = self
        setReachabilityEnabled(true)
        hidesBottomBarWhenPushed = true
    }
    
    required init(coder decoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit {
        stickersView.removeFromSuperview()
        stickersCloseButton.removeFromSuperview()
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if let tableView = tableView {
            ChatCellDrawerFactory.registerCells(tableView)
        }
        setNavBarBackButton(nil)
        setupUI()
        setupToastView()
        setupRelatedProducts()
        setupDirectAnswers()
        setupStickersView()
        initStickersWindow()
        setupSendingRx()
        setupExpressBannerRx()
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(menuControllerWillShow(_:)),
                                                         name: UIMenuControllerWillShowMenuNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(menuControllerWillHide(_:)),
                                                         name: UIMenuControllerWillHideMenuNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(applicationWillEnterForeground(_:)),
                                                         name: UIApplicationWillEnterForegroundNotification, object: nil)
    }

    dynamic private func applicationWillEnterForeground(notification: NSNotification) {
        viewModel.applicationWillEnterForeground()
    }

    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        UIApplication.sharedApplication().setStatusBarStyle(.Default, animated: true)
        setNavBarBackgroundStyle(.Default)
        updateReachableAndToastViewVisibilityIfNeeded()
        viewModel.active = true
        updateChatInteraction(viewModel.chatEnabled)
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        viewModel.active = false
        removeStickersTooltip()
    }

    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        viewModel.didAppear()
    }

    override func didMoveToParentViewController(parent: UIViewController?) {
        super.didMoveToParentViewController(parent)
        if parent == nil {
            viewModel.wentBack()
        }
    }

    override func textView(textView: UITextView, shouldChangeTextInRange range: NSRange, replacementText text: String) -> Bool {
        guard !text.hasEmojis() else { return false }
        return super.textView(textView, shouldChangeTextInRange: range, replacementText: text)
    }
    
    // This method overrides a private method in SLKTextViewController that was returning an incorrect bottom
    // margin when hidesBottombar is false.
    func slk_appropriateBottomMargin() -> CGFloat {
        return 0
    }
    
    
    // MARK: > Slack methods
    
    override func didPressRightButton(sender: AnyObject!) {
        viewModel.sendText(textView.text, isQuickAnswer: false)
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
    override func keyForTextCaching() -> String? {
        return viewModel.keyForTextCaching
    }
    
    // MARK: > TableView Delegate
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.objectCount
    }
    
    override func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        // Just to reserve the space for directAnswersView
        return directAnswersPresenter.height + relatedProductsView.visibleHeight.value
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

        return cell
    }

    override func tableView(tableView: UITableView, willDisplayCell cell: UITableViewCell,
                            forRowAtIndexPath indexPath: NSIndexPath) {
        dispatch_async(dispatch_get_main_queue()) { [weak self] in
            self?.viewModel.setCurrentIndex(indexPath.row)
        }
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
        view.backgroundColor = UIColor.grayBackground
        
        setupNavigationBar()
        
        tableView?.clipsToBounds = true
        tableView?.estimatedRowHeight = 120
        tableView?.rowHeight = UITableViewAutomaticDimension
        tableView?.separatorStyle = .None
        tableView?.backgroundColor = UIColor.grayBackground
        tableView?.allowsSelection = false
        textView.placeholder = LGLocalizedString.chatMessageFieldHint
        textView.backgroundColor = UIColor.whiteColor()
        textInputbar.backgroundColor = UIColor.whiteColor()
        textInputbar.clipsToBounds = true
        textInputbar.translucent = false
        textInputbar.rightButton.setTitle(LGLocalizedString.chatSendButton, forState: .Normal)
        rightButton.tintColor = UIColor.primaryColor
        rightButton.titleLabel?.font = UIFont.smallButtonFont
        leftButton.setImage(UIImage(named: "ic_stickers"), forState: .Normal)
        leftButton.tintColor = UIColor.grayDark

        addSubviews()
        setupFrames()
        setupConstraints()

        relationInfoView.setupUIForStatus(viewModel.chatStatus, otherUserName: viewModel.otherUserName)
        textInputbarHidden = !viewModel.chatEnabled
        
        // chat info view setup
        keyboardPanningEnabled = false
        
        if let patternBackground = UIColor.emptyViewBackgroundColor {
            tableView?.backgroundColor = UIColor.clearColor()
            view.backgroundColor = patternBackground
        }
        
        updateProductView()

        let action = UIAction(interface: .Button(LGLocalizedString.chatExpressBannerButtonTitle,
            .Secondary(fontSize: .Small, withBorder: true)), action: { [weak self] in
                self?.viewModel.bannerActionButtonTapped()
            })
        expressChatBanner.setupChatBannerWith(LGLocalizedString.chatExpressBannerTitle, action: action)
    }

    private func setupNavigationBar() {
        productView.height = navigationBarHeight
        productView.layoutIfNeeded()

        setNavBarTitleStyle(.Custom(productView))
        setLetGoRightButtonWith(imageName: "ic_more_options", selector: "optionsBtnPressed")
    }
    
    private func addSubviews() {
        relationInfoView.translatesAutoresizingMaskIntoConstraints = false
        expressChatBanner.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(relationInfoView)
        view.addSubview(activityIndicator)
        view.addSubview(expressChatBanner)
    }
    
    private func setupFrames() {
        if let tableView = tableView {
            tableView.contentInset.bottom = navBarHeight + blockedToastOffset
            tableView.frame = CGRectMake(0, blockedToastOffset,
                                         tableView.width, tableView.height - blockedToastOffset)
        }
        
        activityIndicator.frame = CGRect(x: 0, y: 0, width: 100, height: 100)
        activityIndicator.center = view.center
    }

    private func setupConstraints() {
        var views: [String: AnyObject] = ["relationInfoView": relationInfoView]
        view.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("H:|-0-[relationInfoView]-0-|", options: [],
            metrics: nil, views: views))
        view.addConstraint(NSLayoutConstraint(item: relationInfoView, attribute: .Top, relatedBy: .Equal,
                                              toItem: topLayoutGuide, attribute: .Bottom, multiplier: 1, constant: 0))

        let bannerHeight = NSLayoutConstraint(item: expressChatBanner, attribute: .Height, relatedBy: .GreaterThanOrEqual, toItem: nil, attribute: .NotAnAttribute, multiplier: 1, constant: expressBannerHeight)
        expressChatBanner.addConstraint(bannerHeight)

        views = ["expressChatBanner": expressChatBanner]
        bannerTopConstraint = NSLayoutConstraint(item: expressChatBanner, attribute: .Top, relatedBy: .Equal, toItem: topLayoutGuide, attribute: .Bottom, multiplier: 1, constant: -expressBannerHeight)
        let bannerSides = NSLayoutConstraint.constraintsWithVisualFormat("H:|-0-[expressChatBanner]-0-|", options: [], metrics: nil, views: views)

        view.addConstraint(bannerTopConstraint)
        view.addConstraints(bannerSides)
    }

    private func setupRelatedProducts() {
        relatedProductsView.setupOnTopOfView(textInputbar)
        relatedProductsView.title.value = LGLocalizedString.chatRelatedProductsTitle
        relatedProductsView.delegate = viewModel
        relatedProductsView.visibleHeight.asObservable().distinctUntilChanged().bindNext { [weak self] _ in
            self?.tableView?.reloadData()
            }.addDisposableTo(disposeBag)
    }

    private func setupDirectAnswers() {
        directAnswersPresenter.hidden = !viewModel.shouldShowDirectAnswers
        directAnswersPresenter.setupOnTopOfView(relatedProductsView)
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

        switch viewModel.chatStatus {
        case .Forbidden, .UserDeleted, .UserPendingDelete:
            productView.disableUserProfileInteraction()
            productView.disableProductInteraction()
        case .ProductDeleted:
            productView.disableProductInteraction()
        case .Available, .Blocked, .BlockedBy, .ProductSold:
            break
        }

        showReviewButton()
    }

    private func showReviewButton() {
        productView.showReviewButton(viewModel.userIsReviewable, withTooltip: viewModel.shouldShowUserReviewTooltip)
        guard let tooltip = productView.userRatingTooltip else { return }
        navigationController?.navigationBar.forceTouchesFor(tooltip)
    }
    
    private func showActivityIndicator(show: Bool) {
        show ? activityIndicator.startAnimating() : activityIndicator.stopAnimating()
    }
    
    private func updateChatInteraction(enabled: Bool) {
        setTextInputbarHidden(!enabled, animated: true)
        textView.userInteractionEnabled = enabled
        if !enabled {
            removeStickersTooltip()
        }
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

    private func removeStickersTooltip() {
        if let tooltip = stickersTooltip where view.subviews.contains(tooltip) {
            tooltip.removeFromSuperview()
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


// MARK: ConversationDataDisplayer

extension OldChatViewController: ConversationDataDisplayer {
    func isDisplayingConversationData(data: ConversationData) -> Bool {
        return viewModel.isMatchingConversationData(data)
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
    
    func vmDidRefreshChatMessages() {
        showActivityIndicator(false)
        tableView?.reloadData()
    }
    
    func vmUpdateAfterReceivingMessagesAtPositions(positions: [Int], isUpdate: Bool) {
        showActivityIndicator(false)
        
        guard positions.count > 0 else { return }
        if isUpdate {
            tableView?.reloadData()
            return
        }
        
        let newPositions: [NSIndexPath] = positions.map({NSIndexPath(forRow: $0, inSection: 0)})
        
        tableView?.beginUpdates()
        tableView?.insertRowsAtIndexPaths(newPositions, withRowAnimation: .Automatic)
        tableView?.endUpdates()
    }
    
    
    // MARK: > Send Message

    func vmClearText() {
        textView.text = ""
    }
    
    func vmDidFailSendingMessage() {
        showAutoFadingOutMessageAlert(LGLocalizedString.chatMessageLoadGenericError)
    }
    
    func vmDidSucceedSendingMessage(index: Int) {
        tableView?.beginUpdates()
        let indexPath = NSIndexPath(forRow: index, inSection: 0)
        tableView?.insertRowsAtIndexPaths([indexPath], withRowAnimation: .Automatic)
        tableView?.endUpdates()
        tableView?.scrollToRowAtIndexPath(indexPath, atScrollPosition: UITableViewScrollPosition.Top, animated: true)
    }
    
    
    // MARK: > Direct answers related
    
    func vmDidUpdateDirectAnswers() {
        directAnswersPresenter.hidden = !viewModel.shouldShowDirectAnswers
        tableView?.reloadData()
    }
    
    func vmDidUpdateProduct(messageToShow message: String?) {
        updateProductView()
        guard let message = message else { return }
        showAutoFadingOutMessageAlert(message)
    }
    
    // MARK: > Product

    func vmShowRelatedProducts(productId: String?) {
        relatedProductsView.productId.value = productId
    }

    // MARK: > User

    func vmShowReportUser(reportUserViewModel: ReportUsersViewModel) {
        let vc = ReportUsersViewController(viewModel: reportUserViewModel)
        self.navigationController?.pushViewController(vc, animated: true)
    }

    func vmShowUserRating(source: RateUserSource, data: RateUserData) {
        guard let tabBarController = self.tabBarController as? TabBarController else { return }
        tabBarController.openUserRating(source, data: data)
    }

    // MARK: > Info views
    
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
    
    func vmHideKeyboard(animated animated: Bool) {
        showKeyboard(false, animated: animated)
    }
    
    func vmShowMessage(message: String, completion: (() -> ())?) {
        showAutoFadingOutMessageAlert(message, completion:  completion)
    }
    
    func vmShowOptionsList(options: [String], actions: [() -> Void]) {
        guard options.count == actions.count else { return }
        let alert = UIAlertController(title: nil, message: nil, preferredStyle: .ActionSheet)
        alert.popoverPresentationController?.barButtonItem = self.navigationItem.rightBarButtonItem

        for i in 0..<options.count {
            alert.addAction(UIAlertAction(title: options[i], style: .Default, handler: { _ in actions[i]() } ))
        }
        
        alert.addAction(UIAlertAction(title: LGLocalizedString.commonCancel, style: .Cancel, handler: nil))
        self.presentViewController(alert, animated: true, completion: nil)
    }
    
    func vmShowQuestion(title title: String, message: String, positiveText: String,
                              positiveAction: (() -> Void)?, positiveActionStyle: UIAlertActionStyle?, negativeText: String,
                              negativeAction: (() -> Void)?, negativeActionStyle: UIAlertActionStyle?) {
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

    func vmLoadStickersTooltipWithText(text: NSAttributedString) {
        guard stickersTooltip == nil else { return }

        stickersTooltip = Tooltip(targetView: leftButton, superView: view, title: text, style: .Black(closeEnabled: true),
                                  peakOnTop: false, actionBlock: { [weak self] in
                                    self?.showStickers()
                            }, closeBlock: { [weak self] in
                                    self?.viewModel.stickersShown()
        })

        guard let tooltip = stickersTooltip else { return }
        view.addSubview(tooltip)
        setupExternalConstraintsForTooltip(tooltip, targetView: leftButton, containerView: view)

        view.layoutIfNeeded()
    }

    func vmUpdateUserIsReadyToReview() {
        showReviewButton()
    }
}


// MARK: - Animate ProductView with keyboard

extension OldChatViewController {
    // Need to override this to fix the position of the Slack tableView
    // if you have a "header" view below the navBar
    // It is an open issue in the Library https://github.com/slackhq/SlackTextViewController/issues/137
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        tableView?.contentInset.bottom = navBarHeight + blockedToastOffset
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
        guard let tableView = tableView else { return }
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
        let message = viewModel.messageAtIndex(indexPath.row)
        guard message.copyEnabled else { return false }

        selectedCellIndexPath = indexPath //Need to save the currently selected cell to reposition the menu later
        return true
    }
    
    override func tableView(tableView: UITableView, canPerformAction action: Selector, forRowAtIndexPath
        indexPath: NSIndexPath, withSender sender: AnyObject?) -> Bool {
        if action == #selector(copy(_:)) {
            guard let cell = tableView.cellForRowAtIndexPath(indexPath) else { return false }
            cell.setSelected(true, animated: true)
            return true
        }
        return false
    }
    
    override  func tableView(tableView: UITableView, performAction action: Selector, forRowAtIndexPath
        indexPath: NSIndexPath, withSender sender: AnyObject?) {
        if action == #selector(copy(_:)) {
            UIPasteboard.generalPasteboard().string =  viewModel.textOfMessageAtIndex(indexPath.row)
        }
    }
}


// MARK: - ChatSafeTips

extension OldChatViewController {
    
    private func showSafetyTips() {
        guard let navCtlView = navigationController?.view else { return }
        guard let chatSafetyTipsView = ChatSafetyTipsView.chatSafetyTipsView() else { return }

        navCtlView.userInteractionEnabled = false

        // Delay is needed in order not to mess with the kb show/hide animation
        delay(0.5) { [weak self] in
            navCtlView.userInteractionEnabled = true
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

    func productViewDidTapUserReview() {
        viewModel.reviewUserPressed()
    }

    func productViewDidCloseUserReviewTooltip() {
        viewModel.closeReviewTooltipPressed()
    }
}


// MARK: - Stickers

extension OldChatViewController {
    
    func vmDidUpdateStickers() {
        stickersView.reloadStickers(viewModel.stickers)
    }

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

    private func initStickersWindow() {
        let windowFrame = CGRectMake(0, view.height, view.width, view.height)
    
        stickersWindow = UIWindow(frame: windowFrame)
        stickersWindow?.windowLevel = 100000001 // needs to be higher then the level of the keyboard (100000000)
        stickersWindow?.addSubview(stickersView)
        stickersWindow?.hidden = true
        stickersWindow?.backgroundColor = UIColor.clearColor()
        stickersWindow?.addSubview(stickersCloseButton)
        stickersView.hidden = true
        showingStickers = false
        
        let originSignal = keyboardHelper.rx_keyboardOrigin.asObservable().distinctUntilChanged()
        let heightSignal = keyboardHelper.rx_keyboardHeight.asObservable().distinctUntilChanged()
        let combined = Observable.combineLatest(originSignal, heightSignal) { $0 }
        
        combined.bindNext { [weak self] (origin, height) in
            guard let `self` = self else { return }
            let windowFrame = CGRectMake(0, origin-self.inputBarHeight, self.view.width, height+self.inputBarHeight)
            let stickersFrame = CGRect(x: 0, y: self.inputBarHeight, width: self.view.width, height: height)
            let buttonFrame = CGRect(x: 0, y: 0, width: self.view.width, height: self.inputBarHeight)
            self.stickersWindow?.frame = windowFrame
            self.stickersView.frame = stickersFrame
            self.stickersCloseButton.frame = buttonFrame

            }.addDisposableTo(disposeBag)
    }

    func showStickers() {
        viewModel.stickersShown()
        removeStickersTooltip()
        showKeyboard(true, animated: false)
        stickersWindow?.hidden = false
        stickersView.hidden = false
        leftButton.setImage(UIImage(named: "ic_keyboard"), forState: .Normal)
        showingStickers = true
    }
    
    func hideStickers() {
        stickersWindow?.hidden = true
        stickersView.hidden = true
        leftButton.setImage(UIImage(named: "ic_stickers"), forState: .Normal)
        showingStickers = false
    }
}

extension OldChatViewController: ChatStickersViewDelegate {
    func stickersViewDidSelectSticker(sticker: Sticker) {
        viewModel.sendSticker(sticker)
    }
}


// MARK: Sending blocks

extension OldChatViewController {
    func setupSendingRx() {
        let sendActionsEnabled = viewModel.isSendingMessage.asObservable().map { !$0 }
        sendActionsEnabled.bindTo(rightButton.rx_enabled).addDisposableTo(disposeBag)
        sendActionsEnabled.bindNext { [weak self] enabled in
            self?.stickersView.enabled = enabled
            self?.directAnswersPresenter.enabled = enabled
        }.addDisposableTo(disposeBag)
    }
}


// MARK: ExpressChatBanner

extension OldChatViewController {
    func setupExpressBannerRx() {
        viewModel.shouldShowExpressBanner.asObservable().skip(1).bindNext { [weak self] showBanner in
            if showBanner {
                self?.showBanner()
            } else {
                self?.hideBanner()
            }
        }.addDisposableTo(disposeBag)
    }

    func showBanner() {
        expressChatBanner.hidden = false
        bannerTopConstraint.constant = 0
        UIView.animateWithDuration(0.5) { [weak self] in
            self?.view.layoutIfNeeded()
        }
    }

    func hideBanner() {
        bannerTopConstraint.constant = -expressChatBanner.frame.height
        UIView.animateWithDuration(0.5, animations: { [weak self] in
            self?.view.layoutIfNeeded()
        }) { [weak self] _ in
            self?.expressChatBanner.hidden = true
        }
    }
}

extension OldChatViewController: ChatBannerDelegate {
    func chatBannerDidFinish() {
        hideBanner()
    }
}


extension OldChatViewController {
    func setAccessibilityIds() {
        tableView?.accessibilityId = .ChatViewTableView
        navigationItem.rightBarButtonItem?.accessibilityId = .ChatViewMoreOptionsButton
        navigationItem.backBarButtonItem?.accessibilityId = .ChatViewBackButton
        textInputbar.leftButton.accessibilityId = .ChatViewStickersButton
        textInputbar.rightButton.accessibilityId = .ChatViewSendButton
        textInputbar.accessibilityId = .ChatViewTextInputBar
        stickersCloseButton.accessibilityId = .ChatViewCloseStickersButton
        expressChatBanner.accessibilityId = .ExpressChatBanner
    }
}
