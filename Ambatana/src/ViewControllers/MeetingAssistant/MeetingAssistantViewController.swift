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

final class MeetingAssistantViewController: BaseViewController {

    static private var cellSize: CGSize = CGSize(width: 160, height: 220)

    private var cellMapViewer: CellMapViewer = CellMapViewer()

    @IBOutlet weak private var placeHeaderLabel: UILabel!
    @IBOutlet weak private var dateTimeHeaderLabel: UILabel!

    @IBOutlet weak private var locationLabel: UILabel!

    @IBOutlet weak private var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak private var suggestedLocationsContainer: UIView!
    @IBOutlet weak private var suggestedLocationsCollection: UICollectionView!

    @IBOutlet weak private var selectDayLabel: UILabel!

    @IBOutlet weak private var sendMeetingButton: LetgoButton!

    @IBOutlet weak private var datePickerContainer: UIView!
    @IBOutlet weak private var datePicker: UIDatePicker!
    @IBOutlet weak private var datePickerDoneButton: UIButton!

    @IBOutlet weak private var datePickerContainerHeight: NSLayoutConstraint!

    fileprivate var viewModel: MeetingAssistantViewModel

    private let disposeBag = DisposeBag()

    init(viewModel: MeetingAssistantViewModel) {
        self.viewModel = viewModel
        super.init(viewModel: viewModel, nibName: "MeetingAssistantViewController")
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setupRx()
        setupUI()
        setAccesibilityIds()
    }

    private func setupRx() {

        let combinedSignal = Observable.combineLatest(viewModel.suggestedLocations.asObservable().skip(1),
                                                      viewModel.mapSnapshotsCache.asObservable())
        combinedSignal.asObservable().bind { [weak self] _ in
            self?.suggestedLocationsCollection.reloadData()
        }.disposed(by: disposeBag)

        viewModel.locationName.asObservable().bind { [weak self] locName in
            if let name = locName {
                self?.locationLabel.text = name
                self?.locationLabel.textColor = UIColor.blackText
            } else {
                self?.locationLabel.text = LGLocalizedString.meetingCreationViewSelectLocation
                self?.locationLabel.textColor = UIColor.grayText
            }
        }.disposed(by: disposeBag)

        viewModel.date.asObservable().bind { [weak self] date in
            if let _ = date {
                self?.selectDayLabel.textColor = UIColor.blackText
            } else {
                self?.selectDayLabel.text = LGLocalizedString.meetingCreationViewSelectDateTime
                self?.selectDayLabel.textColor = UIColor.grayText
            }
            }.disposed(by: disposeBag)

        viewModel.saveButtonEnabled.asObservable().bind(to: sendMeetingButton.rx.isEnabled).disposed(by: disposeBag)

        viewModel.activityIndicatorActive.asDriver().drive(onNext: { [weak self] active in
            if active {
                self?.activityIndicator.startAnimating()
            } else {
                self?.activityIndicator.stopAnimating()
            }
            self?.suggestedLocationsCollection.isHidden = active
        }).disposed(by: disposeBag)
    }

    private func setupUI() {
        view.backgroundColor = UIColor.white
        suggestedLocationsCollection.showsHorizontalScrollIndicator = false

        let locNib = UINib(nibName: SuggestedLocationCell.reusableID, bundle: nil)
        suggestedLocationsCollection.register(locNib, forCellWithReuseIdentifier: SuggestedLocationCell.reusableID)

        if let layout = suggestedLocationsCollection.collectionViewLayout as? UICollectionViewFlowLayout {
            layout.scrollDirection = UICollectionViewScrollDirection.horizontal
        }

        setNavBarTitle(LGLocalizedString.meetingCreationViewTitle)
        setLetGoRightButtonWith(image: #imageLiteral(resourceName: "ic_meeting_tips"),
                                renderingMode: .alwaysOriginal,
                                selector: "tipsButtonTapped")
        setNavBarBackgroundStyle(.transparent(substyle: .light))
        navigationController?.navigationBar.backgroundColor = UIColor.white

        let cancelButton = UIBarButtonItem(image: #imageLiteral(resourceName: "ic_close_red"), style: .plain, target: self, action: #selector(onNavBarCancel))
        cancelButton.tintColor = UIColor.primaryColor
        self.navigationItem.leftBarButtonItem = cancelButton

        sendMeetingButton.setTitle(LGLocalizedString.meetingCreationViewSendButton, for: .normal)
        sendMeetingButton.setStyle(.primary(fontSize: .big))
        
        setupLabelActions()

        datePickerContainer.alpha = 0
        datePickerContainer.addTopViewBorderWith(width: LGUIKitConstants.onePixelSize, color: UIColor.grayLight)
        datePickerContainerHeight.constant = 0

        let startDate = Date()
        var components = DateComponents()
        components.month = 2
        let calendar = Calendar.current
        let endDate = calendar.date(byAdding: components, to: startDate)

        datePicker.minimumDate = startDate
        datePicker.maximumDate = endDate

        placeHeaderLabel.text = LGLocalizedString.meetingCreationViewPlace.uppercased()
        dateTimeHeaderLabel.text = LGLocalizedString.meetingCreationViewDateTime.uppercased()
    }

    private func setupLabelActions() {
        let dayTap = UITapGestureRecognizer(target: self, action: #selector(onDayLabelTap))
        selectDayLabel.addGestureRecognizer(dayTap)
        selectDayLabel.isUserInteractionEnabled = true

        let locationTap = UITapGestureRecognizer(target: self, action: #selector(onLocationLabelTap))
        locationLabel.addGestureRecognizer(locationTap)
        locationLabel.isUserInteractionEnabled = true
    }

    private func setAccesibilityIds() {
        view.set(accessibilityId: .meetingCreationView)
        placeHeaderLabel.set(accessibilityId: .meetingCreationPlaceHeaderLabel)
        dateTimeHeaderLabel.set(accessibilityId: .meetingCreationdateTimeHeaderLabel)
        locationLabel.set(accessibilityId: .meetingCreationLocationLabel)
        suggestedLocationsCollection.set(accessibilityId: .meetingCreationSuggestedLocationsCollection)
        selectDayLabel.set(accessibilityId: .meetingCreationSelectDayLabel)
        sendMeetingButton.set(accessibilityId: .meetingCreationSendMeetingButton)
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

    @objc private func onLocationLabelTap() {
        viewModel.openLocationSelector()
    }

    @objc private func tipsButtonTapped() {
        viewModel.openMeetingTips()
    }
    
    @IBAction func onSendMeeting(_ sender: AnyObject) {
        viewModel.sendMeeting()
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
        return MeetingAssistantViewController.cellSize
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

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {

        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: SuggestedLocationCell.reusableID,
                                                            for: indexPath) as? SuggestedLocationCell else {
                                                                return UICollectionViewCell()
        }
        let suggestedLocation = viewModel.suggestedLocationAtIndex(indexPath: indexPath)
        let mapSnapshot = viewModel.mapSnapshotFor(suggestedLocation: suggestedLocation)
        cell.setupWithSuggestedLocation(location: suggestedLocation, mapSnapshot: mapSnapshot)
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
    func suggestedLocationCellImageViewPressed(imageView: UIImageView, coordinates: LGLocationCoordinates2D?) {

        guard let coordinates = coordinates else {
            viewModel.openLocationSelector()
            return
        }
        guard let topView = navigationController?.view else { return }
        cellMapViewer.openMapOnView(mainView: topView, fromInitialView: imageView, withCenterCoordinates: coordinates)
    }
}
