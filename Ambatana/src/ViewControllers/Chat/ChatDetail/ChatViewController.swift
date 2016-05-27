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

    let productViewHeight: CGFloat = 80
    let navBarHeight: CGFloat = 64
    let inputBarHeight: CGFloat = 44
    let productView: ChatProductView
    var selectedCellIndexPath: NSIndexPath?
    let viewModel: ChatViewModel
    var keyboardShown: Bool = false
    var showingStickers = false
    let activityIndicator = UIActivityIndicatorView(activityIndicatorStyle: .Gray)
    let relationInfoView = RelationInfoView.relationInfoView()   // informs if the user is blocked, or the product sold or inactive
    let directAnswersPresenter: DirectAnswersPresenter
    private let chatBlockedMessageView: ChatBlockedMessageView?
    let stickersView: ChatStickersView
    let stickersCloseButton: UIButton
    let keyboardHelper: KeyboardHelper
    let disposeBag = DisposeBag()

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
        setupRxBindings()
        setupStickersView()
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(ChatViewController.menuControllerWillShow(_:)),
                                                         name: UIMenuControllerWillShowMenuNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(ChatViewController.menuControllerWillHide(_:)),
                                                         name: UIMenuControllerWillHideMenuNotification, object: nil)
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        UIApplication.sharedApplication().setStatusBarStyle(.Default, animated: true)
        updateReachableAndToastViewVisibilityIfNeeded()
        viewModel.active = true
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        viewModel.active = false
    }

    override func textView(textView: UITextView, shouldChangeTextInRange range: NSRange, replacementText text: String) -> Bool {
        guard !text.hasEmojis() else { return false }
        return super.textView(textView, shouldChangeTextInRange: range, replacementText: text)
    }
    
    
    // MARK: - Public methods
    
    func isMatchingConversationData(data: ConversationData) -> Bool {
        return viewModel.isMatchingConversationData(data)
    }
    
    
    // MARK: - Slack methods
    
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

        keyboardPanningEnabled = false
        
        if let patternBackground = StyleHelper.emptyViewBackgroundColor {
            tableView.backgroundColor = UIColor.clearColor()
            view.backgroundColor = patternBackground
        }
        
        productView.delegate = self
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

    private func setupDirectAnswers() {
        directAnswersPresenter.hidden = !viewModel.shouldShowDirectAnswers
        directAnswersPresenter.setupOnTopOfView(textInputbar)
        directAnswersPresenter.setDirectAnswers(viewModel.directAnswers)
        directAnswersPresenter.delegate = viewModel
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
                                                action: #selector(ChatViewModel.chatBlockedViewPressed))
        chatBlockedMessageView.addGestureRecognizer(recognizer)
    }

    private func showActivityIndicator(show: Bool) {
        show ? activityIndicator.startAnimating() : activityIndicator.stopAnimating()
    }

    private func showKeyboard(show: Bool, animated: Bool) {
        if !show { hideStickers() }
        guard viewModel.chatEnabled.value else { return }
        show ? presentKeyboard(animated) : dismissKeyboard(animated)
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
            case .Forbidden:
                self?.productView.disableUserProfileInteraction()
                self?.productView.disableProductInteraction()
            case .Available, .Blocked, .BlockedBy, .ProductSold:
                break
            }
            }.addDisposableTo(disposeBag)
        
        
        viewModel.messages.changesObservable.subscribeNext { [weak self] change in
            switch change {
            case .Composite(let changes) where changes.count > 2:
                self?.tableView.reloadData()
            case .Insert, .Remove, .Composite:
                self?.tableView.beginUpdates()
                self?.handleTableChange(change)
                self?.tableView.endUpdates()
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

    private func handleTableChange(change: CollectionChange<ChatViewMessage>) {
        switch change {
        case .Remove(let index, _):
            let indexPath = NSIndexPath(forRow: index, inSection: 0)
            self.tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: UITableViewRowAnimation.None)
        case .Insert(let index, _):
            let indexPath = NSIndexPath(forRow: index, inSection: 0)
            self.tableView.insertRowsAtIndexPaths([indexPath], withRowAnimation: UITableViewRowAnimation.None)
        case .Composite(let changes):
            changes.forEach { [weak self] change in
                self?.handleTableChange(change)
            }
        }
    }
}


// MARK: - TableView Delegate & DataSource

extension ChatViewController {
    
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
        guard indexPath.row < viewModel.objectCount, let message = viewModel.messageAtIndex(indexPath.row) else {
            return UITableViewCell()
        }
        
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

    func vmDidUpdateProduct(messageToShow message: String?) {
        // TODO: 🎪 Show a message when marked as sold is implemented
        guard let message = message else { return }
        showAutoFadingOutMessageAlert(message)
    }
    
    func vmShowProduct(productVC: UIViewController) {
        showKeyboard(false, animated: false)
        self.navigationController?.pushViewController(productVC, animated: true)
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
        showAutoFadingOutMessageAlert(message, completion: completion)
    }
    
    func vmClose() {
        navigationController?.popViewControllerAnimated(true)
    }
}


// MARK: - Animate ProductView with keyboard

extension ChatViewController {
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
}
