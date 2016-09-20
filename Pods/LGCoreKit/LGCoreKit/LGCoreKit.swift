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

    public static func initialize(launchOptions: [NSObject: AnyObject]?) {
        initialize(launchOptions, environmentType: .Production)
    }

    public static func initialize(launchOptions: [NSObject: AnyObject]?, environmentType: EnvironmentType) {
        EnvironmentProxy.sharedInstance.setEnvironmentType(environmentType)

        // Managers setup
        InternalCore.sessionManager.initialize()
        InternalCore.locationManager.initialize()
    }

    public static func start() {
        InternalCore.commercializerRepository.indexTemplates(nil)
        guard let userId = InternalCore.myUserRepository.myUser?.objectId else { return }
        InternalCore.productRepository.indexFavorites(userId, completion: nil)
        InternalCore.stickersRepository.show(nil) // Sync stickers to NSUserDefaults
        if activateWebsocket {
            InternalCore.webSocketClient.startWebSocket(EnvironmentProxy.sharedInstance.webSocketURL) {
                InternalCore.sessionManager.authenticateWebSocket(nil)
            }
        }
    }
    
    public static func refreshData() {
        // Ask for the commercializer templates
        InternalCore.commercializerRepository.indexTemplates(nil)
        // Refresh my user
        InternalCore.myUserRepository.refresh(nil)
    }
    
    static func setupAfterLoggedIn(completion: (() -> ())?) {
        guard let userId = InternalCore.myUserRepository.myUser?.objectId else {
            completion?()
            return
        }
        InternalCore.productRepository.indexFavorites(userId) { _ in
            completion?()
        }
    }
}
