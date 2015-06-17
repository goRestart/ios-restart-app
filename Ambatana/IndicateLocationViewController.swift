//
//  IndicateLocationViewController.swift
//  LetGo
//
//  Created by Ignacio Nieto Carvajal on 06/02/15.
//  Copyright (c) 2015 Ignacio Nieto Carvajal. All rights reserved.
//

import Bolts
import LGCoreKit
import UIKit
import QuartzCore
import MapKit
import Result

protocol IndicateLocationViewControllerDelegate: class {
    func userDidManuallySetCoordinates(coordinates: CLLocationCoordinate2D)
}

class IndicateLocationViewController: UIViewController, MKMapViewDelegate, UIGestureRecognizerDelegate, UITextFieldDelegate, UIAlertViewDelegate {
    // outlets & buttons
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var searchContentView: UIView!
    @IBOutlet weak var searchTextField: UITextField!
    @IBOutlet weak var setLocationBarButtonItem: UIBarButtonItem!
    @IBOutlet weak var keepFingerPressedLabel: UILabel!
    
    weak var delegate: IndicateLocationViewControllerDelegate?
    
    // data
    var locationInMap: CLLocationCoordinate2D = kCLLocationCoordinate2DInvalid {
        didSet {
            self.setLocationBarButtonItem.enabled = true
        }
    }
    let geocoder = CLGeocoder()
    var allowGoingBack = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.searchTextField.delegate = self
        
        // UX/UI
        self.setLetGoNavigationBarStyle(title: translate("change_your_location"))
        
        searchContentView.layer.shadowColor = UIColor.grayColor().CGColor
        searchContentView.layer.shadowOffset = CGSizeMake(0, 2)
        searchContentView.layer.shadowOpacity = 0.75
        
        // Set long pressure gesture recognizer
        let longPressureGestureRecognizer = UILongPressGestureRecognizer(target: self, action: "longPressRecognized:")
        longPressureGestureRecognizer.delegate = self
        longPressureGestureRecognizer.minimumPressDuration = 1.5
        mapView.addGestureRecognizer(longPressureGestureRecognizer)
        
        // localization
        searchTextField.placeholder = translate("write_your_address")
        keepFingerPressedLabel.text = translate("keep_finger_pressed")
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        disableLoadingStatus()

        // if we have a current location (we are accessing through the "Change my location" option in settings, start with that location.
        var initialLocation: CLLocationCoordinate2D?
        if LocationManager.sharedInstance.lastKnownLocation != nil {
            initialLocation = LocationManager.sharedInstance.lastKnownLocation!.coordinate
        }

