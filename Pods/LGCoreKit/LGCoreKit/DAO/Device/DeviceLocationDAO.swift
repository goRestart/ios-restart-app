//
//  DeviceLocationDAO.swift
//  LGCoreKit
//
//  Created by Albert Hernández López on 21/12/15.
//  Copyright © 2015 Ambatana Inc. All rights reserved.
//

protocol DeviceLocationDAO {
    var deviceLocation: DeviceLocation? { get }
    func save(newDeviceLocation: DeviceLocation)
}
