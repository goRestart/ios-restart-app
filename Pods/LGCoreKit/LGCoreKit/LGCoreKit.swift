//
//  LGCoreKit.swift
//  LGCoreKit
//
//  Created by Albert Hernández López on 11/05/15.
//  Copyright (c) 2015 Ambatana Inc. All rights reserved.
//


let InternalCore: DIProxy = DIProxy.sharedInstance
public let Core: DI = {
    return InternalCore
}()


public class LGCoreKit {

    public static var loggingOptions = CoreLoggingOptions.None
    public static var activateWebsocket = false
    public static var quadKeyZoomLevel = LGCoreKitConstants.defaultQuadKeyPrecision

    public static func initialize(_ launchOptions: [AnyHashable: Any]?) {
        initialize(launchOptions, environmentType: .Production)
    }

    public static func initialize(_ launchOptions: [AnyHashable: Any]?, environmentType: EnvironmentType) {
        EnvironmentProxy.sharedInstance.setEnvironmentType(environmentType)

        // Managers setup
        InternalCore.internalSessionManager.initialize()
        InternalCore.locationManager.initialize()
    }

    public static func start() {
        InternalCore.internalCommercializerRepository.indexTemplates(nil)
        guard let userId = InternalCore.myUserRepository.myUser?.objectId else { return }
        InternalCore.productRepository.indexFavorites(userId, completion: nil)
        InternalCore.stickersRepository.show(nil) // Sync stickers to NSUserDefaults
    }
    
    public static func applicationWillEnterForeground() {
        // Ask for the commercializer templates
        InternalCore.internalCommercializerRepository.indexTemplates(nil)
        // Refresh my user
        InternalCore.myUserRepository.refresh(nil)
    }

    public static func applicationDidBecomeActive() {
        InternalCore.internalSessionManager.applicationDidBecomeActive()
    }

    public static func applicationDidEnterBackground() {
        InternalCore.internalSessionManager.applicationDidEnterBackground()
    }

    static func setupAfterLoggedIn(_ completion: (() -> ())?) {
        guard let userId = InternalCore.myUserRepository.myUser?.objectId else {
            completion?()
            return
        }
        InternalCore.productRepository.indexFavorites(userId) { _ in
            completion?()
        }
    }
}
