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
    
    static let annotationLabelMaxWidth : CGFloat = 200.0
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        hidesBottomBarWhenPushed = true
        
        super.viewDidLoad()
        self.setLetGoNavigationBarStyle(title: NSLocalizedString("product_location_title", comment: ""))
        
        if location != nil {
            // set map region
            let coordinate = CLLocationCoordinate2D(latitude: location!.latitude, longitude: location!.longitude)
            let region = MKCoordinateRegionMakeWithDistance(coordinate, Constants.nonAccurateRegionRadius, Constants.nonAccurateRegionRadius)
            mapView.setRegion(region, animated: true)
            
            // add an overlay (actually drawn at mapView(mapView:,rendererForOverlay))
            let circle = MKCircle(centerCoordinate:coordinate, radius: Constants.nonAccurateRegionRadius*0.40)
            mapView.addOverlay(circle)
            
            // annotation
            
            var annotation = MKPointAnnotation()
            annotation.coordinate = coordinate
            annotation.title = annotationTitle
            annotation.subtitle = annotationSubtitle
            
            mapView.addAnnotation(annotation)
            mapView.selectAnnotation(annotation, animated: true)
        }
    }
    
    // MARK: - MKMapViewDelegate
    
    func mapView(mapView: MKMapView!, viewForAnnotation annotation: MKAnnotation!) -> MKAnnotationView! {
        
        var newAnnotationView = MKAnnotationView(annotation: annotation, reuseIdentifier: "annotationViewID")
        newAnnotationView.image = UIImage()
        newAnnotationView.annotation = annotation
        newAnnotationView.canShowCallout = false
        
        return newAnnotationView
    }

    
    func mapView(mapView: MKMapView!, rendererForOverlay overlay: MKOverlay!) -> MKOverlayRenderer! {
        if overlay is MKCircle {
            let renderer = MKCircleRenderer(overlay: overlay)
            renderer.fillColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.10)
            return renderer
        }
        return nil;
    }

    func mapView(mapView: MKMapView!, didSelectAnnotationView view: MKAnnotationView!) {
        
        // get size of title label
        var titleLabel = UILabel(frame: CGRect(x: 0, y: 0, width: ProductLocationViewController.annotationLabelMaxWidth-20, height: 25))
        titleLabel.text = annotationTitle
        titleLabel.textAlignment = .Center
        titleLabel.numberOfLines = 0
        titleLabel.sizeToFit()
        
        // get size of subtitle label
        var subtitleLabel = UILabel(frame: CGRect(x: 0, y: 0, width: ProductLocationViewController.annotationLabelMaxWidth-20, height: 25))
        subtitleLabel.text = annotationSubtitle
        subtitleLabel.textAlignment = .Center
        subtitleLabel.textColor = StyleHelper.lineColor
        subtitleLabel.numberOfLines = 0
        subtitleLabel.sizeToFit()
        
        // set frame of callout view
        var calloutFrame = titleLabel.frame
        calloutFrame.size.width = ProductLocationViewController.annotationLabelMaxWidth
        calloutFrame.size.height = titleLabel.frame.size.height + subtitleLabel.frame.size.height + 20
        
        var calloutView = UIView(frame: calloutFrame)
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