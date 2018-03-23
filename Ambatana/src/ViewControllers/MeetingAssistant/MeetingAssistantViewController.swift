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

    var mapContainer: UIView = UIView()

    @IBOutlet weak var locationLabel: UILabel!

    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var suggestedLocationsContainer: UIView!
    @IBOutlet weak var suggestedLocationsCollection: UICollectionView!

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

        viewModel.suggestedLocations.asObservable().skip(1).bind { [weak self] suggestedLocations in
            print(suggestedLocations.count)
            self?.suggestedLocationsCollection.reloadData()
        }.disposed(by: disposeBag)

        viewModel.locationName.asObservable().bind { [weak self] locName in
            if let name = locName {
                self?.locationLabel.text = name
                self?.locationLabel.textColor = UIColor.blackText
            } else {
                self?.locationLabel.text = "_Select a location"
                self?.locationLabel.textColor = UIColor.grayText
            }
        }.disposed(by: disposeBag)

        viewModel.date.asObservable().bind { [weak self] date in
            if let _ = date {
                self?.selectDayLabel.textColor = UIColor.blackText
            } else {
                self?.selectDayLabel.text = "_Select a date"
                self?.selectDayLabel.textColor = UIColor.grayText
            }
            }.disposed(by: disposeBag)

        viewModel.saveButtonEnabled.asObservable().bind(to: sendMeetingButton.rx.isEnabled).disposed(by: disposeBag)

        viewModel.activityIndicatorActive.asObservable().bind { [weak self] active in
            if active {
                self?.activityIndicator.startAnimating()
            } else {
                self?.activityIndicator.stopAnimating()
            }
        }.disposed(by: disposeBag)
    }

    private func setupUI() {
        view.backgroundColor = UIColor.white
        suggestedLocationsCollection.showsHorizontalScrollIndicator = false

        let locNib = UINib(nibName: "SuggestedLocationCell", bundle: nil)
        suggestedLocationsCollection.register(locNib, forCellWithReuseIdentifier: "SuggestedLocationCell")

        if let layout = suggestedLocationsCollection.collectionViewLayout as? UICollectionViewFlowLayout {
            layout.scrollDirection = UICollectionViewScrollDirection.horizontal
        }

        setNavBarTitle("_Schedule a Meetup")
        setLetGoRightButtonWith(image: #imageLiteral(resourceName: "ic_meeting_tips"),
                                renderingMode: .alwaysOriginal,
                                selector: "tipsButtonTapped")
        setNavBarBackgroundStyle(.transparent(substyle: .light))
        navigationController?.navigationBar.backgroundColor = UIColor.white

        let cancelButton = UIBarButtonItem(image: #imageLiteral(resourceName: "ic_close_red"), style: .plain, target: self, action: #selector(onNavBarCancel))
        cancelButton.tintColor = UIColor.primaryColor
        self.navigationItem.leftBarButtonItem = cancelButton

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
    }

    private func setupLabelActions() {
        let dayTap = UITapGestureRecognizer(target: self, action: #selector(onDayLabelTap))
        selectDayLabel.addGestureRecognizer(dayTap)
        selectDayLabel.isUserInteractionEnabled = true
    }


    // MARK: Actions

    @objc private func onNavBarCancel() {
        viewModel.cancelMeetingCreation()
    }

    @objc private func onDayLabelTap() {
        datePicker.datePickerMode = .dateAndTime
        datePickerContainerHeight.constant = 250
        UIView.animate(withDuration: 0.3) {
            self.datePickerContainer.alpha = 1
            self.view.layoutIfNeeded()
        }
    }

    @objc private func tipsButtonTapped() {
        viewModel.openMeetingTips()
    }
    
    @IBAction func onSendMeeting(_ sender: AnyObject) {
        viewModel.sendMeeting()
        self.navigationController?.dismiss(animated: true, completion: nil)
    }

    @IBAction func onPickerDoneButton(_ sender: AnyObject) {
        let formatter = DateFormatter()
        formatter.dateFormat = "E d MMM hh:mm a"
        selectDayLabel.text = formatter.string(from: datePicker.date)
        viewModel.saveDate(date: datePicker.date)

        datePickerContainerHeight.constant = 0
        UIView.animate(withDuration: 0.3) {
            self.view.layoutIfNeeded()
            self.datePickerContainer.alpha = 0
        }
    }
}

extension MeetingAssistantViewController: UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return SuggestedLocationCell.cellSize()
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 10.0
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsetsMake(0.0, 20.0, 0.0, 20.0)
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return viewModel.suggestionsCount
    }

    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {

        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: SuggestedLocationCell.reuseId, for: indexPath) as? SuggestedLocationCell else {
                return UICollectionViewCell()
        }
        let suggestedLocation = viewModel.suggestedLocationAtIndex(indexPath: indexPath)

        cell.setupWithSuggestedLocation(location: suggestedLocation)
        cell.imgDelegate = self
        if let selectedLocationId = viewModel.selectedLocation.value?.locationId,
            suggestedLocation?.locationId == selectedLocationId {
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


extension MeetingAssistantViewController: SuggestedLocationCellImageDelegate, MKMapViewDelegate {
    func imagePressed(coordinates: LGLocationCoordinates2D?) {

        guard let coords = coordinates else {
            viewModel.openLocationSelector()
            return
        }

        view.addSubview(mapContainer)
        mapContainer.translatesAutoresizingMaskIntoConstraints = false
        mapContainer.layout(with: view).fill()

        let effect = UIBlurEffect(style: .dark)
        let mapBlurEffectView = UIVisualEffectView(effect: effect)
        mapBlurEffectView.alpha = 0.0
        mapContainer.addSubview(mapBlurEffectView)
        mapBlurEffectView.translatesAutoresizingMaskIntoConstraints = false
        mapBlurEffectView.layout(with: mapContainer).fill()

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

        mapContainer.addSubview(mapView)
        mapView.translatesAutoresizingMaskIntoConstraints = false

        mapView.layout().height(300).width(300)
        mapView.layout(with: mapContainer).center()

        let mapTap = UITapGestureRecognizer(target: self, action: #selector(mapTapped))
        mapView.addGestureRecognizer(mapTap)
        mapContainer.addGestureRecognizer(mapTap)

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
