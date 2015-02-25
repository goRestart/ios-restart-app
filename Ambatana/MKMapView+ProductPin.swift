//
//  MKMapView+ProductPin.swift
//  Ambatana
//
//  Created by Ignacio Nieto Carvajal on 12/2/15.
//  Copyright (c) 2015 Ignacio Nieto Carvajal. All rights reserved.
//

import Foundation
import MapKit

extension MKMapView {
    /** Put a pin in the map with the user location. Remove all previous pins */
    func setPinInTheMapAtCoordinate(coordinate: CLLocationCoordinate2D, title: String? = nil) {
        self.removeAnnotations(self.annotations)
        let pin = MKPointAnnotation()
        pin.coordinate = coordinate
        if (title != nil) { pin.title = title }
        self.addAnnotation(pin)
    }

    /** Add a pin in the map with the user location. */
    func addPinToTheMapAtCoordinate(coordinate: CLLocationCoordinate2D, title: String? = nil) {
        let pin = MKPointAnnotation()
        pin.coordinate = coordinate
        if (title != nil) { pin.title = title }
        self.addAnnotation(pin)
    }

}