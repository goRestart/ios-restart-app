//
//  DeviceLocationUDDAO.swift
//  LGCoreKit
//
//  Created by Albert Hernández López on 21/12/15.
//  Copyright © 2015 Ambatana Inc. All rights reserved.
//

class DeviceLocationUDDAO: DeviceLocationDAO {

    // Constants
    static let DeviceLocationMainKey = "DeviceLocation"
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
    let userDefaults: NSUserDefaults
    private(set) var deviceLocation: DeviceLocation?

    // Singleton
    static let sharedInstance: DeviceLocationUDDAO = DeviceLocationUDDAO()


    // MARK: - Lifecycle

    convenience init() {
        let userDefaults = NSUserDefaults.standardUserDefaults()
        self.init(userDefaults: userDefaults)
    }

    init(userDefaults: NSUserDefaults) {
        self.userDefaults = userDefaults
        self.deviceLocation = fetch()
    }


    // MARK: - DeviceLocationDAO

    func save(newDeviceLocation: DeviceLocation) {
        deviceLocation = newDeviceLocation

        let dict: [String: AnyObject] = newDeviceLocation.encode()
        userDefaults.setValue(dict, forKey: DeviceLocationUDDAO.DeviceLocationMainKey)
    }


    // MARK: - Private methods

    private func fetch() -> DeviceLocation? {
        guard let dict = userDefaults.dictionaryForKey(DeviceLocationUDDAO.DeviceLocationMainKey) else { return nil }
        return LGDeviceLocation.decode(dict)
    }
}
