//
//  OldChatViewController.swift
//  LetGo
//
//  Created by Isaac Roldan on 23/11/15.
//  Copyright © 2015 Ambatana. All rights reserved.
//

import UIKit
import LGCoreKit
import RxSwift

class OldChatViewController: TextViewController, UITableViewDelegate, UITableViewDataSource {

    let navBarHeight: CGFloat = 64
    let inputBarHeight: CGFloat = 44
    let expressBannerHeight: CGFloat = 44
    var productView: ChatProductView
    var selectedCellIndexPath: IndexPath?
    var viewModel: OldChatViewModel
    var keyboardShown: Bool = false
    var showingStickers = false
    let stickersView: ChatStickersView
    var stickersWindow: UIWindow?
    let expressChatBanner: ChatBanner
    var bannerTopConstraint: NSLayoutConstraint = NSLayoutConstraint()
    var activityIndicator = UIActivityIndicatorView(activityIndicatorStyle: .gray)
    var relationInfoView = RelationInfoView.relationInfoView()   // informs if the user is blocked, or the product sold or inactive
    var directAnswersPresenter: DirectAnswersPresenter
    let relatedProductsView: ChatRelatedProductsView
    let featureFlags: FeatureFlaggeable
    let disposeBag = DisposeBag()

    var blockedToastOffset: CGFloat {
        return relationInfoView.isHidden ? 0 : RelationInfoView.defaultHeight
    }

    convenience init(viewModel: OldChatViewModel) {
        self.init(viewModel: viewModel, hidesBottomBar: true)
    }

    convenience init(viewModel: OldChatViewModel, hidesBottomBar: Bool) {
        self.init(viewModel: viewModel, featureFlags: FeatureFlags.sharedInstance, hidesBottomBar: hidesBottomBar)
    }
    
    // MARK: - View lifecycle
    required init(viewModel: OldChatViewModel, featureFlags: FeatureFlags, hidesBottomBar: Bool) {
        self.viewModel = viewModel
        self.featureFlags = featureFlags
        self.productView = ChatProductView.chatProductView(featureFlags.userReviews)
        self.directAnswersPresenter = DirectAnswersPresenter(websocketChatActive: featureFlags.websocketChat)
        self.relatedProductsView = ChatRelatedProductsView()
        self.stickersView = ChatStickersView()
        self.expressChatBanner = ChatBanner()
        super.init(viewModel: viewModel, nibName: nil)
        self.viewModel.delegate = self
        self.expressChatBanner.delegate = self
        hidesBottomBarWhenPushed = hidesBottomBar
    }
    
    required init(coder decoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit {
        stickersView.removeFromSuperview()
        NotificationCenter.default.removeObserver(self)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        ChatCellDrawerFactory.registerCells(tableView)
        setupUI()
        setupRelatedProducts()
        setupDirectAnswers()
        setupStickersView()
        initStickersWindow()
        setupSendingRx()
        setupExpressBannerRx()
        NotificationCenter.default.addObserver(self, selector: #selector(menuControllerWillShow(_:)),
                                                         name: NSNotification.Name.UIMenuControllerWillShowMenu, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(menuControllerWillHide(_:)),
                                                         name: NSNotification.Name.UIMenuControllerWillHideMenu, object: nil)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        updateChatInteraction(viewModel.chatEnabled)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        removeIgnoreTouchesForTooltip()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        viewModel.didAppear()
    }

    override func didMove(toParentViewController parent: UIViewController?) {
        super.didMove(toParentViewController: parent)
        if parent == nil {
            viewModel.wentBack()
        }
    }

    override func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        guard !text.hasEmojis() else { return false }
        return super.textView(textView, shouldChangeTextIn: range, replacementText: text)
    }
    
    
    // MARK: > Slack methods

