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
    let keychain: KeychainSwift

    init(keychain: KeychainSwift) {
        self.keychain = keychain
    }

    var deviceId: String {
        get {
            if let deviceId = keychain.get(DeviceIdKeychainDAO.deviceIdKey) { return deviceId }

            guard let deviceId = UIDevice.current.identifierForVendor?.uuidString else { return "no-device-id" }
            keychain.set(deviceId, forKey: DeviceIdKeychainDAO.deviceIdKey,
                withAccess: .accessibleAfterFirstUnlockThisDeviceOnly)
            return deviceId
        }
        set {
            keychain.set(newValue, forKey: DeviceIdKeychainDAO.deviceIdKey,
                         withAccess: .accessibleAfterFirstUnlockThisDeviceOnly)
        }
    }
}
