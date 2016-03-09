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

class ChatGroupedViewController: BaseViewController, ChatGroupedViewModelDelegate, ChatGroupedListViewDelegate,
                                 ChatListViewDelegate, BlockedUsersListViewDelegate, LGViewPagerDataSource,
                                 LGViewPagerDelegate, ScrollableToTop {
    // UI
    var viewPager: LGViewPager
    var editButton: UIBarButtonItem?

    // Data
    private let viewModel: ChatGroupedViewModel
    private var pages: [BaseView]

    // Rx
    let disposeBag: DisposeBag


    // MARK: - Lifecycle

    convenience init() {
        self.init(viewModel: ChatGroupedViewModel())
    }

    dynamic private func edit() {
        setEditing(!editing, animated: true)
    }

    init(viewModel: ChatGroupedViewModel) {
        self.viewModel = viewModel
        self.viewPager = LGViewPager()
        self.pages = []
        self.disposeBag = DisposeBag()
        super.init(viewModel: viewModel, nibName: nil)
        self.editButton = UIBarButtonItem(title: LGLocalizedString.chatListDelete, style: .Plain, target: self,
            action: "edit")

        automaticallyAdjustsScrollViewInsets = false
        hidesBottomBarWhenPushed = false

        viewModel.delegate = self
        for index in 0..<viewModel.chatListsCount {
            guard let pageVM = viewModel.chatListViewModelForTabAtIndex(index) else { continue }
            let page = ChatListView(viewModel: pageVM)
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

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    deinit {
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupConstraints()
    }

    override func setEditing(editing: Bool, animated: Bool) {
        super.setEditing(editing, animated: animated)
        viewModel.setCurrentPageEditing(editing)
        tabBarController?.setTabBarHidden(editing, animated: true)
        viewPager.scrollEnabled = !editing
    }

    override var active: Bool {
        didSet {
            pages.forEach { $0.active = active }
        }
    }


    // MARK: - ChatGroupedViewModelDelegate

    func viewModelShouldOpenHome(viewModel: ChatGroupedViewModel) {
        guard let tabBarCtl = tabBarController as? TabBarController else { return }
        tabBarCtl.switchToTab(.Home)
    }

    func viewModelShouldOpenSell(viewModel: ChatGroupedViewModel) {
        guard let tabBarController = self.tabBarController as? TabBarController else { return }
        tabBarController.sellButtonPressed()
    }


    // MARK: - ChatGroupedListViewDelegate

    func chatGroupedListViewShouldUpdateInfoIndicators() {
        viewPager.reloadInfoIndicatorState()
    }


    // MARK: - ChatListViewDelegate

    func chatListView(chatListView: ChatListView, didSelectChatWithViewModel chatViewModel: ChatViewModel) {
        navigationController?.pushViewController(ChatViewController(viewModel: chatViewModel), animated: true)
    }

    func chatListView(chatListView: ChatListView, showArchiveConfirmationWithTitle title: String, message: String,
        cancelText: String, actionText: String, action: () -> ()) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .Alert)
        let cancelAction = UIAlertAction(title: cancelText, style: .Cancel, handler: nil)
        let archiveAction = UIAlertAction(title: actionText, style: .Default) { (_) -> Void in
            action()
        }
        alert.addAction(cancelAction)
        alert.addAction(archiveAction)
        presentViewController(alert, animated: true, completion: nil)
    }

    func chatListViewDidStartArchiving(chatListView: ChatListView) {
        showLoadingMessageAlert()
    }

    func chatListView(chatListView: ChatListView, didFinishArchivingWithMessage message: String?) {
        dismissLoadingMessageAlert { [weak self] in
            if let message = message {
                self?.showAutoFadingOutMessageAlert(message)
            } else {
                self?.setEditing(false, animated: true)
            }
        }
    }

    func chatListView(chatListView: ChatListView, didFinishUnarchivingWithMessage message: String?) {
        dismissLoadingMessageAlert { [weak self] in
            if let message = message {
                self?.showAutoFadingOutMessageAlert(message)
            } else {
                self?.setEditing(false, animated: true)
            }
        }
    }


    // MARK: - BlockedUsersListViewDelegate

    func didSelectBlockedUser(user: User) {
        let blockedUserViewController = EditProfileViewController(user: user, source: EditProfileSource.Chat)
        navigationController?.pushViewController(blockedUserViewController, animated: true)
    }

    func didStartUnblocking() {
        showLoadingMessageAlert()
    }

    func didFinishUnblockingWithMessage(message: String?) {
        dismissLoadingMessageAlert { [weak self] in
            if let message = message {
                self?.showAutoFadingOutMessageAlert(message)
            } else {
                self?.setEditing(false, animated: true)
            }
        }
    }


    // MARK: - LGViewPagerDataSource

    func viewPagerNumberOfTabs(viewPager: LGViewPager) -> Int {
        return viewModel.tabCount
    }

    func viewPager(viewPager: LGViewPager, viewForTabAtIndex index: Int) -> UIView {
        return pages[index]
    }

    func viewPager(viewPager: LGViewPager, showInfoBadgeAtIndex index: Int) -> Bool {
        return viewModel.showInfoBadgeAtIndex(index)
    }

    func viewPager(viewPager: LGViewPager, titleForUnselectedTabAtIndex index: Int) -> NSAttributedString {
        return viewModel.titleForTabAtIndex(index, selected: false)
    }

    func viewPager(viewPager: LGViewPager, titleForSelectedTabAtIndex index: Int) -> NSAttributedString {
        return viewModel.titleForTabAtIndex(index, selected: true)
    }


    // MARK: - LGViewPagerDelegate

    func viewPager(viewPager: LGViewPager, willDisplayView view: UIView, atIndex index: Int) {
        if let tab = ChatGroupedViewModel.Tab(rawValue: index) {
            viewModel.currentTab.value = tab
        }
        if editing {
            setEditing(false, animated: true)
        }
        viewModel.refreshCurrentPage()
    }

    func viewPager(viewPager: LGViewPager, didEndDisplayingView view: UIView, atIndex index: Int) {

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
        view.backgroundColor = StyleHelper.backgroundColor
        setLetGoNavigationBarStyle(LGLocalizedString.chatListTitle)

        viewPager.dataSource = self
        viewPager.delegate = self
        viewPager.indicatorSelectedColor = StyleHelper.primaryColor
        viewPager.infoBadgeColor = StyleHelper.primaryColor
        viewPager.tabsSeparatorColor = StyleHelper.lineColor
        viewPager.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(viewPager)

//        updateNavigationBarButtons()

        viewPager.reloadData()
    }

    private func setupConstraints() {
        let top = NSLayoutConstraint(item: viewPager, attribute: .Top, relatedBy: .Equal,
            toItem: topLayoutGuide, attribute: .Bottom, multiplier: 1, constant: 0)

        let bottom = NSLayoutConstraint(item: viewPager, attribute: .Bottom, relatedBy: .Equal,
            toItem: bottomLayoutGuide, attribute: .Bottom, multiplier: 1, constant: 0)
        view.addConstraints([top, bottom])

        let views = ["viewPager": viewPager]
        let hConstraints = NSLayoutConstraint.constraintsWithVisualFormat("H:|[viewPager]|",
            options: NSLayoutFormatOptions(rawValue: 0), metrics: nil, views: views)
        view.addConstraints(hConstraints)
    }
}


// MARK: - Rx

extension ChatGroupedViewController {

    private func setupRxBindings() {
        setupRxNavBarBindings()
    }

    private func setupRxNavBarBindings() {
        guard let editButton = editButton else { return }
        viewModel.editButtonText.asObservable().bindTo(editButton.rx_optionalTitle).addDisposableTo(disposeBag)
        viewModel.editButtonHidden.asObservable().subscribeNext { [weak self] hidden in
            guard let strongSelf = self else { return }

            // If becomes hidden then end editing
            let wasVisible = strongSelf.navigationItem.rightBarButtonItem != nil
            if wasVisible && hidden {
                self?.setEditing(false, animated: true)
            }

            // Update right bar button
            let rightBarButtonItem: UIBarButtonItem? = hidden ? nil : strongSelf.editButton
            UIView.performWithoutAnimation { _ in
                strongSelf.navigationItem.rightBarButtonItem = rightBarButtonItem
            }

        }.addDisposableTo(disposeBag)
    }
}
