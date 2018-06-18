import UIKit
import MapKit
import LGCoreKit
import RxSwift
import RxSwiftExt
import RxCocoa
import Result
import LGComponents

final class EditLocationViewController: BaseViewController, EditLocationViewModelDelegate {

    private struct Layout {
        static let mapRegionMarginMutiplier = 0.5
        static let mapRegionDiameterMutiplier = 2.0
        static let cellHeight: CGFloat = 44
    }
    
    var mapView: MKMapView { return editView.mapView }
    fileprivate var circleOverlay: MKOverlay?

    var searchField: UITextField { return editView.searchTextField }
    var searchButton: UIButton { return editView.searchButton }

    var approximateLocationSwitch: UISwitch { return editView.approximateSwitch }
    var gpsLocationButton: UIButton { return editView.gpsLocatizationButton }

    var setLocationButton: UIButton { return editView.locationButton }
    var setLocationLoading: UIActivityIndicatorView { return editView.locationActivityIndicator }

    var suggestionsTableView: UITableView { return editView.searchTableView }

    var poiImage: UIImageView { return editView.pin }
    var aproxLocationArea: UIView { return editView.aproxLocationArea }

    fileprivate static let suggestionCellId = "suggestionCell"

    private let editView = EditLocationView()
    fileprivate let viewModel: EditLocationViewModel
    private let disposeBag = DisposeBag()

    private var mapCentered: Bool = false
    fileprivate var mapGestureFromUserInteraction = false //Required to check whether the user moved the map or was automatic


    // MARK: - Lifecycle
    
    init(viewModel: EditLocationViewModel) {
        self.viewModel = viewModel
        super.init(viewModel: viewModel, nibName: nil)
        self.viewModel.delegate = self
    }

    required init?(coder aDecoder: NSCoder) { fatalError("Die xibs, die") }

    override func loadView() {
        super.loadView()

        view.addSubviewForAutoLayout(editView)
        NSLayoutConstraint.activate([
            editView.topAnchor.constraint(equalTo: safeTopAnchor),
            editView.rightAnchor.constraint(equalTo: view.rightAnchor),
            editView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            editView.leftAnchor.constraint(equalTo: view.leftAnchor)
        ])
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupNavigationBar()
        setupUI()
        setupAccessibilityIds()
        setRxBindings()
    }

    // MARK: - IBActions

    private func setupTouchEvents() {
        searchButton
            .rx
            .tap
            .asDriver()
            .drive(onNext: { [weak self] (_) in
            self?.goToLocation(nil)
        }).disposed(by: disposeBag)
        gpsLocationButton
            .rx
            .tap
            .asDriver()
            .drive(onNext: { [weak self] (_) in
                self?.gpsLocationButtonPressed()
            }).disposed(by: disposeBag)
        setLocationButton
            .rx
            .tap
            .asDriver()
            .drive(onNext: { [weak self] (_) in
                self?.setLocationButtonPressed()
            }).disposed(by: disposeBag)
    }

    func searchButtonPressed() {
        goToLocation(nil)
    }

    func gpsLocationButtonPressed() {
        mapCentered = false
        viewModel.showGPSLocation()
    }
    
