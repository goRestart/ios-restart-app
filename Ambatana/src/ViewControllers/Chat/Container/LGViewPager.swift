//
//  LGViewPagerController.swift
//  LetGo
//
//  Created by Albert Hernández López on 27/01/16.
//  Copyright © 2016 Ambatana. All rights reserved.
//

import UIKit


protocol LGViewPagerDelegate: class {
    func viewPager(viewPager: LGViewPager, willDisplayViewController viewController: UIViewController, atIndex index: Int)
    func viewPager(viewPager: LGViewPager, didEndDisplayingViewController viewController: UIViewController, atIndex index: Int)
}


protocol LGViewPagerDataSource: class {
    func viewPagerNumberOfTabs(viewPager: LGViewPager) -> Int
    func viewPager(viewPager: LGViewPager, viewControllerForTabAtIndex index: Int) -> UIViewController
    func viewPager(viewPager: LGViewPager, titleForSelectedTabAtIndex index: Int) -> NSAttributedString
    func viewPager(viewPager: LGViewPager, titleForUnselectedTabAtIndex index: Int) -> NSAttributedString
}


class LGViewPager: UIView, UIScrollViewDelegate {

    // Constants
    private static let defaultIndicatorSelectedColor = UIColor.redColor()

    // UI
    private let tabsScrollView: UIScrollView
    private let indicatorContainer: UIView
    private let indicator: UIView
    private let pagesScrollView: UIScrollView
    private var pageWidthConstraints: [NSLayoutConstraint]
    private var pageHeightConstraints: [NSLayoutConstraint]

    private var tabMenuItems: [LGViewPagerTabItem]
    private var viewControllers: [UIViewController]

    private var lines: [CALayer]

    var indicatorSelectedColor: UIColor {
        didSet {
            tabMenuItems.forEach { $0.indicatorSelectedColor = indicatorSelectedColor }
        }
    }

    // Delegate & data source
    weak var delegate: LGViewPagerDelegate?
    weak var dataSource: LGViewPagerDataSource?

    // Data
    private let indicatorHeight: CGFloat = 2
    private let tabHeight: CGFloat = 38

    private(set) var currentPage: Int = 0

    var pageCount: Int {
        return viewControllers.count
    }

    private var scrollingTabScrollViewAnimately: Bool


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

        self.indicatorSelectedColor = LGViewPager.defaultIndicatorSelectedColor

        self.scrollingTabScrollViewAnimately = false
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

        self.indicatorSelectedColor = LGViewPager.defaultIndicatorSelectedColor

        self.scrollingTabScrollViewAnimately = false
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

    func reloadData() {
        reloadPages()
        reloadTabs()
    }

    func reloadTabMenuItemTitles() {
        guard let dataSource = dataSource else { return }

        for (index, tabMenuItem) in tabMenuItems.enumerate() {
            let selectedTitle = dataSource.viewPager(self, titleForSelectedTabAtIndex: index)
            tabMenuItem.selectedTitle = selectedTitle
            let unselectedTitle = dataSource.viewPager(self, titleForUnselectedTabAtIndex: index)
            tabMenuItem.unselectedTitle = unselectedTitle
        }
    }


    // MARK: - UIScrollViewDelegate

    func scrollViewDidScroll(scrollView: UIScrollView) {
        switch scrollView {
        case pagesScrollView:
            // If tabs scroll view is animating do not move it
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
            updateCurrentPageAndNotifyDelegate(false)
        default:
            break
        }
    }

