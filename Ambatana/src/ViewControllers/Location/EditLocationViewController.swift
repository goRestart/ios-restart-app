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
import RxSwiftExt
import RxCocoa
import Result


class EditLocationViewController: BaseViewController, EditLocationViewModelDelegate {

    static let mapRegionMarginMutiplier = 0.5   // var to set the right region depending on the distance
    static let mapRegionDiameterMutiplier = 2.0 // var to set the right region depending on the distance

    // UI
    @IBOutlet weak var mapView: MKMapView!
    fileprivate var circleOverlay: MKOverlay?
    @IBOutlet weak var searchField: LGTextField!
    
    @IBOutlet weak var approxLocationContainer: UIView!
    @IBOutlet weak var approxLocationHeight: NSLayoutConstraint!
    @IBOutlet weak var approximateLocationSwitch: UISwitch!
    @IBOutlet weak var approximateLocationLabel: UILabel!

    @IBOutlet weak var gpsLocationButton: UIButton!
    @IBOutlet weak var searchButton: UIButton!
    @IBOutlet weak var setLocationButtonContainer: UIView!
    @IBOutlet weak var setLocationButton: UIButton!
    @IBOutlet weak var setLocationLoading: UIActivityIndicatorView!

    @IBOutlet weak var suggestionsTableView : UITableView!

    @IBOutlet weak var aproxLocationArea: UIView!
    @IBOutlet weak var poiImage: UIImageView!
    
    @IBOutlet weak var navBarContainer: UIView!
    @IBOutlet weak var navBarContainerHeight: NSLayoutConstraint!

    fileprivate let filterDistanceSlider = FilterDistanceSlider()
    
    fileprivate static let suggestionCellId = "suggestionCell"
    fileprivate static let suggestionCellHeight: CGFloat = 44

    fileprivate let viewModel: EditLocationViewModel
    private let disposeBag = DisposeBag()

    private var mapCentered: Bool = false
    fileprivate var mapGestureFromUserInteraction = false //Required to check whether the user moved the map or was automatic


    // MARK: - Lifecycle
    
    init(viewModel: EditLocationViewModel) {
        self.viewModel = viewModel
        super.init(viewModel: viewModel, nibName: "EditLocationViewController")
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

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        aproxLocationArea.layer.cornerRadius = aproxLocationArea.width / 2
    }


    // MARK: - IBActions
    
    @IBAction func searchButtonPressed() {
        goToLocation(nil)
    }

    @IBAction func gpsLocationButtonPressed() {
        mapCentered = false
        viewModel.showGPSLocation()
    }
    
    @IBAction func setLocationButtonPressed(_ sender: AnyObject) {
        viewModel.applyLocation()
    }

    func goToLocation(_ resultsIndex: Int?) {
        // Dismissing keyboard so that it doesn't show up after searching. If it fails we will show it programmaticaly
        searchField.resignFirstResponder()
        
        if let resultsIndex = resultsIndex {
            viewModel.selectPlace(resultsIndex)
        } else if let textToSearch = searchField.text {
            viewModel.searchText.value = (textToSearch, true)
        }
    }
    
    func setLocationCloseButtonPressed() {
        viewModel.cancelSetLocation()
    }
    
    
    // MARK: - view model delegate methods

    func vmUpdateSearchTableWithResults(_ results: [String]) {
        guard let searchField = searchField else { return } // Make sure ui binding is done
        /*If searchfield is not first responder means user is not typing so doesn't make sense to show/update
        suggestions table*/
        if !searchField.isFirstResponder { return }

        let newHeight = CGFloat(results.count) * EditLocationViewController.suggestionCellHeight
        suggestionsTableView.frame = CGRect(x: suggestionsTableView.frame.origin.x,
            y: suggestionsTableView.frame.origin.y, width: suggestionsTableView.frame.size.width, height: newHeight);
        suggestionsTableView.isHidden = false
        suggestionsTableView.reloadData()
    }

    func vmDidFailFindingSuggestions() {
        guard suggestionsTableView != nil else { return }
        suggestionsTableView.isHidden = true
    }

    func vmDidFailToFindLocationWithError(_ error: String) {
        guard searchField != nil else { return }
        showAutoFadingOutMessageAlert(error) { [weak self] in
            // Showing keyboard again as the user must update the text
            self?.searchField.becomeFirstResponder()
        }
    }

