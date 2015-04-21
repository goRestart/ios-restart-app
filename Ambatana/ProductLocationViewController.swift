//
//  ProductLocationViewController.swift
//  LetGo
//
//  Created by AHL on 11/3/15.
//  Copyright (c) 2015 Ignacio Nieto Carvajal. All rights reserved.
//

import Foundation
import MapKit
import UIKit

class ProductLocationViewController: UIViewController, MKMapViewDelegate {
    
    // UI
    @IBOutlet weak var mapView: MKMapView!
    
    // Data
    var location: CLLocationCoordinate2D?
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setLetGoNavigationBarStyle(title: translate("item_location"), includeBackArrow: true)
        
        if location != nil {
            // set map region
            let coordinate = CLLocationCoordinate2D(latitude: location!.latitude, longitude: location!.longitude)
            let region = MKCoordinateRegionMakeWithDistance(coordinate, 2000, 2000)
            mapView.setRegion(region, animated: true)
            
            // add an overlay (actually drawn at mapView(mapView:,rendererForOverlay))
            let circle = MKCircle(centerCoordinate:coordinate, radius: 500)
            mapView.addOverlay(circle)
        }
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        TrackingManager.sharedInstance.trackEvent(kLetGoTrackingEventNameScreenPrivate, eventParameter: kLetGoTrackingParameterNameScreenName, eventValue: "product-location-detail")
    }
    
    // MARK: - MKMapViewDelegate
    
    func mapView(mapView: MKMapView!, rendererForOverlay overlay: MKOverlay!) -> MKOverlayRenderer! {
        if overlay is MKCircle {
            let renderer = MKCircleRenderer(overlay: overlay)
            renderer.fillColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.20)
            renderer.strokeColor = UIColor.redColor()
            renderer.lineWidth = 1
            return renderer
        }
        return nil;
    }
}