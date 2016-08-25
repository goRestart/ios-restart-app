//
//  ChatViewController.swift
//  LetGo
//
//  Created by Isaac Roldan on 29/4/16.
//  Copyright © 2016 Ambatana. All rights reserved.
//


import UIKit
import SlackTextViewController
import LGCoreKit
import RxSwift
import CollectionVariable

class ChatViewController: SLKTextViewController {

    let navBarHeight: CGFloat = 64
    let inputBarHeight: CGFloat = 44
    let productView: ChatProductView
    var selectedCellIndexPath: NSIndexPath?
    let viewModel: ChatViewModel
    var keyboardShown: Bool = false
    var showingStickers = false
    let activityIndicator = UIActivityIndicatorView(activityIndicatorStyle: .Gray)
    let relationInfoView = RelationInfoView.relationInfoView()   // informs if the user is blocked, or the product sold or inactive
    let relatedProductsView: RelatedProductsView
    let directAnswersPresenter: DirectAnswersPresenter
    let stickersView: ChatStickersView
    let stickersCloseButton: UIButton
    var stickersWindow: UIWindow?
    let keyboardHelper: KeyboardHelper
    let disposeBag = DisposeBag()

    var stickersTooltip: Tooltip?

    var blockedToastOffset: CGFloat {
        return relationInfoView.hidden ? 0 : RelationInfoView.defaultHeight
    }


    // MARK: - View lifecycle
    
    convenience init(viewModel: ChatViewModel, hidesBottomBar: Bool) {
        self.init(viewModel: viewModel, keyboardHelper: KeyboardHelper.sharedInstance)
        hidesBottomBarWhenPushed = hidesBottomBar
    }

    required init(viewModel: ChatViewModel, keyboardHelper: KeyboardHelper = KeyboardHelper.sharedInstance) {
        self.viewModel = viewModel
        self.productView = ChatProductView.chatProductView()
        self.relatedProductsView = RelatedProductsView()
        self.directAnswersPresenter = DirectAnswersPresenter()
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
        setNavBarBackButton(nil)
        setupUI()
        setupToastView()
        setupRelatedProducts()
        setupDirectAnswers()
        setupRxBindings()
        setupStickersView()
        initStickersWindow()
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(ChatViewController.menuControllerWillShow(_:)),
                                                         name: UIMenuControllerWillShowMenuNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(ChatViewController.menuControllerWillHide(_:)),
                                                         name: UIMenuControllerWillHideMenuNotification, object: nil)
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        setNavBarBackgroundStyle(.Default)
        
        UIApplication.sharedApplication().setStatusBarStyle(.Default, animated: true)
        updateReachableAndToastViewVisibilityIfNeeded()
        viewModel.active = true
    }

    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        viewModel.active = false
        removeStickersTooltip()
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
    
    
    // MARK: - Public methods
    
    func isMatchingConversationData(data: ConversationData) -> Bool {
        return viewModel.isMatchingConversationData(data)
    }
    
    
    // MARK: - Slack methods
    
    override func didPressRightButton(sender: AnyObject!) {
        let message = textView.text
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
    
    
    // MARK: - Private methods
    
    // MARK: > UI
    
    private func setupUI() {
        view.backgroundColor = UIColor.grayBackground

        setupNavigationBar()

        tableView.clipsToBounds = true
        tableView.estimatedRowHeight = 120
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.separatorStyle = .None
        tableView.backgroundColor = UIColor.grayBackground
        tableView.allowsSelection = false
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

        keyboardPanningEnabled = false
        
        if let patternBackground = UIColor.emptyViewBackgroundColor {
            tableView.backgroundColor = UIColor.clearColor()
            view.backgroundColor = patternBackground
        }
        
        productView.delegate = self
    }
    
    private func setupNavigationBar() {
        productView.height = navigationBarHeight
        productView.layoutIfNeeded()

        setNavBarTitleStyle(.Custom(productView))
        setLetGoRightButtonWith(imageName: "ic_more_options", selector: "optionsBtnPressed")
    }
    
    private func addSubviews() {
        relationInfoView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(relationInfoView)
        view.addSubview(activityIndicator)
    }
    
    private func setupFrames() {
        tableView.contentInset.bottom = navBarHeight + blockedToastOffset
        tableView.frame = CGRectMake(0, blockedToastOffset, tableView.width, tableView.height - blockedToastOffset)
        
        activityIndicator.frame = CGRect(x: 0, y: 0, width: 100, height: 100)
        activityIndicator.center = view.center
    }
    
    private func setupConstraints() {
        let views: [String: AnyObject] = ["relationInfoView": relationInfoView]
        view.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("H:|-0-[relationInfoView]-0-|", options: [],
            metrics: nil, views: views))
        view.addConstraint(NSLayoutConstraint(item: relationInfoView, attribute: .Top, relatedBy: .Equal,
            toItem: topLayoutGuide, attribute: .Bottom, multiplier: 1, constant: 0))
    }

    private func setupRelatedProducts() {
        relatedProductsView.setupOnTopOfView(textInputbar)
        relatedProductsView.title.value = LGLocalizedString.chatRelatedProductsTitle
        relatedProductsView.delegate = viewModel
        relatedProductsView.visibleHeight.asObservable().distinctUntilChanged().bindNext { [weak self] _ in
            self?.tableView.reloadData()
            }.addDisposableTo(disposeBag)
    }

    private func setupDirectAnswers() {
        directAnswersPresenter.hidden = !viewModel.shouldShowDirectAnswers
        directAnswersPresenter.setupOnTopOfView(relatedProductsView)
        directAnswersPresenter.setDirectAnswers(viewModel.directAnswers)
        directAnswersPresenter.delegate = viewModel
    }

    private func showActivityIndicator(show: Bool) {
        show ? activityIndicator.startAnimating() : activityIndicator.stopAnimating()
    }

    private func showKeyboard(show: Bool, animated: Bool) {
        if !show { hideStickers() }
        guard viewModel.chatEnabled.value else { return }
        show ? presentKeyboard(animated) : dismissKeyboard(animated)
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
        viewModel.openOptionsMenu()
    }
    
    
    // MARK: > Rating

    private func askForRating() {
        delay(1.0) { [weak self] in
            self?.showKeyboard(false, animated: true)
            guard let tabBarCtrl = self?.tabBarController as? TabBarController else { return }
            tabBarCtrl.showAppRatingViewIfNeeded(.Chat)
        }
    }
}


