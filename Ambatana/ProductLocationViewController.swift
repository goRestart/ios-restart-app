//
//  ProductLocationViewController.swift
//  Ambatana
//
//  Created by AHL on 11/3/15.
//  Copyright (c) 2015 Ambatana. All rights reserved.
//

import Foundation
import MapKit
import UIKit

class ProductLocationViewController: UIViewController, MKMapViewDelegate {
    
    // UI
    @IBOutlet weak var mapView: MKMapView!
    
    // Data
    let location: CLLocationCoordinate2D?
    
    // MARK: - Lifecycle
    
    init(location: CLLocationCoordinate2D) {
        self.location = location
        super.init(nibName: "ProductLocationViewController", bundle: nil)
    }
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setAmbatanaNavigationBarStyle(title: translate("item_location"), includeBackArrow: true)
        
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
    
    // MARK: - MKMapViewDelegate
    
    func mapView(mapView: MKMapView!, rendererForOverlay overlay: MKOverlay!) -> MKOverlayRenderer! {
        if overlay is MKCircle {
            let renderer = MKCircleRenderer(overlay: overlay)
            renderer.fillColor = UIColor(red: 0.6, green: 0.6, blue: 0.6, alpha: 0.5)
            renderer.strokeColor = UIColor.redColor()
            renderer.lineWidth = 1 * UIScreen.mainScreen().scale
            return renderer
        }
        return nil;
    }
}