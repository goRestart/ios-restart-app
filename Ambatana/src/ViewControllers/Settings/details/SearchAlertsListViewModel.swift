import LGCoreKit
import RxSwift
import LGComponents

enum SearchAlertsState {
    case initial
    case empty
    case error
    case full

    var icon: UIImage? {
        switch self {
        case .empty:
            return #imageLiteral(resourceName: "ic_search_alerts_empty")
        case .error:
            return #imageLiteral(resourceName: "ic_search_alerts_error")
        case .full, .initial:
            return nil
        }
    }

    var text: String? {
        switch self {
        case .empty:
            return R.Strings.searchAlertsPlaceholderEmptyText
        case .error:
            return R.Strings.searchAlertsPlaceholderErrorText
        case .full, .initial:
            return nil
        }
    }

    var buttonTitle: String? {
        switch self {
        case .empty:
            return R.Strings.searchAlertsPlaceholderEmptyButton
        case .error:
            return R.Strings.searchAlertsPlaceholderErrorButton
        case .full, .initial:
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

    var searchAlertsState = Variable<SearchAlertsState>(.initial)
    var searchAlerts = Variable<[SearchAlert]>([])
    
    convenience override init() {
        self.init(searchAlertsRepository: Core.searchAlertsRepository,
                  myUserRepository: Core.myUserRepository,
                  tracker: TrackerProxy.sharedInstance)
    }
    
    init(searchAlertsRepository: SearchAlertsRepository, myUserRepository: MyUserRepository, tracker: Tracker) {
        self.searchAlertsRepository = searchAlertsRepository
        self.myUserRepository = myUserRepository
        self.tracker = tracker
        super.init()
    }
    
    override func didBecomeActive(_ firstTime: Bool) {
        retrieveSearchAlerts()
    }
    
    
    // MARK: - Requests
    
    private func retrieveSearchAlerts() {
        searchAlertsRepository.index(limit: SearchAlertsListViewModel.searchAlertLimit, offset: 0) { [weak self] result in
            if let value = result.value {
                self?.searchAlerts.value = value
                self?.searchAlertsState.value = value.count > 0 ? .full : .empty
            } else if let _ = result.error {
                self?.searchAlertsState.value = .error
            }
        }
    }

    func placeholderButtonTapped() {
        switch searchAlertsState.value {
        case .error:
            retrieveSearchAlerts()
        case .empty:
            navigator?.openSearch()
        case .full, .initial:
            break
        }

    }

    func triggerEnableOrDisable(searchAlertId: String, enable: Bool) {
        if enable {
            enableSearchAlert(withId: searchAlertId)
        } else {
            disableSearchAlert(withId: searchAlertId)
        }
        let trackerEvent = TrackerEvent.searchAlertSwitchChanged(userId: myUserRepository.myUser?.objectId,
                                                                 searchKeyword: queryForSearchAlertWith(alertId: searchAlertId),
                                                                 enabled: EventParameterBoolean(bool: enable),
                                                                 source: .settings)
        tracker.trackEvent(trackerEvent)
    }
    
    private func enableSearchAlert(withId id: String) {
        searchAlertsRepository.enable(searchAlertId: id) { [weak self] result in
            if let _ = result.value {
                self?.updateEnableValueOfSearchAlertWith(alertId: id)
            } else if let error = result.error {
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
                self?.delegate?.vmShowAutoFadingMessage(errorMessage) { [weak self] in
                    self?.retrieveSearchAlerts()
                }
            }
        }
    }
    
    private func disableSearchAlert(withId id: String) {
        searchAlertsRepository.disable(searchAlertId: id) { [weak self] result in
            if let _ = result.value {
                self?.updateEnableValueOfSearchAlertWith(alertId: id)
            } else if let _ = result.error {
                self?.delegate?.vmShowAutoFadingMessage(R.Strings.searchAlertDisableErrorMessage) { [weak self] in
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
                strongSelf.searchAlerts.value.remove(at: index)
                strongSelf.searchAlertsState.value = strongSelf.searchAlerts.value.count > 0 ? .full : .empty
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

    private func updateEnableValueOfSearchAlertWith(alertId: String)  {
        let optionalSearchAlert = searchAlerts.value.filter { $0.objectId == alertId }.first
        guard let searchAlert = optionalSearchAlert as? LGSearchAlert else { return }
        let newAlert = searchAlert.updating(enabled: !searchAlert.enabled)
        let optIndex = searchAlerts.value.index { $0.objectId == newAlert.objectId }
        if let index = optIndex {
            searchAlerts.value[index] = newAlert
        }
    }
}

