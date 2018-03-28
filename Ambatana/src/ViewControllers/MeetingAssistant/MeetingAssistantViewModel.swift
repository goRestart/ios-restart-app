//
//  MeetingAssistantViewModel.swift
//  LetGo
//
//  Created by Dídac on 21/11/2017.
//  Copyright © 2017 Ambatana. All rights reserved.
//

import Foundation
import LGCoreKit
import RxSwift
import MapKit

protocol MeetingAssistantDataDelegate: class {
    func sendMeeting(meeting: AssistantMeeting)
}


class MeetingAssistantViewModel: BaseViewModel {

    var suggestionsCount: Int {
        return suggestedLocations.value.count
    }

    var listingId: String?

    let locationName = Variable<String?>(nil)

    var selectedPlace: Place?
    let selectedLocation = Variable<SuggestedLocation?>(nil)

    weak var navigator: MeetingAssistantNavigator?
    weak var dataDelegate: MeetingAssistantDataDelegate?

    let activityIndicatorActive = Variable<Bool>(false)
    let suggestedLocations = Variable<[SuggestedLocation?]>([nil])
    let mapSnapshotsCache = Variable<[String:UIImage?]>([:])

    let date = Variable<Date?>(nil)
    let saveButtonEnabled = Variable<Bool>(false)

    private let disposeBag = DisposeBag()

    private let suggestedLocationsRepository: SuggestedLocationsRepository
    private let keyValueStorage: KeyValueStorageable
    private let tracker: TrackerProxy


    // MARK: - lifecycle

    convenience init(listingId: String?) {
        self.init(listingId: listingId, suggestedLocationsRepository: Core.suggestedLocationsRepository, keyValueStorage: KeyValueStorage.sharedInstance, tracker: TrackerProxy.sharedInstance)
    }

    init(listingId: String?, suggestedLocationsRepository: SuggestedLocationsRepository, keyValueStorage: KeyValueStorageable,
         tracker: TrackerProxy) {
        self.listingId = listingId
        self.suggestedLocationsRepository = suggestedLocationsRepository
        self.keyValueStorage = keyValueStorage
        self.tracker = tracker
        super.init()
        setupRx()
    }

    func setupRx() {
        Observable.combineLatest(date.asObservable(), locationName.asObservable()) { ($0, $1) }
            .bind { [weak self] (date, locationName) in
                if let _ = date, let _ = locationName {
                    self?.saveButtonEnabled.value = true
                } else {
                    self?.saveButtonEnabled.value = false
                }
            }.disposed(by: disposeBag)
    }

    override func didBecomeActive(_ firstTime: Bool) {
        if firstTime {
            let meetingStartEvent = TrackerEvent.assistantMeetingStartFor(listingId: listingId)
            tracker.trackEvent(meetingStartEvent)

            retrieveSuggestedLocations()
        }
    }

    // MARK: Public methods

    func suggestedLocationAtIndex(indexPath: IndexPath) -> SuggestedLocation? {
        guard 0 <= indexPath.row, indexPath.row < suggestedLocations.value.count else { return nil }
        return suggestedLocations.value[indexPath.row]
    }

    func selectSuggestedLocationAtIndex(indexPath: IndexPath) {
        guard let suggestedLocation = suggestedLocationAtIndex(indexPath: indexPath) else {
            openLocationSelector()
            return
        }

        selectedLocation.value = suggestedLocation

        var locationFullName = suggestedLocation.locationName
        let city = cityFor(location: suggestedLocation)
        if let cityName = city {
            locationFullName = locationFullName + ", " + cityName
        }
        locationFullName = locationFullName.replacingOccurrences(of: "[()]", with: " ", options: [.regularExpression])
        self.locationName.value = locationFullName

        let postalAddress = PostalAddress(address: selectedLocation.value?.locationAddress, city: city, zipCode: nil, state: nil, countryCode: nil, country: nil)
        selectedPlace = Place(postalAddress: postalAddress, location: selectedLocation.value?.locationCoords)
    }

    func mapSnapshotFor(suggestedLocation: SuggestedLocation?) -> UIImage? {
        guard let locationId = suggestedLocation?.locationId,
        let snapshot = mapSnapshotsCache.value[locationId] else { return nil }
        return snapshot
    }

