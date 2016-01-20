//
//  LGCoreKit.swift
//  LGCoreKit
//
//  Created by Albert Hernández López on 11/05/15.
//  Copyright (c) 2015 Ambatana Inc. All rights reserved.
//

import Parse

public class LGCoreKit {
    public static func initialize(launchOptions: [NSObject: AnyObject]?) {
        // Parse setup
        Parse.setApplicationId(EnvironmentProxy.sharedInstance.parseApplicationId,
            clientKey: EnvironmentProxy.sharedInstance.parseClientId)

        SessionManager.sharedInstance.initialize()
    }

    public static func start(completion: (() -> ())?) {
        SessionManager.sharedInstance.start() {
            guard let userId = MyUserRepository.sharedInstance.myUser?.objectId else {
                completion?()
                return
            }
            ProductRepository.sharedInstance.indexFavorites(userId) { _ in
                completion?()
            }
        }
    }
    
    static func setupAfterLoggedIn(completion: (() -> ())?) {
        guard let userId = MyUserRepository.sharedInstance.myUser?.objectId else {
            completion?()
            return
        }
        ProductRepository.sharedInstance.indexFavorites(userId) { _ in
            completion?()
        }
    }
}
