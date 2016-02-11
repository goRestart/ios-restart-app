//
//  ChatGroupedViewController.swift
//  LetGo
//
//  Created by Albert Hernández López on 27/01/16.
//  Copyright © 2016 Ambatana. All rights reserved.
//

import UIKit
import LGCoreKit


class ChatGroupedViewController: BaseViewController, ChatGroupedViewModelDelegate, ChatListViewDelegate,
                                 BlockedUsersListViewDelegate, LGViewPagerDataSource, LGViewPagerDelegate, ScrollableToTop {
    // UI
    var editButton: UIBarButtonItem?
    var viewPager: LGViewPager

    // Data
    private let viewModel: ChatGroupedViewModel
    private var pages: [ChatListView]


    // MARK: - Lifecycle

    convenience init() {
        self.init(viewModel: ChatGroupedViewModel())
    }

    init(viewModel: ChatGroupedViewModel) {
        self.viewModel = viewModel
        self.viewPager = LGViewPager()
        self.pages = []
        super.init(viewModel: viewModel, nibName: nil)
        self.editButton = editButtonItem()

        automaticallyAdjustsScrollViewInsets = false
        hidesBottomBarWhenPushed = false

        viewModel.delegate = self
        for index in 0..<viewModel.tabCount {

            if index < viewModel.tabCount - 1 {
                guard let pageVM = viewModel.chatListViewModelForTabAtIndex(index) as? ChatListViewModel else { continue }
                let page = ChatListView(viewModel: pageVM)
                page.delegate = self
                pages.append(page)
            } else {
                guard let pageVM = viewModel.chatListViewModelForTabAtIndex(index) as? BlockedUsersListViewModel else { continue }
                let page = BlockedUsersListView(viewModel: pageVM)
                page.delegate = self
                pages.append(page)
            }
        }
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
        viewModel.setCurrentPageEditing(editing, animated: animated)
        tabBarController?.setTabBarHidden(editing, animated: true)
        viewPager.scrollEnabled = !editing
    }

    override var active: Bool {
        didSet {
            pages.forEach { $0.active = active }
        }
    }


    // MARK: - ChatGroupedViewModelDelegate

    func viewModelShouldUpdateNavigationBarButtons(viewModel: ChatGroupedViewModel) {
        updateNavigationBarButtons()
    }


    // MARK: - ChatListViewDelegate

    func chatListView(chatListView: ChatListView, didSelectChatWithViewModel chatViewModel: ChatViewModel) {
        navigationController?.pushViewController(ChatViewController(viewModel: chatViewModel), animated: true)
    }

    func chatListViewShouldUpdateNavigationBarButtons(chatListView: ChatListView) {
        updateNavigationBarButtons()
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
        let completion: (() -> ())?
        if let message = message {
            completion = { [weak self] in
                self?.showAutoFadingOutMessageAlert(message)
            }
        } else {
            completion = nil
        }
        dismissLoadingMessageAlert(completion)
    }


    // MARK: - BlockedUsersListViewDelegate

    func blockedUsersListView(blockedUsersListView: BlockedUsersListView, didSelectBlockedUser user: User) {

    }

    func blockedUsersListViewShouldUpdateNavigationBarButtons(blockedUsersListView: BlockedUsersListView) {

    }

    func blockedUsersListView(blockedUsersListView: BlockedUsersListView, showUnblockConfirmationWithTitle title: String, message: String, cancelText: String, actionText: String, action: () -> ()) {
    }

    func blockedUsersListViewDidStartArchiving(blockedUsersListView: BlockedUsersListView) {
    }

    func blockedUsersListView(blockedUsersListView: BlockedUsersListView, didFinishUnblockingWithMessage message: String?) {

    }


    // MARK: - LGViewPagerDataSource

    func viewPagerNumberOfTabs(viewPager: LGViewPager) -> Int {
        return viewModel.tabCount
    }

    func viewPager(viewPager: LGViewPager, viewForTabAtIndex index: Int) -> UIView {
        return pages[index]
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
            viewModel.currentTab = tab
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

        if let pageAsProtocol = pages[viewPager.currentPage] as? protocol<ScrollableToTop> {
            pageAsProtocol.scrollToTop()
        }

//        pages[viewPager.currentPage].scrollToTop()
    }


    // MARK: - Private methods

    private func setupUI() {
        view.backgroundColor = StyleHelper.backgroundColor
        setLetGoNavigationBarStyle(LGLocalizedString.chatListTitle)

        viewPager.dataSource = self
        viewPager.delegate = self
        viewPager.indicatorSelectedColor = StyleHelper.primaryColor
        viewPager.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(viewPager)

        updateNavigationBarButtons()

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

    private func updateNavigationBarButtons() {
        let visible = viewModel.editButtonVisible
        let rightBarButtonItem: UIBarButtonItem? = viewModel.editButtonVisible ? editButton : nil

        let wasVisible = navigationItem.rightBarButtonItem != nil
        if wasVisible && !visible {
            setEditing(false, animated: true)
        }
        navigationItem.rightBarButtonItem = rightBarButtonItem
    }
}
