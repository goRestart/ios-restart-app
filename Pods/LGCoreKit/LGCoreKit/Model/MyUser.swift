//
//  User.swift
//  Ambatana
//
//  Created by AHL on 17/3/15.
//  Copyright (c) 2015 Ambatana. All rights reserved.
//

import CoreLocation

@objc public protocol MyUser: BaseModel {
    var username: String? { get set }
    var password: String? { get set }
    var email: String? { get set }
    
    var address: String? { get set }
    var avatarURL: String? { get }
    var city: String? { get set }
    var countryCode: String? { get set }
    var gpsCoordinates: CLLocationCoordinate2D { get set }
//    var radius: NSNumber! { get set }
    var publicUsername :String? { get set }
    var zipCode :String? { get set }
}