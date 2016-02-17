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
    
    public static func initialize(launchOptions: [NSObject: AnyObject]?) {
        initialize(launchOptions, environmentType: .Production)
    }

    public static func initialize(launchOptions: [NSObject: AnyObject]?, environmentType: EnvironmentType) {
        EnvironmentProxy.sharedInstance.setEnvironmentType(environmentType)

        // Managers setup
        InternalCore.sessionManager.initialize()
        InternalCore.locationManager.initialize()
    }

    public static func start(completion: (() -> ())?) {
        InternalCore.sessionManager.start {
            
            completion?()
            
            guard let userId = InternalCore.myUserRepository.myUser?.objectId else { return }
            
            InternalCore.productRepository.indexFavorites(userId) { _ in
                
            }
        }
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
