//
//  ChatGroupedViewController.swift
//  LetGo
//
//  Created by Albert Hernández López on 27/01/16.
//  Copyright © 2016 Ambatana. All rights reserved.
//

import UIKit

class ChatGroupedViewController: BaseViewController, ChatGroupedViewModelDelegate, LGViewPagerDataSource,
                                 LGViewPagerDelegate {
    var viewModel: ChatGroupedViewModel
    var viewPager: LGViewPager
    var pages: [ChatListView]

    // MARK: - Lifecycle

    convenience init() {
        self.init(viewModel: ChatGroupedViewModel())
    }

    init(viewModel: ChatGroupedViewModel) {
        self.viewModel = viewModel
        self.viewPager = LGViewPager()
        self.pages = []
        super.init(viewModel: viewModel, nibName: nil)

        automaticallyAdjustsScrollViewInsets = false
        hidesBottomBarWhenPushed = false

        viewModel.delegate = self
        for index in 0..<viewModel.tabCount {
            let pageVM = viewModel.chatListViewModelForTabAtIndex(index)
            let page = ChatListView(viewModel: pageVM)
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
        guard currentPageIdx < pages.count else { return }

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
        guard let tab = ChatGroupedViewModel.Tab(rawValue: index) else { return }
        viewModel.currentTab = tab

        if editing {
            setEditing(false, animated: true)
        }
    }

    func viewPager(viewPager: LGViewPager, didEndDisplayingView view: UIView, atIndex index: Int) {

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
        // TODO: Strings!
//        let editButton = UIBarButtonItem(barButtonSystemItem: .Edit, target: self, action: "edit")
        let rightBarButtonItem: UIBarButtonItem? = viewModel.hasEditButton ? editButtonItem() : nil
        navigationItem.rightBarButtonItem = rightBarButtonItem
    }
}
