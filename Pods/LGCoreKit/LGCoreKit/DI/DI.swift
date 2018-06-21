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

    // Background
    var networkBackgroundCompletion: (() -> Void)? { get set }
    
    // Manager
    var sessionManager: SessionManager { get }
    var locationManager: LocationManager { get }

    // Repository
    var myUserRepository: MyUserRepository { get }
    var installationRepository: InstallationRepository { get }
    var listingRepository: ListingRepository { get }
    var fileRepository: FileRepository { get }
    var contactRepository: ContactRepository { get }
    var userRepository: UserRepository { get }
    var chatRepository: ChatRepository { get }
    var notificationsRepository: NotificationsRepository { get }
    var stickersRepository: StickersRepository { get }
    var searchRepository: SearchRepository { get }
    var categoryRepository: CategoryRepository { get }
    var userRatingRepository: UserRatingRepository { get }
    var monetizationRepository: MonetizationRepository { get }
    var carsInfoRepository: CarsInfoRepository { get }
    var locationRepository: LocationRepository { get }
    var machineLearningRepository: MachineLearningRepository { get }
    var suggestedLocationsRepository: SuggestedLocationsRepository { get }
    var searchAlertsRepository: SearchAlertsRepository { get }
    var preSignedUploadUrlRepository: PreSignedUploadUrlRepository { get }
    var imageMultiplierRepository: ImageMultiplierRepository { get }
    var servicesInfoRepository: ServicesInfoRepository { get }
    var notificationSettingsPusherRepository: NotificationSettingsPusherRepository { get }
    var notificationSettingsMailerRepository: NotificationSettingsMailerRepository { get }

    
    // Helper
    var dateFormatter: DateFormatter { get }
    var currencyHelper: CurrencyHelper { get }
    var countryHelper: CountryHelper { get }

    // Logs
    var reporter: ReporterProxy { get }
}


protocol InternalDI: DI {
    
    // Manager
    var internalSessionManager: InternalSessionManager { get }

    // Repository
    var internalMyUserRepository: InternalMyUserRepository { get }
    var internalInstallationRepository: InternalInstallationRepository { get }

    // Clients
    var apiClient: ApiClient { get }
    var webSocketClient: WebSocketClient { get }
    var keychain: KeychainSwift { get }
    var webSocketLibrary: WebSocketLibraryProtocol { get }

    // DAO
    var tokenDAO: TokenDAO { get }
    var deviceIdDAO: DeviceIdDAO { get }
    var installationDAO: InstallationDAO { get }
    var myUserDAO: MyUserDAO { get }
    var listingsLimboDAO: ListingsLimboDAO { get }
    var networkDAO: NetworkDAO { get }

    // Reachability
    var reachability: ReachabilityProtocol? { get }
}
