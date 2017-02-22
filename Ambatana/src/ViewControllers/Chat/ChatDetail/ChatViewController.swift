//
//  ChatViewController.swift
//  LetGo
//
//  Created by Isaac Roldan on 29/4/16.
//  Copyright © 2016 Ambatana. All rights reserved.
//


import UIKit
import LGCoreKit
import RxSwift

class ChatViewController: TextViewController {

    let navBarHeight: CGFloat = 64
    let inputBarHeight: CGFloat = 44
    let expressBannerHeight: CGFloat = 44
    let productView: ChatProductView
    var selectedCellIndexPath: IndexPath?
    let viewModel: ChatViewModel
    var keyboardShown: Bool = false
    var showingStickers = false
    let activityIndicator = UIActivityIndicatorView(activityIndicatorStyle: .gray)
    let relationInfoView = RelationInfoView.relationInfoView()   // informs if the user is blocked, or the product sold or inactive
    let relatedProductsView: ChatRelatedProductsView
    let directAnswersPresenter: DirectAnswersPresenter
    let stickersView: ChatStickersView
    var stickersWindow: UIWindow?
    let disposeBag = DisposeBag()
    let expressChatBanner: ChatBanner
    var bannerTopConstraint: NSLayoutConstraint = NSLayoutConstraint()
    var stickersTooltip: Tooltip?
    var featureFlags: FeatureFlaggeable

    var blockedToastOffset: CGFloat {
        return relationInfoView.isHidden ? 0 : RelationInfoView.defaultHeight
    }


    // MARK: - View lifecycle

    convenience init(viewModel: ChatViewModel) {
        self.init(viewModel: viewModel, hidesBottomBar: true)
    }

    convenience init(viewModel: ChatViewModel, hidesBottomBar: Bool) {
        self.init(viewModel: viewModel, featureFlags: FeatureFlags.sharedInstance, hidesBottomBar: hidesBottomBar)
    }

    required init(viewModel: ChatViewModel, featureFlags: FeatureFlaggeable, hidesBottomBar: Bool) {
        self.viewModel = viewModel
        self.productView = ChatProductView.chatProductView(featureFlags.userReviews)
        self.relatedProductsView = ChatRelatedProductsView()
        self.directAnswersPresenter = DirectAnswersPresenter(websocketChatActive: featureFlags.websocketChat)
        self.stickersView = ChatStickersView()
        self.featureFlags = featureFlags
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
        setupRxBindings()
        setupStickersView()
        initStickersWindow()
        NotificationCenter.default.addObserver(self, selector: #selector(ChatViewController.menuControllerWillShow(_:)),
                                                         name: NSNotification.Name.UIMenuControllerWillShowMenu, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(ChatViewController.menuControllerWillHide(_:)),
                                                         name: NSNotification.Name.UIMenuControllerWillHideMenu, object: nil)
    }


    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        removeStickersTooltip()
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
    
    
    // MARK: - TextViewController methods
    
    override func sendButtonPressed() {
        guard let message = textView.text else { return }
        viewModel.send(text: message)
    }

