//
//  ChatGroupedViewController.swift
//  LetGo
//
//  Created by Albert Hernández López on 27/01/16.
//  Copyright © 2016 Ambatana. All rights reserved.
//

import LGCoreKit
import RxCocoa
import RxSwift
import UIKit

class ChatGroupedViewController: BaseViewController, ChatGroupedListViewDelegate,
                                 ChatListViewDelegate, BlockedUsersListViewDelegate, LGViewPagerDataSource,
                                 LGViewPagerDelegate, ScrollableToTop {
    // UI
    var viewPager: LGViewPager
    var editButton: UIBarButtonItem?

    var validationPendingEmptyView: LGEmptyView = LGEmptyView()

    // Data
    fileprivate let viewModel: ChatGroupedViewModel
    private var pages: [BaseView]

    // Rx
    let disposeBag: DisposeBag
    
    // FeatureFlags
    private let featureFlags: FeatureFlaggeable


    // MARK: - Lifecycle

    dynamic fileprivate func edit() {
        setEditing(!isEditing, animated: true)
    }

    init(viewModel: ChatGroupedViewModel, featureFlags: FeatureFlaggeable) {
        self.featureFlags = featureFlags
        self.viewModel = viewModel
        self.viewPager = LGViewPager()
        self.pages = []
        self.disposeBag = DisposeBag()
        super.init(viewModel: viewModel, nibName: nil)
        
        self.editButton = UIBarButtonItem(title: LGLocalizedString.chatListDelete, style: .plain, target: self,
                                          action: #selector(edit))
        
        automaticallyAdjustsScrollViewInsets = false
        hidesBottomBarWhenPushed = false
        hasTabBar = true

        for index in 0..<viewModel.chatListsCount {
            let page: ChatListView
            if featureFlags.websocketChat {
                guard let pageVM = viewModel.wsChatListViewModelForTabAtIndex(index) else { continue }
                page = ChatListView(viewModel: pageVM)
            } else {
                guard let pageVM = viewModel.oldChatListViewModelForTabAtIndex(index) else { continue }
                page = ChatListView(viewModel: pageVM)
            }
            
            page.tableView.accessibilityId = viewModel.accessibilityIdentifierForTableViewAtIndex(index)
            page.footerButton.accessibilityId = .chatListViewFooterButton
            page.chatGroupedListViewDelegate = self
            page.delegate = self
            pages.append(page)
        }
        
        let pageVM = viewModel.blockedUsersListViewModel
        let page = BlockedUsersListView(viewModel: pageVM)
        page.chatGroupedListViewDelegate = self
        page.blockedUsersListViewDelegate = self
        pages.append(page)
        
        setupRxBindings()
        
        
    }
    
    convenience init(viewModel: ChatGroupedViewModel) {
        self.init(viewModel: viewModel, featureFlags: FeatureFlags.sharedInstance)
    }

    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupConstraints()
        setAccessibilityIds()
    }

    override func setEditing(_ editing: Bool, animated: Bool) {
        super.setEditing(editing, animated: animated)
        viewModel.setCurrentPageEditing(editing)
        if viewModel.active {
            tabBarController?.setTabBarHidden(editing, animated: true)
        }
        viewPager.scrollEnabled = !editing
    }

    override var active: Bool {
        didSet {
            pages.forEach { $0.active = active }
        }
    }


    // MARK: - ChatGroupedListViewDelegate

    func chatGroupedListViewShouldUpdateInfoIndicators() {
        viewPager.reloadInfoIndicatorState()
    }


    // MARK: - ChatListViewDelegate

    func chatListView(_ chatListView: ChatListView, showDeleteConfirmationWithTitle title: String, message: String,
        cancelText: String, actionText: String, action: @escaping () -> ()) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let cancelAction = UIAlertAction(title: cancelText, style: .cancel, handler: nil)
        let archiveAction = UIAlertAction(title: actionText, style: .destructive) { (_) -> Void in
            action()
        }
        alert.addAction(cancelAction)
        alert.addAction(archiveAction)
        present(alert, animated: true, completion: nil)
    }

    func chatListViewDidStartArchiving(_ chatListView: ChatListView) {
        showLoadingMessageAlert()
    }

    func chatListView(_ chatListView: ChatListView, didFinishArchivingWithMessage message: String?) {
        dismissLoadingMessageAlert { [weak self] in
            if let message = message {
                self?.showAutoFadingOutMessageAlert(message)
            } else {
                self?.setEditing(false, animated: true)
            }
        }
    }

    func chatListView(_ chatListView: ChatListView, didFinishUnarchivingWithMessage message: String?) {
        dismissLoadingMessageAlert { [weak self] in
            if let message = message {
                self?.showAutoFadingOutMessageAlert(message)
            } else {
                self?.setEditing(false, animated: true)
            }
        }
    }


    // MARK: - BlockedUsersListViewDelegate

    func didSelectBlockedUser(_ user: User) {
        viewModel.blockedUserPressed(user)
    }

    func didStartUnblocking() {
        showLoadingMessageAlert()
    }

    func didFinishUnblockingWithMessage(_ message: String?) {
        dismissLoadingMessageAlert { [weak self] in
            if let message = message {
                self?.showAutoFadingOutMessageAlert(message)
            } else {
                self?.setEditing(false, animated: true)
            }
        }
    }


    // MARK: - LGViewPagerDataSource

    func viewPagerNumberOfTabs(_ viewPager: LGViewPager) -> Int {
        return viewModel.tabCount
    }

    func viewPager(_ viewPager: LGViewPager, viewForTabAtIndex index: Int) -> UIView {
        return pages[index]
    }

    func viewPager(_ viewPager: LGViewPager, showInfoBadgeAtIndex index: Int) -> Bool {
        return viewModel.showInfoBadgeAtIndex(index)
    }

    func viewPager(_ viewPager: LGViewPager, titleForUnselectedTabAtIndex index: Int) -> NSAttributedString {
        return viewModel.titleForTabAtIndex(index, selected: false)
    }

    func viewPager(_ viewPager: LGViewPager, titleForSelectedTabAtIndex index: Int) -> NSAttributedString {
        return viewModel.titleForTabAtIndex(index, selected: true)
    }
    
    func viewPager(_ viewPager: LGViewPager, accessibilityIdentifierAtIndex index: Int) -> AccessibilityId? {
        return viewModel.accessibilityIdentifierForTabButtonAtIndex(index)
    }


    // MARK: - LGViewPagerDelegate

    func viewPager(_ viewPager: LGViewPager, willDisplayView view: UIView, atIndex index: Int) {
        if let tab = ChatGroupedViewModel.Tab(rawValue: index) {
            viewModel.currentTab.value = tab
        }
        if isEditing {
            setEditing(false, animated: true)
        }
        viewModel.refreshCurrentPage()
    }

    func viewPager(_ viewPager: LGViewPager, didEndDisplayingView view: UIView, atIndex index: Int) {

    }


    // MARK: - ScrollableToTop

    func scrollToTop() {
        guard viewPager.currentPage < pages.count else { return }

        if let scrollable = pages[viewPager.currentPage] as? ScrollableToTop {
            scrollable.scrollToTop()
        }
    }


    // MARK: - Private methods

    private func setupUI() {
        #if GOD_MODE
        let chatType = featureFlags.websocketChat ? "New" : "Old"
        let leftButton = UIBarButtonItem(title: chatType, style: .plain, target: self, action: #selector(chatInfo))
        navigationItem.leftBarButtonItem = leftButton
        #endif

        setupValidationEmptyState()

        view.backgroundColor = UIColor.listBackgroundColor
        setNavBarTitle(LGLocalizedString.chatListTitle)

        viewPager.dataSource = self
        viewPager.delegate = self
        viewPager.indicatorSelectedColor = UIColor.primaryColor
        viewPager.infoBadgeColor = UIColor.primaryColor
        viewPager.tabsSeparatorColor = UIColor.lineGray
        viewPager.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(viewPager)

        viewPager.reloadData()
    }

    private func setupValidationEmptyState() {
        guard let emptyVM = viewModel.verificationPendingEmptyVM else { return }
        validationPendingEmptyView.setupWithModel(emptyVM)
        validationPendingEmptyView.frame = view.frame
        view.addSubview(validationPendingEmptyView)
    }

    private dynamic func chatInfo() {
        let message = featureFlags.websocketChat ? "You're using the F*ng new chat!!" : "You're using the crappy old chat :("
        showAutoFadingOutMessageAlert(message)
    }

    private func setupConstraints() {
        let top = NSLayoutConstraint(item: viewPager, attribute: .top, relatedBy: .equal,
            toItem: topLayoutGuide, attribute: .bottom, multiplier: 1, constant: 0)

        let bottom = NSLayoutConstraint(item: viewPager, attribute: .bottom, relatedBy: .equal,
            toItem: bottomLayoutGuide, attribute: .bottom, multiplier: 1, constant: 0)
        view.addConstraints([top, bottom])

        let views = ["viewPager": viewPager]
        let hConstraints = NSLayoutConstraint.constraints(withVisualFormat: "H:|[viewPager]|",
            options: NSLayoutFormatOptions(rawValue: 0), metrics: nil, views: views)
        view.addConstraints(hConstraints)
    }
}


