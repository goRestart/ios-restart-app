//
//  DI.swift
//  LGCoreKit
//
//  Created by Albert Hernández López on 08/01/16.
//  Copyright © 2016 Ambatana Inc. All rights reserved.
//

import Alamofire
import CoreLocation
import KeychainSwift
import Reachability

final class CoreDI: InternalDI {
    // MARK: - Lifecycle
    
    init() {
        self.networkDAO = NetworkDefaultsDAO()
        let timeoutInterval = networkDAO.timeoutIntervalForRequests ?? LGCoreKitConstants.timeoutIntervalForRequest
        let userAgentBuilder = LGUserAgentBuilder()
        if ProcessInfo.processInfo.environment["isRunningUnitTests"] != nil {
            networkManager = Alamofire.SessionManager.make(backgroundEnabled: false,
                                                           userAgentBuilder: userAgentBuilder,
                                                           timeoutIntervalForRequest: timeoutInterval)
        } else {
            networkManager = Alamofire.SessionManager.make(backgroundEnabled: true,
                                                           userAgentBuilder: userAgentBuilder,
                                                           timeoutIntervalForRequest: timeoutInterval)
        }

        keychain = KeychainSwift()
        userDefaults = UserDefaults.standard

        tokenDAO = TokenKeychainDAO(keychain: keychain)

        let apiClient = AFApiClient(alamofireManager: networkManager,
                                    tokenDAO: tokenDAO)
        let reachability = LGReachability()
        let webSocketLibrary = LGWebSocketLibrary()
        self.webSocketLibrary = webSocketLibrary
        let webSocketClient = LGWebSocketClient(webSocket: webSocketLibrary,
                                                reachability: reachability)
        webSocketClient.timeoutIntervalForRequest = timeoutInterval

        let appVersion = Bundle.main
        let locale = Locale.autoupdatingCurrent
        let timeZone = TimeZone.current

        let deviceIdDAO = DeviceIdKeychainDAO(keychain: keychain)
        let installationDAO = InstallationUserDefaultsDAO(userDefaults: userDefaults)
        let installationDataSource = InstallationApiDataSource(apiClient: apiClient)
        let installationRepository = LGInstallationRepository(deviceIdDao: deviceIdDAO,
                                                              dao: installationDAO,
                                                              dataSource: installationDataSource,
                                                              appVersion: appVersion,
                                                              locale: locale,
                                                              timeZone: timeZone)

        let myUserDataSource = MyUserApiDataSource(apiClient: apiClient)
        let myUserDAO = MyUserUDDAO(userDefaults: userDefaults)
        let myUserRepository = LGMyUserRepository(dataSource: myUserDataSource,
                                                  dao: myUserDAO,
                                                  locale: locale)

        let countryInfoDAO: CountryInfoDAO = CountryInfoPlistDAO()
        let countryHelper = CountryHelper(locale: locale, countryInfoDAO: countryInfoDAO)

        let appleLocationDataSource = LGAppleLocationDataSource()
        let niordLocationDataSource = LGNiordLocationDataSource(apiClient: apiClient, locale: locale)
        let ipLookupDataSource = LGIPLookupDataSource(apiClient: apiClient)
        locationRepository = LGLocationRepository(appleLocationDataSource: appleLocationDataSource,
                                                  niordLocationDataSource: niordLocationDataSource,
                                                  ipLookupDataSource: ipLookupDataSource,
                                                  locationManager: CLLocationManager())
        locationRepository.distance = LGCoreKitConstants.locationDistanceFilter
        locationRepository.accuracy = LGCoreKitConstants.locationDesiredAccuracy
        let deviceLocationDAO = DeviceLocationUDDAO()

        let locationManager = LGLocationManager(myUserRepository: myUserRepository,
                                                locationRepository: locationRepository,
                                                deviceLocationDAO: deviceLocationDAO,
                                                countryHelper: countryHelper)

        let suggestedLocationsApiDataSource = SuggestedLocationsApiDataSource(apiClient: apiClient)

        let carsInfoDataSource = CarsInfoApiDataSource(apiClient: apiClient)
        let carsInfoCache: CarsInfoDAO = CarsInfoRealmDAO() ?? CarsInfoMemoryDAO()
        let carsInfoRepository = LGCarsInfoRepository(dataSource: carsInfoDataSource,
                                                      cache: carsInfoCache,
                                                      locationManager: locationManager)
        self.carsInfoRepository = carsInfoRepository

        let taxonomiesCache: TaxonomiesDAO = TaxonomiesRealmDAO() ?? TaxonomiesMemoryDAO()
        let taxonomiesDataSource = TaxonomiesApiDataSource(apiClient: apiClient)
        let categoryRepository = LGCategoryRepository(dataSource: taxonomiesDataSource,
                                                      taxonomiesCache: taxonomiesCache,
                                                      locationManager: locationManager)
        self.categoryRepository = categoryRepository
        
        let servicesInfoDataSource = ServicesInfoApiDataSource(apiClient: apiClient)
        let servicesInfoCache: LGServicesInfoRepository.ServicesInfoCache = ServicesInfoRealmDAO() ?? ServicesInfoMemoryDAO()
        let servicesInfoRepository = LGServicesInfoRepository(dataSource: servicesInfoDataSource,
                                                              cache: servicesInfoCache,
                                                              locationManager: locationManager)
        self.servicesInfoRepository = servicesInfoRepository
        
        let spellCorrectorDataSource = SpellCorrectorApiDataSource(apiClient: apiClient)
        let spellCorrectorRepository = LGSpellCorrectorRepository(dataSource: spellCorrectorDataSource)
        

        let listingDataSource = ListingApiDataSource(apiClient: apiClient)
        let listingsLimboDAO = ListingsLimboUDDAO(userDefaults: userDefaults)
        let listingRepository = LGListingRepository(listingDataSource: listingDataSource,
                                                    myUserRepository: myUserRepository,
                                                    listingsLimboDAO: listingsLimboDAO,
                                                    carsInfoRepository: carsInfoRepository,
                                                    spellCorrectorRepository: spellCorrectorRepository,
                                                    servicesInfoRepository: servicesInfoRepository)
        self.listingRepository = listingRepository

        let apiDataSource = UserApiDataSource(apiClient: apiClient)
        let userRepository = LGUserRepository(dataSource: apiDataSource,
                                              myUserRepository: myUserRepository,
                                              usersDAO: UsersMemoryDAO())
        self.internalUserRepository = userRepository

        let chatDataSource = ChatWebSocketDataSource(webSocketClient: webSocketClient, apiClient: apiClient)
        let chatRepository = LGChatRepository(dataSource: chatDataSource,
                                              myUserRepository: myUserRepository,
                                              userRepository: userRepository,
                                              listingRepository: listingRepository)
        self.chatRepository = chatRepository


        let stickersDAO = StickersUDDAO(userDefaults: userDefaults)

        let sessionManager = LGSessionManager(apiClient: apiClient,
                                              websocketClient: webSocketClient,
                                              myUserRepository: myUserRepository,
                                              installationRepository: installationRepository,
                                              tokenDAO: tokenDAO,
                                              deviceLocationDAO: deviceLocationDAO)

        locationManager.observeSessionManager(sessionManager)

        apiClient.installationRepository = installationRepository
        apiClient.sessionManager = sessionManager
        webSocketClient.sessionManager = sessionManager
        self.apiClient = apiClient
        self.webSocketClient = webSocketClient
        self.internalSessionManager = sessionManager
        self.locationManager = locationManager

        self.internalMyUserRepository = myUserRepository
        self.internalInstallationRepository = installationRepository

        let notificationsDataSource = NotificationsApiDataSource(apiClient: self.apiClient)
        self.notificationsRepository = LGNotificationsRepository(dataSource: notificationsDataSource)

        let stickersDataSoruce = StickersApiDataSource(apiClient: self.apiClient)
        self.stickersRepository = LGStickersRepository(dataSource: stickersDataSoruce,
                                                       stickersDAO: stickersDAO)

        let searchDataSource = SearchApiDataSource(apiClient: self.apiClient)
        self.searchRepository = LGSearchRepository(dataSource: searchDataSource)

        let userRatingDataSource = UserRatingApiDataSource(apiClient: self.apiClient)
        self.userRatingRepository = LGUserRatingRepository(dataSource: userRatingDataSource,
                                                           myUserRepository: myUserRepository)

        self.deviceIdDAO = deviceIdDAO
        self.installationDAO = installationDAO
        self.myUserDAO = myUserDAO
        self.stickersDAO = stickersDAO
        self.listingsLimboDAO = listingsLimboDAO

        self.reachability = reachability

        self.currencyHelper = CurrencyHelper(countryInfoDAO: countryInfoDAO,
                                             defaultLocale: locale)
        self.countryHelper = countryHelper
        
        let imageMultiplierDataSource = ImageMultiplierApiDataSource(apiClient: apiClient)
        imageMultiplierRepository = LGImageMultiplierRepository(dataSource: imageMultiplierDataSource)

        self.reporter = ReporterProxy()
    }


