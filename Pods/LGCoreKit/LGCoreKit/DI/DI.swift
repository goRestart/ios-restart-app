//
//  File.swift
//  LGCoreKit
//
//  Created by Albert Hernández López on 13/01/16.
//  Copyright © 2016 Ambatana Inc. All rights reserved.
//

import KeychainSwift
import Alamofire

public protocol DI: class {
    init(backgroundEnabled: Bool)

    // Background
    var networkBackgroundCompletion: (() -> Void)? { get set }
    
    // Manager
    var sessionManager: SessionManager { get }
    var locationManager: LocationManager { get }

    // Repository
    var myUserRepository: MyUserRepository { get }
    var installationRepository: InstallationRepository { get }
    var oldChatRepository: OldChatRepository { get }
    var productRepository: ProductRepository { get }
    var fileRepository: FileRepository { get }
    var contactRepository: ContactRepository { get }
    var userRepository: UserRepository { get }
    var commercializerRepository: CommercializerRepository { get }
    var chatRepository: ChatRepository { get }
    var notificationsRepository: NotificationsRepository { get }
    var stickersRepository: StickersRepository { get }
    var trendingSearchesRepository: TrendingSearchesRepository { get }
    var categoryRepository: CategoryRepository { get }
    var userRatingRepository: UserRatingRepository { get }


    // Helper
    var dateFormatter: NSDateFormatter { get }
    var currencyHelper: CurrencyHelper { get }
    var countryHelper: CountryHelper { get }

    //Logs
    var reporter: ReporterProxy { get }
}


protocol InternalDI: DI {
    // Clients
    var apiClient: ApiClient { get }
    var webSocketClient: WebSocketClient { get }
    var keychain: KeychainSwift { get }

    // DAO
    static var tokenDAO: TokenDAO { get }
    var deviceIdDAO: DeviceIdDAO { get }
    var installationDAO: InstallationDAO { get }
    var myUserDAO: MyUserDAO { get }
    var favoritesDAO: FavoritesDAO { get }
    var productsLimboDAO: ProductsLimboDAO { get }
}
