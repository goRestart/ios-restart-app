import MapKit
import LGCoreKit
import RxSwift
import LGComponents

class LGSearchMap: UIView, MKMapViewDelegate, LGSearchMapViewModelDelegate, UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate {

    
    struct LGSearchMapConstants {
        static let mapRegionMarginMutiplier = 0.5
        static let mapRegionDiameterMutiplier = 2.0
        static let suggestionCellId = "suggestionCell"
        static let suggestionCellHeight: CGFloat = 44
        static let searchBarIconSize: CGSize = CGSize(width: 20, height: 20)
        static let gpsIconSize: CGSize = CGSize(width: 50, height: 50)
        static let cornerRadius: CGFloat = 10
        static let searchFieldHeight: CGFloat = 40
    }
    
    private let mapView = MKMapView()
    private let searchField = LGTextField()
    private let suggestionsTableView = UITableView()
    private let gpsLocationButton = UIButton()
    private let searchIcon = UIImageView()
    private var circleOverlay: MKOverlay?
    private var aproxLocationArea = UIView()
    
    let viewModel: LGSearchMapViewModel
    
    private let disposeBag = DisposeBag()
    
    
    // MARK: - LifeCycle
    
    init(frame: CGRect, viewModel: LGSearchMapViewModel) {
        self.viewModel = viewModel
        super.init(frame: frame)
        self.viewModel.delegate = self
        setupLayout()
        setupUI()
        setupRx()
        updateCenterMap(location: viewModel.coordinate)
    }
    
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    // MARK: - Setup UI
    
    private func setupUI() {
        searchField.insetX = 40
        searchField.placeholder = R.Strings.changeLocationSearchFieldHint
        searchField.cornerRadius = LGUIKitConstants.mediumCornerRadius
        searchField.layer.borderColor = UIColor.lineGray.cgColor
        searchField.layer.borderWidth = LGUIKitConstants.onePixelSize
        searchField.delegate = self
        
        searchField.layer.shadowColor = UIColor.black.cgColor
        searchField.layer.shadowOpacity = 0.16
        searchField.layer.shadowOffset = CGSize(width: 0, height: 2)
        searchField.layer.shadowRadius = 6
        
        searchField.backgroundColor = UIColor.white
        searchField.textColor = UIColor.blackText
        searchField.clearButtonMode = .always
        
        searchIcon.image = #imageLiteral(resourceName: "list_search")
        
        suggestionsTableView.cornerRadius = LGUIKitConstants.smallCornerRadius
        suggestionsTableView.layer.borderColor = UIColor.lineGray.cgColor
        suggestionsTableView.layer.borderWidth = LGUIKitConstants.onePixelSize
        suggestionsTableView.delegate = self
        suggestionsTableView.dataSource = self
        suggestionsTableView.register(UITableViewCell.self,
                                      forCellReuseIdentifier: LGSearchMapConstants.suggestionCellId)
        
        gpsLocationButton.cornerRadius = 10
        gpsLocationButton.setImage(UIImage(named:"map_user_location_button"), for: .normal)
        gpsLocationButton.addTarget(self, action: #selector(LGSearchMap.gpsButtonPressed), for: .touchUpInside)
        
        aproxLocationArea.backgroundColor = UIColor.black
        aproxLocationArea.alpha = 0.1
        mapView.delegate = self
    }
    
    private func setupLayout() {
        setTranslatesAutoresizingMaskIntoConstraintsToFalse(for: [mapView,
                                                                  searchField,
                                                                  suggestionsTableView,
                                                                  gpsLocationButton,
                                                                  searchIcon,
                                                                  aproxLocationArea])
        addSubviews([mapView, aproxLocationArea, searchField, suggestionsTableView, gpsLocationButton, searchIcon])
        mapView.layout(with: self).fill()
        
        searchField.layout(with: mapView).top(by: Metrics.margin).fillHorizontal(by: Metrics.margin)
        searchField.layout().height(LGSearchMapConstants.searchFieldHeight)
        searchIcon.layout().height(LGSearchMapConstants.searchBarIconSize.height).width(LGSearchMapConstants.searchBarIconSize.width)
        searchIcon.layout(with: searchField).centerY().left(by: Metrics.shortMargin)
        
        gpsLocationButton.layout(with: searchField).below(by: Metrics.shortMargin).right()
        gpsLocationButton.layout().height(LGSearchMapConstants.gpsIconSize.height).width(LGSearchMapConstants.gpsIconSize.width)
        
        suggestionsTableView.layout(with: searchField).below().fillHorizontal()
        
        aproxLocationArea.layout(with: mapView).center().proportionalHeight(multiplier: 0.6)
        aproxLocationArea.layout().widthProportionalToHeight()
        aproxLocationArea.isUserInteractionEnabled = false
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        aproxLocationArea.setRoundedCorners()
        cornerRadius = LGSearchMapConstants.cornerRadius
    }
    
    private func setupRx() {
        searchField.rx.text.bind { [weak self] text in
            guard let searchField = self?.searchField, searchField.isFirstResponder else { return }
            guard let text = text else { return }
            self?.viewModel.searchText.value = (text, autoSelect:false)
        }.disposed(by: disposeBag)
        
        viewModel.placeLocation.asObservable().bind { [weak self] (place) in
            guard let place = place else { return }
            self?.updateCenterMap(location: place.location)
        }.disposed(by: disposeBag)
        
        viewModel.placeGPSObservable.bind { [weak self] (place) in
            guard let location = place?.location else { return }
            self?.updateCenterMap(location: location)
        }.disposed(by: disposeBag)
       
        viewModel.placeInfoText.asObservable().bind { [weak self] infoText in
            self?.searchField.text = infoText
        }.disposed(by: disposeBag)
        
        viewModel.placeSuggestedObservable.bind { [weak self] place in
            guard let location = place?.location else { return }
            self?.updateCenterMap(location: location)
        }.disposed(by: disposeBag)
    }
    
    
    func moveToLocation(_ resultsIndex: Int?) {
        searchField.resignFirstResponder()
        
        if let resultsIndex = resultsIndex {
            viewModel.selectPlace(resultsIndex)
        } else if let textToSearch = searchField.text {
            viewModel.searchText.value = (textToSearch, true)
        }
    }
    
    fileprivate func centerMapInLocation(_ coordinate: CLLocationCoordinate2D, radius: Double) {
        let region = MKCoordinateRegionMakeWithDistance(coordinate, radius, radius)
        mapView.setRegion(region, animated: true)
    }
    
    // MARK: - Map Actions
    
    func updateCenterMap(location: LGLocationCoordinates2D?) {
        guard let latitude = location?.latitude, let longitude = location?.longitude else { return }
        let coordinates: CLLocationCoordinate2D = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
        let radius = Constants.accurateRegionRadius
        let region = MKCoordinateRegionMakeWithDistance(coordinates, radius, radius)
        mapView.setRegion(region, animated: false)
    }
    
    @objc func gpsButtonPressed() {
        viewModel.showGPSLocation()
    }
    
    
    // MARK: - MKMapViewDelegate
    
    func mapView(_ mapView: MKMapView, regionDidChangeAnimated animated: Bool) {
        viewModel.userMovedLocation.value = mapView.centerCoordinate
    }
    
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        let circleRenderer = MKCircleRenderer(overlay: overlay)
        circleRenderer.fillColor = UIColor.white
        circleRenderer.alpha = 0.5
        return circleRenderer
    }

    
    // MARK: - UITableViewDataSource, UITableViewDelegate
    
