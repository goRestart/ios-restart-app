import Amplitude_iOS
import LGCoreKit
import RxSwift
import LGComponents

final class AmplitudeTracker: Tracker {
    
    // Constants
    // > User properties
    private static let userPropIdKey = "user-id"
    private static let userPropEmailKey = "user-email"
    private static let userPropLatitudeKey = "user-lat"
    private static let userPropLongitudeKey = "user-lon"
    private static let userPropCountryCodeKey = "user-country-code"
    private static let userPropReputationBadge = "reputation-badge"
    private static let userPropInstallationIdKey = "installation-id"

    // enabled permissions
    private static let userPropPushEnabled = "push-enabled"
    private static let userPropGpsEnabled = "gps-enabled"

    private static let userPropUserRating = "user-rating"

    // AB Tests
    private static let userPropABTests = "AB-test"
    private static let userPropABTestsCore = "AB-test-core"
    private static let userPropABTestsRealEstate = "AB-test-realEstate"
    private static let userPropABTestsVerticals = "AB-test-verticals"
    private static let userPropABTestsMoney = "AB-test-money"
    private static let userPropABTestsRetention = "AB-test-retention"
    private static let userPropABTestsChat = "AB-test-chat"
    private static let userPropABTestsProducts = "AB-test-products"
    private static let userPropABTestsUsers = "AB-test-users"
    private static let userPropABTestsDiscovery = "AB-test-discovery"

    private static let userPropMktPushNotificationKey = "marketing-push-notification"
    private static let userPropMktPushNotificationValueOn = "on"
    private static let userPropMktPushNotificationValueOff = "off"

    // Login required tracking
    private var loggedIn = false
    private var pendingLoginEvent: TrackerEvent?

    private let disposeBag = DisposeBag()
    
    // MARK: - Tracker
    
    func application(_ application: UIApplication,
                     didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?,
                     featureFlags: FeatureFlaggeable) {
        Amplitude.instance().trackingSessionEvents = false
        Amplitude.instance().initializeApiKey(EnvironmentProxy.sharedInstance.amplitudeAPIKey)
        setupABTestsRx(featureFlags: featureFlags)
    }
    
    func application(_ application: UIApplication, openURL url: URL, sourceApplication: String?, annotation: Any?) {
    }
    
    func applicationDidEnterBackground(_ application: UIApplication) {
    }
    
    func applicationWillEnterForeground(_ application: UIApplication) {
    }
    
    func applicationDidBecomeActive(_ application: UIApplication) {
    }

    func setInstallation(_ installation: Installation?) {
        let identify = AMPIdentify()
        let installationValue = NSString(string: installation?.objectId ?? "")
        identify.set(AmplitudeTracker.userPropInstallationIdKey, value: installationValue)
        Amplitude.instance().identify(identify)
    }

    func setUser(_ user: MyUser?) {
        // https://ambatana.atlassian.net/browse/ABIOS-3984
        loggedIn = user != nil
        guard let loggedUser = user else { return }

        let identify = AMPIdentify()
        Amplitude.instance().setUserId(loggedUser.emailOrId)

        let userIdValue = NSString(string: loggedUser.objectId ?? "")
        identify.set(AmplitudeTracker.userPropIdKey, value: userIdValue)

        let ratingAverageValue = NSNumber(value: loggedUser.ratingAverage ?? 0)
        identify.set(AmplitudeTracker.userPropUserRating, value: ratingAverageValue)
        let reputationBadge = NSString(string: loggedUser.reputationBadge.rawValue)
        identify.set(AmplitudeTracker.userPropReputationBadge, value: reputationBadge)
        Amplitude.instance().identify(identify)

        if let pendingLoginEvent = pendingLoginEvent {
            trackEvent(pendingLoginEvent)
        }
    }
    
    func trackEvent(_ event: TrackerEvent) {
        switch event.name {
        case .loginEmail, .loginFB, .loginGoogle, .signupEmail:
            if loggedIn {
                Amplitude.instance().logEvent(event.actualName, withEventProperties: event.params?.stringKeyParams)
                pendingLoginEvent = nil
            } else {
                pendingLoginEvent = event
            }
        default:
            Amplitude.instance().logEvent(event.actualName, withEventProperties: event.params?.stringKeyParams)
        }
    }

