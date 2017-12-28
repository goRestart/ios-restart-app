//
//  DeviceLocationUDDAO.swift
//  LGCoreKit
//
//  Created by Albert Hernández López on 21/12/15.
//  Copyright © 2015 Ambatana Inc. All rights reserved.
//

import CoreLocation

class DeviceLocationUDDAO: DeviceLocationDAO {
    
    // Constants
    static let DeviceLocationMainKey = "DeviceLocation"
    static let DeviceLocationStatusKey = "DeviceLocationStatus"
    
    struct DeviceLocationKeys {
        static let latitude = "latitude"
        static let longitude = "longitude"
        static let locationType = "locationType"
        
        static let address = "address"
        static let city = "city"
        static let zipCode = "zipCode"
        static let countryCode = "countryCode"
        static let country = "country"
    }
    
    // iVars
    let userDefaults: UserDefaults
    private(set) var deviceLocation: DeviceLocation?
    private(set) var locationStatus: CLAuthorizationStatus?
    
    // MARK: - Lifecycle
    
    convenience init() {
        let userDefaults = UserDefaults.standard
        self.init(userDefaults: userDefaults)
    }
    
    init(userDefaults: UserDefaults) {
        self.userDefaults = userDefaults
        self.deviceLocation = fetch()
        self.locationStatus = fetchStatus()
    }
    
    
    // MARK: - DeviceLocationDAO
    
    func save(_ newDeviceLocation: DeviceLocation) {
        deviceLocation = newDeviceLocation
        
        let dict: [String: Any] = newDeviceLocation.encode()
        userDefaults.setValue(dict, forKey: DeviceLocationUDDAO.DeviceLocationMainKey)
    }
    
    func save(_ locationStatus: CLAuthorizationStatus) {
        self.locationStatus = locationStatus
        userDefaults.setValue(Int(locationStatus.rawValue), forKey: DeviceLocationUDDAO.DeviceLocationStatusKey)
    }
    
    
    // MARK: - Private methods
    
    private func fetch() -> DeviceLocation? {
        guard let dict = userDefaults.dictionary(forKey: DeviceLocationUDDAO.DeviceLocationMainKey) else { return nil }
        return LGDeviceLocation.decode(dict)
    }
    
    private func fetchStatus() -> CLAuthorizationStatus? {
        guard let status = userDefaults.value(forKey: DeviceLocationUDDAO.DeviceLocationStatusKey) as? Int else { return nil }
        return CLAuthorizationStatus(rawValue: Int32(status))
    }
}