    func vmShowMessage(_ message: String, completion: (() -> ())?) {
        showAutoFadingOutMessageAlert(message, completion: completion)
    }


    // MARK: - Private methods
    
    private func setupUI() {
        
        if viewModel.shouldShowCustomNavigationBar {
            navBarContainer.layout(with: view)
                .top()
            navBarContainerHeight.constant = 64
            
            let closeButton = UIButton()
            closeButton.setImage(UIImage(named: "ic_close_red"), for: .normal)
            closeButton.addTarget(self, action: #selector(setLocationCloseButtonPressed), for: .touchUpInside)
            let titleLabel = UILabel()
            titleLabel.font = UIFont.pageTitleFont
            titleLabel.textColor = UIColor.blackText
            titleLabel.text = LGLocalizedString.quickFilterLocationTitle
            titleLabel.textAlignment = .center
            
            closeButton.translatesAutoresizingMaskIntoConstraints = false
            titleLabel.translatesAutoresizingMaskIntoConstraints = false
            navBarContainer.addSubview(closeButton)
            navBarContainer.addSubview(titleLabel)

            closeButton.layout(with: navBarContainer)
                .left(by: Metrics.veryShortMargin)
            closeButton.layout()
                .width(40).widthProportionalToHeight()
            closeButton.layout(with: titleLabel)
                .centerY()
                .right(to: .left, by: -Metrics.margin, relatedBy: .lessThanOrEqual)
            
            titleLabel.layout(with: navBarContainer)
                .top(by: 20)
                .right(by: -Metrics.margin, relatedBy: .lessThanOrEqual)
                .bottom()
                .centerX()
            
            navBarContainer.layoutIfNeeded()
            _ = navBarContainer.addBottomBorderWithWidth(1, color: UIColor.gray)
        } else {
            navBarContainer.layout(with: topLayoutGuide)
                .top(to: .bottom, by: 0)
        }
        
        if viewModel.shouldShowDistanceSlider {
            let sliderContainer = UIView()
            sliderContainer.backgroundColor = UIColor.white
            sliderContainer.translatesAutoresizingMaskIntoConstraints = false
            view.addSubview(sliderContainer)
            sliderContainer.layout()
                .height(50)
            sliderContainer.layout(with: view)
                .left()
                .right()
            sliderContainer.layout(with: setLocationButtonContainer)
                .bottom(to: .top)
            
            filterDistanceSlider.translatesAutoresizingMaskIntoConstraints = false
            sliderContainer.addSubview(filterDistanceSlider)
            filterDistanceSlider.layout(with: sliderContainer)
                .fill()

            filterDistanceSlider.delegate = self
            filterDistanceSlider.distanceType = viewModel.distanceType
            filterDistanceSlider.distance = viewModel.distanceRadius ?? 0
        }

        searchField.insetX = 40
        searchField.placeholder = LGLocalizedString.changeLocationSearchFieldHint
        searchField.layer.cornerRadius = LGUIKitConstants.textfieldCornerRadius
        searchField.layer.borderColor = UIColor.lineGray.cgColor
        searchField.layer.borderWidth = LGUIKitConstants.onePixelSize

        searchField.layer.shadowColor = UIColor.black.cgColor
        searchField.layer.shadowOpacity = 0.16
        searchField.layer.shadowOffset = CGSize(width: 0, height: 2)
        searchField.layer.shadowRadius = 6

        suggestionsTableView.layer.cornerRadius = LGUIKitConstants.defaultCornerRadius
        suggestionsTableView.layer.borderColor = UIColor.lineGray.cgColor
        suggestionsTableView.layer.borderWidth = LGUIKitConstants.onePixelSize
        setLocationButton.setStyle(.primary(fontSize: .medium))
        setLocationButton.setTitle(LGLocalizedString.changeLocationApplyButton, for: .normal)
        gpsLocationButton.layer.cornerRadius = 10
        poiImage.isHidden = true
        aproxLocationArea.isHidden = true

        approximateLocationLabel.text = LGLocalizedString.changeLocationApproximateLocationLabel

        setNavBarTitle(LGLocalizedString.changeLocationTitle)

        registerCells()
    }

    private func setupAccessibilityIds() {
        mapView.accessibilityId = .editLocationMap
        searchButton.accessibilityId = .editLocationSearchButton
        searchField.accessibilityId = .editLocationSearchTextField
        suggestionsTableView.accessibilityId = .editLocationSearchSuggestionsTable
        gpsLocationButton.accessibilityId = .editLocationSensorLocationButton
        aproxLocationArea.accessibilityId = .editLocationApproxLocationCircleView
        poiImage.accessibilityId = .editLocationPOIImageView
        setLocationButton.accessibilityId = .editLocationSetLocationButton
        approximateLocationSwitch.accessibilityId = .editLocationApproxLocationSwitch
    }

    private func setRxBindings() {
        setupSearchRx()
        setupInfoViewsRx()
        setupLocationRx()
        setupSetLocationButtonRx()
    }

    private func setupSearchRx() {
        //When search field is active and user types, forward to viewModel
        searchField.rx.text.subscribeNext{ [weak self] text in
            guard let searchField = self?.searchField, searchField.isFirstResponder else { return }
            guard let text = text else { return }
            self?.viewModel.searchText.value = (text, autoSelect:false)
            }.addDisposableTo(disposeBag)

        //When infoText changes and we're in approxLocation mode, set the info on search field
        viewModel.placeInfoText.asObservable().subscribeNext { [weak self] infoText in
            let approxLocation = self?.viewModel.approxLocation.value ?? false
            self?.searchField.text = approxLocation ? infoText : ""
        }.addDisposableTo(disposeBag)
    }

    private func setupInfoViewsRx() {
        viewModel.placeInfoText.asObservable().bindTo(searchField.rx.text).addDisposableTo(disposeBag)
        //When approx location changes show/hide views accordingly
        viewModel.approxLocation.asObservable().subscribeNext { [weak self] approximate in
            self?.poiImage.isHidden = approximate
            self?.aproxLocationArea.isHidden = !approximate
        }.addDisposableTo(disposeBag)
    }

    private func setupLocationRx() {
        viewModel.approxLocation.asObservable().bindTo(approximateLocationSwitch.rx.value).addDisposableTo(disposeBag)
        approximateLocationSwitch.rx.value.bindTo(viewModel.approxLocation).addDisposableTo(disposeBag)

        viewModel.approxLocationHidden.asObservable().subscribeNext { [weak self] hidden in
            self?.approxLocationContainer.isHidden = hidden
            self?.approxLocationHeight.constant = hidden ? 0 : 50
        }.addDisposableTo(disposeBag)

        //When place changes on viewModel map must follow its location
        //Each time approxLocation or distance value changes, map must zoom-in/out map accordingly
        Observable.combineLatest(viewModel.approxLocation.asObservable(),
                                 viewModel.placeLocation.asObservable().unwrap(),
                                 viewModel.currentDistanceRadius.asObservable()) { ($0, $1, $2) }
            .bindNext { [weak self] (approximate, location, currentRadius) in
                var radius = approximate ? Constants.nonAccurateRegionRadius : Constants.accurateRegionRadius
                if let _ = currentRadius, let distanceMeters = self?.viewModel.distanceMeters {
                    radius = distanceMeters * (EditLocationViewController.mapRegionMarginMutiplier +
                                              EditLocationViewController.mapRegionDiameterMutiplier)
                }
                self?.centerMapInLocation(location, radius: radius)
            }
            .addDisposableTo(disposeBag)
    }

    private func setupSetLocationButtonRx() {
        //Loading variable activates/deactivates locationButtonLoading
        viewModel.loading.asObservable().subscribeNext { [weak self] loading in
            if loading {
                self?.setLocationButton.setTitle("", for: .normal)
                self?.setLocationLoading.startAnimating()
            } else {
                self?.setLocationButton.setTitle(LGLocalizedString.changeLocationApplyButton,
                    for: .normal)
                self?.setLocationLoading.stopAnimating()
            }
            }.addDisposableTo(disposeBag)

        viewModel.setLocationEnabled.asObservable().bindTo(setLocationButton.rx.isEnabled).addDisposableTo(disposeBag)
    }

    /**
        Centers the map in the given location, if any and zooms if a radius is specified
        - coordinate: the location where it should center
        - radius: the size of the region to show
     */
    fileprivate func centerMapInLocation(_ coordinate: CLLocationCoordinate2D, radius: Double) {
        let region = MKCoordinateRegionMakeWithDistance(coordinate, radius, radius)
        mapView.setRegion(region, animated: true)
    }
    
    fileprivate func updateCircleOverlay() {
        guard viewModel.shouldShowCircleOverlay else { return }
        removeCircleOverlay()
        circleOverlay = MKCircle(center: mapView.centerCoordinate, radius: viewModel.distanceMeters)
        if let circleOverlay = circleOverlay {
            mapView.add(circleOverlay)
        }
    }
    
    fileprivate func removeCircleOverlay() {
        guard viewModel.shouldShowCircleOverlay else { return }
        if let previousCircleOverlay = circleOverlay {
            mapView.remove(previousCircleOverlay)
        }
    }
}

// MARK: - 

extension EditLocationViewController: FilterDistanceSliderDelegate {
    func filterDistanceChanged(distance: Int) {
        viewModel.currentDistanceRadius.value = distance
        updateCircleOverlay()
        centerMapInLocation(mapView.centerCoordinate, radius: viewModel.distanceMeters *
                                                                (EditLocationViewController.mapRegionMarginMutiplier +
                                                                EditLocationViewController.mapRegionDiameterMutiplier))
    }
}

// MARK: - MKMapViewDelegate

extension EditLocationViewController: MKMapViewDelegate {
    func mapView(_ mapView: MKMapView, regionWillChangeAnimated animated: Bool) {
        removeCircleOverlay()
        
        mapGestureFromUserInteraction = false

        guard let gestureRecognizers = mapView.subviews.first?.gestureRecognizers else { return }
        for gestureRecognizer in gestureRecognizers {
            if gestureRecognizer.state == UIGestureRecognizerState.began ||
                gestureRecognizer.state == UIGestureRecognizerState.ended {
                    mapGestureFromUserInteraction = true
                    viewModel.userTouchingMap.value = true
                    break
            }
        }
    }

