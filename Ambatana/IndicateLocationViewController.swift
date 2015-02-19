//
//  IndicateLocationViewController.swift
//  Ambatana
//
//  Created by Nacho on 06/02/15.
//  Copyright (c) 2015 Ignacio Nieto Carvajal. All rights reserved.
//

import UIKit
import QuartzCore
import MapKit

class IndicateLocationViewController: UIViewController, MKMapViewDelegate, UIGestureRecognizerDelegate, UITextFieldDelegate {
    // outlets & buttons
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var searchContentView: UIView!
    @IBOutlet weak var searchTextField: UITextField!
    @IBOutlet weak var setLocationBarButtonItem: UIBarButtonItem!
    @IBOutlet weak var keepFingerPressedLabel: UILabel!
    
    // data
    var locationInMap: CLLocationCoordinate2D = kCLLocationCoordinate2DInvalid {
        didSet {
            self.setLocationBarButtonItem.enabled = true
        }
    }
    let geocoder = CLGeocoder()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.searchTextField.delegate = self
        
        // UX/UI
        self.setAmbatanaNavigationBarStyle(title: translate("change_your_location"), includeBackArrow: false)
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
        self.setLocationBarButtonItem.enabled = false

        NSNotificationCenter.defaultCenter().addObserver(self, selector: "unableToSetUserLocation:", name: kAmbatanaUnableToSetUserLocationNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "userLocationSet:", name: kAmbatanaUserLocationSuccessfullySetNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "userLocationSet:", name: kAmbatanaUserLocationSuccessfullyChangedNotification, object: nil)
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - Buttons and touch interactions
    
    @IBAction func setLocation(sender: AnyObject) {
        if CLLocationCoordinate2DIsValid(locationInMap) {
            enableLoadingStatus()
            LocationManager.sharedInstance.userSpecifiedLocationDirectly(locationInMap)
        } else {
            let alert = UIAlertController(title: translate("error"), message: translate("select_valid_location"), preferredStyle:.Alert)
            alert.addAction(UIAlertAction(title: translate("ok"), style:.Default, handler: nil))
            self.presentViewController(alert, animated: true, completion: nil)
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
        if countElements(textField.text) < 1 { return true }
        
        self.enableLoadingStatus()
        geocoder.geocodeAddressString(textField.text, completionHandler: { (placemarks, error) -> Void in
            var coordinate: CLLocationCoordinate2D?
            if (placemarks != nil && placemarks.count > 0) {
                let placemark = placemarks.first as CLPlacemark
                if placemark.location != nil {
                    coordinate = placemark.location.coordinate
                }
            }
            if coordinate != nil && CLLocationCoordinate2DIsValid(coordinate!) {
                self.locationInMap = coordinate!
                // set map region
                let region = MKCoordinateRegionMakeWithDistance(coordinate!, 1000, 1000)
                self.mapView.setRegion(region, animated: true)
                // add pin
                self.mapView.setPinInTheMapAtCoordinate(coordinate!, title: translate("i_am_here"))
            } else {
                self.showAutoFadingOutMessageAlert(translate("unable_find_location"))
            }
            self.disableLoadingStatus()
        })
        return true
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
    
    // MARK: - Notifications for listening to the user's revese geolocation attempt.
    
    func unableToSetUserLocation(notification: NSNotification) {
        let alert = UIAlertController(title: translate("error"), message: translate("unable_set_location"), preferredStyle:.Alert)
        alert.addAction(UIAlertAction(title: translate("ok"), style:.Default, handler: nil))
        self.presentViewController(alert, animated: true, completion: nil)
        disableLoadingStatus()
    }
    
    func userLocationSet(notification: NSNotification) {
        disableLoadingStatus()
        let alert = UIAlertController(title: translate("success"), message: translate("stored_your_location"), preferredStyle:.Alert)
        alert.addAction(UIAlertAction(title: translate("ok"), style: .Default, handler: { (action) -> Void in
            self.dismissViewControllerAnimated(true, completion: nil)
        }))
        self.presentViewController(alert, animated: true, completion: nil)
        
    }
}




















