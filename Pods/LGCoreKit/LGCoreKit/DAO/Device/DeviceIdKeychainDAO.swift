//
//  DeviceIdKeychainDAO.swift
//  LGCoreKit
//
//  Created by Isaac Roldan on 14/12/15.
//  Copyright © 2015 Ambatana Inc. All rights reserved.
//

import Foundation
import KeychainSwift

class DeviceIdKeychainDAO: DeviceIdDAO {
    
    static let deviceIdKey = "deviceIdKey"
    static let sharedInstance = DeviceIdKeychainDAO()
    let keychain: KeychainSwift
    
    convenience init() {
        self.init(keychain: KeychainSwift())
    }
    
    init(keychain: KeychainSwift) {
        self.keychain = keychain
    }
    
    var deviceId: String {
        if let deviceId = keychain.get(DeviceIdKeychainDAO.deviceIdKey) { return deviceId }
        
        guard let deviceId = UIDevice.currentDevice().identifierForVendor?.UUIDString else { return "no-device-id" }
        keychain.set(deviceId, forKey: DeviceIdKeychainDAO.deviceIdKey)
        return deviceId
    }
}
