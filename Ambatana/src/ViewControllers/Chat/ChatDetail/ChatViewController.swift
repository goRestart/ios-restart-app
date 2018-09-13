import UIKit
import LGCoreKit
import RxSwift
import MapKit
import LGComponents

final class ChatViewController: TextViewController {

    private var cellMapViewer: CellMapViewer = CellMapViewer()
    private let connectionStatusView = ChatConnectionStatusView()
    private var connectionStatusViewTopConstraint: NSLayoutConstraint = NSLayoutConstraint()
    private let chatPaymentBannerView = ChatPaymentBannerView()
    
    let navBarHeight: CGFloat = 64
    let inputBarHeight: CGFloat = 44
    let expressBannerHeight: CGFloat = 44
    let professionalSellerBannerHeight: CGFloat = 44

    let listingView: ChatListingView
    let chatDetailHeader: ChatDetailNavBarInfoView
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

    var blockedToastOffset: CGFloat {
        return relationInfoView.isHidden ? 0 : RelationInfoView.defaultHeight
    }
    
    var expressChatBannerOffset: CGFloat {
        return expressChatBanner.isHidden ? 0 : expressChatBanner.height
    }
    
    var tableViewInsetBottom: CGFloat {
        return navBarHeight + blockedToastOffset + expressChatBannerOffset
    }
    
    private lazy var textTapGesture: UITapGestureRecognizer = {
        return UITapGestureRecognizer(target: self, action: #selector(hideStickers))
    }()


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
        self.chatDetailHeader = ChatDetailNavBarInfoView()
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
        showConnectionToastView = !featureFlags.showChatConnectionStatusBar.isActive
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
    
    // MARK: - Status Bar style
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .default
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
        textView.placeholder = R.Strings.chatMessageFieldHint
        textView.placeholderColor = UIColor.gray
        textView.placeholderFont = UIFont.systemFont(ofSize: 17)
        textView.backgroundColor = UIColor.white
        textView.text = viewModel.predefinedMessage
        textViewFont = UIFont.systemFont(ofSize: 17)
        textViewBarColor = UIColor.white
        sendButton.setTitle(R.Strings.chatSendButton, for: .normal)
        sendButton.tintColor = UIColor.primaryColor
        sendButton.titleLabel?.font = UIFont.smallButtonFont
        reloadLeftActions()
        
        addSubviews()
        setupFrames()
        setupConstraints()

        
        if let patternBackground = UIColor.emptyViewBackgroundColor {
            tableView.backgroundColor = .clear
            view.backgroundColor = viewModel.showWhiteBackground ? .white : patternBackground
        }
        
        listingView.delegate = self

        let action = UIAction(interface: .button(R.Strings.chatExpressBannerButtonTitle,
            .secondary(fontSize: .small, withBorder: true)), action: { [weak self] in
                self?.viewModel.expressChatBannerActionButtonTapped()
            })
        expressChatBanner.setupChatBannerWith(R.Strings.chatExpressBannerTitle, action: action)
    }

    private func setupNavigationBar() {
        listingView.letgoAssistantTag.isHidden = !viewModel.isUserDummy
        setNavBarTitleStyle(.custom(listingView))
        setLetGoRightButtonWith(image: R.Asset.IconsButtons.icMoreOptions.image, selector: "optionsBtnPressed")
        setNavBarBackgroundStyle(viewModel.showWhiteBackground ? .white : .default)
    }

    private func updateNavigationBarHeaderWith(view: UIView?) {
        guard let view = view else { return }
        setNavBarTitleStyle(.custom(view))
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

        if featureFlags.showChatConnectionStatusBar.isActive {
            view.addSubviewForAutoLayout(connectionStatusView)
            connectionStatusViewTopConstraint = connectionStatusView.topAnchor.constraint(equalTo: safeTopAnchor, constant: Metrics.veryBigMargin)
            NSLayoutConstraint.activate([
                connectionStatusView.heightAnchor.constraint(equalToConstant: ChatConnectionStatusView.standardHeight),
                connectionStatusView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
                connectionStatusView.leadingAnchor.constraint(greaterThanOrEqualTo: view.leadingAnchor, constant: Metrics.margin),
                connectionStatusView.trailingAnchor.constraint(lessThanOrEqualTo: view.trailingAnchor, constant: Metrics.margin),
                connectionStatusViewTopConstraint
                ])
            connectionStatusView.cornerRadius = ChatConnectionStatusView.standardHeight/2
            connectionStatusView.alpha = 0
        }
 
        // TODO: Feature flag payments
        
        view.addSubviewForAutoLayout(chatPaymentBannerView)
        
        let chatPaymentBannerConstraints = [
            chatPaymentBannerView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            chatPaymentBannerView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            chatPaymentBannerView.topAnchor.constraint(equalTo: safeTopAnchor)
        ]
        chatPaymentBannerConstraints.activate()
    }

