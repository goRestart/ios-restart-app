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
            ProductRepository.sharedInstance.indexFavorites() { _ in
                completion?()
            }
        }
    }
    
    static func setupAfterLoggedIn(completion: (() -> ())?) {
        ProductRepository.sharedInstance.indexFavorites() { _ in
            completion?()
        }
    }
}
