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

    public static func initialize(config: LGCoreKitConfig) {
        EnvironmentProxy.sharedInstance.setEnvironmentType(config.environmentType)

        InternalCore.internalSessionManager.initialize()
        InternalCore.locationManager.initialize()

        // Fill cars Info cache with local data
        InternalCore.carsInfoRepository.loadFirstRunCacheIfNeeded(jsonURL: config.carsInfoAppJSONURL)

        // Fill taxonomies cache with local data
        InternalCore.categoryRepository.loadFirstRunCacheIfNeeded(jsonURL: config.taxonomiesAppJSONURL)
        
        // Fill services cache with local data
        InternalCore.servicesInfoRepository.loadFirstRunCacheIfNeeded(jsonURL: config.servicesInfoAppJSONURL)
    }

    public static func start() {
        InternalCore.categoryRepository.refreshTaxonomiesCache()
        InternalCore.stickersRepository.show(nil) // Sync stickers to UserDefaults
    }

    public static func applicationDidEnterBackground() {
        InternalCore.webSocketClient.applicationDidEnterBackground()
    }
    
    public static func applicationWillEnterForeground() {
        InternalCore.myUserRepository.refresh(nil)
        InternalCore.webSocketClient.applicationWillEnterForeground()
    }

    static func setupAfterLoggedIn(_ completion: (() -> ())?) {
        completion?()
    }

}