// MARK: - Stickers

extension ChatViewController {
    
    private func setupStickersView() {
        let height = keyboardHelper.keyboardHeight
        let frame = CGRectMake(0, view.frame.height - height, view.frame.width, height)
        stickersView.frame = frame
        stickersView.delegate = self
        viewModel.stickers.asObservable().bindNext { [weak self] stickers in
            self?.stickersView.reloadStickers(stickers)
            }.addDisposableTo(disposeBag)
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

extension ChatViewController: ChatStickersViewDelegate {
    func stickersViewDidSelectSticker(sticker: Sticker) {
        viewModel.sendSticker(sticker)
    }
}


// MARK: - Rx config

extension ChatViewController {

    private func setupRxBindings() {
        viewModel.chatEnabled.asObservable().bindNext { [weak self] enabled in
            guard let strongSelf = self else { return }
            self?.setTextInputbarHidden(!enabled, animated: true)
            UIView.performWithoutAnimation({ 
                self?.directAnswersPresenter.hidden = !strongSelf.viewModel.shouldShowDirectAnswers
            })
            self?.textView.userInteractionEnabled = enabled
            }.addDisposableTo(disposeBag)
        
        viewModel.chatStatus.asObservable().bindNext { [weak self] status in
            self?.relationInfoView.setupUIForStatus(status, otherUserName: self?.viewModel.interlocutorName.value)
            switch status {
            case .ProductDeleted:
                self?.productView.disableProductInteraction()
            case .Forbidden, .UserPendingDelete, .UserDeleted:
                self?.productView.disableUserProfileInteraction()
                self?.productView.disableProductInteraction()
            case .Available, .Blocked, .BlockedBy, .ProductSold:
                break
            }
            }.addDisposableTo(disposeBag)

        Observable.combineLatest(viewModel.shouldShowReviewButton.asObservable(),
        viewModel.userReviewTooltipVisible.asObservable()) { $0 }
            .subscribeNext { [weak self] (showReviewButton, showReviewTooltip) in
                self?.productView.showReviewButton(showReviewButton, withTooltip: showReviewTooltip)
            }.addDisposableTo(disposeBag)

        viewModel.messages.changesObservable.subscribeNext { [weak self] change in
            switch change {
            case .Composite(let changes) where changes.count > 2:
                self?.tableView.reloadData()
            case .Insert, .Remove, .Composite:
                self?.tableView.handleCollectionChange(change)
            }
            }.addDisposableTo(disposeBag)
        
        viewModel.productName.asObservable().bindTo(productView.productName.rx_text).addDisposableTo(disposeBag)
        viewModel.interlocutorName.asObservable().bindTo(productView.userName.rx_text).addDisposableTo(disposeBag)
        viewModel.productPrice.asObservable().bindTo(productView.productPrice.rx_text).addDisposableTo(disposeBag)
        viewModel.productImageUrl.asObservable().bindNext { [weak self] imageUrl in
            guard let url = imageUrl else { return }
            self?.productView.productImage.lg_setImageWithURL(url)
            }.addDisposableTo(disposeBag)
        
        let placeHolder = Observable.combineLatest(viewModel.interlocutorId.asObservable(),
                                                   viewModel.interlocutorName.asObservable()) {
                                                    (id, name) -> UIImage in
                                                    return LetgoAvatar.avatarWithID(id, name: name)
        }
        Observable.combineLatest(placeHolder, viewModel.interlocutorAvatarURL.asObservable()) { $0 }
            .bindNext { [weak self] (placeholder, avatarUrl) in
                if let url = avatarUrl {
                    self?.productView.userAvatar.lg_setImageWithURL(url, placeholderImage: placeholder)
                } else {
                    self?.productView.userAvatar.image = placeholder
                }
            }.addDisposableTo(disposeBag)
    }
}


// MARK: - TableView Delegate & DataSource

extension ChatViewController {
    
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
        guard indexPath.row < viewModel.objectCount, let message = viewModel.messageAtIndex(indexPath.row) else {
            return UITableViewCell()
        }
        
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
}


// MARK: - ChatViewModelDelegate

extension ChatViewController: ChatViewModelDelegate {
    
    func vmDidFailRetrievingChatMessages() {
        showActivityIndicator(false)
        showAutoFadingOutMessageAlert(LGLocalizedString.chatMessageLoadGenericError) { [weak self] in
            self?.popBackViewController()
        }
    }
    
    func vmDidFailSendingMessage() {
        showAutoFadingOutMessageAlert(LGLocalizedString.chatMessageLoadGenericError)
    }
    
    func vmDidUpdateDirectAnswers() {
        directAnswersPresenter.hidden = !viewModel.shouldShowDirectAnswers
        tableView.reloadData()
    }

    func vmShowRelatedProducts(productId: String?) {
        relatedProductsView.productId.value = productId
    }

    func vmDidUpdateProduct(messageToShow message: String?) {
        // TODO: 🎪 Show a message when marked as sold is implemented
        guard let message = message else { return }
        showAutoFadingOutMessageAlert(message)
    }
    
    func vmClearText() {
        textView.text = ""
    }

    
    // MARK: > Report user

    func vmShowReportUser(reportUserViewModel: ReportUsersViewModel) {
        let vc = ReportUsersViewController(viewModel: reportUserViewModel)
        self.navigationController?.pushViewController(vc, animated: true)
    }

    // MARK: > Rate user

    func vmShowUserRating(source: RateUserSource, data: RateUserData) {
        guard let tabBarController = self.tabBarController as? TabBarController else { return }
        tabBarController.openUserRating(source, data: data)
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

    func vmHideKeyboard(animated: Bool) {
        showKeyboard(false, animated: animated)
    }
    
    func vmShowMessage(message: String, completion: (() -> ())?) {
        showAutoFadingOutMessageAlert(message, completion: completion)
    }
    
    func vmClose() {
        navigationController?.popViewControllerAnimated(true)
    }

    func vmRequestLogin(loggedInAction: () -> Void) {
        dismissKeyboard(false)
        ifLoggedInThen(.AskQuestion, loginStyle: .Popup(LGLocalizedString.chatLoginPopupText),
                       loggedInAction: loggedInAction, elsePresentSignUpWithSuccessAction: loggedInAction)
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
}


// MARK: - Animate ProductView with keyboard

extension ChatViewController {
    // Need to override this to fix the position of the Slack tableView
    // if you have a "header" view below the navBar
    // It is an open issue in the Library https://github.com/slackhq/SlackTextViewController/issues/137
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        self.tableView.contentInset.bottom = navBarHeight + blockedToastOffset
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
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(ChatViewController.menuControllerWillShow(_:)),
                                                         name: UIMenuControllerWillShowMenuNotification, object: nil)
    }
    
    override func tableView(tableView: UITableView, shouldShowMenuForRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        guard let message = viewModel.messageAtIndex(indexPath.row) where message.copyEnabled else { return false }

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

extension ChatViewController {
   
    private func showSafetyTips() {
        guard let navCtlView = navigationController?.view else { return }
        guard let chatSafetyTipsView = ChatSafetyTipsView.chatSafetyTipsView() else { return }

        // Delay is needed in order not to mess with the kb show/hide animation
        delay(0.5) { [weak self] in
            self?.showKeyboard(false, animated: true)
            chatSafetyTipsView.dismissBlock = { [weak self] in
                self?.viewModel.safetyTipsDismissed()
                guard let chatEnabled = self?.viewModel.chatEnabled where chatEnabled.value else { return }
                self?.textView.becomeFirstResponder()
            }
            chatSafetyTipsView.frame = navCtlView.frame
            navCtlView.addSubview(chatSafetyTipsView)
            chatSafetyTipsView.show()
        }
    }
}


// MARK: - ChatProductViewDelegate

extension ChatViewController: ChatProductViewDelegate {  
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


extension ChatViewController {
    func setAccessibilityIds() {
        tableView.accessibilityId = .ChatViewTableView
        navigationItem.rightBarButtonItem?.accessibilityId = .ChatViewMoreOptionsButton
        navigationItem.backBarButtonItem?.accessibilityId = .ChatViewBackButton
        textInputbar.leftButton.accessibilityId = .ChatViewStickersButton
        textInputbar.rightButton.accessibilityId = .ChatViewSendButton
        textInputbar.accessibilityId = .ChatViewTextInputBar
        stickersCloseButton.accessibilityId = .ChatViewCloseStickersButton
    }
}
