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
    
    init() {
        let alamofireManager = Manager.sharedInstance
        let tokenDAO = CoreDI.tokenDAO
        let apiClient = AFApiClient(alamofireManager: alamofireManager, tokenDAO: tokenDAO)
        let webSocketClient = LGWebSocketClient()
        
        let userDefaults = NSUserDefaults.standardUserDefaults()
        let deviceIdDAO = DeviceIdKeychainDAO(keychain: CoreDI.keychain)
        let installationDAO = InstallationUserDefaultsDAO(userDefaults: userDefaults)
        let installationDataSource = InstallationApiDataSource(apiClient: apiClient)
        let installationRepository = InstallationRepository(deviceIdDao: deviceIdDAO, dao: installationDAO,
            dataSource: installationDataSource)
        
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

        let locale = NSLocale.autoupdatingCurrentLocale()
        let countryInfoDAO: CountryInfoDAO = CountryInfoPlistDAO()
        let countryHelper = CountryHelper(locale: locale, countryInfoDAO: countryInfoDAO)
        
        let locationManager = LocationManager(myUserRepository: myUserRepository,
            sensorLocationService: sensorLocationService, ipLookupLocationService: ipLookupLocationService,
            postalAddressRetrievalService: postalAddressRetrievalService, deviceLocationDAO: deviceLocationDAO,
            countryHelper: countryHelper)
        
        let favoritesDAO = FavoritesUDDAO(userDefaults: userDefaults)
        
        let sessionManager = SessionManager(apiClient: apiClient, locationManager: locationManager,
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
        
        self.deviceIdDAO = deviceIdDAO
        self.installationDAO = installationDAO
        self.myUserDAO = myUserDAO
        self.favoritesDAO = favoritesDAO
        
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
    
    
    // MARK: > Manager
    
    let sessionManager: SessionManager
    let locationManager: LocationManager
    
    lazy var categoriesManager: CategoriesManager = {
        let categoriesRetrieveService = LGCategoriesRetrieveService()
        return CategoriesManager(categoriesRetrieveService: categoriesRetrieveService)
    }()
    
    
    // MARK: > Repository
    
    let myUserRepository: MyUserRepository
    let installationRepository: InstallationRepository
    let oldChatRepository: OldChatRepository
    let commercializerRepository: CommercializerRepository
    let chatRepository: ChatRepository
    let notificationsRepository: NotificationsRepository
    
    lazy var productRepository: ProductRepository = {
        let dataSource = ProductApiDataSource(apiClient: self.apiClient)
        let favouritesDAO = FavoritesUDDAO(userDefaults: self.userDefaults)
        return ProductRepository(productDataSource: dataSource, myUserRepository: self.myUserRepository,
            fileRepository: self.fileRepository, favoritesDAO: favouritesDAO, locationManager: self.locationManager,
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
}