    override func sendButtonPressed() {
        viewModel.send(text: textView.text)
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
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.objectCount
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard indexPath.row < viewModel.objectCount else {
            return UITableViewCell()
        }
        let message = viewModel.messageAtIndex(indexPath.row)
        let drawer = ChatCellDrawerFactory.drawerForMessage(message)
        let cell = drawer.cell(tableView, atIndexPath: indexPath)
        
        drawer.draw(cell, message: message)
        UIView.performWithoutAnimation {
            cell.transform = tableView.transform
        }

        return cell
    }

    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell,
                            forRowAt indexPath: IndexPath) {
        DispatchQueue.main.async { [weak self] in
            self?.viewModel.setCurrentIndex(indexPath.row)
        }
    }

    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableViewAutomaticDimension
    }
    
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        showKeyboard(false, animated: true)
    }
    
    
    // MARK: - Private methods
    
    // MARK: > UI
    
    private func setupUI() {
        view.backgroundColor = UIColor.grayBackground
        
        setupNavigationBar()

        tableView.delegate = self
        tableView.dataSource = self
        tableView.clipsToBounds = true
        tableView.estimatedRowHeight = 120
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.separatorStyle = .none
        tableView.backgroundColor = UIColor.grayBackground
        tableView.allowsSelection = false
        textView.placeholder = LGLocalizedString.chatMessageFieldHint
        textView.placeholderColor = UIColor.gray
        textView.placeholderFont = UIFont.systemFont(ofSize: 17)
        textView.tintColor = UIColor.primaryColor
        textViewFont = UIFont.systemFont(ofSize: 17)
        textView.backgroundColor = UIColor.white
        textViewBarColor = UIColor.white
        sendButton.setTitle(LGLocalizedString.chatSendButton, for: .normal)
        sendButton.tintColor = UIColor.primaryColor
        sendButton.titleLabel?.font = UIFont.smallButtonFont
        reloadLeftActions()

        addSubviews()
        setupFrames()
        setupConstraints()

        relationInfoView.setupUIForStatus(viewModel.chatStatus, otherUserName: viewModel.otherUserName)

        if let patternBackground = UIColor.emptyViewBackgroundColor {
            tableView.backgroundColor = UIColor.clear
            view.backgroundColor = patternBackground
        }
        
        updateProductView()

        let action = UIAction(interface: .button(LGLocalizedString.chatExpressBannerButtonTitle,
            .secondary(fontSize: .small, withBorder: true)), action: { [weak self] in
                self?.viewModel.bannerActionButtonTapped()
            })
        expressChatBanner.setupChatBannerWith(LGLocalizedString.chatExpressBannerTitle, action: action)

        keyboardChanges.bindNext { [weak self] change in
            if !change.visible {
                self?.hideStickers()
            }
        }.addDisposableTo(disposeBag)
    }

    private func setupNavigationBar() {
        productView.height = navigationBarHeight
        productView.layoutIfNeeded()

        setNavBarTitleStyle(.custom(productView))
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
        tableView.contentInset.bottom = navBarHeight + blockedToastOffset
        tableView.frame = CGRect(x: 0, y: blockedToastOffset,
                                     width: tableView.width, height: tableView.height - blockedToastOffset)

        activityIndicator.frame = CGRect(x: 0, y: 0, width: 100, height: 100)
        activityIndicator.center = view.center
    }

    private func setupConstraints() {
        var views: [String: Any] = ["relationInfoView": relationInfoView]
        view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-0-[relationInfoView]-0-|", options: [],
            metrics: nil, views: views))
        view.addConstraint(NSLayoutConstraint(item: relationInfoView, attribute: .top, relatedBy: .equal,
                                              toItem: topLayoutGuide, attribute: .bottom, multiplier: 1, constant: 0))

        let bannerHeight = NSLayoutConstraint(item: expressChatBanner, attribute: .height, relatedBy: .greaterThanOrEqual, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: expressBannerHeight)
        expressChatBanner.addConstraint(bannerHeight)

        views = ["expressChatBanner": expressChatBanner]
        bannerTopConstraint = NSLayoutConstraint(item: expressChatBanner, attribute: .top, relatedBy: .equal, toItem: topLayoutGuide, attribute: .bottom, multiplier: 1, constant: -expressBannerHeight)
        let bannerSides = NSLayoutConstraint.constraints(withVisualFormat: "H:|-0-[expressChatBanner]-0-|", options: [], metrics: nil, views: views)

        view.addConstraint(bannerTopConstraint)
        view.addConstraints(bannerSides)
    }

    private func setupRelatedProducts() {
        relatedProductsView.setupOnTopOfView(textViewBar)
        relatedProductsView.title.value = LGLocalizedString.chatRelatedProductsTitle
        relatedProductsView.delegate = viewModel
        relatedProductsView.visibleHeight.asObservable().distinctUntilChanged().bindNext { [weak self] _ in
            self?.configureBottomMargin(animated: true)
        }.addDisposableTo(disposeBag)
    }

    private func setupDirectAnswers() {
        directAnswersPresenter.hidden = viewModel.directAnswersState.value != .visible
        directAnswersPresenter.setupOnTopOfView(relatedProductsView)
        directAnswersPresenter.setDirectAnswers(viewModel.directAnswers)
        directAnswersPresenter.delegate = viewModel

        viewModel.directAnswersState.asObservable().bindNext { [weak self] state in
            guard let strongSelf = self else { return }
            let visible = state == .visible
            strongSelf.directAnswersPresenter.hidden = !visible
            strongSelf.configureBottomMargin(animated: true)
        }.addDisposableTo(disposeBag)
    }

    fileprivate func updateProductView() {
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
        case .forbidden, .userDeleted, .userPendingDelete:
            productView.disableUserProfileInteraction()
            productView.disableProductInteraction()
        case .productDeleted:
            productView.disableProductInteraction()
        case .available, .blocked, .blockedBy, .productSold:
            break
        }

        updateReviewButton()
    }
    
    fileprivate func updateReviewButton() {
        productView.showReviewButton(viewModel.userIsReviewable, withTooltip: viewModel.shouldShowUserReviewTooltip)
        guard let tooltip = productView.userRatingTooltip else { return }
        navigationController?.navigationBar.forceTouchesFor(tooltip)
    }
    
    fileprivate func showActivityIndicator(_ show: Bool) {
        show ? activityIndicator.startAnimating() : activityIndicator.stopAnimating()
    }
    
    fileprivate func updateChatInteraction(_ enabled: Bool) {
        setTextViewBarHidden(!enabled, animated: true)
        textView.isUserInteractionEnabled = enabled
    }
    
    func showKeyboard(_ show: Bool, animated: Bool) {
        if !show { hideStickers() }
        guard viewModel.chatEnabled else { return }
        if show {
            presentKeyboard(animated)
        } else {
            dismissKeyboard(animated)
        }
    }

    fileprivate func configureBottomMargin(animated: Bool) {
        let total = directAnswersPresenter.height + relatedProductsView.visibleHeight.value
        setTableBottomMargin(total, animated: animated)
    }
    
    func removeIgnoreTouchesForTooltip() {
        guard let tooltip = self.productView.userRatingTooltip else { return }
        self.navigationController?.navigationBar.endForceTouchesFor(tooltip)
    }

    
    // MARK: > Navigation
    
    dynamic private func productInfoPressed() {
        viewModel.productInfoPressed()
    }
    
    dynamic private func optionsBtnPressed() {
        viewModel.optionsBtnPressed()
    }
    
    // MARK: > Rating
    
    fileprivate func askForRating() {
        let delay = Int64(1.0 * Double(NSEC_PER_SEC))
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + Double(delay) / Double(NSEC_PER_SEC)) { [weak self] in
            self?.showKeyboard(false, animated: true)
            guard let tabBarCtrl = self?.tabBarController as? TabBarController else { return }
            tabBarCtrl.showAppRatingViewIfNeeded(.chat)
        }
    }
}


