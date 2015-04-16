//
//  LetGoGoogleGeoLocation.swift
//  LetGo
//
//  Created by Nacho on 15/4/15.
//  Copyright (c) 2015 Ambatana. All rights reserved.
//

import UIKit

class LetGoGoogleGeoLocation: NSObject {
    // data
    var formatedAddress: String?
    var location: CLLocationCoordinate2D!
    var components: [LetGoGoogleAddressComponent] = []
    var placeId: String?
    var name: String?
    var reference: String?
    var url: String?
    var vicinity: String?
    
    init(formatedAddress: String, location: CLLocationCoordinate2D, components: [LetGoGoogleAddressComponent], placeId: String, name: String, reference: String, url: String, vicinity: String) {
        self.formatedAddress = formatedAddress
        self.location = location
        self.components = components
        self.placeId = placeId
        self.name = name
        self.reference = reference
        self.url = url
        self.vicinity = vicinity
    }
    
    init?(valuesFromDictionary dictionary: [String: AnyObject]) {
        super.init()
        
        // mandatory values
        if let geometry = dictionary[kLetGoRestAPIParameterGeometry] as? [String: AnyObject] {
            if let location = dictionary[kLetGoRestAPIParameterLocation] as? [String: AnyObject] {
                if let latitude = dictionary[kLetGoRestAPIParameterLatitude]?.floatValue, longitude = dictionary[kLetGoRestAPIParameterLongitude]?.floatValue {
                    self.location = CLLocationCoordinate2DMake(CLLocationDegrees(latitude), CLLocationDegrees(longitude))
                }
            }
        }
        if self.location == nil || !CLLocationCoordinate2DIsValid(self.location) { return nil }
        
        // optional values
        if let fa = dictionary[kLetGoRestAPIParameterFormatedAddress] as? String { self.formatedAddress = fa }
        if let ac = dictionary[kLetGoRestAPIParameterAddressComponents] as? [[String: AnyObject]] {
            for componentData in ac {
                if let component = LetGoGoogleAddressComponent(valuesFromDictionary: componentData) { self.components.append(component) }
            }
        }
        if let pi = dictionary[kLetGoRestAPIParameterPlaceId] as? String { self.placeId = pi }
        if let name = dictionary[kLetGoRestAPIParameterName] as? String { self.name = name }
        if let rf = dictionary[kLetGoRestAPIParameterReference] as? String { self.reference = rf }
        if let url = dictionary[kLetGoRestAPIParameterURL] as? String { self.url = url }
        if let vn = dictionary[kLetGoRestAPIParameterVicinity] as? String { self.vicinity = vn }
    }
}