    // MARK: - DI
    // MARK: > Clients

    let apiClient: ApiClient
    let webSocketClient: WebSocketClient
    let webSocketLibrary: WebSocketLibraryProtocol

    let keychain: KeychainSwift

    var networkBackgroundCompletion: (() -> Void)? {
        get {
            return networkManager.backgroundCompletionHandler
        }
        set {
            networkManager.backgroundCompletionHandler = newValue
        }
    }


    // MARK: > Manager

    var sessionManager: SessionManager {
        return internalSessionManager
    }
    let internalSessionManager: InternalSessionManager
    let locationManager: LocationManager


    // MARK: > Repository

    var userRepository: UserRepository {
        return internalUserRepository
    }
    let internalUserRepository: InternalUserRepository
    var myUserRepository: MyUserRepository {
        return internalMyUserRepository
    }
    let internalMyUserRepository: InternalMyUserRepository
    var installationRepository: InstallationRepository {
        return internalInstallationRepository
    }
    let internalInstallationRepository: InternalInstallationRepository
    let chatRepository: ChatRepository
    let notificationsRepository: NotificationsRepository
    let stickersRepository: StickersRepository
    let searchRepository: SearchRepository
    let userRatingRepository: UserRatingRepository
    let carsInfoRepository: CarsInfoRepository
    let categoryRepository: CategoryRepository
    var locationRepository: LocationRepository
    let imageMultiplierRepository: ImageMultiplierRepository
    let servicesInfoRepository: ServicesInfoRepository

