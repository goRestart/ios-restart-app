//
//  EditUserLocationViewController.swift
//  LetGo
//
//  Created by Dídac on 12/08/15.
//  Copyright (c) 2015 Ambatana. All rights reserved.
//

import UIKit
import MapKit

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
    

    // MARK : - Lifecycle
    
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

        // Do any additional setup after loading the view.
        
        setupUI()

    }
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
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
//        viewModel.applyLocation()
    }
    
    
    // MARK : - private methods

    func viewModel(viewModel: EditUserLocationViewModel, updateTextFieldWithString locationName: String) {
        self.searchField.text = locationName
    }

 
    func viewModel(viewModel: EditUserLocationViewModel, updateSearchTableWithResults results: [String]) {

        var newHeight = CGFloat(results.count*44)
        suggestionsTableView.frame = CGRectMake(suggestionsTableView.frame.origin.x, suggestionsTableView.frame.origin.y, suggestionsTableView.frame.size.width, newHeight);
        suggestionsTableView.hidden = false
        suggestionsTableView.reloadData()
    }
    
    func viewModel(viewModel: EditUserLocationViewModel, centerMapInLocation location: CLLocationCoordinate2D, approximate: Bool) {
        centerMapInLocation(location, approximate: approximate)
        viewModel.goingToLocation = false
    }
    
    func centerMapInLocation(coordinate: CLLocationCoordinate2D, approximate: Bool) {
        // set map region
        mapView.removeAnnotations(mapView.annotations)
        mapView.removeOverlays(mapView.overlays)
        
//        var regionRadius = (accurate)?Constants.accurateRegionRadius:Constants.nonAccurateRegionRadius
        
        if !approximate {
            let region = MKCoordinateRegionMakeWithDistance(coordinate, Constants.accurateRegionRadius, Constants.accurateRegionRadius)
            self.mapView.setRegion(region, animated: true)
            var annotation = MKPointAnnotation()
            annotation.coordinate = coordinate
            annotation.title = viewModel.searchText
            annotation.subtitle = "test"
            
            mapView.addAnnotation(annotation)
        }
        else {
            let region = MKCoordinateRegionMakeWithDistance(coordinate, Constants.nonAccurateRegionRadius, Constants.nonAccurateRegionRadius)
            mapView.setRegion(region, animated: true)
            
            // add an overlay (actually drawn at mapView(mapView:,rendererForOverlay))
            let circle = MKCircle(centerCoordinate:coordinate, radius: Constants.nonAccurateRegionRadius*0.40)
            mapView.addOverlay(circle)
        }
        
        

    }
    
    // MARK : - MapView methods
    
    
    func mapView(mapView: MKMapView!, viewForAnnotation annotation: MKAnnotation!) -> MKAnnotationView! {
        
        var newAnnotationView = MKAnnotationView(annotation: annotation, reuseIdentifier: "annotationViewID")
        newAnnotationView.image = UIImage(named: "map_pin")
        newAnnotationView.annotation = annotation
        newAnnotationView.canShowCallout = true

        return newAnnotationView
    }
    
    
    func mapView(mapView: MKMapView!, rendererForOverlay overlay: MKOverlay!) -> MKOverlayRenderer! {
        if overlay is MKCircle {
            let renderer = MKCircleRenderer(overlay: overlay)
            renderer.fillColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.10)
//            renderer.strokeColor = UIColor.redColor()
            renderer.lineWidth = 1
            return renderer
        }
        return nil;
    }
    
    
    // MARK : - textFieldDelegate methods

    override func touchesBegan(touches: Set<NSObject>, withEvent event: UIEvent) {
        searchField.resignFirstResponder()
        super.touchesBegan(touches, withEvent: event)
    }

    func textField(textField: UITextField, shouldChangeCharactersInRange range: NSRange, replacementString string: String) -> Bool {
        let searchText = (textField.text as NSString).stringByReplacingCharactersInRange(range, withString: string)
        viewModel.searchText = searchText
        // get locations and update table
        
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
    
    
    // MARK : UITableViewDelegate Methods
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return viewModel.predictiveResults.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {

        let cell = tableView.dequeueReusableCellWithIdentifier("cell", forIndexPath: indexPath) as! UITableViewCell
        
        cell.textLabel!.text = viewModel.predictiveResults[indexPath.row].placeResumedData
        cell.selectionStyle = .None
        
        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        self.searchField.text = viewModel.predictiveResults[indexPath.row].placeResumedData
        viewModel.goingToLocation = true
        viewModel.searchText = self.searchField.text
        suggestionsTableView.hidden = true
        goToLocation()
    }
    
    
    
    private func setupUI() {
        
        searchField.insetX = 40
        searchField.placeholder = "_Enter city or postal code"
        searchField.layer.cornerRadius = 4
        searchField.layer.borderColor = UIColor.lightGrayColor().CGColor
        searchField.layer.borderWidth = 1
        
        gpsLocationButton.layer.cornerRadius = 10
        
        self.setLetGoNavigationBarStyle(title: "_Set Your Location" ?? UIImage(named: "navbar_logo"))
        
        applyBarButton = UIBarButtonItem(title: "_Apply", style: UIBarButtonItemStyle.Plain, target: self, action: Selector("applyBarButtonPressed"))
        self.navigationItem.rightBarButtonItem = applyBarButton;

        suggestionsTableView.registerClass(UITableViewCell.self, forCellReuseIdentifier: "cell")
        
//        mapView.region = MKCoordinateRegionMakeWithDistance(CLLocationCoordinate2D(), Constants.nonAccurateRegionRadius, Constants.nonAccurateRegionRadius)

//        viewModel.showInitialUserLocation()
    }
    

    
}
