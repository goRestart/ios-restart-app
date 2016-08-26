//
//  EditLocationViewController.swift
//  LetGo
//
//  Created by Dídac on 12/08/15.
//  Copyright (c) 2015 Ambatana. All rights reserved.
//

import UIKit
import MapKit
import LGCoreKit
import RxSwift
import RxCocoa
import Result

class EditLocationViewController: BaseViewController, EditLocationViewModelDelegate {

    // UI
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var searchField: LGTextField!
    
    @IBOutlet weak var approxLocationContainer: UIView!
    @IBOutlet weak var approxLocationHeight: NSLayoutConstraint!
    @IBOutlet weak var approximateLocationSwitch: UISwitch!
    @IBOutlet weak var approximateLocationLabel: UILabel!

    @IBOutlet weak var gpsLocationButton: UIButton!
    @IBOutlet weak var searchButton: UIButton!
    @IBOutlet weak var setLocationButton: UIButton!
    @IBOutlet weak var setLocationLoading: UIActivityIndicatorView!

    @IBOutlet weak var suggestionsTableView : UITableView!

    @IBOutlet weak var aproxLocationArea: UIView!
    @IBOutlet weak var poiImage: UIImageView!
    @IBOutlet weak var addressTopText: UILabel!
    @IBOutlet weak var addressBottomText: UILabel!

    private static let suggestionCellId = "suggestionCell"
    private static let suggestionCellHeight: CGFloat = 44

    private let viewModel: EditLocationViewModel
    private let disposeBag = DisposeBag()

    private var mapCentered: Bool = false
    private var mapGestureFromUserInteraction = false //Required to check whether the user moved the map or was automatic


    // MARK: - Lifecycle
    
    init(viewModel: EditLocationViewModel) {
        self.viewModel = viewModel
        super.init(viewModel: nil, nibName: "EditLocationViewController")
        self.viewModel.delegate = self
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupUI()
        setupAccessibilityIds()
        setRxBindings()
    }


    // MARK: - IBActions
    
    @IBAction func searchButtonPressed() {
        goToLocation(nil)
    }

    @IBAction func gpsLocationButtonPressed() {
        mapCentered = false
        viewModel.showGPSLocation()
    }
    
    @IBAction func setLocationButtonPressed(sender: AnyObject) {
        viewModel.applyLocation()
    }

    func goToLocation(resultsIndex: Int?) {
        // Dismissing keyboard so that it doesn't show up after searching. If it fails we will show it programmaticaly
        searchField.resignFirstResponder()
        
        if let resultsIndex = resultsIndex {
            viewModel.selectPlace(resultsIndex)
        } else if let textToSearch = searchField.text {
            viewModel.searchText.value = (textToSearch, true)
        }
    }
    
    
    // MARK: - view model delegate methods

    func vmUpdateSearchTableWithResults(results: [String]) {
        /*If searchfield is not first responder means user is not typing so doesn't make sense to show/update
        suggestions table*/
        if !searchField.isFirstResponder() { return }

        let newHeight = CGFloat(results.count) * EditLocationViewController.suggestionCellHeight
        suggestionsTableView.frame = CGRectMake(suggestionsTableView.frame.origin.x,
            suggestionsTableView.frame.origin.y, suggestionsTableView.frame.size.width, newHeight);
        suggestionsTableView.hidden = false
        suggestionsTableView.reloadData()
    }

    func vmDidFailFindingSuggestions() {
        suggestionsTableView.hidden = true
    }

    func vmDidFailToFindLocationWithError(error: String) {
        showAutoFadingOutMessageAlert(error) { [weak self] in
            // Showing keyboard again as the user must update the text
            self?.searchField.becomeFirstResponder()
        }
    }

    func vmShowMessage(message: String, completion: (() -> ())?) {
        showAutoFadingOutMessageAlert(message, completion: completion)
    }

    func vmGoBack() {
        popBackViewController()
    }


    // MARK: - Private methods
    
