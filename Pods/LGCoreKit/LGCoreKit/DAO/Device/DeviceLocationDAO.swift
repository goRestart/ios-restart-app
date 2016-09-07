//
//  DeviceLocationDAO.swift
//  LGCoreKit
//
//  Created by Albert Hernández López on 21/12/15.
//  Copyright © 2015 Ambatana Inc. All rights reserved.
//

import CoreLocation

protocol DeviceLocationDAO {
    var deviceLocation: DeviceLocation? { get }
    func save(newDeviceLocation: DeviceLocation)
    
    var locationStatus: CLAuthorizationStatus? { get }
    func save(locationStatus: CLAuthorizationStatus)
}