// MARK: ConversationDataDisplayer

extension OldChatViewController: ConversationDataDisplayer {
    func isDisplayingConversationData(_ data: ConversationData) -> Bool {
        return viewModel.isMatchingConversationData(data)
    }
}


// MARK: - OldChatViewModelDelegate

extension OldChatViewController: OldChatViewModelDelegate {
    // MARK: > Messages list
    
    func vmDidStartRetrievingChatMessages(hasData: Bool) {
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
        tableView.reloadData()
    }
    
    func vmUpdateAfterReceivingMessagesAtPositions(_ positions: [Int], isUpdate: Bool) {
        showActivityIndicator(false)
        
        guard positions.count > 0 else { return }
        if isUpdate {
            tableView.reloadData()
            return
        }
        
        let newPositions: [IndexPath] = positions.map({IndexPath(row: $0, section: 0)})
        
        tableView.beginUpdates()
        tableView.insertRows(at: newPositions, with: .automatic)
        tableView.endUpdates()
    }
    
    
    // MARK: > Send Message

    func vmClearText() {
        textView.text = ""
    }
    
    func vmDidFailSendingMessage() {
        showAutoFadingOutMessageAlert(LGLocalizedString.chatSendErrorGeneric)
    }
    
    func vmDidSucceedSendingMessage(_ index: Int) {
        tableView.beginUpdates()
        let indexPath = IndexPath(row: index, section: 0)
        tableView.insertRows(at: [indexPath], with: .automatic)
        tableView.endUpdates()
        tableView.scrollToRow(at: indexPath, at: UITableViewScrollPosition.top, animated: true)
    }

