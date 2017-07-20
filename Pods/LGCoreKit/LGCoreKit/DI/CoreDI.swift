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
import ReachabilitySwift

final class CoreDI: InternalDI {
    // MARK: - Lifecycle
    
    init() {
        let userAgentBuilder = LGUserAgentBuilder()
        if ProcessInfo.processInfo.environment["isRunningUnitTests"] != nil {
            networkManager = Alamofire.SessionManager.make(backgroundEnabled: false,
                                                           userAgentBuilder: userAgentBuilder)
        } else {
            networkManager = Alamofire.SessionManager.make(backgroundEnabled: true,
                                                           userAgentBuilder: userAgentBuilder)
        }
        
        keychain = KeychainSwift()
        userDefaults = UserDefaults.standard
        
        let tokenKeychainDAO = TokenKeychainDAO(keychain: keychain)
        let userDefaultsDAO = TokenUserDefaultsDAO(userDefaults: UserDefaults.standard)
        tokenDAO = TokenCleanupDAO(primaryDAO: tokenKeychainDAO,
                                   toDeleteDAO: userDefaultsDAO)

        let apiClient = AFApiClient(alamofireManager: networkManager,
                                    tokenDAO: tokenDAO)
        let reachability = LGReachability()
        let webSocketLibrary = LGWebSocketLibrary()
        self.webSocketLibrary = webSocketLibrary
        let webSocketClient = LGWebSocketClient(webSocket: webSocketLibrary,
                                                reachability: reachability)

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
        
        let locationDataSource = CoreLocationDataSource(apiClient: apiClient)
        let locationRepository = LGLocationRepository(dataSource: locationDataSource,
                                                      locationManager: CLLocationManager())
        locationRepository.distance = LGCoreKitConstants.locationDistanceFilter
        locationRepository.accuracy = LGCoreKitConstants.locationDesiredAccuracy
        let deviceLocationDAO = DeviceLocationUDDAO()
        
        let countryInfoDAO: CountryInfoDAO = CountryInfoPlistDAO()
        let countryHelper = CountryHelper(locale: locale, countryInfoDAO: countryInfoDAO)
        
        let locationManager = LGLocationManager(myUserRepository: myUserRepository,
                                                locationRepository: locationRepository,
                                                deviceLocationDAO: deviceLocationDAO,
                                                countryHelper: countryHelper)
        
        let carsInfoDataSource = CarsInfoApiDataSource(apiClient: apiClient)
        let carsInfoCache: CarsInfoDAO = CarsInfoRealmDAO() ?? CarsInfoMemoryDAO()
        let carsInfoRepository = LGCarsInfoRepository(dataSource: carsInfoDataSource,
                                                      cache: carsInfoCache,
                                                      locationManager: locationManager)
        self.carsInfoRepository = carsInfoRepository
        
        let listingDataSource = ListingApiDataSource(apiClient: apiClient)
        let favoritesDAO = FavoritesUDDAO(userDefaults: userDefaults)
        let listingsLimboDAO = ListingsLimboUDDAO(userDefaults: userDefaults)
        let listingRepository = LGListingRepository(listingDataSource: listingDataSource,
                                                    myUserRepository: myUserRepository,
                                                    favoritesDAO: favoritesDAO,
                                                    listingsLimboDAO: listingsLimboDAO,
                                                    carsInfoRepository: carsInfoRepository)
        self.listingRepository = listingRepository
        
        let apiDataSource = UserApiDataSource(apiClient: apiClient)
        let userRepository = LGUserRepository(dataSource: apiDataSource,
                                              myUserRepository: myUserRepository)
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
                                              deviceLocationDAO: deviceLocationDAO,
                                              favoritesDAO: favoritesDAO)

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
        let oldChatDataSource = ChatApiDataSource(apiClient: apiClient)
        let oldchatRepository = LGOldChatRepository(dataSource: oldChatDataSource,
                                                    myUserRepository: myUserRepository)
        self.oldChatRepository = oldchatRepository

        let commercializerDataSource = CommercializerApiDataSource(apiClient: self.apiClient)
        let commercializerRepository = LGCommercializerRepository(dataSource: commercializerDataSource)
        self.commercializerRepository = commercializerRepository

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
        let passiveBuyersDataSource = PassiveBuyersApiDataSource(apiClient: self.apiClient)
        self.passiveBuyersRepository = LGPassiveBuyersRepository(dataSource: passiveBuyersDataSource)

        self.deviceIdDAO = deviceIdDAO
        self.installationDAO = installationDAO
        self.myUserDAO = myUserDAO
        self.favoritesDAO = favoritesDAO
        self.stickersDAO = stickersDAO
        self.listingsLimboDAO = listingsLimboDAO
        
        self.reachability = reachability
        
        self.currencyHelper = CurrencyHelper(countryInfoDAO: countryInfoDAO,
                                             defaultLocale: locale)
        self.countryHelper = countryHelper

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
    let oldChatRepository: OldChatRepository
    let commercializerRepository: CommercializerRepository
    let chatRepository: ChatRepository
    let notificationsRepository: NotificationsRepository
    let stickersRepository: StickersRepository
    let searchRepository: SearchRepository
    let userRatingRepository: UserRatingRepository
    let passiveBuyersRepository: PassiveBuyersRepository
    let carsInfoRepository: CarsInfoRepository
    lazy var categoryRepository: CategoryRepository = {
        return LGCategoryRepository()
    }()

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
    lazy var locationRepository: LocationRepository = {
        let dataSource = CoreLocationDataSource(apiClient: self.apiClient)
        return LGLocationRepository(dataSource: dataSource, locationManager: CLLocationManager())
    }()

    // MARK: > DAO
    
    let tokenDAO: TokenDAO
    let deviceIdDAO: DeviceIdDAO
    let installationDAO: InstallationDAO
    let myUserDAO: MyUserDAO
    let favoritesDAO: FavoritesDAO
    let stickersDAO: StickersDAO
    let listingsLimboDAO: ListingsLimboDAO
    
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
    private let networkManager: Alamofire.SessionManager
}
