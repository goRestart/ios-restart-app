import LGCoreKit
import RxSwift
import LGComponents

class NotificationsViewModel: BaseViewModel {

    weak var navigator: NotificationsTabNavigator?

    let viewState = Variable<ViewState>(.loading)

    private var notificationsData: [NotificationData] = []

    private let notificationsRepository: NotificationsRepository
    private let listingRepository: ListingRepository
    private let userRepository: UserRepository
    fileprivate let myUserRepository: MyUserRepository
    private let notificationsManager: NotificationsManager
    fileprivate let locationManager: LocationManager
    fileprivate let tracker: Tracker
    fileprivate let featureFlags: FeatureFlaggeable
    private let disposeBag = DisposeBag()

    convenience override init() {
        self.init(notificationsRepository: Core.notificationsRepository,
                  listingRepository: Core.listingRepository,
                  userRepository: Core.userRepository,
                  myUserRepository: Core.myUserRepository,
                  notificationsManager: LGNotificationsManager.sharedInstance,
                  locationManager: Core.locationManager,
                  tracker: TrackerProxy.sharedInstance, featureFlags: FeatureFlags.sharedInstance)
    }

    init(notificationsRepository: NotificationsRepository, listingRepository: ListingRepository,
         userRepository: UserRepository, myUserRepository: MyUserRepository,
         notificationsManager: NotificationsManager, locationManager: LocationManager,
         tracker: Tracker, featureFlags: FeatureFlaggeable) {
        self.notificationsRepository = notificationsRepository
        self.listingRepository = listingRepository
        self.myUserRepository = myUserRepository
        self.userRepository = userRepository
        self.notificationsManager = notificationsManager
        self.locationManager = locationManager
        self.tracker = tracker
        self.featureFlags = featureFlags
        super.init()
    }

    override func didBecomeActive(_ firstTime: Bool) {
        super.didBecomeActive(firstTime)

        if firstTime {
            setupRx()
        }
        trackVisit()
        reloadNotifications()
    }

    // MARK: - Public

    var dataCount: Int {
        return notificationsData.count
    }

    func dataAtIndex(_ index: Int) -> NotificationData? {
        guard 0..<dataCount ~= index else { return nil }
        return notificationsData[index]
    }

    func refresh() {
        reloadNotifications()
    }

    func selectedItemAtIndex(_ index: Int) {
        guard let data = dataAtIndex(index) else { return }
        data.primaryAction?()
    }
    

    // MARK: - Private methods

    private func setupRx() {
        let loggedOut = myUserRepository.rx_myUser.filter { return $0 == nil }
        loggedOut.subscribeNext { [weak self] _ in
            self?.viewState.value = .loading
        }.disposed(by: disposeBag)
    }

    private func reloadNotifications() {
        notificationsRepository.index(allowEditDiscarded: true) { [weak self] result in
            guard let strongSelf = self else { return }
            if let notifications = result.value {
                let remoteNotifications = notifications.flatMap{ strongSelf.buildNotification($0) }
                strongSelf.notificationsData = remoteNotifications
                if strongSelf.notificationsData.isEmpty {
                    let emptyViewModel = LGEmptyViewModel(icon: R.Asset.IconsButtons.icNotificationsEmpty.image,
                        title:  R.Strings.notificationsEmptyTitle,
                        body: R.Strings.notificationsEmptySubtitle, buttonTitle: R.Strings.tabBarToolTip,
                        action: { [weak self] in self?.navigator?.openSell(source: .notifications, postCategory: nil) },
                        secondaryButtonTitle: nil, secondaryAction: nil, emptyReason: .emptyResults, errorCode: nil,
                        errorDescription: nil)

                    strongSelf.viewState.value = .empty(emptyViewModel)
                    if let errorReason = emptyViewModel.emptyReason {
                        strongSelf.trackErrorStateShown(reason: errorReason, errorCode: emptyViewModel.errorCode,
                                                        errorDescription: emptyViewModel.errorDescription)
                    }
                } else {
                    strongSelf.viewState.value = .data
                    strongSelf.afterReloadOk()
                }
            } else if let error = result.error {
                switch error {
                    case .forbidden, .internalError, .notFound, .serverError, .tooManyRequests, .unauthorized, .userNotVerified,
                         .network(errorCode: _, onBackground: false), .wsChatError, .searchAlertError:
                        if let emptyViewModel = LGEmptyViewModel.map(from: error, action: { [weak self] in
                                self?.viewState.value = .loading
                                self?.reloadNotifications()
                            }) {
                            strongSelf.viewState.value = .error(emptyViewModel)
                            if let errorReason = emptyViewModel.emptyReason {
                                strongSelf.trackErrorStateShown(reason: errorReason,
                                                                errorCode: emptyViewModel.errorCode,
                                                                errorDescription: emptyViewModel.errorDescription)
                            }
                    }
                    case .network(errorCode: _, onBackground: true):
                        break
                }
            }
        }
    }

    private func afterReloadOk() {
        notificationsManager.updateNotificationCounters()
    }

    fileprivate func markCompleted(_ data: NotificationData) {
        guard let primaryActionCompleted = data.primaryActionCompleted, !primaryActionCompleted else { return }
        guard data.id != nil else { return }
        guard let index = notificationsData.index(where: { $0.id != nil && $0.id == data.id }) else { return }
        let completedData = NotificationData(id: data.id, modules: data.modules, date: data.date, isRead: data.isRead,
                                             campaignType: data.campaignType, primaryAction: nil, primaryActionCompleted: true)
        notificationsData[index] = completedData
        viewState.value = .data
    }
}


// MARK: - Notifications builder

fileprivate extension NotificationsViewModel {

    func buildNotification(_ notification: NotificationModel) -> NotificationData? {
        return NotificationData(id: notification.objectId,
                                modules: notification.modules,
                                date: notification.createdAt, isRead: notification.isRead,
                                campaignType: notification.campaignType,
                                primaryAction: { [weak self] in
                                    guard let deeplink = notification.modules.callToActions.first?.deeplink else { return }
                                    self?.triggerModularNotificationDeeplink(deeplink: deeplink, source: .main,
                                                                             notificationCampaign: notification.campaignType)
                                })
    }
}


// MARK: - modularNotificationCellDelegate

extension NotificationsViewModel: ModularNotificationCellDelegate {
    func triggerModularNotificationDeeplink(deeplink: String, source: EventParameterNotificationClickArea,
                                            notificationCampaign: String?) {
        guard let deepLinkURL = URL(string: deeplink) else { return }
        guard let deepLink = UriScheme.buildFromUrl(deepLinkURL)?.deepLink else { return }
        trackItemPressed(source: source, cardAction: deepLink.cardActionParameter,
                         notificationCampaign: notificationCampaign)
        navigator?.openNotificationDeepLink(deepLink: deepLink)
    }
}


// MARK: - Trackings

fileprivate extension NotificationsViewModel {
    func trackVisit() {
        let event = TrackerEvent.notificationCenterStart()
        tracker.trackEvent(event)
    }

    func trackItemPressed(source: EventParameterNotificationClickArea, cardAction: String?, notificationCampaign: String?) {
        let event = TrackerEvent.notificationCenterComplete(source: source, cardAction: cardAction,
                                                            notificationCampaign: notificationCampaign)
        tracker.trackEvent(event)
    }
    
    func trackErrorStateShown(reason: EventParameterEmptyReason, errorCode: Int?, errorDescription: String?) {
        let event = TrackerEvent.emptyStateVisit(typePage: .notifications, reason: reason,
                                                 errorCode: errorCode,
                                                 errorDescription: errorDescription)
        tracker.trackEvent(event)
    }
}