    // MARK: > Product

    func vmDidUpdateProduct(messageToShow message: String?) {
        updateProductView()
        guard let message = message else { return }
        showAutoFadingOutMessageAlert(message)
    }

    func vmShowRelatedProducts(_ productId: String?) {
        relatedProductsView.productId.value = productId
    }

    // MARK: > User

    func vmShowReportUser(_ reportUserViewModel: ReportUsersViewModel) {
        let vc = ReportUsersViewController(viewModel: reportUserViewModel)
        self.navigationController?.pushViewController(vc, animated: true)
    }

    func vmShowUserRating(_ source: RateUserSource, data: RateUserData) {
        guard let tabBarController = self.tabBarController as? TabBarController else { return }
        tabBarController.openUserRating(source, data: data)
    }

    // MARK: > Info views
    
    func vmUpdateRelationInfoView(_ status: ChatInfoViewStatus) {
        relationInfoView.setupUIForStatus(status, otherUserName: viewModel.otherUserName)
    }
    
    func vmUpdateChatInteraction(_ enabled: Bool) {
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
    
    func vmShowPrePermissions(_ type: PrePermissionType) {
        showKeyboard(false, animated: true)
        LGPushPermissionsManager.sharedInstance.showPrePermissionsViewFrom(self, type: type, completion: nil)
    }
    
    func vmShowKeyboard() {
        showKeyboard(true, animated: true)
    }
    
    func vmHideKeyboard(animated: Bool) {
        showKeyboard(false, animated: animated)
    }
    
    func vmShowMessage(_ message: String, completion: (() -> ())?) {
        showAutoFadingOutMessageAlert(message, completion:  completion)
    }
    
    func vmShowOptionsList(_ options: [String], actions: [() -> Void]) {
        guard options.count == actions.count else { return }
        let alert = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        alert.popoverPresentationController?.barButtonItem = self.navigationItem.rightBarButtonItem

        for i in 0..<options.count {
            alert.addAction(UIAlertAction(title: options[i], style: .default, handler: { _ in actions[i]() } ))
        }
        
        alert.addAction(UIAlertAction(title: LGLocalizedString.commonCancel, style: .cancel, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
    
    func vmShowQuestion(title: String, message: String, positiveText: String,
                              positiveAction: (() -> Void)?, positiveActionStyle: UIAlertActionStyle?, negativeText: String,
                              negativeAction: (() -> Void)?, negativeActionStyle: UIAlertActionStyle?) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let cancelAction = UIAlertAction(title: negativeText, style: negativeActionStyle ?? .cancel,
                                         handler: { _ in negativeAction?() })
        let goAction = UIAlertAction(title: positiveText, style: positiveActionStyle ?? .default,
                                     handler: { _ in positiveAction?() })
        alert.addAction(cancelAction)
        alert.addAction(goAction)
        
        showKeyboard(false, animated: true)
        present(alert, animated: true, completion: nil)
    }
    
    func vmClose() {
        navigationController?.popBackViewController()
    }

    func vmUpdateReviewButton() {
        updateReviewButton()
    }
}


// MARK: - Animate ProductView with keyboard

extension OldChatViewController {
    // Need to override this to fix the position of the Slack tableView
    // if you have a "header" view below the navBar
    // It is an open issue in the Library https://github.com/slackhq/SlackTextViewController/issues/137
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        tableView.contentInset.bottom = navBarHeight + blockedToastOffset
    }
}


// MARK: - Copy/Paste feature

extension OldChatViewController {
    
    /**
     Listen to UIMenuController Will Show notification and update the menu position if needed.
     By default, the menu is shown in the middle of the tableView, this method repositions it to the middle of the bubble
     
     - parameter notification: NSNotification received
     */
    func menuControllerWillShow(_ notification: Notification) {
        guard let indexPath = selectedCellIndexPath else { return }
        guard let cell = tableView.cellForRow(at: indexPath) as? ChatBubbleCell else { return }
        selectedCellIndexPath = nil
        NotificationCenter.default.removeObserver(self,
                                                            name: NSNotification.Name.UIMenuControllerWillShowMenu, object: nil)
        
        let menu = UIMenuController.shared
        menu.setMenuVisible(false, animated: false)

        let newFrame = tableView.convert(cell.bubbleView.frame, from: cell)
        menu.setTargetRect(newFrame, in: tableView)
        menu.setMenuVisible(true, animated: true)
    }
    
    
    func menuControllerWillHide(_ notification: Notification) {
        NotificationCenter.default.addObserver(self, selector: #selector(OldChatViewController.menuControllerWillShow(_:)),
                                                         name: NSNotification.Name.UIMenuControllerWillShowMenu, object: nil)
    }
    
    func tableView(_ tableView: UITableView, shouldShowMenuForRowAt indexPath: IndexPath) -> Bool {
        let message = viewModel.messageAtIndex(indexPath.row)
        guard message.copyEnabled else { return false }

        selectedCellIndexPath = indexPath //Need to save the currently selected cell to reposition the menu later
        return true
    }
    
    func tableView(_ tableView: UITableView, canPerformAction action: Selector, forRowAt
        indexPath: IndexPath, withSender sender: Any?) -> Bool {
        if action == #selector(copy(_:)) {
            guard let cell = tableView.cellForRow(at: indexPath) else { return false }
            cell.setSelected(true, animated: true)
            return true
        }
        return false
    }
    
    func tableView(_ tableView: UITableView, performAction action: Selector, forRowAt
        indexPath: IndexPath, withSender sender: Any?) {
        if action == #selector(copy(_:)) {
            UIPasteboard.general.string =  viewModel.textOfMessageAtIndex(indexPath.row)
        }
    }
}


