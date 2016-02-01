//
//  LGViewPagerController.swift
//  LetGo
//
//  Created by Albert Hernández López on 27/01/16.
//  Copyright © 2016 Ambatana. All rights reserved.
//

import UIKit

protocol LGViewPagerControllerDelegate: class {
    func viewPagerController(viewPagerController: LGViewPagerController, willDisplayViewController viewController: UIViewController, atIndex index: Int)
    func viewPagerController(viewPagerController: LGViewPagerController, didEndDisplayingViewController viewController: UIViewController, atIndex index: Int)
}

protocol LGViewPagerControllerDataSource: class {
    func viewPagerControllerNumberOfTabs(viewPagerController: LGViewPagerController) -> Int
    func viewPagerController(viewPagerController: LGViewPagerController, viewControllerForTabAtIndex index: Int) -> UIViewController
    func viewPagerController(viewPagerController: LGViewPagerController, titleForSelectedTabAtIndex index: Int) -> NSAttributedString
    func viewPagerController(viewPagerController: LGViewPagerController, titleForUnselectedTabAtIndex index: Int) -> NSAttributedString
}

class LGViewPagerController: UIView, UIScrollViewDelegate {

    weak var delegate: LGViewPagerControllerDelegate?
    weak var dataSource: LGViewPagerControllerDataSource?

    let indicatorHeight: CGFloat = 2
    let tabHeight: CGFloat = 38

    private(set) var currentPage: Int = 0

    var pageCount: Int {
        return viewControllers.count
    }

    // UI
    let tabsScrollView: UIScrollView
    let indicatorContainer: UIView
    let indicator: UIView
    let pagesScrollView: UIScrollView
    var pageWidthConstraints: [NSLayoutConstraint]
    var pageHeightConstraints: [NSLayoutConstraint]

    var tabMenuItems: [LGViewPagerTabItem]
    var viewControllers: [UIViewController]

    var lines: [CALayer]


    // MARK: - Lifecycle

    override init(frame: CGRect) {
        self.tabsScrollView = UIScrollView()
        self.indicatorContainer = UIView()
        self.indicator = UIView()
        self.pagesScrollView = UIScrollView()
        self.pageWidthConstraints = []
        self.pageHeightConstraints = []

        self.viewControllers = []
        self.tabMenuItems = []

        self.lines = []
        super.init(frame: frame)

        setupUI()
        setupConstraints()
    }

    required init?(coder aDecoder: NSCoder) {
        self.tabsScrollView = UIScrollView()
        self.indicatorContainer = UIView()
        self.indicator = UIView()
        self.pagesScrollView = UIScrollView()
        self.pageWidthConstraints = []
        self.pageHeightConstraints = []

        self.viewControllers = []
        self.tabMenuItems = []

        self.lines = []
        super.init(coder: aDecoder)

        setupUI()
        setupConstraints()
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        lines.forEach { $0.removeFromSuperlayer() }
        lines = []
        lines.append(indicatorContainer.addBottomBorderWithWidth(1, color: StyleHelper.lineColor))
    }

    
    // MARK: - Public methods

