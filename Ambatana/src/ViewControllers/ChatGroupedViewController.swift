//
//  ChatGroupedViewController.swift
//  LetGo
//
//  Created by Albert Hernández López on 27/01/16.
//  Copyright © 2016 Ambatana. All rights reserved.
//

import UIKit

class ChatGroupedViewController: BaseViewController, ChatGroupedViewModelDelegate, ChatListViewDelegate,
                                 LGViewPagerDataSource, LGViewPagerDelegate, ScrollableToTop {
    var viewModel: ChatGroupedViewModel

    var editButton: UIBarButtonItem?
    var viewPager: LGViewPager

    var pages: [ChatListView]

    override var active: Bool {
        didSet {
            pages.forEach { $0.active = active }
        }
    }

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
            guard let pageVM = viewModel.chatListViewModelForTabAtIndex(index) else { continue }
            let page = ChatListView(viewModel: pageVM)
            page.delegate = self
            pages.append(page)
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

        let currentPageIdx = viewPager.currentPage
        guard currentPageIdx >= 0 && currentPageIdx < pages.count else { return }

        let currentPage = pages[currentPageIdx]
        currentPage.setEditing(editing, animated: animated)

        let tabBarHidden = editing
        let toolBarHidden = !editing
        tabBarController?.setTabBarHidden(tabBarHidden, animated: true) { completed in
            currentPage.setToolbarHidden(toolBarHidden, animated: true)
        }

        viewPager.scrollEnabled = !editing
    }


    // MARK: - ChatGroupedViewModelDelegate

    func viewModelShouldUpdateNavigationBarButtons(viewModel: ChatGroupedViewModel) {
        updateNavigationBarButtons()
    }


    // MARK: - ChatListViewDelegate

    func chatListView(chatListView: ChatListView, didSelectChatWithViewModel chatViewModel: ChatViewModel) {
        navigationController?.pushViewController(ChatViewController(viewModel: chatViewModel), animated: true)
    }

    func chatListView(chatListView: ChatListView, didUpdateStatus status: ChatListStatus) {
        updateNavigationBarButtons()
    }

    func chatListView(chatListView: ChatListView, showArchiveConfirmationWithAction action: () -> ()) {
        let alert = UIAlertController(title: LGLocalizedString.chatListArchiveAlertTitle,
            message: LGLocalizedString.chatListArchiveAlertText,
            preferredStyle: .Alert)

        let noAction = UIAlertAction(title: LGLocalizedString.commonCancel, style: .Cancel, handler: nil)
        let yesAction = UIAlertAction(title: LGLocalizedString.chatListArchive, style: .Default,
            handler: { (_) -> Void in
                action()
        })
        alert.addAction(noAction)
        alert.addAction(yesAction)

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
        // Tab update
        if let tab = ChatGroupedViewModel.Tab(rawValue: index) {
            viewModel.currentTab = tab
        }

        // End the edition
        if editing {
            setEditing(false, animated: true)
        }

        // Refresh
        if viewPager.currentPage < pages.count {
            pages[viewPager.currentPage].refreshConversations()
        }
    }

    func viewPager(viewPager: LGViewPager, didEndDisplayingView view: UIView, atIndex index: Int) {

    }


    // MARK: - ScrollableToTop

    func scrollToTop() {
        guard viewPager.currentPage < pages.count else { return }
        pages[viewPager.currentPage].scrollToTop()
    }


    // MARK: - Private methods

    private func setupUI() {
        view.backgroundColor = UIColor.whiteColor()
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
        guard viewPager.currentPage < pages.count else { return }

        var rightBarButtonItem: UIBarButtonItem? = viewModel.hasEditButton ? editButton : nil
        if viewPager.currentPage > pages.count {
            rightBarButtonItem = nil
        } else if let rightBarButtonItem = rightBarButtonItem {
            let enabled = pages[viewPager.currentPage].chatListStatus == ChatListStatus.Conversations
            updateEditModeWithButton(rightBarButtonItem, enabled: enabled)

            rightBarButtonItem.enabled = enabled
        }
        navigationItem.rightBarButtonItem = rightBarButtonItem
    }

    private func updateEditModeWithButton(button: UIBarButtonItem, enabled: Bool) {
        guard viewPager.currentPage < pages.count else { return }

        let wasEnabled = button.enabled
        if wasEnabled && !enabled {
            setEditing(false, animated: true)
        }
    }
}
