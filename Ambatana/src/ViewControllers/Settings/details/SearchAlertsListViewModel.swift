import LGCoreKit
import RxSwift
import LGComponents

enum SearchAlertsState {
    case refreshing
    case empty(buttonAction: (() -> Void))
    case error(buttonAction: (() -> Void))
    case full

    var icon: UIImage? {
        switch self {
        case .empty:
            return R.Asset.IconsButtons.SearchAlerts.icSearchAlertsEmpty.image
        case .error:
            return R.Asset.IconsButtons.SearchAlerts.icSearchAlertsError.image
        case .full, .refreshing:
            return nil
        }
    }

    var text: String? {
        switch self {
        case .empty:
            return R.Strings.searchAlertsPlaceholderEmptyText
        case .error:
            return R.Strings.searchAlertsPlaceholderErrorText
        case .full, .refreshing:
            return nil
        }
    }

    var buttonTitle: String? {
        switch self {
        case .empty:
            return R.Strings.searchAlertsPlaceholderEmptyButton
        case .error:
            return R.Strings.searchAlertsPlaceholderErrorButton
        case .full, .refreshing:
            return nil
        }
    }
    
    var buttonAction: (() -> Void)? {
        switch self {
        case let .error(buttonAction), let .empty(buttonAction):
            return buttonAction
        case .full, .refreshing:
            return nil
        }
    }
}


final class SearchAlertsListViewModel: BaseViewModel {

    private static let searchAlertLimit = 20

    weak var navigator: SearchAlertsListNavigator?
    weak var delegate: BaseViewModelDelegate?
    
    private let searchAlertsRepository: SearchAlertsRepository
    private let myUserRepository: MyUserRepository
    private let tracker: Tracker
    private let featureFlags: FeatureFlaggeable

    var searchAlertsState = Variable<SearchAlertsState>(.refreshing)
    var searchAlerts = Variable<[SearchAlert]>([])
    private var shouldDisableOldestSearchAlertIfMaximumReached: Bool {
        return featureFlags.searchAlertsDisableOldestIfMaximumReached.isActive
    }
    
    
    // MARK: - Lifecycle
    
    convenience override init() {
        self.init(searchAlertsRepository: Core.searchAlertsRepository,
                  myUserRepository: Core.myUserRepository,
                  tracker: TrackerProxy.sharedInstance,
                  featureFlags: FeatureFlags.sharedInstance)
    }
    
    init(searchAlertsRepository: SearchAlertsRepository,
         myUserRepository: MyUserRepository,
         tracker: Tracker,
         featureFlags: FeatureFlaggeable) {
        self.searchAlertsRepository = searchAlertsRepository
        self.myUserRepository = myUserRepository
        self.tracker = tracker
        self.featureFlags = featureFlags
        super.init()
    }
    
    override func didBecomeActive(_ firstTime: Bool) {
        retrieveSearchAlerts()
    }
    
    
    // MARK: - Requests
    
    private func retrieveSearchAlerts() {
        searchAlertsState.value = .refreshing
        searchAlertsRepository.index(limit: SearchAlertsListViewModel.searchAlertLimit, offset: 0) { [weak self] result in
            if let value = result.value {
                self?.searchAlerts.value = value
                self?.updateSearchAlertsStateAsEmptyOrFull()
            } else if let _ = result.error {
                self?.searchAlertsState.value = .error(buttonAction: { [weak self] in
                    self?.retrieveSearchAlerts()
                })
            }
        }
    }

    func triggerEnableOrDisable(searchAlertId: String, enable: Bool) {
        if enable {
            enableSearchAlert(withId: searchAlertId, mutatedSearchAlerts: nil, comesAfterDisablingOldestOne: false)
        } else {
            disableSearchAlert(withId: searchAlertId)
        }
        let trackerEvent = TrackerEvent.searchAlertSwitchChanged(userId: myUserRepository.myUser?.objectId,
                                                                 searchKeyword: queryForSearchAlertWith(alertId: searchAlertId),
                                                                 enabled: EventParameterBoolean(bool: enable),
                                                                 source: .settings)
        tracker.trackEvent(trackerEvent)
    }
    
    private func enableSearchAlert(withId id: String,
                                   mutatedSearchAlerts: [SearchAlert]?,
                                   comesAfterDisablingOldestOne: Bool) {
        searchAlertsRepository.enable(searchAlertId: id) { [weak self] result in
            guard let strongSelf = self else { return }
            if let _ = result.value {
                var newSearchAlerts: [SearchAlert]
                if let mutatedBulkSearchAlerts = mutatedSearchAlerts {
                    newSearchAlerts = mutatedBulkSearchAlerts
                } else {
                    newSearchAlerts = strongSelf.searchAlerts.value
                }
                if let newSearchAlerts = strongSelf.updateEnableValueOfSearchAlertWith(alertId: id,
                                                                                       fromSearchAlerts: newSearchAlerts) {
                    strongSelf.searchAlerts.value = newSearchAlerts
                    if comesAfterDisablingOldestOne {
                        strongSelf.delegate?.vmShowAutoFadingMessage(R.Strings.searchAlertsDisabledOldestMessage,
                                                                     completion: nil)
                    }
                }
            } else if let error = result.error {
                if error.isSearchAlertLimitReachedError &&
                    strongSelf.shouldDisableOldestSearchAlertIfMaximumReached &&
                    !comesAfterDisablingOldestOne {
                    strongSelf.disableOldestSearchAlert { [weak self] mutatedSearchAlerts in
                        self?.enableSearchAlert(withId: id,
                                                mutatedSearchAlerts: mutatedSearchAlerts,
                                                comesAfterDisablingOldestOne: true)
                    }
                } else {
                    strongSelf.reSyncSearchAlertsAfterShowingErrorMessage(error: error)
                }
            }
        }
    }
    