    /**
    Reloads the data.
    */
    func reloadData() {
        guard let dataSource = dataSource else { return }

        // VCs
        self.viewControllers.forEach { $0.view.removeFromSuperview() }

        let numberOfTabs = dataSource.viewPagerControllerNumberOfTabs(self)
        var viewControllers: [UIViewController] = []
        for index in 0..<numberOfTabs {
            let vc = dataSource.viewPagerController(self, viewControllerForTabAtIndex: index)
            viewControllers.append(vc)
        }

        self.viewControllers = viewControllers

        var previousPage: UIView? = nil
        viewControllers.forEach { [weak self] in
            guard let strongSelf = self else { return }
            let pagesScrollView = strongSelf.pagesScrollView
            var pageWidthConstraints = strongSelf.pageWidthConstraints
            var pageHeightConstraints = strongSelf.pageHeightConstraints

            let page = $0.view
            page.translatesAutoresizingMaskIntoConstraints = false
            pagesScrollView.addSubview($0.view)

            var views = [String: AnyObject]()
            views["page"] = page

            let vConstraints = NSLayoutConstraint.constraintsWithVisualFormat("V:|[page]|",
                options: NSLayoutFormatOptions(rawValue: 0), metrics: nil, views: views)
            pagesScrollView.addConstraints(vConstraints)

            let widthConstraint = NSLayoutConstraint(item: page, attribute: .Width, relatedBy: .Equal,
                toItem: pagesScrollView, attribute: .Width, multiplier: 1, constant: 0)
            pageWidthConstraints.append(widthConstraint)

            let heightConstraint = NSLayoutConstraint(item: page, attribute: .Height, relatedBy: .Equal,
                toItem: pagesScrollView, attribute: .Height, multiplier: 1, constant: 0)
            pageHeightConstraints.append(heightConstraint)

            pagesScrollView.addConstraints([widthConstraint, heightConstraint])

            let leftConstraint: NSLayoutConstraint
            if let previousPage = previousPage {
                leftConstraint = NSLayoutConstraint(item: page, attribute: .Left, relatedBy: .Equal,
                    toItem: previousPage, attribute: .Right, multiplier: 1, constant: 0)
            } else {
                leftConstraint = NSLayoutConstraint(item: page, attribute: .Left, relatedBy: .Equal,
                    toItem: pagesScrollView, attribute: .Left, multiplier: 1, constant: 0)

            }
            pagesScrollView.addConstraint(leftConstraint)

            previousPage = page
        }

        if let lastPage = previousPage {
            let rightConstraint = NSLayoutConstraint(item: lastPage, attribute: .Right, relatedBy: .Equal,
                toItem: pagesScrollView, attribute: .Right, multiplier: 1, constant: 0)
            pagesScrollView.addConstraint(rightConstraint)
        }

        // Tabs
        tabMenuItems.forEach { $0.removeFromSuperview() }

        var previousTab: UIView? = nil
        for index in 0..<numberOfTabs {
            let selectedTitle = dataSource.viewPagerController(self, titleForSelectedTabAtIndex: index)
            let unselectedTitle = dataSource.viewPagerController(self, titleForUnselectedTabAtIndex: index)
            let tab = tabMenuItem(selectedTitle, unselectedTitle: unselectedTitle)
            if index == 0 {
                tab.selected = true
            }

            tab.translatesAutoresizingMaskIntoConstraints = false
            tabsScrollView.addSubview(tab)
            tabMenuItems.append(tab)

            var metrics = [String: AnyObject]()
            metrics["tabHeight"] = tabHeight

            var views = [String: AnyObject]()
            views["tab"] = tab

            let vConstraints = NSLayoutConstraint.constraintsWithVisualFormat("V:|[tab(tabHeight)]|",
                options: NSLayoutFormatOptions(rawValue: 0), metrics: metrics, views: views)
            tabsScrollView.addConstraints(vConstraints)

            let leftConstraint: NSLayoutConstraint
            if let previousTab = previousTab {
                leftConstraint = NSLayoutConstraint(item: tab, attribute: .Left, relatedBy: .Equal,
                    toItem: previousTab, attribute: .Right, multiplier: 1, constant: 0)
            } else {
                leftConstraint = NSLayoutConstraint(item: tab, attribute: .Left, relatedBy: .Equal,
                    toItem: tabsScrollView, attribute: .Left, multiplier: 1, constant: 0)
            }
            tabsScrollView.addConstraint(leftConstraint)

            previousTab = tab
        }
        if let lastTab = previousTab {
            let rightConstraint = NSLayoutConstraint(item: lastTab, attribute: .Right, relatedBy: .Equal,
                toItem: tabsScrollView, attribute: .Right, multiplier: 1, constant: 0)
            tabsScrollView.addConstraint(rightConstraint)
        }
    }

