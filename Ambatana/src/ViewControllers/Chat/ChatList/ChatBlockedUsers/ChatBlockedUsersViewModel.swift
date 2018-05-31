import LGCoreKit
import Result
import RxSwift
import LGComponents

final class ChatBlockedUsersViewModel: BaseViewModel {

    weak var navigator: TabNavigator?
    private let tracker: Tracker

    private let userRepository: UserRepository
    var blockedUsersCount: Int {
        return blockedUserList.value.count
    }
    let blockedUserList = Variable<[User]>([])
    let viewStatus = Variable<ViewState>(.loading)
    let rx_navigationActionSheet = PublishSubject<NavigationActionSheet>()
    let rx_isEditing = Variable<Bool>(false)

    let emptyStateVM: LGEmptyViewModel = {
        return LGEmptyViewModel(icon: UIImage(named: "err_list_no_blocked_users"),
                                title: R.Strings.chatListBlockedEmptyTitle,
                                body: R.Strings.chatListBlockedEmptyBody, buttonTitle: nil,
                                action: nil, secondaryButtonTitle: nil, secondaryAction: nil,
                                emptyReason: .emptyResults, errorCode: nil, errorDescription: nil)
    }()

    let errorStateVM: LGEmptyViewModel = {
        return LGEmptyViewModel(icon: UIImage(named: "err_list_no_blocked_users"),
                                title: R.Strings.chatListBlockedEmptyTitle,
                                body: R.Strings.chatListBlockedEmptyBody, buttonTitle: nil,
                                action: nil, secondaryButtonTitle: nil, secondaryAction: nil,
                                emptyReason: .emptyResults, errorCode: nil, errorDescription: nil)
    }()


    // MARK: - Lifecycle

    convenience init(navigator: TabNavigator) {
        self.init(navigator: navigator, userRepository: Core.userRepository, tracker: TrackerProxy.sharedInstance)
    }

    required init(navigator: TabNavigator, userRepository: UserRepository, tracker: Tracker) {
        self.navigator = navigator
        self.userRepository = userRepository
        self.tracker = tracker
        super.init()
        retrieveBlockedUsers()
    }

    func retrieveBlockedUsers() {
        viewStatus.value = .loading
        userRepository.indexBlocked { [weak self] result in
            guard let strongSelf = self else { return }
            if let blockedUsers = result.value {
                strongSelf.blockedUserList.value = blockedUsers
                strongSelf.viewStatus.value = blockedUsers.count > 0 ? .data : .empty(strongSelf.emptyStateVM)
            } else if let error = result.error {
                strongSelf.viewStatus.value = strongSelf.viewStatusFor(error: error)
            }
        }
    }

    func objectAt(index: Int) -> User? {
        guard 0..<blockedUsersCount ~= index else { return nil }
        return blockedUserList.value[index]
    }

    func unblockSelectedUserAt(index: Int) {
        guard 0..<blockedUsersCount ~= index else { return }
        guard let userId = blockedUserList.value[index].objectId else { return }

        trackUnblockUserWith(userId: userId)
        userRepository.unblockUserWithId(userId) { [weak self] result in
            guard let strongSelf = self else { return }
            if let _ = result.value {
                strongSelf.blockedUserList.value = strongSelf.blockedUserList.value.filter { $0.objectId != userId }
                strongSelf.viewStatus.value = strongSelf.blockedUsersCount > 0 ? .data : .empty(strongSelf.emptyStateVM)
            } else if let error = result.error {
                strongSelf.viewStatus.value = strongSelf.viewStatusFor(error: error)
            }
        }
    }

    func selectedBlockedUserAt(index: Int) {
        guard 0..<blockedUsersCount ~= index else { return }
        let user = blockedUserList.value[index]
        let data = UserDetailData.userAPI(user: user, source: .chat)
        navigator?.openUser(data)
    }

    // MARK: - Actions
    
    func openOptionsActionSheet() {
        var unblockAction: UIAction {
            return UIAction(interface: .text(R.Strings.chatListUnblock),
                            action: { [weak self] in self?.switchEditMode(isEditing: true) })
        }
        rx_navigationActionSheet.onNext((cancelTitle: R.Strings.commonCancel,
                                         actions: blockedUsersCount > 0 ? [unblockAction] : []))
    }
    
    func tableViewRowActions() -> [UITableViewRowAction]? {
        let unblockAction = UITableViewRowAction(style: .normal, title: R.Strings.chatListUnblock) { [weak self] action, indexPath in
            self?.unblockSelectedUserAt(index: indexPath.row)
        }
        return [unblockAction]
    }
    
    func switchEditMode(isEditing: Bool) {
        rx_isEditing.value = isEditing
    }
    
    // MARK: - Private Methods

    private func viewStatusFor(error: RepositoryError) -> ViewState {
        var viewStatusForError: ViewState = .empty(emptyStateVM)
        if let vmForError = emptyViewModelForError(error) {
            viewStatusForError = .error(vmForError)
        }
        return viewStatusForError
    }

    private func emptyViewModelForError(_ error: RepositoryError) -> LGEmptyViewModel? {
        let retryAction: () -> () = { [weak self] in
            self?.retrieveBlockedUsers()
        }
        return LGEmptyViewModel.map(from: error, action: retryAction)
    }
    
    // MARK: - Tracking Methods

    private func trackUnblockUserWith(userId: String) {
        let unblockUserEvent = TrackerEvent.profileUnblock(.chatList, unblockedUsersIds: [userId])
        TrackerProxy.sharedInstance.trackEvent(unblockUserEvent)
    }
}
