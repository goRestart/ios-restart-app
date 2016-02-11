//
//  BlockedUsersListView.swift
//  LetGo
//
//  Created by Dídac on 10/02/16.
//  Copyright © 2016 Ambatana. All rights reserved.
//

import LGCoreKit

protocol BlockedUsersListViewDelegate: class {

    func blockedUsersListView(blockedUsersListView: BlockedUsersListView, didSelectBlockedUser user: User)

    func blockedUsersListViewShouldUpdateNavigationBarButtons(blockedUsersListView: BlockedUsersListView)

    func blockedUsersListView(blockedUsersListView: BlockedUsersListView, showUnblockConfirmationWithTitle title: String, message: String,
        cancelText: String, actionText: String, action: () -> ())

    func blockedUsersListViewDidStartArchiving(blockedUsersListView: BlockedUsersListView)
    func blockedUsersListView(blockedUsersListView: BlockedUsersListView, didFinishUnblockingWithMessage message: String?)
}

class BlockedUsersListView: BaseView, BlockedUsersListViewModelDelegate, UITableViewDataSource, UITableViewDelegate, ScrollableToTop {

    static let blockedUsersListCellId = "BlockedUserCell"

    @IBOutlet weak var contentView: UIView!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    var refreshControl: UIRefreshControl!

    // Edit mode toolbar
    @IBOutlet weak var toolbar: UIToolbar!
    var unblockButton: UIBarButtonItem = UIBarButtonItem()

    @IBOutlet weak var emptyView: LGEmptyView!

    var viewModel: BlockedUsersListViewModel
    weak var delegate: BlockedUsersListViewDelegate?


    // MARK: - Lifecycle

    convenience init(viewModel: BlockedUsersListViewModel) {
        self.init(viewModel: viewModel, frame: CGRectZero)
    }

    init(viewModel: BlockedUsersListViewModel, frame: CGRect) {
        self.viewModel = viewModel
        super.init(viewModel: viewModel, frame: frame)

        viewModel.delegate = self
        setupUI()
    }

    init?(viewModel: BlockedUsersListViewModel, coder aDecoder: NSCoder) {
        self.viewModel = viewModel
        super.init(viewModel: viewModel, coder: aDecoder)

        viewModel.delegate = self
        setupUI()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    internal override func didBecomeActive(firstTime: Bool) {
        super.didBecomeActive(firstTime)

        if firstTime {
            NSNotificationCenter.defaultCenter().addObserver(self, selector: "refreshBlockedUsersList",
                name: PushManager.Notification.DidReceiveUserInteraction.rawValue, object: nil)
            NSNotificationCenter.defaultCenter().addObserver(self, selector: "clearBlockedUsersList:",
                name: SessionManager.Notification.Logout.rawValue, object: nil)

            viewModel.retrieveFirstPage()
        }
    }


    // MARK: - Public Methods

    func refreshBlockedUsersList() {
        viewModel.reloadCurrentPages()
    }

    /**
     Clears the table view
     */
    func clearBlockedUsersList(notification: NSNotification) {
        viewModel.clearBlockedUsersList()
        tableView.reloadData()
    }

    func setToolbarHidden(hidden: Bool, animated: Bool, completion: ((Bool) -> (Void))? = nil) {

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
    

    // MARK: - BlockedUsersListViewModelDelegate

    func blockedUsersListViewModelShouldUpdateStatus(viewModel: BlockedUsersListViewModel) {
    }

    func blockedUsersListViewModel(viewModel: BlockedUsersListViewModel, setEditing editing: Bool, animated: Bool) {

    }

    func didStartRetrievingBlockedUsersList(viewModel: BlockedUsersListViewModel) {

    }

    func didFailRetrievingBlockedUsersList(viewModel: BlockedUsersListViewModel, page: Int) {

    }

    func didSucceedRetrievingBlockedUsersList(viewModel: BlockedUsersListViewModel, page: Int) {
        tableView.reloadData()
    }


    // MARK: - ScrollableToTop

    func scrollToTop() {
        guard let tableView = tableView else { return }
        tableView.setContentOffset(CGPointZero, animated: true)
    }
    

    // MARK: - UITableView DataSource & Delegate

    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }

    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 5
    }

    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier(BlockedUsersListView.blockedUsersListCellId,
            forIndexPath: indexPath) as! BlockedUserCell

        cell.userNameLabel.text = "User \(indexPath.row)"
//        if let blockedUser = viewModel.blockedUserAtIndex(indexPath.row) {
//            cell.setupCellWithUser(blockedUser, indexPath: indexPath)
//        }

        // Paginable
        viewModel.setCurrentIndex(indexPath.row)

        return cell
    }

    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {

    }


    // MARK: - Private Methods

    private func setupUI() {
        // Load the view, and add it as Subview
        NSBundle.mainBundle().loadNibNamed("BlockedUsersListView", owner: self, options: nil)
        contentView.frame = bounds
        contentView.autoresizingMask = [.FlexibleHeight, .FlexibleWidth]
        addSubview(contentView)

        // register cell
        let cellNib = UINib(nibName: BlockedUsersListView.blockedUsersListCellId, bundle: nil)
        tableView.registerNib(cellNib, forCellReuseIdentifier: BlockedUsersListView.blockedUsersListCellId)
        tableView.allowsMultipleSelectionDuringEditing = false
        tableView.rowHeight = BlockedUserCell.defaultHeight

        // setup toolbar for edit mode
        let flexibleSpace = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.FlexibleSpace, target: self,
            action: nil)
        unblockButton = UIBarButtonItem(title: LGLocalizedString.chatListArchive, style: .Plain, target: self,
            action: "unblockSelectedUsers")
        unblockButton.enabled = false

        toolbar.setItems([flexibleSpace, unblockButton], animated: false)
        toolbar.tintColor = StyleHelper.primaryColor
        setToolbarHidden(true, animated: false)

        // internationalization

        // add a pull to refresh control
        refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: "refreshBlockedUsersList", forControlEvents: UIControlEvents.ValueChanged)
        tableView.addSubview(refreshControl)

        // Error View
    }

    private func resetUI() {
        
    }

}
