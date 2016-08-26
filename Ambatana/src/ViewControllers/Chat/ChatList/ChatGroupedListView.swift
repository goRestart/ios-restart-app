//
//  ChatGroupedListView.swift
//  LetGo
//
//  Created by Dídac on 15/02/16.
//  Copyright © 2016 Ambatana. All rights reserved.
//

import LGCoreKit

protocol ChatGroupedListViewDelegate: class {
    func chatGroupedListViewShouldUpdateInfoIndicators()
}

class ChatGroupedListView: BaseView, ChatGroupedListViewModelDelegate, ScrollableToTop, UITableViewDataSource,
                              UITableViewDelegate {

    // Constants
    private let tabBarBottomInset: CGFloat = 49

    // UI
    @IBOutlet weak private var contentView: UIView!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var footerView: UIView!
    @IBOutlet weak var footerViewBottom: NSLayoutConstraint!
    @IBOutlet weak var footerButton: UIButton!

    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!

    @IBOutlet weak var emptyView: LGEmptyView!

    var refreshControl = UIRefreshControl()

    
    // > Insets
    @IBOutlet weak var tableViewBottomInset: NSLayoutConstraint!
    @IBOutlet weak var activityIndicatorBottomInset: NSLayoutConstraint!
    @IBOutlet weak var emptyViewBottomInset: NSLayoutConstraint!

    var bottomInset: CGFloat = 0 {
        didSet {
            tableView.contentInset.bottom = bottomInset
            activityIndicatorBottomInset.constant = bottomInset/2
            emptyViewBottomInset.constant = bottomInset
            updateConstraints()
        }
    }

    // Data
    private var viewModel: ChatGroupedListViewModel
    weak var chatGroupedListViewDelegate: ChatGroupedListViewDelegate?


    // MARK: - Lifecycle

    convenience init<T: BaseViewModel where T: ChatGroupedListViewModel>(viewModel: T) {
        self.init(viewModel: viewModel, frame: CGRectZero)
    }

    init<T: BaseViewModel where T: ChatGroupedListViewModel>(viewModel: T, frame: CGRect) {
        self.viewModel = viewModel
        super.init(viewModel: viewModel, frame: frame)

        viewModel.chatGroupedDelegate = self
        setupUI()
        resetUI()
    }

    init?<T: BaseViewModel where T: ChatGroupedListViewModel>(viewModel: T, coder aDecoder: NSCoder) {
        self.viewModel = viewModel
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
            NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(ChatGroupedListView.clear),
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

    func setEditing(editing: Bool) {
        tableView.setEditing(editing, animated: true)
        setFooterHidden(!editing, animated: true)
    }


    // MARK: - UITableViewDataSource

    func cellForRowAtIndexPath(indexPath: NSIndexPath) -> UITableViewCell {
        // Implement in subclasses
        return UITableViewCell()
    }


    // MARK: - UITableViewDelegate

    func didSelectRowAtIndex(index: Int, editing: Bool) {
        if editing {
            footerButton.enabled = tableView.indexPathsForSelectedRows?.count > 0
        }
    }

    func didDeselectRowAtIndex(index: Int, editing: Bool) {
        if editing {
            footerButton.enabled = tableView.indexPathsForSelectedRows?.count > 0
        }
    }

    
    // MARK: - ChatGroupedListViewModelDelegate

    func chatGroupedListViewModelShouldUpdateStatus() {
        chatGroupedListViewDelegate?.chatGroupedListViewShouldUpdateInfoIndicators()
        resetUI()
    }

    func chatGroupedListViewModelSetEditing(editing: Bool) {
        setEditing(editing)
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
        return cellForRowAtIndexPath(indexPath)
    }

    func tableView(tableView: UITableView, willDisplayCell cell: UITableViewCell, forRowAtIndexPath indexPath: NSIndexPath) {
        dispatch_async(dispatch_get_main_queue()) { [weak self] in
            self?.viewModel.setCurrentIndex(indexPath.row)
        }
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
        contentView.backgroundColor = UIColor.listBackgroundColor
        addSubview(contentView)

        // Empty view
        emptyView.backgroundColor = UIColor.listBackgroundColor
        refreshControl.addTarget(self, action: #selector(ChatGroupedListView.refresh),
                                 forControlEvents: UIControlEvents.ValueChanged)
        tableView.addSubview(refreshControl)

        // Footer
        footerButton.setStyle(.Primary(fontSize: .Medium))
        footerButton.enabled = false
        bottomInset = tabBarBottomInset
        setFooterHidden(true, animated: false)
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

    func setFooterHidden(hidden: Bool, animated: Bool, completion: ((Bool) -> (Void))? = nil) {
        let visibilityOK = ( footerViewBottom.constant < 0 ) == hidden
        guard !visibilityOK else { return }

        if !hidden {
            footerButton.enabled = tableView.indexPathsForSelectedRows?.count > 0
        }
        bottomInset = hidden ? tabBarBottomInset : 0
        footerViewBottom.constant = hidden ? -footerView.frame.height : 0

        let duration : NSTimeInterval = (animated ? NSTimeInterval(UINavigationControllerHideShowBarDuration) : 0.0)
        UIView.animateWithDuration(duration, animations: { [weak self] in
            self?.layoutIfNeeded()
        }, completion: completion)
    }
}

