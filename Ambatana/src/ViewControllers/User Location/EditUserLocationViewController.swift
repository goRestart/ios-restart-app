//
//  EditUserLocationViewController.swift
//  LetGo
//
//  Created by Dídac on 12/08/15.
//  Copyright (c) 2015 Ambatana. All rights reserved.
//

import UIKit
import MapKit
import LGCoreKit
import Result

class EditUserLocationViewController: BaseViewController, EditUserLocationViewModelDelegate, MKMapViewDelegate, UITextFieldDelegate, UITableViewDataSource, UITableViewDelegate {

    // UI
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var searchField: LGTextField!
    
    @IBOutlet weak var approximateLocationSwitch: UISwitch!
    @IBOutlet weak var approximateLocationLabel: UILabel!

    @IBOutlet weak var gpsLocationButton: UIButton!
    @IBOutlet weak var searchButton: UIButton!

    @IBOutlet weak var suggestionsTableView : UITableView!
    
    var applyBarButton : UIBarButtonItem!
    
    
    // ViewModel
    var viewModel : EditUserLocationViewModel!
    

    // MARK: - Lifecycle
    
    init() {
        self.viewModel = EditUserLocationViewModel()
        super.init(viewModel: nil, nibName: "EditUserLocationViewController")
        self.viewModel.delegate = self
    }

    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupUI()
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        approximateLocationSwitch.on = viewModel.approximateLocation
        viewModel.showInitialUserLocation()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    @IBAction func searchButtonPressed() {
        goToLocation()
    }

    @IBAction func gpsLocationButtonPressed() {
        viewModel.showGPSUserLocation()
    }

    @IBAction func approximateLocationSwitchChanged() {
        viewModel.approximateLocation = approximateLocationSwitch.on
        viewModel.updateApproximateSwitchChanged()
    }

    func goToLocation() {
        viewModel.goToLocation()
    }
    
    
    func applyBarButtonPressed() {
        viewModel.applyLocation()
        self.popBackViewController()
    }
    
    
    // MARK: - view model delegate methods
    
    func viewModelDidStartSearchingLocation(viewModel: EditUserLocationViewModel) {
        showLoadingMessageAlert()
    }

    func viewModel(viewModel: EditUserLocationViewModel, updateTextFieldWithString locationName: String) {
        self.searchField.text = locationName
    }

 
    func viewModel(viewModel: EditUserLocationViewModel, updateSearchTableWithResults results: [String]) {

        var newHeight = CGFloat(results.count*44)
        suggestionsTableView.frame = CGRectMake(suggestionsTableView.frame.origin.x, suggestionsTableView.frame.origin.y, suggestionsTableView.frame.size.width, newHeight);
        suggestionsTableView.hidden = false
        suggestionsTableView.reloadData()
    }
    
    func viewModelDidFailFindingSuggestions(viewModel: EditUserLocationViewModel) {
        suggestionsTableView.hidden = true
    }

    
    func viewModel(viewModel: EditUserLocationViewModel, didFailToFindLocationWithResult result: Result<[Place], SearchLocationSuggestionsServiceError>) {
        
        var completion: (() -> Void)? = nil
        
        switch (result) {
        case .Success:
            completion = {
                self.showAutoFadingOutMessageAlert(NSLocalizedString("change_location_error_search_location_message", comment: ""))
            }
            break
        case .Failure(let error):
            let message: String
            switch (error.value) {
            case .Network:
                message = NSLocalizedString("change_location_error_search_location_message", comment: "")
            case .Internal:
                message = NSLocalizedString("change_location_error_search_location_message", comment: "")
            case .UnknownLocation:
                message = String(format: NSLocalizedString("change_location_error_unknown_location_message", comment: ""), arguments: [searchField.text])
            }
            completion = {
                self.showAutoFadingOutMessageAlert(message)
            }
        }
        
        dismissLoadingMessageAlert(completion: completion)
    }

    
    func viewModel(viewModel: EditUserLocationViewModel, centerMapInLocation location: CLLocationCoordinate2D, withPostalAddress postalAddress: PostalAddress?, approximate: Bool) {
        dismissLoadingMessageAlert()
        centerMapInLocation(location, withPostalAddress: postalAddress, approximate: approximate)
        viewModel.goingToLocation = false
    }
    
    
    // MARK: - MapView methods
    
