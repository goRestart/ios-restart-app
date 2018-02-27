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
    let professionalSellerBannerHeight: CGFloat = 44

    let listingView: ChatListingView
    var selectedCellIndexPath: IndexPath?
    let viewModel: ChatViewModel
    var keyboardShown: Bool = false
    var showingStickers = false
    let activityIndicator = UIActivityIndicatorView(activityIndicatorStyle: .gray)
    let relationInfoView = RelationInfoView.relationInfoView()   // informs if the user is blocked, or the product sold or inactive
    let relatedListingsView: ChatRelatedListingsView
    let directAnswersPresenter: DirectAnswersPresenter
    let stickersView: ChatStickersView
    let disposeBag = DisposeBag()
    let expressChatBanner: ChatBanner
    var expressChatBannerTopConstraint: NSLayoutConstraint = NSLayoutConstraint()
    let professionalSellerBanner: ChatBanner
    var professionalSellerBannerTopConstraint: NSLayoutConstraint = NSLayoutConstraint()
    var featureFlags: FeatureFlaggeable
    var pushPermissionManager: PushPermissionsManager
    var selectedQuickAnswer: QuickAnswer?

    var blockedToastOffset: CGFloat {
        return relationInfoView.isHidden ? 0 : RelationInfoView.defaultHeight
    }
    
    var expressChatBannerOffset: CGFloat {
        return expressChatBanner.isHidden ? 0 : expressChatBanner.height
    }
    
    var tableViewInsetBottom: CGFloat {
        return navBarHeight + blockedToastOffset + expressChatBannerOffset
    }


    // MARK: - View lifecycle

    convenience init(viewModel: ChatViewModel) {
        self.init(viewModel: viewModel, hidesBottomBar: true)
    }

    convenience init(viewModel: ChatViewModel, hidesBottomBar: Bool) {
        self.init(viewModel: viewModel, featureFlags: FeatureFlags.sharedInstance,
                  pushPermissionManager: LGPushPermissionsManager.sharedInstance,
                  hidesBottomBar: hidesBottomBar)
    }

    required init(viewModel: ChatViewModel, featureFlags: FeatureFlaggeable,
                  pushPermissionManager: PushPermissionsManager,
                  hidesBottomBar: Bool) {
        self.viewModel = viewModel
        self.listingView = ChatListingView.chatListingView()
        self.relatedListingsView = ChatRelatedListingsView()
        self.directAnswersPresenter = DirectAnswersPresenter()
        self.stickersView = ChatStickersView()
        self.featureFlags = featureFlags
        self.pushPermissionManager = pushPermissionManager
        self.expressChatBanner = ChatBanner()
        self.professionalSellerBanner = ChatBanner()
        super.init(viewModel: viewModel, nibName: nil)
        self.viewModel.delegate = self
        self.expressChatBanner.delegate = self
        self.professionalSellerBanner.delegate = self
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
        setupRxBindings()
        setupStickersView()
        initStickersView()
        NotificationCenter.default.addObserver(self, selector: #selector(ChatViewController.menuControllerWillShow(_:)),
                                                         name: NSNotification.Name.UIMenuControllerWillShowMenu, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(ChatViewController.menuControllerWillHide(_:)),
                                                         name: NSNotification.Name.UIMenuControllerWillHideMenu, object: nil)
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        viewModel.didAppear()
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        hideStickers()
    }

    // Need to override this to fix the position of the Slack tableView
    // if you have a "header" view below the navBar
    // It is an open issue in the Library https://github.com/slackhq/SlackTextViewController/issues/137
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        self.tableView.contentInset.bottom = tableViewInsetBottom
    }
    
    override func didMove(toParentViewController parent: UIViewController?) {
        super.didMove(toParentViewController: parent)
        if parent == nil {
            viewModel.wentBack()
        }
    }
    
    override func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        return super.textView(textView, shouldChangeTextIn: range, replacementText: text)
    }

    
    // MARK: - TextViewController methods
    
    override func sendButtonPressed() {
        guard let message = textView.text else { return }
        if let quickAnswer = selectedQuickAnswer, message == quickAnswer.text {
            viewModel.send(quickAnswer: quickAnswer)
        } else {
            viewModel.send(text: message)
        }
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

        setupNavigationBar()

        tableView.delegate = self
        tableView.dataSource = self
        tableView.clipsToBounds = true
        tableView.estimatedRowHeight = 120
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.separatorStyle = .none
        tableView.backgroundColor = UIColor.grayBackground
        tableView.allowsSelection = false
        if #available(iOS 11.0, *) {
            tableView.contentInsetAdjustmentBehavior = .never
        }
        textView.placeholder = LGLocalizedString.chatMessageFieldHint
        textView.placeholderColor = UIColor.gray
        textView.placeholderFont = UIFont.systemFont(ofSize: 17)
        textView.backgroundColor = UIColor.white
        textView.text = viewModel.predefinedMessage
        textViewFont = UIFont.systemFont(ofSize: 17)
        textViewBarColor = UIColor.white
        sendButton.setTitle(LGLocalizedString.chatSendButton, for: .normal)
        sendButton.tintColor = UIColor.primaryColor
        sendButton.titleLabel?.font = UIFont.smallButtonFont
        reloadLeftActions()

        addSubviews()
        setupFrames()
        setupConstraints()

        
        if let patternBackground = UIColor.emptyViewBackgroundColor {
            tableView.backgroundColor = .clear
            view.backgroundColor = patternBackground
        }
        
        listingView.delegate = self

        let action = UIAction(interface: .button(LGLocalizedString.chatExpressBannerButtonTitle,
            .secondary(fontSize: .small, withBorder: true)), action: { [weak self] in
                self?.viewModel.expressChatBannerActionButtonTapped()
            })
        expressChatBanner.setupChatBannerWith(LGLocalizedString.chatExpressBannerTitle, action: action)
    }

    private func setupNavigationBar() {
        listingView.height = navigationBarHeight
        listingView.layoutIfNeeded()

        setNavBarTitleStyle(.custom(listingView))
        setLetGoRightButtonWith(imageName: "ic_more_options", selector: "optionsBtnPressed")
    }
    
    private func addSubviews() {
        relationInfoView.translatesAutoresizingMaskIntoConstraints = false
        expressChatBanner.translatesAutoresizingMaskIntoConstraints = false
        professionalSellerBanner.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(expressChatBanner)
        view.addSubview(relationInfoView)
        view.addSubview(activityIndicator)
        view.addSubview(professionalSellerBanner)
    }

    private func setupFrames() {
        tableView.contentInset.bottom = tableViewInsetBottom
        tableView.frame = CGRect(x: 0, y: blockedToastOffset, width: tableView.width,
                                     height: tableView.height - blockedToastOffset)
        
        activityIndicator.frame = CGRect(x: 0, y: 0, width: 100, height: 100)
        activityIndicator.center = view.center
    }
    
    private func setupConstraints() {
        relationInfoView.layout(with: topLayoutGuide).below()
        relationInfoView.layout(with: view).fillHorizontal()
        
        expressChatBanner.layout().height(expressBannerHeight, relatedBy: .greaterThanOrEqual)
        expressChatBanner.layout(with: view).fillHorizontal()
        expressChatBanner.layout(with: relationInfoView).below(by: -relationInfoView.height, constraintBlock: { [weak self] in self?.expressChatBannerTopConstraint = $0 })
    }

    fileprivate func setupRelatedProducts() {
        relatedListingsView.setupOnTopOfView(textViewBar)
        relatedListingsView.title.value = LGLocalizedString.chatRelatedProductsTitle
        relatedListingsView.delegate = viewModel
        relatedListingsView.visibleHeight.asObservable().distinctUntilChanged().bind { [weak self] _ in
            self?.configureBottomMargin(animated: true)
        }.disposed(by: disposeBag)
    }

    fileprivate func setupDirectAnswers() {
        directAnswersPresenter.hidden = viewModel.directAnswersState.value != .visible
        directAnswersPresenter.setupOnTopOfView(relatedListingsView)
        directAnswersPresenter.setDirectAnswers(viewModel.directAnswers, isDynamic: viewModel.areQuickAnswersDynamic)
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

    fileprivate func configureBottomMargin(animated: Bool) {
        let total = directAnswersPresenter.height + relatedListingsView.visibleHeight.value
        setTableBottomMargin(total, animated: animated)
    }

    fileprivate func setupProfessionalSellerBannerWithPhone(phoneNumber: String?) {
        var action: UIAction? = nil
        var buttonIcon: UIImage? = nil
        if let phone = phoneNumber, phone.isPhoneNumber, viewModel.professionalBannerHasCallAction {
            action = UIAction(interface: .button(LGLocalizedString.chatProfessionalBannerButtonTitle,
                                                 .primary(fontSize: .small)),
                              action: { [weak self] in
                                self?.viewModel.professionalSellerBannerActionButtonTapped()
            })
            buttonIcon = #imageLiteral(resourceName: "ic_phone_call")
        }

        professionalSellerBanner.setupChatBannerWith(LGLocalizedString.chatProfessionalBannerTitle,
                                                     action: action,
                                                     buttonIcon: buttonIcon)

        professionalSellerBanner.layout().height(professionalSellerBannerHeight,
                                                 relatedBy: .greaterThanOrEqual)
        professionalSellerBanner.layout(with: view).fillHorizontal()
        professionalSellerBanner.layout(with: relationInfoView).below(by: -relationInfoView.height,
                                                                      constraintBlock: { [weak self] in
                                                                        self?.professionalSellerBannerTopConstraint = $0
        })
    }

    // MARK: > Navigation
    
    @objc private func listingInfoPressed() {
        viewModel.listingInfoPressed()
    }

    @objc private func optionsBtnPressed() {
        viewModel.openOptionsMenu()
    }
}