        // do we have an initial location?
        if initialLocation != nil && CLLocationCoordinate2DIsValid(initialLocation!) {
            self.locationInMap = initialLocation!
            self.centerMapInLocation(initialLocation!, andIncludePin: true)
        }
    }
    
    // MARK: - Buttons and touch interactions
    
    @IBAction func setLocation(sender: AnyObject) {
        if CLLocationCoordinate2DIsValid(locationInMap) {
            
            // Show loading
            enableLoadingStatus()

            // Save the user coordinates / address in the backend and when finished the pop
            MyUserManager.sharedInstance.saveUserCoordinates(locationInMap) { [weak self] (result: Result<CLLocationCoordinate2D, SaveUserCoordinatesError>) in
                if let strongSelf = self {
                    
                    // Hide loading
                    strongSelf.disableLoadingStatus()
                    
                    // Success
                    if let coordinates = result.value {
                        strongSelf.delegate?.userDidManuallySetCoordinates(strongSelf.locationInMap)
                        strongSelf.dismissViewControllerAnimated(true, completion: nil)
                    }
                }
            }
        }
        else {
            if iOSVersionAtLeast("8.0") {
                let alert = UIAlertController(title: translate("error"), message: translate("select_valid_location"), preferredStyle:.Alert)
                alert.addAction(UIAlertAction(title: translate("ok"), style:.Default, handler: nil))
                self.presentViewController(alert, animated: true, completion: nil)
            } else {
                let alert = UIAlertView(title: translate("error"), message: translate("select_valid_location"), delegate: nil, cancelButtonTitle: translate("ok"))
                alert.show()
            }
        }
    }
    
    func longPressRecognized(gestureRecognizer: UILongPressGestureRecognizer) {
        if (gestureRecognizer.state == .Began) {
            // calculate location CLLocationCoordinate2D and center map upon it.
            locationInMap = mapView.convertPoint(gestureRecognizer.locationInView(mapView), toCoordinateFromView: mapView)
            mapView.setCenterCoordinate(locationInMap, animated: true)
            self.mapView.setPinInTheMapAtCoordinate(locationInMap, title: translate("i_am_here"))
        }
    }
    
    // MARK: - Search textfield interactions
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        self.view.endEditing(true)
        if count(textField.text) < 1 { return true }
        
        self.enableLoadingStatus()
        geocoder.geocodeAddressString(textField.text, completionHandler: { (placemarks, error) -> Void in
            var coordinate: CLLocationCoordinate2D?
            if (placemarks != nil && placemarks.count > 0) {
                let placemark = placemarks.first as! CLPlacemark
                if placemark.location != nil {
                    coordinate = placemark.location.coordinate
                }
            }
            if coordinate != nil && CLLocationCoordinate2DIsValid(coordinate!) {
                self.centerMapInLocation(coordinate!, andIncludePin: true)
            } else {
                self.showAutoFadingOutMessageAlert(translate("unable_find_location"))
            }
            self.disableLoadingStatus()
        })
        return true
    }
    
    func centerMapInLocation(coordinate: CLLocationCoordinate2D, andIncludePin includePin: Bool) {
        self.locationInMap = coordinate
        // set map region
        let region = MKCoordinateRegionMakeWithDistance(coordinate, 1000, 1000)
        self.mapView.setRegion(region, animated: true)
        // add pin
        if includePin { self.mapView.setPinInTheMapAtCoordinate(coordinate, title: translate("i_am_here")) }
    }
    
    
    // MARK: - Loading and unloading status for the UI
    
    func enableLoadingStatus() {
        setLocationBarButtonItem.enabled = false
        searchTextField.userInteractionEnabled = false
        mapView.userInteractionEnabled = false
        activityIndicator.hidden = false
        activityIndicator.startAnimating()
    }
    
    func disableLoadingStatus() {
        setLocationBarButtonItem.enabled = true
        searchTextField.userInteractionEnabled = true
        mapView.userInteractionEnabled = true
        activityIndicator.stopAnimating()
        activityIndicator.hidden = true
    }
    
//    // MARK: - Notifications for listening to the user's revese geolocation attempt.
//    
//    func unableToSetUserLocation(notification: NSNotification) {
//        if iOSVersionAtLeast("8.0") {
//            let alert = UIAlertController(title: translate("error"), message: translate("unable_set_location"), preferredStyle:.Alert)
//            alert.addAction(UIAlertAction(title: translate("ok"), style:.Default, handler: nil))
//            self.presentViewController(alert, animated: true, completion: nil)
//        } else {
//            let alert = UIAlertView(title: translate("error"), message: translate("unable_set_location"), delegate: nil, cancelButtonTitle: translate("ok"))
//            alert.show()
//        }
//        
//        disableLoadingStatus()
//    }
//    
//    func userLocationSet(notification: NSNotification) {
//        disableLoadingStatus()
//        if iOSVersionAtLeast("8.0") {
//            let alert = UIAlertController(title: translate("success"), message: translate("stored_your_location"), preferredStyle:.Alert)
//            alert.addAction(UIAlertAction(title: translate("ok"), style: .Default, handler: { (action) -> Void in
//                self.popBackViewController()
//            }))
//            self.presentViewController(alert, animated: true, completion: nil)
//        } else {
//            let alert = UIAlertView(title: translate("message"), message: translate("stored_your_location"), delegate: self, cancelButtonTitle: translate("ok"))
//            alert.show()
//        }
//        
//    }
    
    func alertView(alertView: UIAlertView, didDismissWithButtonIndex buttonIndex: Int) { dismissViewControllerAnimated(true, completion: nil) }
}




