    fileprivate func setupRelatedProducts() {
        relatedListingsView.setupOnTopOfView(textViewBar)
        relatedListingsView.title.value = R.Strings.chatRelatedProductsTitle
        relatedListingsView.delegate = viewModel
        relatedListingsView.visibleHeight.asObservable().distinctUntilChanged().bind { [weak self] _ in
            self?.configureBottomMargin(animated: true)
        }.disposed(by: disposeBag)
    }

    fileprivate func setupDirectAnswers(_ quickAnswers: [QuickAnswer]) {
        guard quickAnswers.count > 0 else { return }
        guard let parentView = relatedListingsView.superview else { return }
        directAnswersPresenter.horizontalView?.removeFromSuperview()
        let defaultHeight = DirectAnswersHorizontalView.Layout.Height.standard
        let defaultWidth = DirectAnswersHorizontalView.Layout.Width.standard
        let initialFrame = CGRect(x: 0, y: relatedListingsView.top - defaultHeight, width: defaultWidth, height: defaultHeight)
        let directAnswers = DirectAnswersHorizontalView(frame: initialFrame, answers: directAnswersPresenter.answers)
        directAnswers.delegate = directAnswersPresenter
        directAnswers.answersEnabled = directAnswersPresenter.enabled
        directAnswers.isHidden = directAnswersPresenter.hidden
        directAnswers.translatesAutoresizingMaskIntoConstraints = false
        parentView.insertSubview(directAnswers, belowSubview: relatedListingsView)
        directAnswers.layout(with: parentView).leading().trailing()
        directAnswers.layout(with: relatedListingsView).bottom(to: .top, by: -DirectAnswersHorizontalView.Layout.standardSideMargin)
        directAnswersPresenter.horizontalView = directAnswers
        directAnswersPresenter.setDirectAnswers(quickAnswers)
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
        if phoneNumber != nil, viewModel.professionalBannerHasCallAction {
            action = UIAction(interface: .button(R.Strings.chatProfessionalBannerButtonTitle,
                                                 .primary(fontSize: .small)),
                              action: { [weak self] in
                                self?.viewModel.professionalSellerBannerActionButtonTapped()
            })
            buttonIcon = R.Asset.Monetization.icPhoneCall.image
        }

        professionalSellerBanner.setupChatBannerWith(R.Strings.chatProfessionalBannerTitle,
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
        textView.addGestureRecognizer(textTapGesture)
        reloadLeftActions()
    }
    
    @objc func hideStickers() {
        guard showingStickers else { return }
        stickersView.removeFromSuperview()
        showingStickers = false
        textView.removeGestureRecognizer(textTapGesture)
        reloadLeftActions()
    }

    func reloadLeftActions() {
        var actions = [UIAction]()
        var image: UIImage
        if showingStickers {
            image = R.Asset.IconsButtons.icKeyboard.image
        } else if viewModel.showStickerBadge.value {
            image = R.Asset.IconsButtons.icStickersWithBadge.image
        } else {
            image = R.Asset.IconsButtons.icStickers.image
        }
        let kbAction = UIAction(interface: .image(image, nil), action: { [weak self] in
            guard let showing = self?.showingStickers else { return }
            showing ? self?.hideStickers() : self?.showStickers()
        }, accessibility: AccessibilityId.chatViewStickersButton)
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
        guard !viewModel.interlocutorProfessionalInfo.value.isProfessional else { return }
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

    func animateStatusBar(visible: Bool) {
        let existingTopOffset = blockedToastOffset + expressChatBannerOffset
        connectionStatusViewTopConstraint.constant = visible ? Metrics.veryBigMargin + existingTopOffset : existingTopOffset
        UIView.animate(withDuration: 0.5) { [weak self] in
            self?.connectionStatusView.alpha = visible ? 1 : 0
            self?.view.layoutIfNeeded()
        }
    }

    func updateChatActions(enabled: Bool) {
        directAnswersPresenter.enabled = enabled
        navigationItem.rightBarButtonItem?.isEnabled = enabled
        textView.isUserInteractionEnabled = enabled
    }

    func setupRxBindings() {

        viewModel.rx_connectionBarStatus.asDriver().drive(onNext: { [weak self] status in
            guard let _ = status.title else {
                self?.animateStatusBar(visible: false)
                return
            }
            self?.connectionStatusView.status = status
            self?.animateStatusBar(visible: true)
            }).disposed(by: disposeBag)

        viewModel.chatUserInteractionsEnabled.asDriver()
            .distinctUntilChanged()
            .drive(onNext: { [weak self] chatActionsEnabled in
                self?.updateChatActions(enabled: chatActionsEnabled)
            }).disposed(by: disposeBag)

        viewModel.chatEnabled.asObservable().bind { [weak self] enabled in
            self?.setTextViewBarHidden(!enabled, animated: false)
            self?.textView.isUserInteractionEnabled = enabled
            }.disposed(by: disposeBag)
        
        viewModel.textBoxVisible.asDriver().drive(onNext: { [weak self] enabled in
            self?.setTextViewBarHidden(!enabled, animated: false)
            self?.textView.isUserInteractionEnabled = enabled
        }).disposed(by: disposeBag)

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

        viewModel.interlocutorProfessionalInfo.asObservable()
            .map { !$0.isProfessional }
            .bind(to: listingView.proTag.rx.isHidden)
            .disposed(by: disposeBag)

        viewModel.listingName.asObservable().bind(to: listingView.listingName.rx.text).disposed(by: disposeBag)
        viewModel.interlocutorName.asObservable().bind(to: listingView.userName.rx.text).disposed(by: disposeBag)
        viewModel.listingPrice.asObservable().bind(to: listingView.listingPrice.rx.text).disposed(by: disposeBag)
        viewModel.listingImageUrl.asObservable().bind { [weak self] imageUrl in
            guard let url = imageUrl else { return }
            self?.listingView.listingImage.lg_setImageWithURL(url)
            }.disposed(by: disposeBag)
        viewModel.shouldUpdateQuickAnswers
            .asObservable()
            .ignoreNil()
            .distinctUntilChanged()
            .subscribeNext { [weak self] quickAnswers in
                self?.setupDirectAnswers(quickAnswers)
            }
            .disposed(by: disposeBag)
        
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

        Observable.combineLatest(viewModel.interlocutorAvatarURL.asObservable(),
                                 viewModel.interlocutorName.asObservable())
            .bind { [weak self] (avatarUrl, name) in
                guard let vm = self?.viewModel, vm.isUserDummy else { return }
                self?.chatDetailHeader.setupWith(info: .assistant(name: name, imageUrl: avatarUrl)) { [weak self] in
                    self?.viewModel.userInfoPressed()
                }
                self?.updateNavigationBarHeaderWith(view: self?.chatDetailHeader)
            }.disposed(by: disposeBag)

        Observable.combineLatest(viewModel.listingName.asObservable(),
                                 viewModel.listingPrice.asObservable(),
                                 viewModel.listingImageUrl.asObservable())
            .bind { [weak self] (listingName, listingPrice, listingImageUrl) in
                guard let strongSelf = self else { return }
                let isAssistantWithNoProduct = strongSelf.viewModel.isUserDummy
                    && listingName.isEmpty
                guard !isAssistantWithNoProduct else { return }
                guard let showNoUserHeader = self?.featureFlags.showChatHeaderWithoutUser,
                    showNoUserHeader else { return }
                let chatNavBarInfo = ChatDetailNavBarInfo.listing(name: listingName,
                                                                  price: listingPrice,
                                                                  imageUrl: listingImageUrl)
                self?.chatDetailHeader.setupWith(info: chatNavBarInfo) { [weak self] in
                    self?.viewModel.listingInfoPressed()
                }
                self?.updateNavigationBarHeaderWith(view: self?.chatDetailHeader)
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

        viewModel.interlocutorProfessionalInfo.asObservable().bind { [weak self] professionalInfo in
            guard let strongSelf = self else { return }
            guard professionalInfo.isProfessional else { return }
            strongSelf.setupProfessionalSellerBannerWithPhone(phoneNumber: professionalInfo.phoneNumber)
            strongSelf.showProfessionalSellerBanner()
        }.disposed(by: disposeBag)

        viewModel.interlocutorIsVerified.asDriver().drive(onNext: { [weak self] verified in
            self?.listingView.badgeImageView.isHidden = !verified
        }).disposed(by: disposeBag)

        textView.rx.text
            .orEmpty
            .skip(1)
            .bind(to: viewModel.chatBoxText)
            .disposed(by: disposeBag)
        
        
        guard let buyerId = viewModel.buyerId, let sellerId = viewModel.sellerId, let listingId = viewModel.listingIdentifier else { return }
            
        let params = P2PPaymentStateParams(buyerId: buyerId, sellerId: sellerId, listingId: listingId)
        let actionButtonEvent = chatPaymentBannerView
            .actionButtonEvent
            .asObservable()
            .ignore(.none)
        
        actionButtonEvent.subscribeNext { event in
            // TODO: @julian Handle events
        }.disposed(by: disposeBag)
        
        chatPaymentBannerView.configure(with: params)
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
        
        let drawer = ChatCellDrawerFactory.drawerForMessage(message, meetingsEnabled: viewModel.meetingsEnabled)
        let cell = drawer.cell(tableView, atIndexPath: indexPath)

        let bubbleColor: UIColor = viewModel.showWhiteBackground ? .chatOthersBubbleBgColorGray : .chatOthersBubbleBgColorWhite

        drawer.draw(cell, message: message, bubbleColor: bubbleColor)
        UIView.performWithoutAnimation {
            cell.transform = tableView.transform
        }

        if let otherMeetingCell = cell as? ChatOtherMeetingCell {
            otherMeetingCell.delegate = self
            otherMeetingCell.locationDelegate = self
            return otherMeetingCell
        } else if let myMeetingCell = cell as? ChatMyMeetingCell {
            myMeetingCell.locationDelegate = self
            return myMeetingCell
        } else if let ctaCell = cell as? ChatCallToActionCell {
            ctaCell.delegate = self
            return ctaCell
        } else if let carouselCell = cell as? ChatCarouselCollectionCell {
            carouselCell.delegate = self
            return carouselCell
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
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if let message = viewModel.messageAtIndex(indexPath.row) {
            if case .carousel = message.type {
                return ChatCarouselCollectionCardCell.cellSize.height
                    + ChatCarouselCollectionCell.topBottomInsetForShadows*2
                    + ChatCarouselCollectionCell.bottomMargin
            }
        }
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
        showAutoFadingOutMessageAlert(message: R.Strings.chatMessageLoadGenericError) { [weak self] in
            self?.popBackViewController()
        }
    }

    func vmDidUpdateProduct(messageToShow message: String?) {
        guard let message = message else { return }
        showAutoFadingOutMessageAlert(message: message)
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
        pushPermissionManager.showPrePermissionsViewFrom(self, type: type)
    }
    
    func vmDidBeginEditing() {
        showKeyboard(true, animated: true)
    }

    func vmDidEndEditing(animated: Bool) {
        showKeyboard(false, animated: animated)
    }
    
    func vmDidNotifyMessage(_ message: String, completion: (() -> ())?) {
        showAutoFadingOutMessageAlert(message: message, completion: completion)
    }
    
    func vmAskPhoneNumber() {
        let alert = UIAlertController(title: R.Strings.professionalDealerAskPhoneAlertEnterPhone,
                                      message: nil,
                                      preferredStyle: .alert)

        alert.addTextField { [weak self] textField in
            textField.delegate = self
            textField.keyboardType = .numberPad
        }

        let confirmAction = UIAlertAction(title: R.Strings.commonConfirm, style: .default) { [weak self] _ in
            self?.viewModel.sendPhoneFrom(alert: alert)
        }
        alert.addAction(confirmAction)
        let cancelAction = UIAlertAction(title: R.Strings.commonCancel, style: .cancel, handler: nil)
        alert.addAction(cancelAction)

        present(alert, animated: true, completion: nil)
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
            if range.location == SharedConstants.usaFirstDashPosition {
                textField.text?.insert("-", at: String.Index(encodedOffset: SharedConstants.usaFirstDashPosition))
            } else if range.location == SharedConstants.usaSecondDashPosition {
                textField.text?.insert("-", at: String.Index(encodedOffset: SharedConstants.usaSecondDashPosition))
            }
        }
        return true
    }
}

extension ChatViewController: OtherMeetingCellDelegate {
    func acceptMeeting() {
        viewModel.acceptMeeting()
    }

    func rejectMeeting() {
        viewModel.rejectMeeting()
    }
}

extension ChatViewController: MeetingCellImageDelegate, MKMapViewDelegate {
    func meetingCellImageViewPressed(imageView: UIImageView, coordinates: LGLocationCoordinates2D) {

        guard let topView = navigationController?.view else { return }
        cellMapViewer.openMapOnView(mainView: topView, fromInitialView: imageView, withCenterCoordinates: coordinates)

        textView.resignFirstResponder()
    }
}

extension ChatViewController: ChatDeeplinkCellDelegate {

    func openDeeplink(url: URL, trackingKey: String?) {
        viewModel.openDeeplink(url: url, trackingKey: trackingKey)
    }
}
