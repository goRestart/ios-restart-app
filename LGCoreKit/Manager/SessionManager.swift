//
//  SessionManager.swift
//  LGCoreKit
//
//  Created by AHL on 29/4/15.
//  Copyright (c) 2015 Ambatana Inc. All rights reserved.
//

import Bolts

public class SessionManager {

    // Constants
    private static let userDefaultsKeyAccessToken = "accessToken"
    private static let userDefaultsKeyExpirationDate = "expirationDate"
    
    // Singleton
    public static let sharedInstance: SessionManager = SessionManager(sessionService: LGSessionService(), userDefaults: NSUserDefaults.standardUserDefaults())

    // iVars
    private var sessionService: SessionService
    private var userDefaults: NSUserDefaults

    public var sessionToken: SessionToken?
    
    // MARK: - Lifecycle
    
    public init(sessionService: SessionService, userDefaults: NSUserDefaults = NSUserDefaults.standardUserDefaults()) {
        self.sessionService = sessionService
        self.userDefaults = userDefaults

        if let accessToken = userDefaults.stringForKey(SessionManager.userDefaultsKeyAccessToken),
           let expirationDate = userDefaults.objectForKey(SessionManager.userDefaultsKeyExpirationDate) as? NSDate {
            self.sessionToken = LGSessionToken(accessToken: accessToken, expirationDate: expirationDate)
        }
    }
    
    // MARK: - Public methods
    
    public func retrieveSessionToken() -> BFTask {
        var task = BFTaskCompletionSource()
        
        let clientId = EnvironmentProxy.sharedInstance.apiClientId
        let clientSecret = EnvironmentProxy.sharedInstance.apiClientSecret
        let params = RetrieveTokenParams(clientId: clientId, clientSecret: clientSecret)
        
        sessionService.retrieveTokenWithParams(params) { [weak self] (token: SessionToken?, error: NSError?) -> Void in
            
            if let strongSelf = self {
                if let newToken = token {
                    strongSelf.sessionToken = newToken
                    strongSelf.saveSessionToken(newToken)
                }
            }
            
            if let actualError = error {
                task.setError(error)
            }
            else if let actualToken = token {
                task.setResult(actualToken)
            }
            else {
                task.setError(NSError(code: LGErrorCode.Internal))
            }
        }
        return task.task
    }

    
    public func isSessionValid() -> Bool {
        if let token = sessionToken {
            return !token.isExpired()
        }
        return false
    }
    
    // MARK: - Private methods
    
    private func saveSessionToken(token: SessionToken) {
        userDefaults.setObject(token.accessToken, forKey: SessionManager.userDefaultsKeyAccessToken)
        userDefaults.setObject(token.expirationDate, forKey: SessionManager.userDefaultsKeyExpirationDate)
        userDefaults.synchronize()
    }
}