// MARK: - ChatSafeTips

extension OldChatViewController {
    
    fileprivate func showSafetyTips() {
        guard let navCtlView = navigationController?.view else { return }
        guard let chatSafetyTipsView = ChatSafetyTipsView.chatSafetyTipsView() else { return }

        navCtlView.isUserInteractionEnabled = false

        // Delay is needed in order not to mess with the kb show/hide animation
        delay(0.5) { [weak self] in
            navCtlView.isUserInteractionEnabled = true
            self?.showKeyboard(false, animated: true)
            chatSafetyTipsView.dismissBlock = { [weak self] in
                self?.viewModel.safetyTipsDismissed()
                guard let chatEnabled = self?.viewModel.chatEnabled, chatEnabled else { return }
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
        showKeyboard(false, animated: true)
        viewModel.reviewUserPressed()
    }

    func productViewDidCloseUserReviewTooltip() {
        viewModel.closeReviewTooltipPressed()
    }
}


// MARK: - Stickers

extension OldChatViewController: UIGestureRecognizerDelegate {
    
    func vmDidUpdateStickers() {
        stickersView.reloadStickers(viewModel.stickers)
    }

    func setupStickersView() {
        let height = keyboardFrame.height
        let frame = CGRect(x: 0, y: view.frame.height - height, width: view.frame.width, height: height)
        stickersView.frame = frame
        stickersView.delegate = self
        vmDidUpdateStickers()
        stickersView.isHidden = true
        singleTapGesture?.addTarget(self, action: #selector(hideStickers))
        let textTapGesture = UITapGestureRecognizer(target: self, action: #selector(hideStickers))
        textTapGesture.delegate = self
        textView.addGestureRecognizer(textTapGesture)
    }

    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer,
                           shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }

    func initStickersWindow() {
        let windowFrame = CGRect(x: 0, y: view.height, width: view.width, height: view.height)
    
        stickersWindow = UIWindow(frame: windowFrame)
        stickersWindow?.windowLevel = 100000001 // needs to be higher then the level of the keyboard (100000000)
        stickersWindow?.addSubview(stickersView)
        stickersWindow?.isHidden = true
        stickersWindow?.backgroundColor = UIColor.clear
        stickersView.isHidden = true
        showingStickers = false

        keyboardChanges.bindNext { [weak self] change in
            guard let `self` = self else { return }
            let origin = change.origin
            let height = change.height
            let windowFrame = CGRect(x:0, y: origin, width: self.view.width, height: height)
            let stickersFrame = CGRect(x: 0, y: 0, width: self.view.width, height: height)
            self.stickersWindow?.frame = windowFrame
            self.stickersView.frame = stickersFrame
        }.addDisposableTo(disposeBag)
    }

    func showStickers() {
        viewModel.stickersShown()
        showKeyboard(true, animated: false)
        stickersWindow?.isHidden = false
        stickersView.isHidden = false
        showingStickers = true
        reloadLeftActions()
    }
    
    func hideStickers() {
        stickersWindow?.isHidden = true
        stickersView.isHidden = true
        showingStickers = false
        reloadLeftActions()
    }

    func reloadLeftActions() {
        var actions = [UIAction]()
        var image: UIImage
        if showingStickers {
            image = #imageLiteral(resourceName: "ic_keyboard")
        } else if viewModel.shouldShowStickerBadge {
            image = #imageLiteral(resourceName: "icStickersWithBadge")
        } else {
            image = #imageLiteral(resourceName: "ic_stickers")
        }
        let kbAction = UIAction(interface: .image(image, nil), action: { [weak self] in
            guard let showing = self?.showingStickers else { return }
            showing ? self?.hideStickers() : self?.showStickers()
            }, accessibilityId: .chatViewStickersButton)
        actions.append(kbAction)

        leftActions = actions
    }
}

extension OldChatViewController: ChatStickersViewDelegate {
    func stickersViewDidSelectSticker(_ sticker: Sticker) {
        viewModel.send(sticker: sticker)
    }
}


// MARK: Sending blocks

extension OldChatViewController {
    func setupSendingRx() {
        let sendActionsEnabled = viewModel.isSendingMessage.asObservable().map { !$0 }
        sendActionsEnabled.bindTo(sendButton.rx.isEnabled).addDisposableTo(disposeBag)
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
        expressChatBanner.isHidden = false
        bannerTopConstraint.constant = 0
        UIView.animate(withDuration: 0.5, animations: { [weak self] in
            self?.view.layoutIfNeeded()
        }) 
    }

    func hideBanner() {
        bannerTopConstraint.constant = -expressChatBanner.frame.height
        UIView.animate(withDuration: 0.5, animations: { [weak self] in
            self?.view.layoutIfNeeded()
        }, completion: { [weak self] _ in
            self?.expressChatBanner.isHidden = true
        }) 
    }
}

extension OldChatViewController: ChatBannerDelegate {
    func chatBannerDidFinish() {
        hideBanner()
    }
}


extension OldChatViewController {
    func setAccessibilityIds() {
        tableView.accessibilityId = .chatViewTableView
        navigationItem.rightBarButtonItem?.accessibilityId = .chatViewMoreOptionsButton
        navigationItem.backBarButtonItem?.accessibilityId = .chatViewBackButton
        sendButton.accessibilityId = .chatViewSendButton
        textViewBar.accessibilityId = .chatViewTextInputBar
        expressChatBanner.accessibilityId = .expressChatBanner
    }
}