// MARK: - Rx

extension ChatGroupedViewController {

    fileprivate func setupRxBindings() {
        setupRxNavBarBindings()
        setupRxVerificationViewBindings()
    }

    private func setupRxNavBarBindings() {
        viewModel.editButtonText.asObservable().subscribeNext { [weak self] editButtonText in
            guard let strongSelf = self else { return }

            let editButton = UIBarButtonItem(title: editButtonText, style: .plain, target: strongSelf,
                action: #selector(ChatGroupedViewController.edit))
            editButton.isEnabled = strongSelf.viewModel.editButtonEnabled.value
            strongSelf.editButton = editButton
            strongSelf.navigationItem.rightBarButtonItem = editButton
        }.addDisposableTo(disposeBag)

        viewModel.editButtonEnabled.asObservable().subscribeNext { [weak self] enabled in
            guard let strongSelf = self else { return }

            // If becomes hidden then end editing
            let wasEnabled = strongSelf.navigationItem.rightBarButtonItem?.isEnabled ?? false
            if wasEnabled && !enabled {
                self?.setEditing(false, animated: true)
            }

            strongSelf.editButton?.isEnabled = enabled
        }.addDisposableTo(disposeBag)
    }

    private func setupRxVerificationViewBindings() {
        viewModel.verificationPending.asObservable().bindTo(viewPager.rx.isHidden).addDisposableTo(disposeBag)
        viewModel.verificationPending.asObservable().map { !$0 }.bindTo(validationPendingEmptyView.rx.isHidden)
            .addDisposableTo(disposeBag)
    }
}

extension ChatGroupedViewController {
    func setAccessibilityIds() {
        navigationItem.rightBarButtonItem?.accessibilityId = AccessibilityId.chatGroupedViewRightNavBarButton
    }
}
