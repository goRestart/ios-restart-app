import LGCoreKit
import RxSwift
import LGComponents

enum NotificationCenterSectionDate: Equatable {
    case today
    case yesterday
    case daysAgo(days: Int)
    case oneWeekAgo
    case weeksAgo(weeks: Int)
    case oneMonthAgo
    case monthsAgo(months: Int)
    
    var title: String {
        switch self {
        case .today:
            return R.Strings.notificationsSectionToday
        case .yesterday:
            return R.Strings.notificationsSectionYesterday
        case .daysAgo(let days):
            return R.Strings.notificationsSectionDaysAgo(days)
        case .oneWeekAgo:
            return R.Strings.notificationSectionOneWeekAgo
        case .weeksAgo(let weeks):
            return R.Strings.notificationsSectionWeeksAgo(weeks)
        case .oneMonthAgo:
            return R.Strings.notificationSectionOneMonthAgo
        case .monthsAgo(let months):
            return R.Strings.notificationsSectionMonthsAgo(months)
        }
    }
}

struct NotificationCenterSection {
    let sectionDate: NotificationCenterSectionDate
    var notifications: [NotificationData]
}


final class NotificationsViewModel: BaseViewModel {

    weak var navigator: NotificationsTabNavigator?

    let viewState = Variable<ViewState>(.loading)

    private var notificationsData: [NotificationData] = []

    private let notificationsRepository: NotificationsRepository
    private let listingRepository: ListingRepository
    private let userRepository: UserRepository
    private let myUserRepository: MyUserRepository
    private let notificationsManager: NotificationsManager
    private let locationManager: LocationManager
    private let tracker: Tracker
    private let featureFlags: FeatureFlaggeable
    private let disposeBag = DisposeBag()
    
    var sections: [NotificationCenterSection] = []
    
    var isNotificationCenterRedesign: Bool {
        return featureFlags.notificationCenterRedesign == .active
    }

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

    var numberOfSections: Int {
        return isNotificationCenterRedesign ? sections.count : 1
    }
    
    func dataCount(atSection section: Int = 0) -> Int {
        if isNotificationCenterRedesign {
            guard section < sections.count else { return 0 }
            return sections[section].notifications.count
        } else {
            return notificationsData.count
        }
    }

    func data(atSection section: Int = 0, atIndex index: Int) -> NotificationData? {
        if isNotificationCenterRedesign {
            guard 0..<dataCount(atSection: section) ~= index else { return nil }
            return sections[safeAt: section]?.notifications[safeAt: index]
        } else {
            guard 0..<dataCount(atSection: section) ~= index else { return nil }
            return notificationsData[safeAt: index]
        }
    }

    func refresh() {
        reloadNotifications()
    }

    func selectedItemAtIndex(_ index: Int) {
        guard let data = data(atIndex: index) else { return }
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
                let remoteNotifications = notifications.compactMap{ strongSelf.buildNotification($0) }
                strongSelf.notificationsData = remoteNotifications
                if strongSelf.isNotificationCenterRedesign {
                    strongSelf.populateNotificationSections()
                }
                if strongSelf.notificationsData.isEmpty {
                    let emptyViewModel = LGEmptyViewModel(icon: R.Asset.IconsButtons.icNotificationsEmpty.image,
                        title:  R.Strings.notificationsEmptyTitle,
                        body: R.Strings.notificationsEmptySubtitle, buttonTitle: R.Strings.tabBarToolTip,
                        action: { [weak self] in
                            let source: PostingSource = .notifications
                            self?.trackStartSelling(source: source)
                            self?.navigator?.openSell(source: source, postCategory: nil)
                        },
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
    
    private func populateNotificationSections() {
        var sections: [NotificationCenterSection] = []
        for notificationData in notificationsData {
            let dateSection = notificationData.date.notificationCenterSectionTitle()
            let found = sections.index(where: { $0.sectionDate == dateSection })
            if let found = found {
                sections[found].notifications.append(notificationData)
            } else {
                let newSection = NotificationCenterSection(sectionDate: dateSection, notifications: [notificationData])
                sections.append(newSection)
            }
        }
        
        self.sections = sections
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


// MARK: - NotificationCenterModularCellDelegate

extension NotificationsViewModel: NotificationCenterModularCellDelegate {
    func triggerModularNotification(deeplink: String,
                                    source: EventParameterNotificationClickArea,
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
    private func trackStartSelling(source: PostingSource) {
        tracker.trackEvent(TrackerEvent.listingSellStart(typePage: source.typePage,
                                                         buttonName: source.buttonName,
                                                         sellButtonPosition: source.sellButtonPosition,
                                                         category: nil))
    }

    func trackVisit() {
        let event = TrackerEvent.notificationCenterStart()
        tracker.trackEvent(event)
    }

    func trackItemPressed(source: EventParameterNotificationClickArea,
                          cardAction: String?,
                          notificationCampaign: String?) {
        let event = TrackerEvent.notificationCenterComplete(source: source,
                                                            cardAction: cardAction,
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


fileprivate extension Date {
    func notificationCenterSectionTitle() -> NotificationCenterSectionDate {
        if isToday {
            return .today
        } else if isYesterday {
            return .yesterday
        }
        
        let calendar = NSCalendar.current
        let startOfNow = calendar.startOfDay(for: Date())
        let startOfTimeStamp = calendar.startOfDay(for: self)
        let days = calendar.dateComponents([.day], from: startOfNow, to: startOfTimeStamp).day
        let weeks = calendar.dateComponents([.weekOfMonth], from: startOfNow, to: startOfTimeStamp).weekOfMonth
        let months = calendar.dateComponents([.month], from: startOfNow, to: startOfTimeStamp).month
        
        switch (days, weeks, months) {
        case (.some(let days), _, _) where abs(days) < DateDescriptor.maximumDaysInAWeek:
            return .daysAgo(days: abs(days))
        case (_, .some(let weeks), _) where abs(weeks) < DateDescriptor.maximumWeeksInAMonth:
            let totalWeeks = abs(weeks)
            if totalWeeks == 1 {
                return .oneWeekAgo
            }
            return .weeksAgo(weeks: abs(totalWeeks))
        case (_, _, .some(let months)):
            let totalMonths = abs(months)
            if totalMonths == 1 {
                return .oneMonthAgo
            }
            return .monthsAgo(months: totalMonths)
        default:
            return .today
        }
    }
}