    func mapView(_ mapView: MKMapView, regionDidChangeAnimated animated: Bool) {
        viewModel.userTouchingMap.value = false

        if mapGestureFromUserInteraction {
            mapGestureFromUserInteraction = false
            viewModel.userMovedLocation.value = mapView.centerCoordinate
        }
        updateCircleOverlay()
    }
    
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        let circleRenderer = MKCircleRenderer(overlay: overlay)
        circleRenderer.fillColor = UIColor.white
        circleRenderer.alpha = 0.5
        return circleRenderer
    }
}


// MARK: - UITableViewDataSource, UITableViewDelegate

extension EditLocationViewController: UITableViewDataSource, UITableViewDelegate {

    func registerCells() {
        suggestionsTableView.register(UITableViewCell.self,
            forCellReuseIdentifier: EditLocationViewController.suggestionCellId)
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.placeCount
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        let cell = tableView.dequeueReusableCell(withIdentifier: EditLocationViewController.suggestionCellId, for: indexPath)

        cell.textLabel?.text = viewModel.placeResumedDataAtPosition(indexPath.row)
        cell.selectionStyle = .none

        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.searchField.text = viewModel.placeResumedDataAtPosition(indexPath.row)
        suggestionsTableView.isHidden = true
        goToLocation(indexPath.row)
    }
}


// MARK: - UITextFieldDelegate

extension EditLocationViewController: UITextFieldDelegate {
    // "touchesBegan" used to hide the keyboard when touching outside the textField
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        searchField.resignFirstResponder()
        super.touchesBegan(touches, with: event)
    }

    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange,
        replacementString string: String) -> Bool {
            if textField.textReplacingCharactersInRange(range, replacementString: string).isEmpty {
                suggestionsTableView.isHidden = true
            }
            return true
    }

    func textFieldDidEndEditing(_ textField: UITextField) {
        suggestionsTableView.isHidden = true
    }

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if let textFieldText = textField.text, textFieldText.characters.count < 1 {
            return true
        }
        suggestionsTableView.isHidden = true
        goToLocation(nil)
        return true
    }

    func textFieldShouldClear(_ textField: UITextField) -> Bool {
        suggestionsTableView.isHidden = true
        return true
    }
}