    /**
     TextViewController Caches the text in the textView if you close the view before sending
     Need to override this method to set the cache key to the product id
     so the cache is not shared between products chats
     
     - returns: Cache key String
     */
    override func keyForTextCaching() -> String? {
        return viewModel.keyForTextCaching
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
        textView.backgroundColor = UIColor.white
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

        
        if let patternBackground = UIColor.emptyViewBackgroundColor {
            tableView.backgroundColor = UIColor.clear
            view.backgroundColor = patternBackground
        }
        
        productView.delegate = self

        let action = UIAction(interface: .button(LGLocalizedString.chatExpressBannerButtonTitle,
            .secondary(fontSize: .small, withBorder: true)), action: { [weak self] in
                self?.viewModel.bannerActionButtonTapped()
            })
        expressChatBanner.setupChatBannerWith(LGLocalizedString.chatExpressBannerTitle, action: action)
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
        tableView.frame = CGRect(x: 0, y: blockedToastOffset, width: tableView.width,
                                     height: tableView.height - blockedToastOffset)
        
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


    fileprivate func setupRelatedProducts() {
        relatedProductsView.setupOnTopOfView(textViewBar)
        relatedProductsView.title.value = LGLocalizedString.chatRelatedProductsTitle
        relatedProductsView.delegate = viewModel
        relatedProductsView.visibleHeight.asObservable().distinctUntilChanged().bindNext { [weak self] _ in
            self?.configureBottomMargin(animated: true)
        }.addDisposableTo(disposeBag)
    }

    fileprivate func setupDirectAnswers() {
        directAnswersPresenter.hidden = viewModel.directAnswersState.value != .visible
        directAnswersPresenter.setDirectAnswers(viewModel.directAnswers)
        directAnswersPresenter.setupOnTopOfView(relatedProductsView)
        directAnswersPresenter.delegate = viewModel
    }

    fileprivate func showActivityIndicator(_ show: Bool) {
        show ? activityIndicator.startAnimating() : activityIndicator.stopAnimating()
    }

    fileprivate func showKeyboard(_ show: Bool, animated: Bool) {
        if !show { hideStickers() }
        guard viewModel.chatEnabled.value else { return }
        show ? presentKeyboard(animated) : dismissKeyboard(animated)
    }

    fileprivate func removeStickersTooltip() {
        if let tooltip = stickersTooltip, view.subviews.contains(tooltip) {
            tooltip.removeFromSuperview()
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
        viewModel.openOptionsMenu()
    }
    
    
    // MARK: > Rating

    fileprivate func askForRating() {
        delay(1.0) { [weak self] in
            self?.showKeyboard(false, animated: true)
            guard let tabBarCtrl = self?.tabBarController as? TabBarController else { return }
            tabBarCtrl.showAppRatingViewIfNeeded(.chat)
        }
    }
}


// MARK: ConversationDataDisplayer

extension ChatViewController: ConversationDataDisplayer {
    func isDisplayingConversationData(_ data: ConversationData) -> Bool {
        return viewModel.isMatchingConversationData(data)
    }
}


// MARK: - Stickers & Direct answers

extension ChatViewController: UIGestureRecognizerDelegate {
    
    fileprivate func setupStickersView() {
        let height = keyboardFrame.height
        let frame = CGRect(x: 0, y: view.frame.height - height, width: view.frame.width, height: height)
        stickersView.frame = frame
        stickersView.delegate = self
        viewModel.stickers.asObservable().bindNext { [weak self] stickers in
            self?.stickersView.reloadStickers(stickers)
            }.addDisposableTo(disposeBag)
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
    
    fileprivate func initStickersWindow() {
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
            let windowFrame = CGRect(x: 0, y: origin, width: self.view.width, height: height)
            let stickersFrame = CGRect(x: 0, y: 0, width: self.view.width, height: height)
            self.stickersWindow?.frame = windowFrame
            self.stickersView.frame = stickersFrame
        }.addDisposableTo(disposeBag)
    }
    
    func showStickers() {
        guard !showingStickers else { return }
        viewModel.stickersShown()
        removeStickersTooltip()
        showKeyboard(true, animated: false)
        stickersWindow?.isHidden = false
        stickersView.isHidden = false
        showingStickers = true
        reloadLeftActions()
    }
    
    func hideStickers() {
        guard showingStickers else { return }
        stickersWindow?.isHidden = true
        stickersView.isHidden = true
        showingStickers = false
        reloadLeftActions()
    }

    func reloadLeftActions() {
        var actions = [UIAction]()

        let image = UIImage(named: showingStickers ? "ic_keyboard" : "ic_stickers")
        let kbAction = UIAction(interface: .image(image, nil), action: { [weak self] in
            guard let showing = self?.showingStickers else { return }
            showing ? self?.hideStickers() : self?.showStickers()
        }, accessibilityId: .chatViewStickersButton)
        actions.append(kbAction)

        leftActions = actions
    }
}

extension ChatViewController: ChatStickersViewDelegate {
    func stickersViewDidSelectSticker(_ sticker: Sticker) {
        viewModel.send(sticker: sticker)
    }
}


// MARK: - ExpressChatBanner

extension ChatViewController {
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


extension ChatViewController: ChatBannerDelegate {
    func chatBannerDidFinish() {
        hideBanner()
    }
}


// MARK: - Rx config

fileprivate extension ChatViewController {

    func setupRxBindings() {
        viewModel.chatEnabled.asObservable().bindNext { [weak self] enabled in
            self?.setTextViewBarHidden(!enabled, animated: true)
            self?.textView.isUserInteractionEnabled = enabled
            }.addDisposableTo(disposeBag)

        viewModel.chatStatus.asObservable().bindNext { [weak self] status in
            self?.relationInfoView.setupUIForStatus(status, otherUserName: self?.viewModel.interlocutorName.value)
            switch status {
            case .productDeleted:
                self?.productView.disableProductInteraction()
            case .forbidden, .userPendingDelete, .userDeleted:
                self?.productView.disableUserProfileInteraction()
                self?.productView.disableProductInteraction()
            case .available, .blocked, .blockedBy, .productSold:
                break
            }
            }.addDisposableTo(disposeBag)

        Observable.combineLatest(viewModel.shouldShowReviewButton.asObservable(),
        viewModel.userReviewTooltipVisible.asObservable()) { $0 }
            .subscribeNext { [weak self] (showReviewButton, showReviewTooltip) in
                self?.productView.showReviewButton(showReviewButton, withTooltip: showReviewTooltip)
                guard let tooltip = self?.productView.userRatingTooltip else { return }
                self?.navigationController?.navigationBar.forceTouchesFor(tooltip)
            }.addDisposableTo(disposeBag)

        viewModel.messages.changesObservable.subscribeNext { [weak self] change in
            switch change {
            case .composite(let changes) where changes.count > 2:
                self?.tableView.reloadData()
            case .insert, .remove, .composite:
                self?.tableView.handleCollectionChange(change)
            }
            }.addDisposableTo(disposeBag)
        
        viewModel.productName.asObservable().bindTo(productView.productName.rx.text).addDisposableTo(disposeBag)
        viewModel.interlocutorName.asObservable().bindTo(productView.userName.rx.text).addDisposableTo(disposeBag)
        viewModel.productPrice.asObservable().bindTo(productView.productPrice.rx.text).addDisposableTo(disposeBag)
        viewModel.productImageUrl.asObservable().bindNext { [weak self] imageUrl in
            guard let url = imageUrl else { return }
            self?.productView.productImage.lg_setImageWithURL(url)
            }.addDisposableTo(disposeBag)
        
        let placeHolder = Observable.combineLatest(viewModel.interlocutorId.asObservable(),
                                                   viewModel.interlocutorName.asObservable()) {
                                                    (id, name) -> UIImage? in
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

        viewModel.shouldShowExpressBanner.asObservable().skip(1).bindNext { [weak self] showBanner in
            if showBanner {
                self?.showBanner()
            } else {
                self?.hideBanner()
            }
        }.addDisposableTo(disposeBag)

        viewModel.directAnswersState.asObservable().bindNext { [weak self] state in
            guard let strongSelf = self else { return }
            let visible = state == .visible
            strongSelf.directAnswersPresenter.hidden = !visible
            strongSelf.configureBottomMargin(animated: true)            
        }.addDisposableTo(disposeBag)

        keyboardChanges.bindNext { [weak self] change in
            if !change.visible {
                self?.hideStickers()
            }
        }.addDisposableTo(disposeBag)
    }
}


// MARK: - TableView Delegate & DataSource

extension ChatViewController: UITableViewDelegate, UITableViewDataSource  {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.objectCount
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard indexPath.row < viewModel.objectCount, let message = viewModel.messageAtIndex(indexPath.row) else {
            return UITableViewCell()
        }
        
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

    func vmShowRelatedProducts(_ productId: String?) {
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

    func vmShowReportUser(_ reportUserViewModel: ReportUsersViewModel) {
        let vc = ReportUsersViewController(viewModel: reportUserViewModel)
        self.navigationController?.pushViewController(vc, animated: true)
    }

    // MARK: > Rate user

    func vmShowUserRating(_ source: RateUserSource, data: RateUserData) {
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
    
    func vmShowPrePermissions(_ type: PrePermissionType) {
        showKeyboard(false, animated: true)
        PushPermissionsManager.sharedInstance.showPrePermissionsViewFrom(self, type: type, completion: nil)
    }
    
    func vmShowKeyboard() {
        showKeyboard(true, animated: true)
    }

    func vmHideKeyboard(_ animated: Bool) {
        showKeyboard(false, animated: animated)
    }
    
    func vmShowMessage(_ message: String, completion: (() -> ())?) {
        showAutoFadingOutMessageAlert(message, completion: completion)
    }

    func vmLoadStickersTooltipWithText(_ text: NSAttributedString) {
        guard stickersTooltip == nil else { return }

        stickersTooltip = Tooltip(targetView: leftButtonsContainer, superView: view, title: text, style: .black(closeEnabled: true),
                                  peakOnTop: false, actionBlock: { [weak self] in
                                    self?.showStickers()
                        }, closeBlock: { [weak self] in
                                    self?.viewModel.stickersShown()
            })

        guard let tooltip = stickersTooltip else { return }
        view.addSubview(tooltip)
        setupExternalConstraintsForTooltip(tooltip, targetView: leftButtonsContainer, containerView: view)

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
        NotificationCenter.default.addObserver(self, selector: #selector(ChatViewController.menuControllerWillShow(_:)),
                                                         name: NSNotification.Name.UIMenuControllerWillShowMenu, object: nil)
    }
    
    func tableView(_ tableView: UITableView, shouldShowMenuForRowAt indexPath: IndexPath) -> Bool {
        guard let message = viewModel.messageAtIndex(indexPath.row), message.copyEnabled else { return false }

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

extension ChatViewController {
   
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
                guard let chatEnabled = self?.viewModel.chatEnabled, chatEnabled.value else { return }
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
        showKeyboard(false, animated: true)
        viewModel.reviewUserPressed()
    }

    func productViewDidCloseUserReviewTooltip() {
        viewModel.closeReviewTooltipPressed()
    }
}


extension ChatViewController {
    func setAccessibilityIds() {
        tableView.accessibilityId = .chatViewTableView
        navigationItem.rightBarButtonItem?.accessibilityId = .chatViewMoreOptionsButton
        navigationItem.backBarButtonItem?.accessibilityId = .chatViewBackButton
        sendButton.accessibilityId = .chatViewSendButton
        textViewBar.accessibilityId = .chatViewTextInputBar
        expressChatBanner.accessibilityId = .expressChatBanner
    }
}
