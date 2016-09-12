//
//  DIProxy.swift
//  LGCoreKit
//
//  Created by Albert Hernández López on 12/01/16.
//  Copyright © 2016 Ambatana Inc. All rights reserved.
//

import KeychainSwift
import Foundation

final class DIProxy: InternalDI {
    
    static let sharedInstance = DIProxy()
    
    private static var diType: InternalDI.Type = CoreDI.self
    private var di: InternalDI
    
    
    // MARK: - Lifecycle
    
    init(backgroundEnabled: Bool = true) {
        self.di = DIProxy.buildDI(DIProxy.diType, backgroundEnabled: backgroundEnabled)
    }
    
    
    // MARK: - Internal methods

    /**
    This method is only used from test target, backgroundEnabled needs to be false
    */
    func setType(type: InternalDI.Type) {
        self.di = DIProxy.buildDI(type, backgroundEnabled: false)
        DIProxy.diType = type
    }
    
    
    // MARK: - InternalDI
    
    var networkBackgroundCompletion: (() -> Void)? {
        get {
            return di.networkBackgroundCompletion
        }
        set {
            di.networkBackgroundCompletion = newValue
        }
    }
    var apiClient: ApiClient {
        return di.apiClient
    }
    var webSocketClient: WebSocketClient {
        return di.webSocketClient
    }
    var keychain: KeychainSwift {
        return di.keychain
    }
    var sessionManager: SessionManager {
        return di.sessionManager
    }
    var locationManager: LocationManager {
        return di.locationManager
    }
    var categoryRepository: CategoryRepository {
        return di.categoryRepository
    }
    var myUserRepository: MyUserRepository {
        return di.myUserRepository
    }
    var installationRepository: InstallationRepository {
        return di.installationRepository
    }
    var oldChatRepository: OldChatRepository {
        return di.oldChatRepository
    }
    var commercializerRepository: CommercializerRepository {
        return di.commercializerRepository
    }
    var chatRepository: ChatRepository {
        return di.chatRepository
    }
    var notificationsRepository: NotificationsRepository {
        return di.notificationsRepository
    }
    var productRepository: ProductRepository {
        return di.productRepository
    }
    var fileRepository: FileRepository {
        return di.fileRepository
    }
    var contactRepository: ContactRepository {
        return di.contactRepository
    }
    var userRepository: UserRepository {
        return di.userRepository
    }
    var stickersRepository: StickersRepository {
        return di.stickersRepository
    }
    var trendingSearchesRepository: TrendingSearchesRepository {
        return di.trendingSearchesRepository
    }
    var userRatingRepository: UserRatingRepository {
        return di.userRatingRepository
    }
    static var tokenDAO: TokenDAO {
        return diType.tokenDAO
    }
    var deviceIdDAO: DeviceIdDAO {
        return di.deviceIdDAO
    }
    var installationDAO: InstallationDAO {
        return di.installationDAO
    }
    var myUserDAO: MyUserDAO {
        return di.myUserDAO
    }
    var favoritesDAO: FavoritesDAO {
        return di.favoritesDAO
    }
    var productsLimboDAO: ProductsLimboDAO {
        return di.productsLimboDAO
    }
    var currencyHelper: CurrencyHelper {
        return di.currencyHelper
    }
    var countryHelper: CountryHelper {
        return di.countryHelper
    }
    var dateFormatter: NSDateFormatter {
        return di.dateFormatter
    }
    var reporter: ReporterProxy {
        return di.reporter
    }

    
    // MARK: - Private methods
    
    private static func buildDI(type: InternalDI.Type, backgroundEnabled: Bool) -> InternalDI {
        return type.init(backgroundEnabled: backgroundEnabled)
    }
}