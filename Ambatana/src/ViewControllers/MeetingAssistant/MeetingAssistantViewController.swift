//
//  MeetingAssistantViewController.swift
//  LetGo
//
//  Created by Dídac on 21/11/2017.
//  Copyright © 2017 Ambatana. All rights reserved.
//

import UIKit
import RxSwift
import MapKit
import LGCoreKit

class MeetingAssistantViewController: BaseViewController {

    var mapContainer: UIVisualEffectView = UIVisualEffectView()

    @IBOutlet weak var locationLabel: UILabel!

    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var suggestedLocationsContainer: UIView!
    @IBOutlet weak var suggestedLocationsCollection: UICollectionView!

    @IBOutlet weak var emptyViewLabel: UILabel!

    @IBOutlet weak var selectDayLabel: UILabel!

    @IBOutlet weak var sendMeetingButton: LetgoButton!

    @IBOutlet weak var datePickerContainer: UIView!
    @IBOutlet weak var datePicker: UIDatePicker!
    @IBOutlet weak var datePickerDoneButton: UIButton!

    @IBOutlet weak var datePickerContainerHeight: NSLayoutConstraint!

    fileprivate var viewModel: MeetingAssistantViewModel

    let disposeBag = DisposeBag()

    init(viewModel: MeetingAssistantViewModel) {
        self.viewModel = viewModel
        super.init(viewModel: viewModel, nibName: "MeetingAssistantViewController")
        viewModel.sugLocDelegate = self
        modalPresentationStyle = .overCurrentContext
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setupRx()
        setupUI()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        suggestedLocationsCollection.reloadData()
        view.layoutIfNeeded()
    }

    private func setupRx() {
        viewModel.locationName.asObservable().bind { [weak self] locName in
            if let name = locName {
                self?.locationLabel.text = name
                self?.locationLabel.textColor = UIColor.blackText
            } else {
                self?.locationLabel.text = "Select a location"
                self?.locationLabel.textColor = UIColor.grayText
            }
        }.disposed(by: disposeBag)

        viewModel.date.asObservable().bind { [weak self] date in
            if let _ = date {
                self?.selectDayLabel.textColor = UIColor.blackText
            } else {
                self?.selectDayLabel.text = "Select a date"
                self?.selectDayLabel.textColor = UIColor.grayText
            }
            }.disposed(by: disposeBag)

        viewModel.saveButtonEnabled.asObservable().bind(to: sendMeetingButton.rx.isEnabled).disposed(by: disposeBag)

        viewModel.selectedLocation.asObservable().bindNext { [weak self] loc in
            self?.suggestedLocationsCollection.reloadData()
        }.disposed(by: disposeBag)

        viewModel.activityIndicatorActive.asObservable().bind { [weak self] active in
            if active {
                self?.activityIndicator.startAnimating()
            } else {
                self?.activityIndicator.stopAnimating()
            }
        }.disposed(by: disposeBag)
    }