// MARK: ConversationDataDisplayer

extension ChatViewController: ConversationIdDisplayer {
    func isDisplayingConversationId(_ conversationId: String) -> Bool {
        return viewModel.isMatchingConversationId(conversationId)
    }
}


// MARK: - Stickers & Direct answers

extension ChatViewController: UIGestureRecognizerDelegate {
    
    fileprivate func setupStickersView() {
        let height = keyboardFrame.height
        let frame = CGRect(x: 0, y: view.frame.height - height, width: view.frame.width, height: height)
        stickersView.frame = frame
        stickersView.delegate = self
        viewModel.stickers.asObservable().bind { [weak self] stickers in
            self?.stickersView.reloadStickers(stickers)
            }.disposed(by: disposeBag)
        singleTapGesture?.addTarget(self, action: #selector(hideStickers))
        let textTapGesture = UITapGestureRecognizer(target: self, action: #selector(hideStickers))
        textTapGesture.delegate = self
        textView.addGestureRecognizer(textTapGesture)
    }
    
    fileprivate func initStickersView() {
        showingStickers = false

        keyboardChanges.bind { [weak self] change in
            guard let `self` = self else { return }
            let stickersFrame = CGRect(x: 0, y: change.origin, width: self.view.width, height: change.height)
            self.stickersView.frame = stickersFrame
        }.disposed(by: disposeBag)
    }
    
    func showStickers() {
        guard !showingStickers else { return }
        viewModel.stickersShown()
        showKeyboard(true, animated: false)
        // Add stickers view to keyboard window (is always the top window)
        UIApplication.shared.windows.last?.addSubview(stickersView)
        showingStickers = true
        reloadLeftActions()
    }
    
    @objc func hideStickers() {
        guard showingStickers else { return }
        stickersView.removeFromSuperview()
        showingStickers = false
        reloadLeftActions()
    }

    func reloadLeftActions() {
        var actions = [UIAction]()
        var image: UIImage
        if showingStickers {
            image = #imageLiteral(resourceName: "ic_keyboard")
        } else if viewModel.showStickerBadge.value {
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

extension ChatViewController: ChatStickersViewDelegate {
    func stickersViewDidSelectSticker(_ sticker: Sticker) {
        viewModel.send(sticker: sticker)
    }
}


// MARK: - ExpressChatBanner

extension ChatViewController {
    func showExpressChatBanner() {
        expressChatBanner.isHidden = false
        expressChatBannerTopConstraint.constant = 0
        UIView.animate(withDuration: 0.5, animations: { [weak self] in
            self?.view.layoutIfNeeded()
        }) 
    }

    func hideExpressChatBanner() {
        expressChatBannerTopConstraint.constant = -expressChatBanner.frame.height
        UIView.animate(withDuration: 0.5, animations: { [weak self] in
            self?.view.layoutIfNeeded()
        }, completion: { [weak self] _ in
            self?.expressChatBanner.isHidden = true
        }) 
    }
}


extension ChatViewController: ChatBannerDelegate {
    func chatBannerDidFinish() {
        guard !viewModel.interlocutorIsProfessional.value else { return }
        hideExpressChatBanner()
    }
}


// MARK: - Professional seller banner

extension ChatViewController {
    func showProfessionalSellerBanner() {
        professionalSellerBanner.isHidden = false
        professionalSellerBannerTopConstraint.constant = 0
        UIView.animate(withDuration: 0.5, animations: { [weak self] in
            self?.view.layoutIfNeeded()
        })
    }
}


// MARK: - Rx config

fileprivate extension ChatViewController {

    func setupRxBindings() {
        viewModel.chatEnabled.asObservable().bind { [weak self] enabled in
            self?.setTextViewBarHidden(!enabled, animated: true)
            self?.textView.isUserInteractionEnabled = enabled
            }.disposed(by: disposeBag)

        viewModel.chatStatus.asObservable().bind { [weak self] status in
            self?.relationInfoView.setupUIForStatus(status, otherUserName: self?.viewModel.interlocutorName.value)
            switch status {
            case .listingDeleted:
                self?.listingView.disableListingInteraction()
            case .forbidden, .userPendingDelete, .userDeleted:
                self?.listingView.disableUserProfileInteraction()
                self?.listingView.disableListingInteraction()
            case .available, .blocked, .blockedBy, .listingSold, .listingGivenAway, .inactiveConversation:
                break
            }
            }.disposed(by: disposeBag)

        viewModel.messages.changesObservable.subscribeNext { [weak self] change in
            switch change {
            case .composite(let changes) where changes.count > 2:
                self?.tableView.reloadData()
            case .insert, .remove, .composite, .swap, .move:
                self?.tableView.handleCollectionChange(change)
            }
            }.disposed(by: disposeBag)

        viewModel.interlocutorIsProfessional.asObservable()
            .map { !$0 }
            .bind(to: listingView.proTag.rx.isHidden)
            .disposed(by: disposeBag)

        viewModel.listingName.asObservable().bind(to: listingView.listingName.rx.text).disposed(by: disposeBag)
        viewModel.interlocutorName.asObservable().bind(to: listingView.userName.rx.text).disposed(by: disposeBag)
        viewModel.listingPrice.asObservable().bind(to: listingView.listingPrice.rx.text).disposed(by: disposeBag)
        viewModel.listingImageUrl.asObservable().bind { [weak self] imageUrl in
            guard let url = imageUrl else { return }
            self?.listingView.listingImage.lg_setImageWithURL(url)
            }.disposed(by: disposeBag)
        viewModel.shouldUpdateQuickAnswers.asObservable().filter{ $0 }.distinctUntilChanged().subscribeNext { [weak self] _ in
            self?.setupDirectAnswers()
        }.disposed(by: disposeBag)
        
        let placeHolder = Observable.combineLatest(viewModel.interlocutorId.asObservable(),
                                                   viewModel.interlocutorName.asObservable()) {
                                                    (id, name) -> UIImage? in
                                                    return LetgoAvatar.avatarWithID(id, name: name)
        }
        Observable.combineLatest(placeHolder, viewModel.interlocutorAvatarURL.asObservable()) { ($0, $1) }
            .bind { [weak self] (placeholder, avatarUrl) in
                if let url = avatarUrl {
                    self?.listingView.userAvatar.lg_setImageWithURL(url, placeholderImage: placeholder)
                } else {
                    self?.listingView.userAvatar.image = placeholder
                }
            }.disposed(by: disposeBag)

        viewModel.shouldShowExpressBanner.asObservable().skip(1).bind { [weak self] showBanner in
            if showBanner {
                self?.showExpressChatBanner()
            } else {
                self?.hideExpressChatBanner()
            }
        }.disposed(by: disposeBag)

        viewModel.directAnswersState.asObservable().bind { [weak self] state in
            guard let strongSelf = self else { return }
            let visible = state == .visible
            strongSelf.directAnswersPresenter.hidden = !visible
            strongSelf.configureBottomMargin(animated: true)
            }.disposed(by: disposeBag)

        keyboardChanges.bind { [weak self] change in
            if !change.visible {
                self?.hideStickers()
            }
        }.disposed(by: disposeBag)
        
        viewModel.showStickerBadge.asObservable().bind { [weak self] _ in
            self?.reloadLeftActions()
        }.disposed(by: disposeBag)
        
        viewModel.relatedListingsState.asObservable().bind { [weak self] state in
            switch state {
            case .visible(let productId):
                self?.relatedListingsView.listingId.value = productId
            case .hidden, .loading:
                self?.relatedListingsView.listingId.value = nil
            }
        }.disposed(by: disposeBag)

        let showProfessionalBanner = Observable.combineLatest(viewModel.interlocutorIsProfessional.asObservable(),
                                                              viewModel.interlocutorPhoneNumber.asObservable()) { ($0, $1) }

        showProfessionalBanner.asObservable().bind { [weak self] (isPro, phoneNum) in
            guard let strongSelf = self else { return }
            guard isPro else { return }
            strongSelf.setupProfessionalSellerBannerWithPhone(phoneNumber: phoneNum)
            strongSelf.showProfessionalSellerBanner()
        }.disposed(by: disposeBag)
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

    func vmDidUpdateProduct(messageToShow message: String?) {
        guard let message = message else { return }
        showAutoFadingOutMessageAlert(message)
    }
    
    func vmDidSendMessage() {
        textView.text = ""
    }

    
    // MARK: > Report user

    func vmDidPressReportUser(_ reportUserViewModel: ReportUsersViewModel) {
        let vc = ReportUsersViewController(viewModel: reportUserViewModel)
        self.navigationController?.pushViewController(vc, animated: true)
    }

    
    // MARK: > Alerts and messages
    
    func vmDidRequestSafetyTips() {
        showSafetyTips()
    }
    
    func vmDidRequestShowPrePermissions(_ type: PrePermissionType) {
        showKeyboard(false, animated: true)
        pushPermissionManager.showPrePermissionsViewFrom(self, type: type, completion: nil)
    }
    
    func vmDidBeginEditing() {
        showKeyboard(true, animated: true)
    }

    func vmDidEndEditing(animated: Bool) {
        showKeyboard(false, animated: animated)
    }
    
    func vmDidNotifyMessage(_ message: String, completion: (() -> ())?) {
        showAutoFadingOutMessageAlert(message, completion: completion)
    }
    
    func vmAskPhoneNumber() {
        let alert = UIAlertController(title: LGLocalizedString.professionalDealerAskPhoneAlertEnterPhone,
                                      message: nil,
                                      preferredStyle: .alert)

        alert.addTextField { [weak self] textField in
            textField.delegate = self
            textField.keyboardType = .numberPad
        }

        let confirmAction = UIAlertAction(title: LGLocalizedString.commonConfirm, style: .default) { [weak self] _ in
            self?.viewModel.sendPhoneFrom(alert: alert)
        }
        alert.addAction(confirmAction)
        let cancelAction = UIAlertAction(title: LGLocalizedString.commonCancel, style: .cancel, handler: nil)
        alert.addAction(cancelAction)

        present(alert, animated: true, completion: nil)
    }


    // MARK: > Direct answers
    
    func vmDidPressDirectAnswer(quickAnswer: QuickAnswer) {
        selectedQuickAnswer = quickAnswer
        textView.text = quickAnswer.text
        textView.becomeFirstResponder()
    }
}


// MARK: - Copy/Paste feature

extension ChatViewController {
    
    /**
     Listen to UIMenuController Will Show notification and update the menu position if needed.
     By default, the menu is shown in the middle of the tableView, this method repositions it to the middle of the bubble
     
     - parameter notification: NSNotification received
     */
    @objc func menuControllerWillShow(_ notification: Notification) {
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
    
    @objc func menuControllerWillHide(_ notification: Notification) {
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
            } as (() -> Void)
            chatSafetyTipsView.frame = navCtlView.frame
            navCtlView.addSubview(chatSafetyTipsView)
            chatSafetyTipsView.show()
        }
    }
}


// MARK: - ChatListingViewDelegate

extension ChatViewController: ChatListingViewDelegate {  
    func listingViewDidTapListingImage() {
        viewModel.listingInfoPressed()
    }
    
    func listingViewDidTapUserAvatar() {
        viewModel.userInfoPressed()
    }
}


extension ChatViewController {
    func setAccessibilityIds() {
        tableView.set(accessibilityId: .chatViewTableView)
        navigationItem.rightBarButtonItem?.set(accessibilityId: .chatViewMoreOptionsButton)
        navigationItem.backBarButtonItem?.set(accessibilityId: .chatViewBackButton)
        sendButton.set(accessibilityId: .chatViewSendButton)
        textViewBar.set(accessibilityId: .chatViewTextInputBar)
        expressChatBanner.set(accessibilityId: .expressChatBanner)
        professionalSellerBanner.set(accessibilityId: .professionalSellerChatBanner)
    }
}

// MARK: UITextFieldDelegate

extension ChatViewController: UITextFieldDelegate {
    func textField(_ textField: UITextField,
                   shouldChangeCharactersIn range: NSRange,
                   replacementString string: String) -> Bool {
        let newText = textField.textReplacingCharactersInRange(range, replacementString: string)
        guard newText.replacingOccurrences(of: "-", with: "").isOnlyDigits else { return false }

        if string.count > 1 {
            textField.text = string.addUSPhoneFormatDashes()
            return false
        } else if range.length == 0 {
            if range.location == Constants.usaFirstDashPosition {
                textField.text?.insert("-", at: String.Index(encodedOffset: Constants.usaFirstDashPosition))
            } else if range.location == Constants.usaSecondDashPosition {
                textField.text?.insert("-", at: String.Index(encodedOffset: Constants.usaSecondDashPosition))
            }
        }
        return true
    }
}