    private func reSyncSearchAlertsAfterShowingErrorMessage(error: RepositoryError) {
        var errorMessage: String
        switch error {
        case .searchAlertError(let searchAlertError):
            switch searchAlertError {
            case .alreadyExists, .apiError:
                errorMessage = R.Strings.searchAlertEnableErrorMessage
            case .limitReached:
                errorMessage = R.Strings.searchAlertErrorTooManyText
            }
        case .tooManyRequests, .network, .forbidden, .internalError, .notFound, .unauthorized, .userNotVerified,
             .serverError, .wsChatError:
            errorMessage = R.Strings.searchAlertEnableErrorMessage
        }
        delegate?.vmShowAutoFadingMessage(errorMessage) { [weak self] in
            self?.retrieveSearchAlerts()
        }
    }
    
    private func disableOldestSearchAlert(completion: (([SearchAlert]) -> Void)?) {
        guard let firstSearchAlert = searchAlerts.value.first else { return }
        let oldestEnabledSearchAlert = searchAlerts.value
            .filter { $0.enabled }
            .reduce(firstSearchAlert, { $0.createdAt < $1.createdAt ? $0 : $1 })
        if let searchAlertId = oldestEnabledSearchAlert.objectId {
            disableSearchAlert(withId: searchAlertId, completion: completion)
        }
    }
    
    private func disableSearchAlert(withId id: String, completion: (([SearchAlert]) -> Void)? = nil) {
        searchAlertsRepository.disable(searchAlertId: id) { [weak self] result in
            guard let strongSelf = self else { return }
            if let _ = result.value {
                if let mutatedSearchAlerts =
                    strongSelf.updateEnableValueOfSearchAlertWith(alertId: id,
                                                                  fromSearchAlerts: strongSelf.searchAlerts.value) {
                    if let completion = completion {
                        completion(mutatedSearchAlerts)
                    } else {
                        strongSelf.searchAlerts.value = mutatedSearchAlerts
                    }
                }
            } else if let _ = result.error {
                strongSelf.delegate?.vmShowAutoFadingMessage(R.Strings.searchAlertDisableErrorMessage) { [weak self] in
                    self?.retrieveSearchAlerts()
                }
            }
        }
    }
    
    func deleteSearchAlertAtIndex(_ index: Int) {
        guard index <= searchAlerts.value.count-1 else { return }
        guard let searchAlertId = searchAlerts.value[index].objectId else { return }
        searchAlertsRepository.delete(searchAlertId: searchAlertId) { [weak self] result in
            guard let strongSelf = self else { return }
            if let _ = result.value {
                guard index < strongSelf.searchAlerts.value.count else { return }
                strongSelf.searchAlerts.value.remove(at: index)
                strongSelf.updateSearchAlertsStateAsEmptyOrFull()
            } else if let _ = result.error {
                strongSelf.delegate?.vmShowAutoFadingMessage(R.Strings.searchAlertDeleteErrorMessage,
                                                             completion: nil)
            }
        }
    }

    private func queryForSearchAlertWith(alertId: String) -> String? {
        let searchAlert = searchAlerts.value.filter { $0.objectId == alertId }.first
        return searchAlert?.query
    }

    private func updateEnableValueOfSearchAlertWith(alertId: String,
                                                    fromSearchAlerts searchAlerts: [SearchAlert]) -> [SearchAlert]? {
        guard let searchAlert = searchAlerts.filter({ $0.objectId == alertId }).first as? LGSearchAlert else { return nil }
        let newAlert = searchAlert.updating(enabled: !searchAlert.enabled)
        let optIndex = searchAlerts.index { $0.objectId == newAlert.objectId }
        if let index = optIndex {
            var mutatedSearchAlerts = searchAlerts
            mutatedSearchAlerts[index] = newAlert
            return mutatedSearchAlerts
        } else {
            return nil
        }
    }
    
    
    // MARK: - SearchAlertsState
    
    private func updateSearchAlertsStateAsEmptyOrFull() {
        searchAlertsState.value = searchAlerts.value.count > 0 ? .full : .empty(buttonAction: { [weak self] in
            self?.navigator?.openSearch()
        })
    }
}

extension RepositoryError {
    var isSearchAlertLimitReachedError: Bool {
        switch self {
        case .searchAlertError(let searchAlertError):
            switch searchAlertError {
            case .limitReached:
                return true
            default:
                return false
            }
        default:
            return false
        }
    }
}
