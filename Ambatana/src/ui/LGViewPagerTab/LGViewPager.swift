//
//  LGViewPagerController.swift
//  LetGo
//
//  Created by Albert Hernández López on 27/01/16.
//  Copyright © 2016 Ambatana. All rights reserved.
//

import UIKit


protocol LGViewPagerDelegate: class {
    func viewPager(viewPager: LGViewPager, willDisplayView view: UIView, atIndex index: Int)
    func viewPager(viewPager: LGViewPager, didEndDisplayingView view: UIView, atIndex index: Int)
}


protocol LGViewPagerScrollDelegate: class {
    func viewPager(viewPager: LGViewPager, didScrollToPagePosition pagePosition: CGFloat)
}

protocol LGViewPagerDataSource: class {
    func viewPagerNumberOfTabs(viewPager: LGViewPager) -> Int
    func viewPager(viewPager: LGViewPager, viewForTabAtIndex index: Int) -> UIView
    func viewPager(viewPager: LGViewPager, showInfoBadgeAtIndex index: Int) -> Bool
    func viewPager(viewPager: LGViewPager, titleForSelectedTabAtIndex index: Int) -> NSAttributedString
    func viewPager(viewPager: LGViewPager, titleForUnselectedTabAtIndex index: Int) -> NSAttributedString
    func viewPager(viewPager: LGViewPager, accessibilityIdentifierAtIndex index: Int) -> AccessibilityId?
}

struct LGViewPagerConfig {
    let tabPosition: LGViewPagerTabPosition
    let tabLayout: LGViewPagerTabLayout
    let tabHeight: CGFloat

    static func defaultConfig() -> LGViewPagerConfig {
        return LGViewPagerConfig(tabPosition: .Top, tabLayout: .Dynamic, tabHeight: 44)
    }
}

enum LGViewPagerTabPosition {
    case Top, Bottom, Hidden
}

enum LGViewPagerTabLayout {
    case Dynamic, Fixed
}


class LGViewPager: UIView, UIScrollViewDelegate {

    // Constants
    private static let defaultIndicatorSelectedColor = UIColor.redColor()
    private static let defaultInfoBadgeColor = UIColor.redColor()

    // UI
    private let tabsScrollView = UIScrollView()
    private let indicatorContainer = UIView()
    private let indicator = UIView()
    private let pagesScrollView = UIScrollView()
    private var pageWidthConstraints = [NSLayoutConstraint]()
    private var pageHeightConstraints = [NSLayoutConstraint]()
    private let config: LGViewPagerConfig

    private var tabMenuItems = [LGViewPagerTabItem]()
    private var pageViews = [UIView]()

    private var lines = [CALayer]()

    var indicatorSelectedColor: UIColor = LGViewPager.defaultIndicatorSelectedColor {
        didSet {
            tabMenuItems.forEach { $0.indicatorSelectedColor = indicatorSelectedColor }
        }
    }
    var infoBadgeColor: UIColor = LGViewPager.defaultInfoBadgeColor {
        didSet {
            tabMenuItems.forEach { $0.infoBadgeColor = infoBadgeColor }
        }
    }
    var tabsBackgroundColor: UIColor? {
        set {
            tabsScrollView.backgroundColor = newValue
        }
        get {
            return tabsScrollView.backgroundColor
        }
    }
    var tabsHidden: Bool {
        set {
            tabMenuItems.forEach{ item in item.hidden = newValue }
        }
        get {
            return tabMenuItems.reduce(false, combine: { $0 || $1.hidden })
        }
    }
    var tabsSeparatorColor: UIColor = UIColor.grayColor()

    // Delegate & data source
    weak var delegate: LGViewPagerDelegate?
    weak var dataSource: LGViewPagerDataSource?
    weak var scrollDelegate: LGViewPagerScrollDelegate?

    // Data
    private let indicatorHeight: CGFloat = 3

    private(set) var currentPage: Int = 0

    var pageCount: Int {
        return pageViews.count
    }

    private var scrollingTabScrollViewAnimately = false
    private var tabsScrollContentSizeSmallThanSize = false
    var scrollEnabled = true {
        didSet {
            tabsScrollView.scrollEnabled = scrollEnabled
            pagesScrollView.scrollEnabled = scrollEnabled
            for (index, tabMenuItem) in tabMenuItems.enumerate() {
                guard index != currentPage else { continue }
                tabMenuItem.enabled = scrollEnabled
            }
        }
    }

    // MARK: - Lifecycle

    convenience override init(frame: CGRect) {
        self.init(config: LGViewPagerConfig.defaultConfig(), frame: frame)
    }

