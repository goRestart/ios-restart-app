//
//  LGCoreKit.swift
//  LGCoreKit
//
//  Created by Albert Hernández López on 11/05/15.
//  Copyright (c) 2015 Ambatana Inc. All rights reserved.
//

let InternalCore: InternalDI = CoreDI()

public let Core: DI = {
    return InternalCore
}()


public class LGCoreKit {

    public static var loggingOptions = CoreLoggingOptions.none
    public static var quadKeyZoomLevel = LGCoreKitConstants.defaultQuadKeyPrecision
    static var shouldUseChatWithWebSocket = false

    public static func initialize(config: LGCoreKitConfig) {

        LGCoreKit.shouldUseChatWithWebSocket = config.shouldUseChatWithWebSocket

        EnvironmentProxy.sharedInstance.setEnvironmentType(config.environmentType)

        // Managers setup
        InternalCore.internalSessionManager.initialize()
        InternalCore.locationManager.initialize()

        // Cars Info cache
        InternalCore.carsInfoRepository.loadFirstRunCacheIfNeeded(jsonURL: config.carsInfoAppJSONURL)
    }

    public static func start() {
        guard let userId = InternalCore.myUserRepository.myUser?.objectId else { return }
        InternalCore.listingRepository.indexFavorites(userId, completion: nil)
        InternalCore.stickersRepository.show(nil) // Sync stickers to UserDefaults
        InternalCore.carsInfoRepository.refreshCarsInfoFile()
    }

    public static func applicationDidEnterBackground() {
        InternalCore.webSocketClient.applicationDidEnterBackground()
    }
    
    public static func applicationWillEnterForeground() {
        // Refresh my user
        InternalCore.myUserRepository.refresh(nil)
        InternalCore.webSocketClient.applicationWillEnterForeground()
    }

    static func setupAfterLoggedIn(_ completion: (() -> ())?) {
        guard let userId = InternalCore.myUserRepository.myUser?.objectId else {
            completion?()
            return
        }
        InternalCore.listingRepository.indexFavorites(userId) { _ in
            completion?()
        }
    }
}
