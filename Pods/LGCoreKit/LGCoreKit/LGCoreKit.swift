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
    public static var shouldUseChatWithWebSocket = false
    public static var quadKeyZoomLevel = LGCoreKitConstants.defaultQuadKeyPrecision

    public static func initialize(_ launchOptions: [UIApplicationLaunchOptionsKey: Any]?) {
        initialize(launchOptions, environmentType: .production)
    }

    public static func initialize(_ launchOptions: [UIApplicationLaunchOptionsKey: Any]?, environmentType: EnvironmentType) {
        EnvironmentProxy.sharedInstance.setEnvironmentType(environmentType)

        // Managers setup
        InternalCore.internalSessionManager.initialize()
        InternalCore.locationManager.initialize()
    }

    public static func start() {
        guard let userId = InternalCore.myUserRepository.myUser?.objectId else { return }
        InternalCore.productRepository.indexFavorites(userId, completion: nil)
        InternalCore.stickersRepository.show(nil) // Sync stickers to UserDefaults
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
        InternalCore.productRepository.indexFavorites(userId) { _ in
            completion?()
        }
    }
}