    init(config: LGViewPagerConfig, frame: CGRect) {
        self.config = config
        super.init(frame: frame)
        setupUI()
        setupConstraints()
    }

    required init?(coder aDecoder: NSCoder) {
        self.config = LGViewPagerConfig.defaultConfig()
        super.init(coder: aDecoder)
        setupUI()
        setupConstraints()
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        lines.forEach { $0.removeFromSuperlayer() }
        lines = []
        lines.append(indicatorContainer.addBottomBorderWithWidth(1, color: tabsSeparatorColor))

        var tabMenuItemsWidth: CGFloat = 0
        tabMenuItems.forEach {
            tabMenuItemsWidth += $0.width
        }
        tabsScrollContentSizeSmallThanSize = tabMenuItemsWidth < tabsScrollView.width
    }

    
    // MARK: - Public methods

    func reloadData() {
        reloadPages()
        reloadTabs()

        setNeedsLayout()
        layoutIfNeeded()
    }

    func reloadInfoIndicatorState() {
        guard let dataSource = dataSource else { return }

        for (index, tabMenuItem) in tabMenuItems.enumerate() {
            tabMenuItem.showInfoBadge = dataSource.viewPager(self, showInfoBadgeAtIndex: index)
        }
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

    func selectTabAtIndex(index: Int) {
        selectTabAtIndex(index, animated: false)
    }

    func selectTabAtIndex(index: Int, animated: Bool) {
        guard 0..<tabMenuItems.count ~= index else { return }
        changeSelectedTab(tabMenuItems[index], animated: animated)
    }
    

    // MARK: - UIScrollViewDelegate

    func scrollViewDidScroll(scrollView: UIScrollView) {
        switch scrollView {
        case pagesScrollView:
            let pagePosition = currentPagePosition()
            scrollDelegate?.viewPager(self, didScrollToPagePosition: pagePosition)

            // If tabs scroll view is animating do not move it
            guard !scrollingTabScrollViewAnimately else { return }
            guard !tabsScrollContentSizeSmallThanSize else { return }

            let remaining = pagePosition - CGFloat(Int(pagePosition))
            guard remaining != 0 else { return }

            let toIndex: Int
            if pagePosition > CGFloat(currentPage) {
                toIndex = min(currentPage + 1, pageCount - 1)
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
                updateCurrentPageAndNotifyDelegate(true)
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
        pagesScrollView.backgroundColor = UIColor.clearColor()
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
        metrics["tabsH"] = config.tabHeight

        let vConstraintsFormat, vIndicatorConstraintsFormat: String
        switch config.tabPosition {
        case .Top:
            vConstraintsFormat = "V:|-0-[tabs(tabsH)]-0-[pages]-0-|"
            vIndicatorConstraintsFormat = "V:[indicator(indicatorH)]-0-[pages]"
        case .Bottom:
            vConstraintsFormat = "V:|-0-[pages]-0-[tabs(tabsH)]-0-|"
            vIndicatorConstraintsFormat = "V:[indicator(indicatorH)]-0-|"
        case .Hidden:
            vConstraintsFormat = "V:|-0-[tabs(0)]-0-[pages]-0-|"
            vIndicatorConstraintsFormat = "V:[indicator(0)]-0-[pages]"
        }
        let vConstraints = NSLayoutConstraint.constraintsWithVisualFormat(vConstraintsFormat,
            options: NSLayoutFormatOptions(rawValue: 0), metrics: metrics, views: views)
        addConstraints(vConstraints)

        let vIndicatorConstraints = NSLayoutConstraint.constraintsWithVisualFormat(vIndicatorConstraintsFormat,
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

        pageViews.forEach { $0.removeFromSuperview() }
        pageViews = []

        let numberOfTabs = dataSource.viewPagerNumberOfTabs(self)
        var previousPage: UIView? = nil
        for index in 0..<numberOfTabs {
            let page = dataSource.viewPager(self, viewForTabAtIndex: index)
            pageViews.append(page)
            if index == 0 {
                delegate?.viewPager(self, willDisplayView: page, atIndex: 0)
            }

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
            tab.showInfoBadge = dataSource.viewPager(self, showInfoBadgeAtIndex: index)
            tab.accessibilityId = dataSource.viewPager(self, accessibilityIdentifierAtIndex: index)
            tabMenuItems.append(tab)
            if index == 0 {
                tab.selected = true
            }

            tab.translatesAutoresizingMaskIntoConstraints = false
            tabsScrollView.addSubview(tab)

            var metrics = [String: AnyObject]()
            metrics["tabHeight"] = config.tabHeight

            var views = [String: AnyObject]()
            views["tab"] = tab

            let vConstraints = NSLayoutConstraint.constraintsWithVisualFormat("V:|[tab(tabHeight)]|",
                options: NSLayoutFormatOptions(rawValue: 0), metrics: metrics, views: views)
            tabsScrollView.addConstraints(vConstraints)

            // A left constraint in installed to previous tab if any, otherwise it installed against the scroll view
            if let previousTab = previousTab {
                tabsScrollView.addConstraint(NSLayoutConstraint(item: tab, attribute: .Left, relatedBy: .Equal,
                    toItem: previousTab, attribute: .Right, multiplier: 1, constant: 0))
            } else {
                tabsScrollView.addConstraint(NSLayoutConstraint(item: tab, attribute: .Left, relatedBy: .Equal,
                    toItem: tabsScrollView, attribute: .Left, multiplier: 1, constant: 0))
            }

            if config.tabLayout == .Fixed {
                // If fixed each tab must have the width of the container/num-of-tabs
                tabsScrollView.addConstraint(NSLayoutConstraint(item: tab, attribute: .Width, relatedBy: .Equal,
                    toItem: tabsScrollView, attribute: .Width, multiplier: 1.0/CGFloat(numberOfTabs), constant: 0))
            }

            previousTab = tab
        }
        if let lastTab = previousTab {
            let rightConstraint = NSLayoutConstraint(item: lastTab, attribute: .Right, relatedBy: .Equal,
                toItem: tabsScrollView, attribute: .Right, multiplier: 1, constant: 0)
            tabsScrollView.addConstraint(rightConstraint)
        }
    }

    private func buildTabMenuItem(selectedTitle: NSAttributedString, unselectedTitle: NSAttributedString) -> LGViewPagerTabItem {
        let item = LGViewPagerTabItem(indicatorHeight: indicatorHeight)
        item.selectedTitle = selectedTitle
        item.unselectedTitle = unselectedTitle
        item.indicatorSelectedColor = indicatorSelectedColor
        item.infoBadgeColor = infoBadgeColor
        item.selected = false
        item.showInfoBadge = false
        item.addTarget(self, action: #selector(LGViewPager.tabMenuItemPressed(_:)), forControlEvents: .TouchUpInside)
        return item
    }


    // MARK: > Helpers

    private func updateCurrentPageAndNotifyDelegate(notifyDelegate: Bool) {
        let newCurrentPage = min(Int(round(currentPagePosition())), pageCount - 1)
        guard newCurrentPage != currentPage else {
            if var nextViewPagerPage = pageViews[currentPage] as? LGViewPagerPage {
                nextViewPagerPage.visible = true
            }
            return
        }

        // Unselect the old tab
        var currentTab = tabMenuItems[currentPage]
        currentTab.selected = false

        let prevPage = pageViews[currentPage]
        if let delegate = delegate where notifyDelegate {
            delegate.viewPager(self, didEndDisplayingView: prevPage, atIndex: currentPage)
        }
        if var prevViewPagerPage = prevPage as? LGViewPagerPage {
            prevViewPagerPage.visible = false
        }

        // Update current page
        currentPage = newCurrentPage

        // Select the current tab
        currentTab = tabMenuItems[currentPage]
        currentTab.selected = true

        let nextPage = pageViews[currentPage]
        if let delegate = delegate where notifyDelegate {
            delegate.viewPager(self, willDisplayView: nextPage, atIndex: currentPage)
        }
        if var nextViewPagerPage = nextPage as? LGViewPagerPage {
            nextViewPagerPage.visible = true
        }
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

    private func scrollTabScrollViewToTab(tab: LGViewPagerTabItem, animated: Bool) {
        guard !tabsScrollContentSizeSmallThanSize else { return }

        scrollingTabScrollViewAnimately = true

        let offset = offsetForSelectedTab(tab)
        // setContentOffset(:) with animated true eventually calls scrollViewDidEndScrollingAnimation(:)
        tabsScrollView.setContentOffset(offset, animated: animated)
    }


    // MARK: > Actions

    private dynamic func tabMenuItemPressed(sender: LGViewPagerTabItem) {
        changeSelectedTab(sender, animated: true)
    }
    
    private func changeSelectedTab(sender: LGViewPagerTabItem, animated: Bool) {
        scrollTabScrollViewToTab(sender, animated: animated)
        guard let idx = tabMenuItems.indexOf(sender) else { return }
        let x = CGFloat(idx) * pagesScrollView.frame.size.width
        let rect = CGRect(x: x, y: 0, width: pagesScrollView.frame.size.width, height: pagesScrollView.frame.size.height)
        pagesScrollView.scrollRectToVisible(rect, animated: animated)
        if !animated {
            updateCurrentPageAndNotifyDelegate(false)
        }
    }
}