    // MARK: - UIScrollViewDelegate

    func scrollViewDidScroll(scrollView: UIScrollView) {
        switch scrollView {
        case pagesScrollView:
            guard !scrollingTabScrollViewAnimately else { return }

            let pagePosition = currentPagePosition()
            let remaining = pagePosition - CGFloat(Int(pagePosition))
            guard remaining != 0 else { return }

            let toIndex: Int
            if pagePosition > CGFloat(currentPage) {
                toIndex = min(currentPage + 1, viewControllers.count - 1)
            } else {
                toIndex = max(0, currentPage - 1)
            }

            let fromTab = tabMenuItems[currentPage]
            let toTab = tabMenuItems[toIndex]

            let leftTab: LGViewPagerTabItem
            let rightTab: LGViewPagerTabItem
            if fromTab.frame.origin.x < toTab.frame.origin.x {
                leftTab = fromTab
                rightTab = toTab
            } else {
                leftTab = toTab
                rightTab = fromTab
            }


            let offsetLeft = offsetForSelectedTab(leftTab)
            let offsetRight = offsetForSelectedTab(rightTab)
            let offsetDelta = offsetRight.x - offsetLeft.x
            let offsetX = offsetLeft.x + offsetDelta * remaining
            let offset = CGPoint(x: offsetX, y: 0)

            tabsScrollView.setContentOffset(offset, animated: false)
        default:
            break
        }
    }

    func scrollViewWillBeginDragging(scrollView: UIScrollView) {
        switch scrollView {
        case pagesScrollView:
            updateCurrentPage()
        default:
            break
        }
    }

    func scrollViewDidEndScrollingAnimation(scrollView: UIScrollView) {

        switch scrollView {
        case pagesScrollView:
            print("scrollViewDidEndScrollingAnimation")
            updateCurrentPage()
        case tabsScrollView:
            scrollingTabScrollViewAnimately = false
        default:
            break
        }
    }

    func scrollViewDidEndDragging(scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        if decelerate {
            switch scrollView {
            case pagesScrollView:
                updateCurrentPage()
            default:
                break
            }
        }
    }

    func scrollViewDidEndDecelerating(scrollView: UIScrollView) {
        switch scrollView {
        case pagesScrollView:
            print("scrollViewDidEndDecelerating")
            updateCurrentPage()
        default:
            break
        }
    }



    // MARK: - Private methods

    /**
    Sets up the user interface.
    */
    private func setupUI() {
        tabsScrollView.translatesAutoresizingMaskIntoConstraints = false
        tabsScrollView.bounces = false
        tabsScrollView.showsHorizontalScrollIndicator = false
        tabsScrollView.showsVerticalScrollIndicator = false
        tabsScrollView.backgroundColor = UIColor.whiteColor()
        tabsScrollView.delegate = self

        addSubview(tabsScrollView)

        indicatorContainer.translatesAutoresizingMaskIntoConstraints = false
        addSubview(indicatorContainer)

        indicator.translatesAutoresizingMaskIntoConstraints = false
        indicatorContainer.backgroundColor = UIColor.clearColor()
        indicatorContainer.addSubview(indicator)

        pagesScrollView.translatesAutoresizingMaskIntoConstraints = false
        pagesScrollView.pagingEnabled = true
        pagesScrollView.bounces = false
        pagesScrollView.showsHorizontalScrollIndicator = false
        pagesScrollView.showsVerticalScrollIndicator = false
        pagesScrollView.backgroundColor = UIColor.redColor()
        pagesScrollView.delegate = self
        addSubview(pagesScrollView)
    }