    private func setupUI() {

        view.addConstraint(NSLayoutConstraint(item: searchField, attribute: .Top, relatedBy: .Equal,
            toItem: topLayoutGuide, attribute: .Bottom, multiplier: 1.0, constant: 8.0))
        searchField.insetX = 40
        searchField.placeholder = LGLocalizedString.changeLocationSearchFieldHint
        searchField.layer.cornerRadius = LGUIKitConstants.defaultCornerRadius
        searchField.layer.borderColor = UIColor.lineGray.CGColor
        searchField.layer.borderWidth = LGUIKitConstants.onePixelSize
        suggestionsTableView.layer.cornerRadius = LGUIKitConstants.defaultCornerRadius
        suggestionsTableView.layer.borderColor = UIColor.lineGray.CGColor
        suggestionsTableView.layer.borderWidth = LGUIKitConstants.onePixelSize
        setLocationButton.setStyle(.Primary(fontSize: .Medium))
        setLocationButton.setTitle(LGLocalizedString.changeLocationApplyButton, forState: UIControlState.Normal)
        gpsLocationButton.layer.cornerRadius = 10
        aproxLocationArea.layer.cornerRadius = aproxLocationArea.width / 2
        poiImage.hidden = true
        aproxLocationArea.hidden = true

        // i18n
        approximateLocationLabel.text = LGLocalizedString.changeLocationApproximateLocationLabel

        setNavBarTitle(LGLocalizedString.changeLocationTitle)

        registerCells()
    }

    private func setupAccessibilityIds() {
        mapView.accessibilityId = .EditLocationMap
        searchButton.accessibilityId = .EditLocationSearchButton
        searchField.accessibilityId = .EditLocationSearchTextField
        suggestionsTableView.accessibilityId = .EditLocationSearchSuggestionsTable
        gpsLocationButton.accessibilityId = .EditLocationSensorLocationButton
        aproxLocationArea.accessibilityId = .EditLocationApproxLocationCircleView
        poiImage.accessibilityId = .EditLocationPOIImageView
        setLocationButton.accessibilityId = .EditLocationSetLocationButton
        approximateLocationSwitch.accessibilityId = .EditLocationApproxLocationSwitch
    }

    private func setRxBindings() {
        setupSearchRx()
        setupInfoViewsRx()
        setupApproxLocationRx()
        setupLocationChangesRx()
        setupSetLocationButtonRx()
    }

    private func setupSearchRx() {
        //When search field is active and user types, forward to viewModel
        searchField.rx_text.subscribeNext{ [weak self] text in
            guard let searchField = self?.searchField where searchField.isFirstResponder() else { return }
            self?.viewModel.searchText.value = (text, autoSelect:false)
            }.addDisposableTo(disposeBag)

        //When infoText changes and we're in approxLocation mode, set the info on search field
        viewModel.placeInfoText.asObservable().subscribeNext { [weak self] infoText in
            let approxLocation = self?.viewModel.approxLocation.value ?? false
            self?.searchField.text = approxLocation ? infoText : ""
        }.addDisposableTo(disposeBag)
    }

    private func setupInfoViewsRx() {
        viewModel.placeInfoText.asObservable().bindTo(searchField.rx_text).addDisposableTo(disposeBag)
        //When approx location changes show/hide views accordingly
        viewModel.approxLocation.asObservable().subscribeNext { [weak self] approximate in
            self?.poiImage.hidden = approximate
            self?.aproxLocationArea.hidden = !approximate
        }.addDisposableTo(disposeBag)
    }

    private func setupApproxLocationRx() {
        viewModel.approxLocation.asObservable().bindTo(approximateLocationSwitch.rx_value).addDisposableTo(disposeBag)
        approximateLocationSwitch.rx_value.bindTo(viewModel.approxLocation).addDisposableTo(disposeBag)
        //Each time approxLocation value changes, map must zoom-in/out map accordingly
        viewModel.approxLocation.asObservable().subscribeNext{ [weak self] approximate in
            guard let location = self?.viewModel.placeLocation.value else { return }
            self?.centerMapInLocation(location)
        }.addDisposableTo(disposeBag)

        viewModel.approxLocationHidden.asObservable().subscribeNext { [weak self] hidden in
            self?.approxLocationContainer.hidden = hidden
            self?.approxLocationHeight.constant = hidden ? 0 : 50
        }.addDisposableTo(disposeBag)
    }

