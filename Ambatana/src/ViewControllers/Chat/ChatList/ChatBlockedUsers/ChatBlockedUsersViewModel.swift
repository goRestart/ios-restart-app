import LGCoreKit
import Result
import RxSwift
import LGComponents

final class ChatBlockedUsersViewModel: ChatBaseViewModel, Paginable {

    let firstPage: Int = 1
    let resultsPerPage: Int = 50
    var nextPage: Int = 1
    var isLastPage: Bool = false
    var isLoading: Bool = false
    var objectCount: Int {
        return blockedUserList.value.count
    }

    weak var navigator: TabNavigator?
    private let tracker: Tracker

    private let userRepository: UserRepository

    let blockedUserList = Variable<[User]>([])
    let viewStatus = Variable<ViewState>(.loading)
    let rx_isEditing = Variable<Bool>(false)

    let emptyStateVM: LGEmptyViewModel = {
        return LGEmptyViewModel(icon: R.Asset.Errors.errListNoBlockedUsers.image,
                                title: R.Strings.chatListBlockedEmptyTitle,
                                body: R.Strings.chatListBlockedEmptyBody, buttonTitle: nil,
                                action: nil, secondaryButtonTitle: nil, secondaryAction: nil,
                                emptyReason: .emptyResults, errorCode: nil, errorDescription: nil)
    }()

    let errorStateVM: LGEmptyViewModel = {
        return LGEmptyViewModel(icon: R.Asset.Errors.errListNoBlockedUsers.image,
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
        retrieveFirstPage()
    }


    // MARK: Pagination

    func refreshFirstPage(completion: (() -> Void)?) {
        retrieveFirstPage(completion: completion)
    }

    func retrievePage(_ page: Int) {
        retrieve(page: page)
    }

    func retrieve(page: Int, completion: (() -> Void)? = nil) {
        guard canRetrieve else {
            completion?()
            return
        }
        let isFirstPage = (page == 1)
        var hasEmptyData: Bool {
            return isFirstPage && objectCount == 0
        }
        isLoading = true
        let offset = max(0, page - 1) * resultsPerPage

        userRepository.indexBlocked(limit: resultsPerPage, offset: offset) { [weak self] result in
            guard let strongSelf = self else { return }
            strongSelf.isLoading = false
            if let blockedUsers = result.value {
                if isFirstPage {
                    strongSelf.blockedUserList.value = blockedUsers
                } else {
                    strongSelf.blockedUserList.value.append(contentsOf: blockedUsers)
                }
                strongSelf.isLastPage = blockedUsers.count < strongSelf.resultsPerPage
                strongSelf.nextPage = page + 1
                strongSelf.viewStatus.value = strongSelf.objectCount > 0 ? .data : .empty(strongSelf.emptyStateVM)
            } else if let error = result.error {
                if hasEmptyData {
                    strongSelf.viewStatus.value = strongSelf.viewStatusFor(error: error)
                }
            }
            completion?()
        }
    }

    func retrieveFirstPage(completion: (() -> Void)? = nil) {
        retrieve(page: 1, completion: completion)
    }

    func objectAt(index: Int) -> User? {
        guard 0..<objectCount ~= index else { return nil }
        return blockedUserList.value[index]
    }

    func unblockSelectedUserAt(index: Int) {
        guard 0..<objectCount ~= index else { return }
        guard let userId = blockedUserList.value[index].objectId else { return }

        trackUnblockUserWith(userId: userId)
        userRepository.unblockUserWithId(userId) { [weak self] result in
            guard let strongSelf = self else { return }
            if let _ = result.value {
                strongSelf.blockedUserList.value = strongSelf.blockedUserList.value.filter { $0.objectId != userId }
                strongSelf.viewStatus.value = strongSelf.objectCount > 0 ? .data : .empty(strongSelf.emptyStateVM)
            } else if let error = result.error {
                strongSelf.viewStatus.value = strongSelf.viewStatusFor(error: error)
            }
        }
    }

    func selectedBlockedUserAt(index: Int) {
        guard 0..<objectCount ~= index else { return }
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
        switchEditMode(isEditing: false)
        rx_vmPresentActionSheet.onNext(VMActionSheet(actions: objectCount > 0 ? [unblockAction] : []))
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
            self?.retrieveFirstPage()
        }
        return LGEmptyViewModel.map(from: error, action: retryAction)
    }
    
    // MARK: - Tracking Methods

    private func trackUnblockUserWith(userId: String) {
        let unblockUserEvent = TrackerEvent.profileUnblock(.chatList, unblockedUsersIds: [userId])
        TrackerProxy.sharedInstance.trackEvent(unblockUserEvent)
    }
}