    func setLocation(_ location: LGLocation?, postalAddress: PostalAddress?) {
        guard let location = location else { return }
        let identify = AMPIdentify()
        let latitude = NSNumber(value: location.coordinate.latitude)
        let longitude = NSNumber(value: location.coordinate.longitude)
        identify.set(AmplitudeTracker.userPropLatitudeKey, value: latitude)
        identify.set(AmplitudeTracker.userPropLongitudeKey, value: longitude)
        if let countryCode = postalAddress?.countryCode {
            let countryObject = NSString(string: countryCode)
            identify.set(AmplitudeTracker.userPropCountryCodeKey, value: countryObject)
        }
        Amplitude.instance().identify(identify)
    }

    func setNotificationsPermission(_ enabled: Bool) {
        let identify = AMPIdentify()
        let enabledValue = NSString(string: enabled ? "true" : "false")
        identify.set(AmplitudeTracker.userPropPushEnabled, value: enabledValue)
        Amplitude.instance().identify(identify)
    }

    func setGPSPermission(_ enabled: Bool) {
        let identify = AMPIdentify()
        let enabledValue = NSString(string: enabled ? "true" : "false")
        identify.set(AmplitudeTracker.userPropGpsEnabled, value: enabledValue)
        Amplitude.instance().identify(identify)
    }

    func setMarketingNotifications(_ enabled: Bool) {
        let identify = AMPIdentify()
        let value = enabled ? AmplitudeTracker.userPropMktPushNotificationValueOn :
            AmplitudeTracker.userPropMktPushNotificationValueOff
        let valueNotifications = NSString(string: value)
        identify.set(AmplitudeTracker.userPropMktPushNotificationKey, value: valueNotifications)
        Amplitude.instance().identify(identify)
    }


    // MARK: - Private

    private func setupABTestsRx(featureFlags: FeatureFlaggeable) {
        featureFlags.trackingData.asObservable().bind { trackingData in
            guard let trackingData = trackingData else { return }
            var legacyABTests: [String] = []
            var coreAbtests: [String] = []
            var moneyAbTests: [String] = []
            var verticalsAbTests: [String] = []
            var realEstateAbTests: [String] = []
            var retentionAbTests: [String] = []
            var chatAbTests: [String] = []
            var productsAbTests: [String] = []
            var usersAbTests: [String] = []
            var discoveryAbTests: [String] = []

            trackingData.forEach({ (identifier, abGroupType) in
                switch abGroupType {
                case .legacyABTests:
                    legacyABTests.append(identifier)
                case .core:
                    coreAbtests.append(identifier)
                case .money:
                    moneyAbTests.append(identifier)
                case .realEstate:
                    realEstateAbTests.append(identifier)
                case .verticals:
                    verticalsAbTests.append(identifier)
                case .retention:
                    retentionAbTests.append(identifier)
                case .chat:
                    chatAbTests.append(identifier)
                case .products:
                    productsAbTests.append(identifier)
                case .users:
                    usersAbTests.append(identifier)
                case .discovery:
                    discoveryAbTests.append(identifier)
                }
            })
            let dict: [String: [String]] = [AmplitudeTracker.userPropABTestsCore: coreAbtests,
                                            AmplitudeTracker.userPropABTestsMoney: moneyAbTests,
                                            AmplitudeTracker.userPropABTestsRealEstate: realEstateAbTests,
                                            AmplitudeTracker.userPropABTestsVerticals: verticalsAbTests,
                                            AmplitudeTracker.userPropABTestsRetention: retentionAbTests,
                                            AmplitudeTracker.userPropABTestsChat: chatAbTests,
                                            AmplitudeTracker.userPropABTestsProducts: productsAbTests,
                                            AmplitudeTracker.userPropABTestsUsers: usersAbTests,
                                            AmplitudeTracker.userPropABTests: legacyABTests,
                                            AmplitudeTracker.userPropABTestsDiscovery: discoveryAbTests
                                            ]
            dict.forEach({ (type, variables) in
                let identify = AMPIdentify()
                let trackingDataValue = NSArray(array: variables)
                identify.set(type, value: trackingDataValue)
                Amplitude.instance().identify(identify)
            })
        }.disposed(by: disposeBag)
    }
}