    private func setupUI() {

        emptyViewLabel.isHidden = true
//        activityIndicator.isHidden = true

        suggestedLocationsCollection.showsHorizontalScrollIndicator = false

        let locNib = UINib(nibName: "SuggestedLocationCell", bundle: nil)
        suggestedLocationsCollection.register(locNib, forCellWithReuseIdentifier: "SuggestedLocationCell")

        if let layout = suggestedLocationsCollection.collectionViewLayout as? UICollectionViewFlowLayout {
            layout.scrollDirection = UICollectionViewScrollDirection.horizontal
        }

        setNavBarTitle("Schedule a Meetup")
        let cancelButton = UIBarButtonItem(title: LGLocalizedString.commonCancel, style: UIBarButtonItemStyle.plain, target: self, action: #selector(onNavbarCancel))
        cancelButton.tintColor = UIColor.primaryColor
        self.navigationItem.leftBarButtonItem = cancelButton;

        sendMeetingButton.setTitle("Send Meeting", for: .normal)
        sendMeetingButton.setStyle(.primary(fontSize: .big))
        
        setupLabelActions()

        datePickerContainer.alpha = 0
        datePickerContainerHeight.constant = 0

        let startDate = Date()
        var components = DateComponents()
        components.month = 2
        let calendar = Calendar.current
        let endDate = calendar.date(byAdding: components, to: startDate)

        datePicker.minimumDate = startDate
        datePicker.maximumDate = endDate

        emptyViewLabel.text = "We couldn't find suggestions for your meeting"
    }

    private func setupLabelActions() {
        let locationTap = UITapGestureRecognizer(target: self, action: #selector(onLocationLabelTap))
        locationLabel.addGestureRecognizer(locationTap)
        locationLabel.isUserInteractionEnabled = true

        let dayTap = UITapGestureRecognizer(target: self, action: #selector(onDayLabelTap))
        selectDayLabel.addGestureRecognizer(dayTap)
        selectDayLabel.isUserInteractionEnabled = true
    }


    // MARK: Actions

    @objc func onNavbarCancel() {
        self.navigationController?.dismiss(animated: true, completion: nil)
    }

    @objc func onLocationLabelTap() {
        viewModel.openLocationSelector()
    }

    @objc func onDayLabelTap() {
        datePicker.datePickerMode = .dateAndTime
        datePickerContainerHeight.constant = 250
        UIView.animate(withDuration: 0.3) {
            self.datePickerContainer.alpha = 1
            self.view.layoutIfNeeded()
        }
    }
    
    @IBAction func onSendMeeting(_ sender: AnyObject) {
        viewModel.sendMeeting()
        self.navigationController?.dismiss(animated: true, completion: nil)
    }

    @IBAction func onPickerDoneButton(_ sender: AnyObject) {

        let formatter = DateFormatter()
        formatter.dateFormat = "EEEE yyyy-MM-dd HH:mm"
        selectDayLabel.text = formatter.string(from: datePicker.date)
        viewModel.saveDate(date: datePicker.date)

        datePickerContainerHeight.constant = 0
        UIView.animate(withDuration: 0.3) {
            self.view.layoutIfNeeded()
            self.datePickerContainer.alpha = 0
        }
    }

    func showEmptyScreen() {
        suggestedLocationsCollection.isHidden = true
        emptyViewLabel.isHidden = false
    }

    func hideEmptyScreen() {
        suggestedLocationsCollection.isHidden = false
        emptyViewLabel.isHidden = true
    }
}

extension MeetingAssistantViewController: UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return SuggestedLocationCell.cellSize()
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsetsMake(-65.0, 20.0, 0.0, 20.0)
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return viewModel.suggestedLocations?.count ?? 0
    }

    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {

        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: SuggestedLocationCell.reuseId, for: indexPath) as? SuggestedLocationCell else {
                return UICollectionViewCell()
        }
        guard let sugLoc = viewModel.suggestedLocationAtIndex(indexPath: indexPath) else {
            return UICollectionViewCell()
        }

        cell.setupWithSuggestedLocation(location: sugLoc)
        cell.imgDelegate = self
        if let selectedLocationId = viewModel.selectedLocation.value?.locationId,
            sugLoc.locationId == selectedLocationId {
            cell.isSelected = true
        } else {
            cell.isSelected = false
        }
        return cell
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        viewModel.selectSuggestedLocationAtIndex(indexPath: indexPath)
    }
}

extension MeetingAssistantViewController: SuggestedLocationsDelegate {
    func suggestedLocationDidStart() {
        hideEmptyScreen()
    }

    func suggestedLocationDidSuccess() {
        hideEmptyScreen()
        suggestedLocationsCollection.reloadData()
    }

    func suggestedLocationDidFail() {
        showEmptyScreen()
    }
}

extension MeetingAssistantViewController: SuggestedLocationCellImageDelegate, MKMapViewDelegate {
    func imagePressed(coords: LGLocationCoordinates2D) {

        let mapView = MKMapView()
        mapView.delegate = self
        mapView.setCenter(coords.coordinates2DfromLocation(), animated: true)

        mapView.layer.cornerRadius = 20.0

        let clCoordinate = coords.coordinates2DfromLocation()
        let region = MKCoordinateRegionMakeWithDistance(clCoordinate, Constants.accurateRegionRadius*2, Constants.accurateRegionRadius*2)
        mapView.setRegion(region, animated: true)

        mapView.isZoomEnabled = true
        mapView.isScrollEnabled = true
        mapView.isPitchEnabled = true

        let mapOverlay: MKOverlay = MKCircle(center:coords.coordinates2DfromLocation(),
                                      radius: 300)

        mapView.add(mapOverlay)

        let effect = UIBlurEffect(style: .dark)
        mapContainer = UIVisualEffectView(effect: effect)

        mapContainer.alpha = 0.0

        let mapTap = UITapGestureRecognizer(target: self, action: #selector(mapTapped))
        mapView.addGestureRecognizer(mapTap)
        mapContainer.addGestureRecognizer(mapTap)

        mapContainer.translatesAutoresizingMaskIntoConstraints = false
        mapView.translatesAutoresizingMaskIntoConstraints = false

        view.addSubview(mapContainer)

        mapContainer.layout(with: view).fill()

        mapContainer.addSubview(mapView)

        mapView.layout().height(300).width(300)
        mapView.layout(with: mapContainer).center()

        UIView.animate(withDuration: 0.3) { [weak self] in
            self?.mapContainer.alpha = 1.0
            self?.view.layoutIfNeeded()
        }
    }

    @objc func mapTapped() {
        UIView.animate(withDuration: 0.3, animations: { [weak self] in
            self?.mapContainer.alpha = 0.0
        }) { [weak self] _ in
            self?.mapContainer.removeFromSuperview()
        }
    }

    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        if overlay is MKCircle {
            let renderer = MKCircleRenderer(overlay: overlay)
            renderer.fillColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.10)
            return renderer
        }
        return MKCircleRenderer()
    }
}