    func setLocationButtonPressed() {
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
    
    @objc func setLocationCloseButtonPressed() {
        viewModel.cancelSetLocation()
    }
    
    
    // MARK: - view model delegate methods

    func vmUpdateSearchTableWithResults(_ results: [String]) {
        /*If searchfield is not first responder means user is not typing so doesn't make sense to show/update
        suggestions table*/
        if !searchField.isFirstResponder { return }

        let newHeight = CGFloat(results.count) * Layout.cellHeight
        suggestionsTableView.frame = CGRect(x: suggestionsTableView.frame.origin.x,
            y: suggestionsTableView.frame.origin.y, width: suggestionsTableView.frame.size.width, height: newHeight);
        suggestionsTableView.isHidden = false
        suggestionsTableView.reloadData()
    }

    func vmDidFailFindingSuggestions() {
        suggestionsTableView.isHidden = true
    }

    func vmDidFailToFindLocationWithError(_ error: String) {
        showAutoFadingOutMessageAlert(message: error) { [weak self] in
            // Showing keyboard again as the user must update the text
            self?.searchField.becomeFirstResponder()
        }
    }

    func vmShowMessage(_ message: String, completion: (() -> ())?) {
        showAutoFadingOutMessageAlert(message: message, completion: completion)
    }


    // MARK: - Private methods

    private func setupNavigationBar() {
        if viewModel.shouldShowCustomNavigationBar {
            navigationItem.leftBarButtonItem = UIBarButtonItem(image: R.Asset.CongratsScreenImages.icCloseRed.image,
                                                               style: .plain,
                                                               target: self,
                                                               action: #selector(setLocationCloseButtonPressed))
            setNavBarTitle(R.Strings.quickFilterLocationTitle)
        } else {
            setNavBarTitle(R.Strings.changeLocationTitle)
        }
    }

    private func setupUI() {
        mapView.delegate = self
        suggestionsTableView.isHidden = true
        suggestionsTableView.dataSource = self
        suggestionsTableView.delegate = self

        poiImage.isHidden = true
        editView.setApproxArea(hidden: true)

        registerCells()

        guard viewModel.shouldShowDistanceSlider else { return }
        editView.addSliderViewWith(delegate: self,
                                   distanceType: viewModel.distanceType,
                                   distanceRadius: viewModel.distanceRadius ?? 0)
    }

    private func setupAccessibilityIds() {
        mapView.set(accessibilityId: .editLocationMap)
        searchButton.set(accessibilityId: .editLocationSearchButton)
        searchField.set(accessibilityId: .editLocationSearchTextField)
        suggestionsTableView.set(accessibilityId: .editLocationSearchSuggestionsTable)
        gpsLocationButton.set(accessibilityId: .editLocationSensorLocationButton)
        aproxLocationArea.set(accessibilityId: .editLocationApproxLocationCircleView)
        poiImage.set(accessibilityId: .editLocationPOIImageView)
        setLocationButton.set(accessibilityId: .editLocationSetLocationButton)
        approximateLocationSwitch.set(accessibilityId: .editLocationApproxLocationSwitch)
    }

    private func setRxBindings() {
        setupSearchRx()
        setupInfoViewsRx()
        setupLocationRx()
        setupSetLocationButtonRx()
        setupTouchEvents()
    }

    private func setupSearchRx() {
        //When search field is active and user types, forward to viewModel
        searchField.rx.text.subscribeNext{ [weak self] text in
            guard let searchField = self?.searchField, searchField.isFirstResponder else { return }
            guard let text = text else { return }
            self?.viewModel.searchText.value = (text, autoSelect:false)
            }.disposed(by: disposeBag)

        //When infoText changes and we're in approxLocation mode, set the info on search field
        viewModel.placeInfoText.asObservable().subscribeNext { [weak self] infoText in
            let approxLocation = self?.viewModel.approxLocation.value ?? false
            self?.searchField.text = approxLocation ? infoText : ""
        }.disposed(by: disposeBag)
    }

    private func setupInfoViewsRx() {
        viewModel.placeInfoText.asObservable().bind(to: searchField.rx.text).disposed(by: disposeBag)
        //When approx location changes show/hide views accordingly
        viewModel.approxLocation.asObservable().subscribeNext { [weak self] approximate in
            self?.poiImage.isHidden = approximate
            self?.editView.setApproxArea(hidden: !approximate)
        }.disposed(by: disposeBag)
    }

    private func setupLocationRx() {
        viewModel.approxLocation.asObservable().bind(to: approximateLocationSwitch.rx.value).disposed(by: disposeBag)
        approximateLocationSwitch.rx.value.bind(to: viewModel.approxLocation).disposed(by: disposeBag)

        viewModel
            .approxLocationHidden
            .asDriver()
            .drive(onNext: { [weak self] hidden in
                self?.editView.setApproxLocation(hidden: hidden)
                self?.editView.layoutIfNeeded()
            }).disposed(by: disposeBag)

        //When place changes on viewModel map must follow its location
        //Each time approxLocation or distance value changes, map must zoom-in/out map accordingly
        Observable.combineLatest(viewModel.approxLocation.asObservable(),
                                 viewModel.placeLocation.asObservable().unwrap(),
                                 viewModel.currentDistanceRadius.asObservable()) { ($0, $1, $2) }
            .bind { [weak self] (approximate, location, currentRadius) in
                var radius = approximate ? SharedConstants.nonAccurateRegionRadius : SharedConstants.accurateRegionRadius
                if let _ = currentRadius, let distanceMeters = self?.viewModel.distanceMeters {
                    radius = distanceMeters * (Layout.mapRegionMarginMutiplier +
                                              Layout.mapRegionDiameterMutiplier)
                }
                self?.centerMapInLocation(location, radius: radius)
            }
            .disposed(by: disposeBag)
    }

    private func setupSetLocationButtonRx() {
        //Loading variable activates/deactivates locationButtonLoading
        viewModel.loading.asObservable().subscribeNext { [weak self] loading in
            if loading {
                self?.setLocationButton.setTitle("", for: .normal)
                self?.setLocationLoading.startAnimating()
            } else {
                self?.setLocationButton.setTitle(R.Strings.changeLocationApplyButton,
                    for: .normal)
                self?.setLocationLoading.stopAnimating()
            }
            }.disposed(by: disposeBag)

        viewModel.setLocationEnabled.asObservable().bind(to: setLocationButton.rx.isEnabled).disposed(by: disposeBag)
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
                                                                (Layout.mapRegionMarginMutiplier +
                                                                Layout.mapRegionDiameterMutiplier))
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

        let cell = tableView.dequeueReusableCell(withIdentifier: EditLocationViewController.suggestionCellId,
                                                 for: indexPath)

        cell.textLabel?.text = viewModel.placeResumedDataAtPosition(indexPath.row)
        cell.selectionStyle = .none

        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        searchField.text = viewModel.placeResumedDataAtPosition(indexPath.row)
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
        if let textFieldText = textField.text, textFieldText.count < 1 {
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