    func mapView(mapView: MKMapView!, viewForAnnotation annotation: MKAnnotation!) -> MKAnnotationView! {
        
        var newAnnotationView = MKAnnotationView(annotation: annotation, reuseIdentifier: "annotationViewID")
        newAnnotationView.image = UIImage(named: "map_pin")
        newAnnotationView.layer.anchorPoint = CGPoint(x: 0.5, y: 1.0)
        newAnnotationView.annotation = annotation
        newAnnotationView.canShowCallout = true

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
    
    
    // MARK: - textFieldDelegate methods

    
    // "touchesBegan" used to hide the keyboard when touching outside the textField
    
    override func touchesBegan(touches: Set<NSObject>, withEvent event: UIEvent) {
        searchField.resignFirstResponder()
        super.touchesBegan(touches, withEvent: event)
    }

    func textField(textField: UITextField, shouldChangeCharactersInRange range: NSRange, replacementString string: String) -> Bool {
        let searchText = (textField.text as NSString).stringByReplacingCharactersInRange(range, withString: string)
        
        if searchText.isEmpty {
            suggestionsTableView.hidden = true
        }
        
        viewModel.searchText = searchText
        
        return true
    }
    
    func textFieldDidEndEditing(textField: UITextField) {
        suggestionsTableView.hidden = true
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        
        if count(textField.text) < 1 { return true }

        suggestionsTableView.hidden = true

        goToLocation()
        
        return true
    }
    
    func textFieldShouldClear(textField: UITextField) -> Bool {
        suggestionsTableView.hidden = true
        
        return true
    }
    
    
    // MARK: UITableViewDelegate Methods
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return viewModel.predictiveResults.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {

        let cell = tableView.dequeueReusableCellWithIdentifier("cell", forIndexPath: indexPath) as! UITableViewCell
        
        cell.textLabel!.text = viewModel.placeResumedDataAtPosition(indexPath.row)
        cell.selectionStyle = .None
        
        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        self.searchField.text = viewModel.placeResumedDataAtPosition(indexPath.row)
        suggestionsTableView.hidden = true

        viewModel.goingToLocation = true
        viewModel.searchText = self.searchField.text
        goToLocation()
    }
    
    // MARK : - private methods
    
    private func setupUI() {
        
        searchField.insetX = 40
        searchField.placeholder = NSLocalizedString("change_location_search_field_hint", comment: "")
        searchField.layer.cornerRadius = 4
        searchField.layer.borderColor = UIColor.lightGrayColor().CGColor
        searchField.layer.borderWidth = 1

        approximateLocationLabel.text = NSLocalizedString("change_location_approximate_location_label", comment: "")
        
        gpsLocationButton.layer.cornerRadius = 10
        
        self.setLetGoNavigationBarStyle(title: NSLocalizedString("change_location_title", comment: "") ?? UIImage(named: "navbar_logo"))
        
        applyBarButton = UIBarButtonItem(title: NSLocalizedString("change_location_apply_button", comment: ""), style: UIBarButtonItemStyle.Plain, target: self, action: Selector("applyBarButtonPressed"))
        self.navigationItem.rightBarButtonItem = applyBarButton;

        suggestionsTableView.registerClass(UITableViewCell.self, forCellReuseIdentifier: "cell")
        
    }
    
    private func centerMapInLocation(coordinate: CLLocationCoordinate2D, withPostalAddress postalAddress: PostalAddress?, approximate: Bool) {
        
        mapView.removeAnnotations(mapView.annotations)
        mapView.removeOverlays(mapView.overlays)
        
        if !approximate {
            let region = MKCoordinateRegionMakeWithDistance(coordinate, Constants.accurateRegionRadius, Constants.accurateRegionRadius)
            self.mapView.setRegion(region, animated: true)
            
            var annotation = MKPointAnnotation()
            annotation.coordinate = coordinate
            if let title = postalAddress?.address {
                annotation.title = title
            }
            var subtitle = ""
            if let zipCode = postalAddress?.zipCode {
                subtitle += zipCode
            }
            if let city = postalAddress?.city {
                if !subtitle.isEmpty {
                    subtitle += " "
                }
                subtitle += city
            }
            annotation.subtitle = subtitle
            
            mapView.addAnnotation(annotation)
            mapView.selectAnnotation(annotation, animated: true)
            
        }
        else {
            let region = MKCoordinateRegionMakeWithDistance(coordinate, Constants.nonAccurateRegionRadius, Constants.nonAccurateRegionRadius)
            mapView.setRegion(region, animated: true)
            
            // add an overlay (actually drawn at mapView(mapView:,rendererForOverlay))
            let circle = MKCircle(centerCoordinate:coordinate, radius: Constants.nonAccurateRegionRadius*0.40)
            mapView.addOverlay(circle)
        }
    }
}
