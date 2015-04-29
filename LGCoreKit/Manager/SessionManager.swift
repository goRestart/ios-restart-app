//
//  SessionManager.swift
//  LGCoreKit
//
//  Created by AHL on 29/4/15.
//  Copyright (c) 2015 Ambatana Inc. All rights reserved.
//

import UIKit

final public class SessionManager {

    // Constants
    private static let userDefaultsKeyAccessToken = "accessToken"
    private static let userDefaultsKeyExpirationDate = "expirationDate"
    
    // Singleton
    public static let sharedInstance: SessionManager = SessionManager(sessionService: LGSessionService(), userDefaults: NSUserDefaults.standardUserDefaults())

    // iVars
    private var sessionService: SessionService
    private var userDefaults: NSUserDefaults

    public private(set) var isLoading: Bool
    public private(set) var sessionToken: SessionToken?
    
    // MARK: - Lifecycle
    
    public init(sessionService: SessionService, userDefaults: NSUserDefaults = NSUserDefaults.standardUserDefaults()) {
        self.sessionService = sessionService
        self.userDefaults = userDefaults
        
        self.isLoading = false
        if let accessToken = userDefaults.stringForKey(SessionManager.userDefaultsKeyAccessToken),
           let expirationDate = userDefaults.objectForKey(SessionManager.userDefaultsKeyExpirationDate) as? NSDate {
            self.sessionToken = LGSessionToken(accessToken: accessToken, expirationDate: expirationDate)
        }
    }
    
    // MARK: - Public methods
    
    public func retrieveSessionTokenWithCompletion(completion: RetrieveTokenCompletion?) -> Bool {
        if isLoading {
            return false
        }
        isLoading = true
        
        let clientId = EnvironmentProxy.sharedInstance.apiClientId
        let clientSecret = EnvironmentProxy.sharedInstance.apiClientSecret
        
        let params = RetrieveTokenParams(clientId: clientId, clientSecret: clientSecret)
        let myCompletion = { [weak self] (token: SessionToken?, error: LGError?) -> Void in
            if let strongSelf = self {
                strongSelf.isLoading = false
                
                if let newToken = token {
                    strongSelf.sessionToken = newToken
                    strongSelf.saveSessionToken(newToken)
                }
            }
            
            if let completionBlock = completion {
                completionBlock(token: token, error: error)
            }
        }
        
        sessionService.retrieveTokenWithParams(params, completion: myCompletion)
        return true
    }
    
    // MARK: - Private methods
    
    private func saveSessionToken(token: SessionToken) {
        userDefaults.setObject(token.accessToken, forKey: SessionManager.userDefaultsKeyAccessToken)
        userDefaults.setObject(token.expirationDate, forKey: SessionManager.userDefaultsKeyExpirationDate)
        userDefaults.synchronize()
    }
}
