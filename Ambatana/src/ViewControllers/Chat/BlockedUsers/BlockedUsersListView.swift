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

    func blockedUsersListView(blockedUsersListView: BlockedUsersListView, showUnblockConfirmationWithTitle title: String, message: String,
        cancelText: String, actionText: String, action: () -> ())

    func blockedUsersListViewDidStartUnblocking(blockedUsersListView: BlockedUsersListView)
    func blockedUsersListView(blockedUsersListView: BlockedUsersListView, didFinishUnblockingWithMessage message: String?)
}

class BlockedUsersListView: ChatGroupedListView<User>, BlockedUsersListViewModelDelegate {

    static let blockedUsersListCellId = "BlockedUserCell"

    // Edit mode toolbar
    var unblockButton: UIBarButtonItem = UIBarButtonItem()


    var viewModel: BlockedUsersListViewModel
    weak var blockedUsersListViewDelegate: BlockedUsersListViewDelegate?


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

//        if firstTime {
//            NSNotificationCenter.defaultCenter().addObserver(self, selector: "refreshBlockedUsersList",
//                name: PushManager.Notification.DidReceiveUserInteraction.rawValue, object: nil)
//            NSNotificationCenter.defaultCenter().addObserver(self, selector: "clearBlockedUsersList:",
//                name: SessionManager.Notification.Logout.rawValue, object: nil)
//
//            viewModel.retrieveFirstPage()
//        }
    }


    // MARK: > Edit

    override func setEditing(editing: Bool, animated: Bool) {
        super.setEditing(editing, animated: animated)
        unblockButton.enabled = tableView.indexPathsForSelectedRows?.count > 0
    }


    // MARK: - UITableViewDelegate & DataSource methods

    override func cellForRowAtIndexPath(indexPath: NSIndexPath) -> UITableViewCell {
        let cell = super.cellForRowAtIndexPath(indexPath)

        guard let user = viewModel.objectAtIndex(indexPath.row) else { return cell }
        guard let userCell = tableView.dequeueReusableCellWithIdentifier(BlockedUsersListView.blockedUsersListCellId,
            forIndexPath: indexPath) as? BlockedUserCell else { return cell }

        userCell.tag = indexPath.hash // used for cell reuse on "setupCellWithChat"
        userCell.setupCellWithUser(user, indexPath: indexPath)
        return userCell
    }

    override func didSelectRowAtIndex(index: Int, editing: Bool) {
        super.didSelectRowAtIndex(index, editing: editing)

        if editing {
            unblockButton.enabled = tableView.indexPathsForSelectedRows?.count > 0
        } else {
            guard let user = viewModel.objectAtIndex(index) else { return }
            blockedUsersListViewDelegate?.blockedUsersListView(self, didSelectBlockedUser: user)
        }
    }

    override func didDeselectRowAtIndex(index: Int, editing: Bool) {
        super.didDeselectRowAtIndex(index, editing: editing)
        if editing {
            unblockButton.enabled = tableView.indexPathsForSelectedRows?.count > 0
        }
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

    func didStartUnblockingUsers(viewModel: BlockedUsersListViewModel) {
//        showLoadingMessageAlert()
    }

    func didFailUnblockingUsers(viewModel: BlockedUsersListViewModel) {
//        dismissLoadingMessageAlert { [weak self] in
//            self?.showAutoFadingOutMessageAlert(LGLocalizedString.unblockUserErrorGeneric)
//        }

        print("🔴🔴🔴🔴  FAIL 🔴🔴🔴🔴")
    }

    func didSucceedUnblockingUsers(viewModel: BlockedUsersListViewModel) {
//        dismissLoadingMessageAlert { [weak self] in
//            self?.showAutoFadingOutMessageAlert(LGLocalizedString.unblockUserSuccessMessage)
//        }

        print("✅✅✅✅ SUCCEED ✅✅✅✅")
    }

    // MARK: - Private Methods

    override func setupUI() {
        super.setupUI()

        // register cell
        let cellNib = UINib(nibName: BlockedUsersListView.blockedUsersListCellId, bundle: nil)
        tableView.registerNib(cellNib, forCellReuseIdentifier: BlockedUsersListView.blockedUsersListCellId)
        tableView.allowsMultipleSelectionDuringEditing = true
        tableView.rowHeight = BlockedUserCell.defaultHeight

        // setup toolbar for edit mode
        let flexibleSpace = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.FlexibleSpace, target: self,
            action: nil)
        unblockButton = UIBarButtonItem(title: LGLocalizedString.chatListUnblock, style: .Plain, target: self,
            action: "unblockUsersPressed")
        unblockButton.enabled = false

        toolbar.setItems([flexibleSpace, unblockButton], animated: false)
    }

    dynamic private func unblockUsersPressed() {
        guard let blockedUsersListViewDelegate = blockedUsersListViewDelegate else { return }
        guard let indexPaths = tableView.indexPathsForSelectedRows else { return }
        let indexes: [Int] = indexPaths.map({ $0.row })
        blockedUsersListViewDelegate.blockedUsersListViewDidStartUnblocking(self)
        viewModel.unblockSelectedUsersAtIndexes(indexes)
    }

    override func resetUI() {
        super.resetUI()
    }

}