    /**
    Sets up the autolayout constraints.
    */
    private func setupConstraints() {
        var views = [String: AnyObject]()
        views["tabs"] = tabsScrollView
        views["indicator"] = indicatorContainer
        views["pages"] = pagesScrollView

        var metrics = [String: AnyObject]()
        metrics["indicatorH"] = indicatorHeight
        metrics["tabsH"] = tabHeight

        let vConstraints = NSLayoutConstraint.constraintsWithVisualFormat("V:|-0-[tabs(tabsH)]-0-[pages]-0-|",
            options: NSLayoutFormatOptions(rawValue: 0), metrics: metrics, views: views)
        addConstraints(vConstraints)

        let vIndicatorConstraints = NSLayoutConstraint.constraintsWithVisualFormat("V:[indicator(indicatorH)]-0-[pages]",
            options: NSLayoutFormatOptions(rawValue: 0), metrics: metrics, views: views)
        addConstraints(vIndicatorConstraints)

        let tabsHConstraints = NSLayoutConstraint.constraintsWithVisualFormat("H:|[tabs]|",
            options: NSLayoutFormatOptions(rawValue: 0), metrics: nil, views: views)
        addConstraints(tabsHConstraints)

        let indicatorHConstraints = NSLayoutConstraint.constraintsWithVisualFormat("H:|[indicator]|",
            options: NSLayoutFormatOptions(rawValue: 0), metrics: nil, views: views)
        addConstraints(indicatorHConstraints)

        let pagesHConstraints = NSLayoutConstraint.constraintsWithVisualFormat("H:|[pages]|",
            options: NSLayoutFormatOptions(rawValue: 0), metrics: nil, views: views)
        addConstraints(pagesHConstraints)
    }

    /**
    Updates the current page.
    */
    private func updateCurrentPage() {
        var currentTab = tabMenuItems[currentPage]
        currentTab.selected = false

        currentPage = min(Int(round(currentPagePosition())), viewControllers.count-1)

        currentTab = tabMenuItems[currentPage]
        currentTab.selected = true
    }

    /**
    Returns the current page position.
    */
    private func currentPagePosition() -> CGFloat {
        return currentPercentagePosition() * CGFloat(pageCount)
    }

    /**
    Returns the current percentage position.
    */
    private func currentPercentagePosition() -> CGFloat {
        return pagesScrollView.contentOffset.x / pagesScrollView.contentSize.width
    }

    /**
    Returns the offset for the given tab to be selected.

    :parameter: tab The tab to be selected.
    :return: The offset.
    */
    private func offsetForSelectedTab(tab: LGViewPagerTabItem) -> CGPoint {
        let minX = CGFloat(0)
        let maxX = tabsScrollView.contentSize.width - tabsScrollView.frame.size.width
        let centerTab = tab.frame.origin.x + tab.frame.size.width/2 - tabsScrollView.frame.size.width/2
        let x = min(max(minX, centerTab), maxX)

        return CGPoint(x: x, y: 0)
    }

    private func tabMenuItem(selectedTitle: NSAttributedString, unselectedTitle: NSAttributedString) -> LGViewPagerTabItem {
        let item = LGViewPagerTabItem(selectedTitle: selectedTitle, unselectedTitle: unselectedTitle,
            indicatorHeight: indicatorHeight)
        item.addTarget(self, action: "tabMenuItemPressed:", forControlEvents: .TouchUpInside)
        item.selected = false
        return item
    }

    var scrollingTabScrollViewAnimately = false

    private dynamic func tabMenuItemPressed(sender: LGViewPagerTabItem) {
        scrollTabScrollViewToTab(sender)

        guard let idx = tabMenuItems.indexOf(sender) else { return }
        let x = CGFloat(idx) * pagesScrollView.frame.size.width
        let rect = CGRect(x: x, y: 0, width: pagesScrollView.frame.size.width, height: pagesScrollView.frame.size.height)
        pagesScrollView.scrollRectToVisible(rect, animated: true)
    }

    private func scrollTabScrollViewToTab(tab: LGViewPagerTabItem) {
        scrollingTabScrollViewAnimately = true

        let offset = offsetForSelectedTab(tab)
        // eventually calls scrollViewDidEndScrollingAnimation(:)
        tabsScrollView.setContentOffset(offset, animated: true)
    }
}