    func registerCells() {
        suggestionsTableView.register(UITableViewCell.self,
                                      forCellReuseIdentifier: LGSearchMapConstants.suggestionCellId)
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.placeCount
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: LGSearchMapConstants.suggestionCellId, for: indexPath)
        
        cell.textLabel?.text = viewModel.placeResumedDataAtPosition(indexPath.row)
        cell.selectionStyle = .none
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        searchField.text = viewModel.placeResumedDataAtPosition(indexPath.row)
        suggestionsTableView.isHidden = true
        moveToLocation(indexPath.row)
    }
    
    
    // MARK: - view model delegate methods
    
    func vmUpdateSearchTableWithResults(_ results: [String]) {
        if !searchField.isFirstResponder { return }
        
        let newHeight = CGFloat(results.count) * LGSearchMapConstants.suggestionCellHeight
        suggestionsTableView.frame = CGRect(x: suggestionsTableView.frame.origin.x,
                                            y: suggestionsTableView.frame.origin.y, width: suggestionsTableView.frame.size.width, height: newHeight);
        suggestionsTableView.isHidden = false
        suggestionsTableView.reloadData()
    }
    
    func vmDidFailFindingSuggestions() {
        suggestionsTableView.isHidden = true
    }
    
    func vmDidFailToFindLocationWithError(_ error: String) {
        viewModel.viewControllerDelegate?.vmShowAutoFadingMessage(error) { [weak self] in
            self?.searchField.becomeFirstResponder()
        }
    }
    
    func vmShowMessage(_ message: String, completion: (() -> ())?) {
        viewModel.viewControllerDelegate?.vmShowAutoFadingMessage(message, completion: completion)
    }
    
    
    // MARK: - Textfield delegate
    
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
        moveToLocation(nil)
        return true
    }
    
    func textFieldShouldClear(_ textField: UITextField) -> Bool {
        suggestionsTableView.isHidden = true
        return true
    }
}
