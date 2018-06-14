import LGCoreKit
import LGComponents

protocol BlockedUsersListViewDelegate: class {
    func didSelectBlockedUser(_ user: User)
    func didStartUnblocking()
    func didFinishUnblockingWithMessage(_ message: String?)
}

class BlockedUsersListView: ChatGroupedListView, BlockedUsersListViewModelDelegate {

    var viewModel: BlockedUsersListViewModel
    weak var blockedUsersListViewDelegate: BlockedUsersListViewDelegate?


    // MARK: - Lifecycle

    convenience init(viewModel: BlockedUsersListViewModel) {
        self.init(viewModel: viewModel, sessionManager: Core.sessionManager, frame: CGRect.zero)
    }

    init(viewModel: BlockedUsersListViewModel, sessionManager: SessionManager, frame: CGRect) {
        self.viewModel = viewModel
        super.init(viewModel: viewModel, sessionManager: sessionManager, frame: frame)

        viewModel.delegate = self
    }

    init?(viewModel: BlockedUsersListViewModel, sessionManager: SessionManager, coder aDecoder: NSCoder) {
        self.viewModel = viewModel
        super.init(viewModel: viewModel, sessionManager: sessionManager, coder: aDecoder)

        viewModel.delegate = self
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func setupUI() {
        super.setupUI()
        tableView.register(BlockedUserCell.self, forCellReuseIdentifier: BlockedUserCell.reusableID)
        tableView.allowsMultipleSelectionDuringEditing = true
        tableView.rowHeight = BlockedUserCell.defaultHeight

        footerButton.setTitle(R.Strings.chatListUnblock, for: .normal)
        footerButton.addTarget(self, action: #selector(BlockedUsersListView.unblockUsersPressed),
                               for: .touchUpInside)
    }


    // MARK: - UITableViewDelegate & DataSource methods

    override func cellForRowAtIndexPath(_ indexPath: IndexPath) -> UITableViewCell {
        let cell = super.cellForRowAtIndexPath(indexPath)

        guard let user = viewModel.objectAtIndex(indexPath.row) else { return cell }
        guard let userCell = tableView.dequeueReusableCell(withIdentifier: BlockedUserCell.reusableID,
            for: indexPath) as? BlockedUserCell else { return cell }

        userCell.tag = (indexPath as NSIndexPath).hash // used for cell reuse on "setupCellWithChat"
        userCell.setupCellWithUser(user, indexPath: indexPath)
        return userCell
    }

    override func didSelectRowAtIndex(_ index: Int, editing: Bool) {
        super.didSelectRowAtIndex(index, editing: editing)

        guard !editing else { return }
        guard let user = viewModel.objectAtIndex(index) else { return }

        blockedUsersListViewDelegate?.didSelectBlockedUser(user)
    }

    
    // MARK: - BlockedUsersListViewModelDelegate

    func didStartUnblockingUsers(_ viewModel: BlockedUsersListViewModel) {
        blockedUsersListViewDelegate?.didStartUnblocking()
    }

    func didFailUnblockingUsers(_ viewModel: BlockedUsersListViewModel) {
        blockedUsersListViewDelegate?.didFinishUnblockingWithMessage(R.Strings.unblockUserErrorGeneric)
    }

    func didSucceedUnblockingUsers(_ viewModel: BlockedUsersListViewModel) {
        blockedUsersListViewDelegate?.didFinishUnblockingWithMessage(nil)
        viewModel.refresh(completion: nil)
        setEditing(false)
    }

    
    // MARK: - Private Methods

    @objc private func unblockUsersPressed() {
        guard let blockedUsersListViewDelegate = blockedUsersListViewDelegate else { return }
        guard let indexPaths = tableView.indexPathsForSelectedRows else { return }
        let indexes: [Int] = indexPaths.map({ $0.row })
        blockedUsersListViewDelegate.didStartUnblocking()
        viewModel.unblockSelectedUsersAtIndexes(indexes)
    }
}