    func scrollViewDidEndScrollingAnimation(scrollView: UIScrollView) {

        switch scrollView {
        case pagesScrollView:
            updateCurrentPageAndNotifyDelegate(true)
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
                updateCurrentPageAndNotifyDelegate(false)
            default:
                break
            }
        }
    }

    func scrollViewDidEndDecelerating(scrollView: UIScrollView) {
        switch scrollView {
        case pagesScrollView:
            updateCurrentPageAndNotifyDelegate(true)
        default:
            break
        }
    }



    // MARK: - Private methods
    // MARK: > UI

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

    private func reloadPages() {
        guard let dataSource = dataSource else { return }

        viewControllers.forEach { $0.view.removeFromSuperview() }
        viewControllers = []

        let numberOfTabs = dataSource.viewPagerNumberOfTabs(self)
        var previousPage: UIView? = nil
        for index in 0..<numberOfTabs {
            let vc = dataSource.viewPager(self, viewControllerForTabAtIndex: index)
            viewControllers.append(vc)
            if index == 0 {
                delegate?.viewPager(self, willDisplayViewController: vc, atIndex: 0)
            }

            let page = vc.view
            page.translatesAutoresizingMaskIntoConstraints = false
            pagesScrollView.addSubview(page)

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

            // A left constraint in installed to previous page if any, otherwise it installed against the scroll view
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
    }

    private func reloadTabs() {
        guard let dataSource = dataSource else { return }

        tabMenuItems.forEach { $0.removeFromSuperview() }
        tabMenuItems = []

        let numberOfTabs = dataSource.viewPagerNumberOfTabs(self)
        var previousTab: UIView? = nil
        for index in 0..<numberOfTabs {
            let selectedTitle = dataSource.viewPager(self, titleForSelectedTabAtIndex: index)
            let unselectedTitle = dataSource.viewPager(self, titleForUnselectedTabAtIndex: index)

            let tab = buildTabMenuItem(selectedTitle, unselectedTitle: unselectedTitle)
            tabMenuItems.append(tab)
            if index == 0 {
                tab.selected = true
            }

            tab.translatesAutoresizingMaskIntoConstraints = false
            tabsScrollView.addSubview(tab)

            var metrics = [String: AnyObject]()
            metrics["tabHeight"] = tabHeight

            var views = [String: AnyObject]()
            views["tab"] = tab

            let vConstraints = NSLayoutConstraint.constraintsWithVisualFormat("V:|[tab(tabHeight)]|",
                options: NSLayoutFormatOptions(rawValue: 0), metrics: metrics, views: views)
            tabsScrollView.addConstraints(vConstraints)

            // A left constraint in installed to previous tab if any, otherwise it installed against the scroll view
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

    private func buildTabMenuItem(selectedTitle: NSAttributedString, unselectedTitle: NSAttributedString) -> LGViewPagerTabItem {
        let item = LGViewPagerTabItem(selectedTitle: selectedTitle, unselectedTitle: unselectedTitle,
            indicatorHeight: indicatorHeight)
        item.addTarget(self, action: "tabMenuItemPressed:", forControlEvents: .TouchUpInside)
        item.selected = false
        return item
    }


    // MARK: > Helpers

    private func updateCurrentPageAndNotifyDelegate(notifyDelegate: Bool) {
        let newCurrentPage = min(Int(round(currentPagePosition())), viewControllers.count-1)
        guard newCurrentPage != currentPage else { return }

        // Unselect the old tab
        var currentTab = tabMenuItems[currentPage]
        currentTab.selected = false

        // Notify previous view controller about its lifecycle & notify the delegate if required
        let prevVC = viewControllers[currentPage]
        prevVC.viewWillDisappear(false)
        if let delegate = delegate where notifyDelegate {
            delegate.viewPager(self, didEndDisplayingViewController: prevVC, atIndex: currentPage)
        }
        prevVC.viewDidDisappear(false)

        // Update current page
        currentPage = newCurrentPage

        // Select the current tab
        currentTab = tabMenuItems[currentPage]
        currentTab.selected = true

        // Notify next view controller about its lifecycle & notify the delegate if required
        let nextVC = viewControllers[currentPage]
        nextVC.viewWillAppear(false)
        if let delegate = delegate where notifyDelegate {
            delegate.viewPager(self, willDisplayViewController: nextVC, atIndex: currentPage)
        }
        nextVC.viewDidAppear(false)
    }

    private func currentPagePosition() -> CGFloat {
        return currentPercentagePosition() * CGFloat(pageCount)
    }

    private func currentPercentagePosition() -> CGFloat {
        return pagesScrollView.contentOffset.x / pagesScrollView.contentSize.width
    }

    private func offsetForSelectedTab(tab: LGViewPagerTabItem) -> CGPoint {
        let minX = CGFloat(0)
        let maxX = tabsScrollView.contentSize.width - tabsScrollView.frame.size.width

        // Centers the tab in the tabs scroll view
        let centerTab = tab.frame.origin.x + tab.frame.size.width/2 - tabsScrollView.frame.size.width/2
        let x = min(max(minX, centerTab), maxX)

        return CGPoint(x: x, y: 0)
    }


    // MARK: > Scroll

    private func scrollTabScrollViewToTab(tab: LGViewPagerTabItem) {
        scrollingTabScrollViewAnimately = true

        let offset = offsetForSelectedTab(tab)
        // setContentOffset(:) with animated true eventually calls scrollViewDidEndScrollingAnimation(:)
        tabsScrollView.setContentOffset(offset, animated: true)
    }


    // MARK: > Actions

    private dynamic func tabMenuItemPressed(sender: LGViewPagerTabItem) {
        scrollTabScrollViewToTab(sender)

        guard let idx = tabMenuItems.indexOf(sender) else { return }
        let x = CGFloat(idx) * pagesScrollView.frame.size.width
        let rect = CGRect(x: x, y: 0, width: pagesScrollView.frame.size.width, height: pagesScrollView.frame.size.height)
        pagesScrollView.scrollRectToVisible(rect, animated: true)
    }
}
