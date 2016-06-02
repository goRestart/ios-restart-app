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
    var annotationTitle : String?
    var annotationSubtitle : String?
    var timer: NSTimer?
    var minLongitudeDelta: CLLocationDegrees?
    var minLatitudeDelta: CLLocationDegrees?
    var isResettingRegion: Bool = false
    
    static let annotationLabelMaxWidth : CGFloat = 200.0
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        hidesBottomBarWhenPushed = true
        
        super.viewDidLoad()
        self.setLetGoNavigationBarStyle(LGLocalizedString.productLocationTitle)
        
        if location != nil {
            // set map region
            let coordinate = CLLocationCoordinate2D(latitude: location!.latitude, longitude: location!.longitude)
            let region = MKCoordinateRegionMakeWithDistance(coordinate, Constants.nonAccurateRegionRadius, Constants.nonAccurateRegionRadius)
            mapView.setRegion(region, animated: true)
            
            minLongitudeDelta = region.span.longitudeDelta
            minLatitudeDelta = region.span.latitudeDelta
            
            // add an overlay (actually drawn at mapView(mapView:,rendererForOverlay))
            let circle = MKCircle(centerCoordinate:coordinate, radius: Constants.nonAccurateRegionRadius*0.40)
            mapView.addOverlay(circle)
            
            // annotation
            
            let annotation = MKPointAnnotation()
            annotation.coordinate = coordinate
            annotation.title = annotationTitle
            annotation.subtitle = annotationSubtitle
            
            mapView.addAnnotation(annotation)
            mapView.selectAnnotation(annotation, animated: true)
        }
    }

    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        UIApplication.sharedApplication().setStatusBarStyle(.Default, animated: true)
    }
    
    
    // MARK: - Limit zoom in
    
    /**
     When the region change starts (user starts pinching), create a timer to observe the region changes
     This method belongs to MKMapViewDelegate
     */
    func mapView(mapView: MKMapView, regionWillChangeAnimated animated: Bool) {
        timer = NSTimer.scheduledTimerWithTimeInterval(0.2, target: self, selector: #selector(ProductLocationViewController.resetRegionDelta),
            userInfo: nil, repeats: true)
    }
    
    /**
     When the region change ends (user ends pinching), invalidate the timer and try to reset the region again
     just in case it was stuck in an invalid state.
     This method belongs to MKMapViewDelegate
     */
    func mapView(mapView: MKMapView, regionDidChangeAnimated animated: Bool) {
        timer?.invalidate()
        resetRegionDelta()
        isResettingRegion = false
    }
    
    /**
     If the user did try to zoom in more than allowed, reset the region span to the original one. 
     If the view is already resetting, this func will just return.
     The reset will be animated.
     This will also reset any rotation in the map.
     */
    func resetRegionDelta() {
        guard !isResettingRegion else { return }
        guard shouldForceResetMapRegion() else { return }
        
        let newRegion = resetRegion(mapView.region)
        mapView.setRegion(newRegion, animated: true)
        isResettingRegion = true
    }
    
    /**
     Calculate whether or not the MapRegion should be resetted according to the current Span and the minimum allowed
     */
    func shouldForceResetMapRegion() -> Bool {
        guard let minLat = minLatitudeDelta, let minLon = minLongitudeDelta else { return false }
        let mapLat = mapView.region.span.latitudeDelta
        let mapLon = mapView.region.span.longitudeDelta
        return mapLat < minLat || mapLon < minLon
    }
    
    /**
     Given a MKCoordinateRegion, creates a new one with the `span` resetted to the allowed minimum deltas.
     */
    func resetRegion(region: MKCoordinateRegion) -> MKCoordinateRegion {
        var newRegion = region
        if let minLatitude = minLatitudeDelta, let minLongitude = minLongitudeDelta {
            newRegion.span.latitudeDelta = minLatitude
            newRegion.span.longitudeDelta = minLongitude
        }
        return newRegion
    }
    
    
    // MARK: - MKMapViewDelegate
    
    func mapView(mapView: MKMapView, viewForAnnotation annotation: MKAnnotation) -> MKAnnotationView? {
        
        let newAnnotationView = MKAnnotationView(annotation: annotation, reuseIdentifier: "annotationViewID")
        newAnnotationView.image = UIImage()
        newAnnotationView.annotation = annotation
        newAnnotationView.canShowCallout = false
        
        return newAnnotationView
    }

    
    func mapView(mapView: MKMapView, rendererForOverlay overlay: MKOverlay) -> MKOverlayRenderer {
        if overlay is MKCircle {
            let renderer = MKCircleRenderer(overlay: overlay)
            renderer.fillColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.10)
            return renderer
        }
        return MKCircleRenderer()
    }

    func mapView(mapView: MKMapView, didSelectAnnotationView view: MKAnnotationView) {
        
        // get size of title label
        let titleLabel = UILabel(frame: CGRect(x: 0, y: 0, width: ProductLocationViewController.annotationLabelMaxWidth-20, height: 25))
        titleLabel.text = annotationTitle
        titleLabel.textAlignment = .Center
        titleLabel.numberOfLines = 0
        titleLabel.sizeToFit()
        
        // get size of subtitle label
        let subtitleLabel = UILabel(frame: CGRect(x: 0, y: 0, width: ProductLocationViewController.annotationLabelMaxWidth-20, height: 25))
        subtitleLabel.text = annotationSubtitle
        subtitleLabel.textAlignment = .Center
        subtitleLabel.textColor = StyleHelper.lineColor
        subtitleLabel.numberOfLines = 0
        subtitleLabel.sizeToFit()
        
        // set frame of callout view
        var calloutFrame = titleLabel.frame
        calloutFrame.size.width = ProductLocationViewController.annotationLabelMaxWidth
        calloutFrame.size.height = titleLabel.frame.size.height + subtitleLabel.frame.size.height + 20
        
        let calloutView = UIView(frame: calloutFrame)
        calloutView.backgroundColor = UIColor.whiteColor()
        calloutView.layer.cornerRadius = 5
        
        calloutView.addSubview(titleLabel)
        calloutView.addSubview(subtitleLabel)
        
        titleLabel.sizeThatFits(calloutView.frame.size)
        subtitleLabel.sizeThatFits(calloutView.frame.size)
        
        let titleCenterOffset = titleLabel.frame.size.height/2+10
        let subtitleCenterOffset = subtitleLabel.frame.size.height/2+10
        
        titleLabel.center = CGPoint(x: calloutView.center.x, y: titleCenterOffset)
        subtitleLabel.center = CGPoint(x: calloutView.center.x, y: calloutView.frame.size.height-subtitleCenterOffset)

        calloutView.center = view.calloutOffset
        
        view.addSubview(calloutView)
        
    }

}