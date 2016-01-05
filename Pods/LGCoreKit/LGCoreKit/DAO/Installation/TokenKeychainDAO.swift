//
//  TokenKeychainDAO.swift
//  LGCoreKit
//
//  Created by Isaac Roldan on 15/12/15.
//  Copyright © 2015 Ambatana Inc. All rights reserved.
//

import Foundation
import KeychainSwift


struct Token {
    let value: String?
    var level: AuthLevel
}


class TokenKeychainDAO: TokenDAO {
    
    static let sharedInstance = TokenKeychainDAO()
    static let installationKey = "InstallationToken"
    static let userKey = "UserToken"
    let keychain: KeychainSwift
    
    lazy var token: Token = {
        return self.fetch()
    }()
    
    convenience init() {
        self.init(keychain: KeychainSwift())
    }
    
    init(keychain: KeychainSwift) {
        self.keychain = keychain
    }
    
    func save(token: Token) {
        guard let _ = token.value else { return }
        storeToken(token)
        if token.level < self.token.level { return }
        self.token = token
    }
    
    func deleteUserToken() {
        keychain.delete(TokenKeychainDAO.userKey)
        token = fetch()
    }
    
    func reset() {
        keychain.delete(TokenKeychainDAO.installationKey)
        deleteUserToken()
    }
    
    private func storeToken(token: Token) {
        guard let tokenString = token.value else { return }
        
        let key: String
        switch token.level {
        case .None:
            return
        case .Installation:
            key = TokenKeychainDAO.installationKey
        case .User:
            key = TokenKeychainDAO.userKey
        }
        
        keychain.set(tokenString, forKey: key)
    }
    
    private func fetch() -> Token {
        
        if let userToken = keychain.get(TokenKeychainDAO.userKey) {
            return Token(value: userToken, level: .User)
        }
        if let installationToken = keychain.get(TokenKeychainDAO.installationKey) {
            return Token(value: installationToken, level: .Installation)
        }
        return Token(value: nil, level: .None)
    }
}