    let listingRepository: ListingRepository
    lazy var fileRepository: FileRepository = {
        let dataSource = FileApiDataSource(apiClient: self.apiClient)
        return LGFileRepository(myUserRepository: self.internalMyUserRepository, fileDataSource: dataSource)
    }()

    lazy var contactRepository: ContactRepository = {
        let dataSource = ContactApiDataSource(apiClient: self.apiClient)
        return LGContactRepository(contactDataSource: dataSource)
    }()
    lazy var monetizationRepository: MonetizationRepository = {
        let dataSource = MonetizationApiDataSource(apiClient: self.apiClient)
        return LGMonetizationRepository(dataSource: dataSource, listingsLimboDAO: self.listingsLimboDAO)
    }()
    lazy var machineLearningRepository: MachineLearningRepository = {
        let machineLearningDataSource = LGMachineLearningDataSource()
        return LGMachineLearningRepository(dataSource: machineLearningDataSource)
    }()
    lazy var suggestedLocationsRepository: SuggestedLocationsRepository = {
        let suggestedLocationsDataSource = SuggestedLocationsApiDataSource(apiClient: self.apiClient)
        return LGSuggestedLocationsRepository(dataSource: suggestedLocationsDataSource)
    }()
    lazy var searchAlertsRepository: SearchAlertsRepository = {
        let searchAlertsDataSource = SearchAlertsApiDataSource(apiClient: self.apiClient)
        return LGSearchAlertsRepository(dataSource: searchAlertsDataSource, locationManager: self.locationManager)
    }()
    lazy var preSignedUploadUrlRepository: PreSignedUploadUrlRepository = {
        let dataSource = LGPreSignedUploadUrlDataSource(apiClient: self.apiClient)
        return LGPreSignedUploadUrlRepository(dataSource: dataSource)
    }()
    lazy var notificationSettingsPusherRepository: NotificationSettingsPusherRepository = {
        let notificationSettingsPusherDataSource = NotificationSettingsPusherApiDataSource(apiClient: self.apiClient)
        return LGNotificationSettingsPusherRepository(dataSource: notificationSettingsPusherDataSource)
    }()
    lazy var notificationSettingsMailerRepository: NotificationSettingsMailerRepository = {
        let notificationSettingsMailerDataSource = NotificationSettingsMailerApiDataSource(apiClient: self.apiClient)
        return LGNotificationSettingsMailerRepository(dataSource: notificationSettingsMailerDataSource)
    }()


    // MARK: > DAO

    let tokenDAO: TokenDAO
    let deviceIdDAO: DeviceIdDAO
    let installationDAO: InstallationDAO
    let myUserDAO: MyUserDAO
    let stickersDAO: StickersDAO
    let listingsLimboDAO: ListingsLimboDAO
    let networkDAO: NetworkDAO

    // MARK: > Reachability

    let reachability: ReachabilityProtocol?

    // MARK: > Helper

    let currencyHelper: CurrencyHelper
    let countryHelper: CountryHelper

    lazy var dateFormatter: DateFormatter = {
        return LGDateFormatter()
    }()


    // MARK: > Logger

    var reporter: ReporterProxy


    // MARK: - Private iVars

    private let userDefaults: UserDefaults
    private(set) var networkManager: Alamofire.SessionManager

}
