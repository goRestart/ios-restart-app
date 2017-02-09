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
    static let keychain = KeychainSwift()
    
    
    // MARK: - Lifecycle
    
    init(backgroundEnabled: Bool) {
        self.networkManager = Alamofire.SessionManager.lgManager(backgroundEnabled)
        let tokenDAO = CoreDI.tokenDAO
        let apiClient = AFApiClient(alamofireManager: self.networkManager, tokenDAO: tokenDAO)
        let webSocketClient = LGWebSocketClient()
        
        let userDefaults = UserDefaults.standard

        let appVersion = Bundle.main
        let locale = Locale.autoupdatingCurrent
        let timeZone = TimeZone.current

        let deviceIdDAO = DeviceIdKeychainDAO(keychain: CoreDI.keychain)
        let installationDAO = InstallationUserDefaultsDAO(userDefaults: userDefaults)
        let installationDataSource = InstallationApiDataSource(apiClient: apiClient)
        let installationRepository = LGInstallationRepository(deviceIdDao: deviceIdDAO, dao: installationDAO,
                                                            dataSource: installationDataSource, appVersion: appVersion,
                                                            locale: locale, timeZone: timeZone)
        
        let myUserDataSource = MyUserApiDataSource(apiClient: apiClient)
        let myUserDAO = MyUserUDDAO(userDefaults: userDefaults)
        let myUserRepository = LGMyUserRepository(dataSource: myUserDataSource, dao: myUserDAO, locale: locale)
        
        let chatDataSource = ChatWebSocketDataSource(webSocketClient: webSocketClient, apiClient: apiClient)
        let chatRepository = LGChatRepository(dataSource: chatDataSource, myUserRepository: myUserRepository)
        self.chatRepository = chatRepository
        
        let sensorLocationService = CLLocationManager()
        sensorLocationService.distance = LGCoreKitConstants.locationDistanceFilter
        sensorLocationService.accuracy = LGCoreKitConstants.locationDesiredAccuracy
        let ipLookupLocationService = LGIPLookupLocationService(apiClient: apiClient)
        let postalAddressRetrievalService = CLPostalAddressRetrievalService()
        let deviceLocationDAO = DeviceLocationUDDAO()

        let countryInfoDAO: CountryInfoDAO = CountryInfoPlistDAO()
        let countryHelper = CountryHelper(locale: locale, countryInfoDAO: countryInfoDAO)
        
        let locationManager = LGLocationManager(myUserRepository: myUserRepository,
            sensorLocationService: sensorLocationService, ipLookupLocationService: ipLookupLocationService,
            postalAddressRetrievalService: postalAddressRetrievalService, deviceLocationDAO: deviceLocationDAO,
            countryHelper: countryHelper)
        
        let favoritesDAO = FavoritesUDDAO(userDefaults: userDefaults)
        let stickersDAO = StickersUDDAO(userDefaults: userDefaults)
        let productsLimboDAO = ProductsLimboUDDAO(userDefaults: userDefaults)
        let reachability = Reachability()

        let sessionManager = LGSessionManager(apiClient: apiClient, websocketClient: webSocketClient,
            myUserRepository: myUserRepository, installationRepository: installationRepository, tokenDAO: tokenDAO,
            deviceLocationDAO: deviceLocationDAO, favoritesDAO: favoritesDAO, reachability: reachability)

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
        let oldchatRepository = LGOldChatRepository(dataSource: oldChatDataSource, myUserRepository: myUserRepository)
        self.oldChatRepository = oldchatRepository

        let commercializerDataSource = CommercializerApiDataSource(apiClient: self.apiClient)
        let commercializerRepository = LGCommercializerRepository(dataSource: commercializerDataSource,
                                                                myUserRepository: myUserRepository)
        self.internalCommercializerRepository = commercializerRepository

        let notificationsDataSource = NotificationsApiDataSource(apiClient: self.apiClient)
        self.notificationsRepository = LGNotificationsRepository(dataSource: notificationsDataSource)
        
        let stickersDataSoruce = StickersApiDataSource(apiClient: self.apiClient)
        self.stickersRepository = LGStickersRepository(dataSource: stickersDataSoruce, stickersDAO: stickersDAO)

        let trendingSearchesDataSource = TrendingSearchesApiDataSource(apiClient: self.apiClient)
        self.trendingSearchesRepository = LGTrendingSearchesRepository(dataSource: trendingSearchesDataSource)

        let userRatingDataSource = UserRatingApiDataSource(apiClient: self.apiClient)
        self.userRatingRepository = LGUserRatingRepository(dataSource: userRatingDataSource, myUserRepository: myUserRepository)
        let passiveBuyersDataSource = PassiveBuyersApiDataSource(apiClient: self.apiClient)
        self.passiveBuyersRepository = LGPassiveBuyersRepository(dataSource: passiveBuyersDataSource)
        
        self.deviceIdDAO = deviceIdDAO
        self.installationDAO = installationDAO
        self.myUserDAO = myUserDAO
        self.favoritesDAO = favoritesDAO
        self.stickersDAO = stickersDAO
        self.productsLimboDAO = productsLimboDAO
        
        self.currencyHelper = CurrencyHelper(countryInfoDAO: countryInfoDAO, defaultLocale: locale)
        self.countryHelper = countryHelper
        
        self.userDefaults = userDefaults

        self.reporter = ReporterProxy()
    }
    
    
    // MARK: - DI
    // MARK: > Clients
    
    let apiClient: ApiClient
    let webSocketClient: WebSocketClient
    
    var keychain: KeychainSwift {
        return CoreDI.keychain
    }

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

    var myUserRepository: MyUserRepository {
        return internalMyUserRepository
    }
    let internalMyUserRepository: InternalMyUserRepository
    var installationRepository: InstallationRepository {
        return internalInstallationRepository
    }
    let internalInstallationRepository: InternalInstallationRepository
    let oldChatRepository: OldChatRepository
    var commercializerRepository: CommercializerRepository {
        return internalCommercializerRepository
    }
    let internalCommercializerRepository: InternalCommercializerRepository
    let chatRepository: ChatRepository
    let notificationsRepository: NotificationsRepository
    let stickersRepository: StickersRepository
    let trendingSearchesRepository: TrendingSearchesRepository
    let userRatingRepository: UserRatingRepository
    let passiveBuyersRepository: PassiveBuyersRepository
    lazy var categoryRepository: CategoryRepository = {
        return LGCategoryRepository()
    }()

    lazy var productRepository: ProductRepository = {
        let dataSource = ProductApiDataSource(apiClient: self.apiClient)
        return LGProductRepository(productDataSource: dataSource, myUserRepository: self.internalMyUserRepository,
                                 fileRepository: self.fileRepository, favoritesDAO: self.favoritesDAO,
                                 productsLimboDAO: self.productsLimboDAO, locationManager: self.locationManager,
                                 currencyHelper: self.currencyHelper)
    }()
    lazy var fileRepository: FileRepository = {
        let dataSource = FileApiDataSource(apiClient: self.apiClient)
        return LGFileRepository(myUserRepository: self.internalMyUserRepository, fileDataSource: dataSource)
    }()
    
    lazy var contactRepository: ContactRepository = {
        let dataSource = ContactApiDataSource(apiClient: self.apiClient)
        return LGContactRepository(contactDataSource: dataSource)
    }()
    lazy var userRepository: UserRepository = {
        let dataSource = UserApiDataSource(apiClient: self.apiClient)
        return LGUserRepository(dataSource: dataSource, myUserRepository: self.internalMyUserRepository)
    }()
    lazy var monetizationRepository: MonetizationRepository = {
        let dataSource = MonetizationApiDataSource(apiClient: self.apiClient)
        return LGMonetizationRepository(dataSource: dataSource, productsLimboDAO: self.productsLimboDAO)
    }()

    // MARK: > DAO
    
    static let tokenDAO: TokenDAO = {
        let keychain = TokenKeychainDAO(keychain: CoreDI.keychain)
        let userDefaults = TokenUserDefaultsDAO(userDefaults: UserDefaults.standard)
        return TokenRedundanceDAO(primaryDAO: keychain, secondaryDAO: userDefaults)
    }()
    let deviceIdDAO: DeviceIdDAO
    let installationDAO: InstallationDAO
    let myUserDAO: MyUserDAO
    let favoritesDAO: FavoritesDAO
    let stickersDAO: StickersDAO
    let productsLimboDAO: ProductsLimboDAO

    
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
