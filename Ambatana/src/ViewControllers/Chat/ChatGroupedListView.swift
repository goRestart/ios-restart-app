//
//  ChatGroupedListView.swift
//  LetGo
//
//  Created by Dídac on 15/02/16.
//  Copyright © 2016 Ambatana. All rights reserved.
//

import LGCoreKit

protocol ChatGroupedListViewDelegate: class {
    func chatGroupedListViewShouldUpdateNavigationBarButtons()
    func chatGroupedListViewShouldUpdateInfoIndicators()
}

class ChatGroupedListView<T>: BaseView, ChatGroupedListViewModelDelegate, ScrollableToTop, UITableViewDataSource,
                              UITableViewDelegate {

    // Constants
    private let tabBarBottomInset: CGFloat = 44

    // UI
    @IBOutlet weak private var contentView: UIView!
    @IBOutlet weak var tableView: UITableView!
    var refreshControl: UIRefreshControl!
    @IBOutlet weak var toolbar: UIToolbar!

    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!

    @IBOutlet weak var emptyView: LGEmptyView!

    // > Insets
    @IBOutlet weak var tableViewBottomInset: NSLayoutConstraint!
    @IBOutlet weak var activityIndicatorBottomInset: NSLayoutConstraint!
    @IBOutlet weak var emptyViewBottomInset: NSLayoutConstraint!

    var bottomInset: CGFloat {
        didSet {
            tableViewBottomInset.constant = bottomInset
            activityIndicatorBottomInset.constant = bottomInset/2
            emptyViewBottomInset.constant = bottomInset
            updateConstraints()
        }
    }

    // Data
    private var viewModel: ChatGroupedListViewModel<T>
    weak var chatGroupedListViewDelegate: ChatGroupedListViewDelegate?


    // MARK: - Lifecycle

    convenience init(viewModel: ChatGroupedListViewModel<T>) {
        self.init(viewModel: viewModel, frame: CGRectZero)
    }

    init(viewModel: ChatGroupedListViewModel<T>, frame: CGRect) {
        self.viewModel = viewModel
        self.bottomInset = tabBarBottomInset
        super.init(viewModel: viewModel, frame: frame)

        viewModel.chatGroupedDelegate = self
        setupUI()
        resetUI()
    }

    init?(viewModel: ChatGroupedListViewModel<T>, coder aDecoder: NSCoder) {
        self.viewModel = viewModel
        self.bottomInset = tabBarBottomInset
        super.init(viewModel: viewModel, coder: aDecoder)

        viewModel.chatGroupedDelegate = self
        setupUI()
        resetUI()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    deinit {
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }

    internal override func didBecomeActive(firstTime: Bool) {
        super.didBecomeActive(firstTime)

        if firstTime {
            NSNotificationCenter.defaultCenter().addObserver(self, selector: "clear",
                name: SessionManager.Notification.Logout.rawValue, object: nil)
            
            viewModel.retrieveFirstPage()
        }
    }


    // MARK: - Public Methods

    dynamic func refresh() {
        viewModel.reloadCurrentPagesWithCompletion(nil)
    }

    dynamic func clear() {
        viewModel.clear()
        tableView.reloadData()
    }

    func setEditing(editing: Bool, animated: Bool) {
        tableView.setEditing(editing, animated: animated)
        setToolbarHidden(!editing, animated: animated)
        bottomInset = editing ? toolbar.frame.height : tabBarBottomInset
    }

    func cellForRowAtIndexPath(indexPath: NSIndexPath) -> UITableViewCell {
        // Implement in subclasses
        return UITableViewCell()
    }

    func didSelectRowAtIndex(index: Int, editing: Bool) {
        // Implement in subclasses
    }

    func didDeselectRowAtIndex(index: Int, editing: Bool) {
        // Implement in subclasses
    }

    
    // MARK: - ChatGroupedListViewModelDelegate

    func chatGroupedListViewModelShouldUpdateStatus() {
        chatGroupedListViewDelegate?.chatGroupedListViewShouldUpdateNavigationBarButtons()
        chatGroupedListViewDelegate?.chatGroupedListViewShouldUpdateInfoIndicators()
        resetUI()
    }

    func chatGroupedListViewModelSetEditing(editing: Bool, animated: Bool) {
        setEditing(editing, animated: animated)
    }

    func chatGroupedListViewModelDidStartRetrievingObjectList() {

    }

    func chatGroupedListViewModelDidFailRetrievingObjectList(page: Int) {
        refreshControl.endRefreshing()
    }

    func chatGroupedListViewModelDidSucceedRetrievingObjectList(page: Int) {
        refreshControl.endRefreshing()
    }


    // MARK: - ScrollableToTop

    func scrollToTop() {
        guard let tableView = tableView else { return }
        tableView.setContentOffset(CGPointZero, animated: true)
    }


    // MARK: - UITableViewDelegate & DataSource methods

    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.objectCount
    }

    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = cellForRowAtIndexPath(indexPath)
        viewModel.setCurrentIndex(indexPath.row)
        return cell
    }

    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        didSelectRowAtIndex(indexPath.row, editing: tableView.editing)
    }

    func tableView(tableView: UITableView, didDeselectRowAtIndexPath indexPath: NSIndexPath) {
        didDeselectRowAtIndex(indexPath.row, editing: tableView.editing)
    }


    // MARK: - Private Methods

    func setupUI() {
        // Load the view, and add it as Subview
        NSBundle.mainBundle().loadNibNamed("ChatGroupedListView", owner: self, options: nil)
        contentView.frame = bounds
        contentView.autoresizingMask = [.FlexibleHeight, .FlexibleWidth]
        contentView.backgroundColor = StyleHelper.backgroundColor
        addSubview(contentView)

        // Empty view
        emptyView.backgroundColor = StyleHelper.backgroundColor
        refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: "refresh", forControlEvents: UIControlEvents.ValueChanged)
        tableView.addSubview(refreshControl)

        // Toolbar
        toolbar.tintColor = StyleHelper.primaryColor
        setToolbarHidden(true, animated: false)
    }

    func resetUI() {
        if viewModel.activityIndicatorAnimating {
            activityIndicator.startAnimating()
        } else {
            activityIndicator.stopAnimating()
        }
        if let emptyViewModel = viewModel.emptyViewModel {
            emptyView.setupWithModel(emptyViewModel)
        }
        emptyView.hidden = viewModel.emptyViewHidden
        tableView.hidden = viewModel.tableViewHidden
        tableView.reloadData()
    }

    private func setToolbarHidden(hidden: Bool, animated: Bool, completion: ((Bool) -> (Void))? = nil) {

        // bail if the current state matches the desired state
        if ((toolbar.frame.origin.y >= CGRectGetMaxY(self.frame)) == hidden) { return }

        // get a frame calculation ready
        let frame = toolbar.frame
        let height = frame.size.height
        let offsetY = (hidden ? height : -height)

        // zero duration means no animation
        let duration : NSTimeInterval = (animated ? NSTimeInterval(UINavigationControllerHideShowBarDuration) : 0.0)

        //  animate the tabBar
        UIView.animateWithDuration(duration, animations: { [weak self] in
            self?.toolbar.frame = CGRectOffset(frame, 0, offsetY)
            self?.layoutIfNeeded()
            }, completion: completion)
    }
}