    func indexForSuggestedLocationWith(locationId: String) -> Int? {
        return suggestedLocations.value.index { $0?.locationId == locationId }
    }

    func openLocationSelector() {
        let editLocVM = EditLocationViewModel(mode: .editFilterLocation,
                                              initialPlace: selectedPlace,
                                              distanceRadius: nil)
        editLocVM.locationDelegate = self
        navigator?.openEditLocation(withViewModel: editLocVM)
    }

    func saveDate(date: Date) {
        self.date.value = date
    }

    func sendMeeting() {
        let coords = selectedPlace?.location ?? selectedLocation.value?.locationCoords
        let meeting: AssistantMeeting = AssistantMeeting(meetingType: .requested,
                                                         date: date.value,
                                                         locationName: locationName.value,
                                                         coordinates: coords,
                                                         status: .pending)

        if keyValueStorage.meetingSafetyTipsAlreadyShown ||
            meetingIsSafe(selectedLocation: selectedLocation.value, time: date.value) {
            dataDelegate?.sendMeeting(meeting: meeting)
            navigator?.meetingCreationDidFinish()
        } else {
            navigator?.openMeetingTipsWith(closeCompletion: { [weak self] in
                self?.dataDelegate?.sendMeeting(meeting: meeting)
                self?.navigator?.meetingCreationDidFinish()
            })
        }
    }

    func cancelMeetingCreation() {
        navigator?.meetingCreationDidFinish()
    }

    func openMeetingTips() {
        navigator?.openMeetingTipsWith(closeCompletion: nil)
    }

    // private methods

    private func meetingIsSafe(selectedLocation: SuggestedLocation?, time: Date?) -> Bool {
        guard let _ = selectedLocation, let time = time, time.isSafeTime else { return false }
        return true
    }

    fileprivate func retrieveSuggestedLocations() {
        guard let listingId = listingId else {
            suggestedLocations.value = [nil]
            return
        }
        activityIndicatorActive.value = true
        suggestedLocationsRepository.retrieveSuggestedLocationsForListing(listingId: listingId) { [weak self] result in
            self?.activityIndicatorActive.value = false
            var receivedSuggestions: [SuggestedLocation?] = []
            if let value = result.value {
                value.forEach { suggestedLocation in
                    self?.getMapSnapshotFor(suggestedLocation: suggestedLocation)
                }
                receivedSuggestions = value
            }
            receivedSuggestions.append(nil)
            self?.suggestedLocations.value = receivedSuggestions
        }
    }

    private func getMapSnapshotFor(suggestedLocation: SuggestedLocation) {

        let mapSnapshotOptions = MKMapSnapshotOptions()

        let coordinates = suggestedLocation.locationCoords.coordinates2DfromLocation()
        let region = MKCoordinateRegionMakeWithDistance(coordinates, 300, 300)
        mapSnapshotOptions.region = region

        mapSnapshotOptions.size = CGSize(width: 300, height: 200)
        let snapShotter = MKMapSnapshotter(options: mapSnapshotOptions)

        snapShotter.start(completionHandler: { [weak self] (snapshot, error) in
            if let snapshot = snapshot {
                self?.mapSnapshotsCache.value[suggestedLocation.locationId] = snapshot.image
            } else {
                self?.mapSnapshotsCache.value[suggestedLocation.locationId] = nil
            }
        })
    }

    private func cityFor(location: SuggestedLocation) -> String? {
        if let address = location.locationAddress, let lastAddressComponent = address.components(separatedBy: [","]).last {
            let city = lastAddressComponent.replacingOccurrences(of: "[,]", with: "", options: [.regularExpression]).trimmingCharacters(in: [" "])
            return city
        }
        return nil
    }
}

extension MeetingAssistantViewModel: EditLocationDelegate {
    func editLocationDidSelectPlace(_ place: Place, distanceRadius: Int?) {
        selectedLocation.value = nil
        selectedPlace = place
        var locationFullname = place.name ?? ""
        if let cityName = place.postalAddress?.city, !locationFullname.isEmpty {
            locationFullname = locationFullname + ", " + cityName
        }
        locationName.value = locationFullname
    }
}
