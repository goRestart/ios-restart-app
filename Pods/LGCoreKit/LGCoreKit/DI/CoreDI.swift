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


final class CoreDI: InternalDI {
    static let keychain = KeychainSwift()
    
    
    // MARK: - Lifecycle
    
    init(backgroundEnabled: Bool) {
        self.networkManager = Manager.lgManager(backgroundEnabled)
        let tokenDAO = CoreDI.tokenDAO
        let apiClient = AFApiClient(alamofireManager: self.networkManager, tokenDAO: tokenDAO)
        let webSocketClient = LGWebSocketClient()
        
        let userDefaults = NSUserDefaults.standardUserDefaults()

        let appVersion = NSBundle.mainBundle()
        let locale = NSLocale.autoupdatingCurrentLocale()
        let timeZone = NSTimeZone.systemTimeZone()

        let deviceIdDAO = DeviceIdKeychainDAO(keychain: CoreDI.keychain)
        let installationDAO = InstallationUserDefaultsDAO(userDefaults: userDefaults)
        let installationDataSource = InstallationApiDataSource(apiClient: apiClient)
        let installationRepository = InstallationRepository(deviceIdDao: deviceIdDAO, dao: installationDAO,
                                                            dataSource: installationDataSource, appVersion: appVersion,
                                                            locale: locale, timeZone: timeZone)
        
        let myUserDataSource = MyUserApiDataSource(apiClient: apiClient)
        let myUserDAO = MyUserUDDAO(userDefaults: userDefaults)
        let myUserRepository = MyUserRepository(dataSource: myUserDataSource, dao: myUserDAO)
        
        let chatDataSource = ChatWebSocketDataSource(webSocketClient: webSocketClient)
        let chatRepository = ChatRepository(dataSource: chatDataSource, myUserRepository: myUserRepository,
                                            webSocketClient: webSocketClient)
        self.chatRepository = chatRepository
        
        let sensorLocationService = CLLocationManager()
        sensorLocationService.distance = LGCoreKitConstants.locationDistanceFilter
        sensorLocationService.accuracy = LGCoreKitConstants.locationDesiredAccuracy
        let ipLookupLocationService = LGIPLookupLocationService(apiClient: apiClient)
        let postalAddressRetrievalService = CLPostalAddressRetrievalService()
        let deviceLocationDAO = DeviceLocationUDDAO()

        let countryInfoDAO: CountryInfoDAO = CountryInfoPlistDAO()
        let countryHelper = CountryHelper(locale: locale, countryInfoDAO: countryInfoDAO)
        
        let locationManager = LocationManager(myUserRepository: myUserRepository,
            sensorLocationService: sensorLocationService, ipLookupLocationService: ipLookupLocationService,
            postalAddressRetrievalService: postalAddressRetrievalService, deviceLocationDAO: deviceLocationDAO,
            countryHelper: countryHelper)
        
        let favoritesDAO = FavoritesUDDAO(userDefaults: userDefaults)
        let stickersDAO = StickersUDDAO(userDefaults: userDefaults)
        let productsLimboDAO = ProductsLimboUDDAO(userDefaults: userDefaults)
        
        let sessionManager = SessionManager(apiClient: apiClient, websocketClient: webSocketClient, locationManager: locationManager,
            myUserRepository: myUserRepository, installationRepository: installationRepository,
            chatRepository: chatRepository, tokenDAO: tokenDAO, deviceLocationDAO: deviceLocationDAO,
            favoritesDAO: favoritesDAO)

        apiClient.installationRepository = installationRepository
        apiClient.sessionManager = sessionManager
        self.apiClient = apiClient
        self.webSocketClient = webSocketClient
        self.sessionManager = sessionManager
        self.locationManager = locationManager
        
        self.myUserRepository = myUserRepository
        self.installationRepository = installationRepository
        let oldChatDataSource = ChatApiDataSource(apiClient: apiClient)
        let oldchatRepository = OldChatRepository(dataSource: oldChatDataSource, myUserRepository: myUserRepository)
        self.oldChatRepository = oldchatRepository

        let commercializerDataSource = CommercializerApiDataSource(apiClient: self.apiClient)
        let commercializerRepository = CommercializerRepository(dataSource: commercializerDataSource,
                                                                myUserRepository: myUserRepository)
        self.commercializerRepository = commercializerRepository

        let notificationsDataSource = NotificationsApiDataSource(apiClient: self.apiClient)
        self.notificationsRepository = NotificationsRepository(dataSource: notificationsDataSource)
        
        let stickersDataSoruce = StickersApiDataSource(apiClient: self.apiClient)
        self.stickersRepository = StickersRepository(dataSource: stickersDataSoruce, stickersDAO: stickersDAO)

        let trendingSearchesDataSource = TrendingSearchesApiDataSource(apiClient: self.apiClient)
        self.trendingSearchesRepository = TrendingSearchesRepository(dataSource: trendingSearchesDataSource)

        let userRatingDataSource = UserRatingApiDataSource(apiClient: self.apiClient)
        self.userRatingRepository = UserRatingRepository(dataSource: userRatingDataSource, myUserRepository: myUserRepository)
        
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
    
    let sessionManager: SessionManager
    let locationManager: LocationManager
    
    
    // MARK: > Repository
    
    let myUserRepository: MyUserRepository
    let installationRepository: InstallationRepository
    let oldChatRepository: OldChatRepository
    let commercializerRepository: CommercializerRepository
    let chatRepository: ChatRepository
    let notificationsRepository: NotificationsRepository
    let stickersRepository: StickersRepository
    let trendingSearchesRepository: TrendingSearchesRepository
    let userRatingRepository: UserRatingRepository
    lazy var categoryRepository: CategoryRepository = {
        return CategoryRepository()
    }()

    lazy var productRepository: ProductRepository = {
        let dataSource = ProductApiDataSource(apiClient: self.apiClient)
        return ProductRepository(productDataSource: dataSource, myUserRepository: self.myUserRepository,
                                 fileRepository: self.fileRepository, favoritesDAO: self.favoritesDAO,
                                 productsLimboDAO: self.productsLimboDAO, locationManager: self.locationManager,
                                 currencyHelper: self.currencyHelper)
    }()
    lazy var fileRepository: FileRepository = {
        let dataSource = FileApiDataSource(apiClient: self.apiClient)
        return LGFileRepository(myUserRepository: self.myUserRepository, fileDataSource: dataSource)
    }()
    
    lazy var contactRepository: ContactRepository = {
        let dataSource = ContactApiDataSource(apiClient: self.apiClient)
        return ContactRepository(contactDataSource: dataSource)
    }()
    lazy var userRepository: UserRepository = {
        let dataSource = UserApiDataSource(apiClient: self.apiClient)
        return UserRepository(dataSource: dataSource, myUserRepository: self.myUserRepository)
    }()


    // MARK: > DAO
    
    static let tokenDAO: TokenDAO = TokenKeychainDAO(keychain: CoreDI.keychain)
    let deviceIdDAO: DeviceIdDAO
    let installationDAO: InstallationDAO
    let myUserDAO: MyUserDAO
    let favoritesDAO: FavoritesDAO
    let stickersDAO: StickersDAO
    let productsLimboDAO: ProductsLimboDAO

    
    // MARK: > Helper
    
    let currencyHelper: CurrencyHelper
    let countryHelper: CountryHelper
    
    lazy var dateFormatter: NSDateFormatter = {
        return LGDateFormatter()
    }()


    // MARK: > Logger

    var reporter: ReporterProxy


    // MARK: - Private iVars
    
    private let userDefaults: NSUserDefaults
    private let networkManager: Manager
}