    private func setupLocationChangesRx() {
        //When place changes on viewModel map must follow its location
        viewModel.placeLocation.asObservable().subscribeNext { [weak self] location in
            guard let strongSelf = self, location = location else { return }
            strongSelf.centerMapInLocation(location)
            }.addDisposableTo(disposeBag)
    }

    private func setupSetLocationButtonRx() {
        //Loading variable activates/deactivates locationButtonLoading
        viewModel.loading.asObservable().subscribeNext { [weak self] loading in
            if loading {
                self?.setLocationButton.setTitle("", forState: UIControlState.Normal)
                self?.setLocationLoading.startAnimating()
            } else {
                self?.setLocationButton.setTitle(LGLocalizedString.changeLocationApplyButton,
                    forState: UIControlState.Normal)
                self?.setLocationLoading.stopAnimating()
            }
            }.addDisposableTo(disposeBag)

        viewModel.setLocationEnabled.asObservable().bindTo(setLocationButton.rx_enabled).addDisposableTo(disposeBag)
    }

    private func centerMapInLocation(coordinate: CLLocationCoordinate2D) {
        let approximate = viewModel.approxLocation.value
        let radius = approximate ? Constants.nonAccurateRegionRadius : Constants.accurateRegionRadius
        let region = MKCoordinateRegionMakeWithDistance(coordinate, radius, radius)
        mapView.setRegion(region, animated: true)
    }
}


// MARK: - MKMapViewDelegate

extension EditLocationViewController: MKMapViewDelegate {
    func mapView(mapView: MKMapView, regionWillChangeAnimated animated: Bool) {
        mapGestureFromUserInteraction = false

        guard let gestureRecognizers = mapView.subviews.first?.gestureRecognizers else { return }
        for gestureRecognizer in gestureRecognizers {
            if gestureRecognizer.state == UIGestureRecognizerState.Began ||
                gestureRecognizer.state == UIGestureRecognizerState.Ended {
                    mapGestureFromUserInteraction = true
                    viewModel.userTouchingMap.value = true
                    break
            }
        }
    }

    func mapView(mapView: MKMapView, regionDidChangeAnimated animated: Bool) {
        viewModel.userTouchingMap.value = false

        if mapGestureFromUserInteraction {
            mapGestureFromUserInteraction = false
            viewModel.userMovedLocation.value = mapView.centerCoordinate
        }
    }
}


// MARK: - UITableViewDataSource, UITableViewDelegate

extension EditLocationViewController: UITableViewDataSource, UITableViewDelegate {

    func registerCells() {
        suggestionsTableView.registerClass(UITableViewCell.self,
            forCellReuseIdentifier: EditLocationViewController.suggestionCellId)
    }

    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.placeCount
    }

    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {

        let cell = tableView.dequeueReusableCellWithIdentifier(EditLocationViewController.suggestionCellId, forIndexPath: indexPath)

        cell.textLabel!.text = viewModel.placeResumedDataAtPosition(indexPath.row)
        cell.selectionStyle = .None

        return cell
    }

    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        self.searchField.text = viewModel.placeResumedDataAtPosition(indexPath.row)
        suggestionsTableView.hidden = true
        goToLocation(indexPath.row)
    }
}


// MARK: - UITextFieldDelegate

extension EditLocationViewController: UITextFieldDelegate {
    // "touchesBegan" used to hide the keyboard when touching outside the textField
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        searchField.resignFirstResponder()
        super.touchesBegan(touches, withEvent: event)
    }

    func textField(textField: UITextField, shouldChangeCharactersInRange range: NSRange,
        replacementString string: String) -> Bool {
            if textField.textReplacingCharactersInRange(range, replacementString: string).isEmpty {
                suggestionsTableView.hidden = true
            }
            return true
    }

    func textFieldDidEndEditing(textField: UITextField) {
        suggestionsTableView.hidden = true
    }

    func textFieldShouldReturn(textField: UITextField) -> Bool {
        if let textFieldText = textField.text where textFieldText.characters.count < 1 {
            return true
        }
        suggestionsTableView.hidden = true
        goToLocation(nil)
        return true
    }

    func textFieldShouldClear(textField: UITextField) -> Bool {
        suggestionsTableView.hidden = true
        return true
    }
}
