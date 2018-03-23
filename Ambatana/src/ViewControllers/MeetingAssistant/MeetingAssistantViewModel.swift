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


protocol MeetingAssistantDataDelegate: class {
    func sendMeeting(meeting: AssistantMeeting)
}

struct MockSuggestedLocation : SuggestedLocation {
    var objectId: String?
    var locationId: String
    var locationName: String
    var locationAddress: String?
    var locationCoords: LGLocationCoordinates2D
    var imageUrl: String?

    init(id: String, name: String, coords: LGLocationCoordinates2D) {
        self.locationId = id
        self.locationName = name
        self.locationAddress = nil
        self.locationCoords = coords
        self.imageUrl = nil
    }
}

class MeetingAssistantViewModel: BaseViewModel {

    var hardCodedSuggestedLocations: [SuggestedLocation?] {

        let mock1 = MockSuggestedLocation(id: "1221", name: "Starbucks", coords: LGLocationCoordinates2D(latitude: 41.38, longitude: 2.18))
        let mock2 = MockSuggestedLocation(id: "46464", name: "City Hall", coords: LGLocationCoordinates2D(latitude: 41.388, longitude: 2.18))
        let mock3 = MockSuggestedLocation(id: "g4e4", name: "Honest Coffe Place", coords: LGLocationCoordinates2D(latitude: 41.38, longitude: 2.17))
        let mock4 = MockSuggestedLocation(id: "br6j766jb", name: "Papa's", coords: LGLocationCoordinates2D(latitude: 41.388, longitude: 2.17))

        return [mock1, mock2, mock3, mock4]
    }

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

    let date = Variable<Date?>(nil)
    let saveButtonEnabled = Variable<Bool>(false)

    let disposeBag = DisposeBag()

    let locationRepository: LocationRepository

    // MARK: - lifecycle

    convenience init(listingId: String?) {
        self.init(listingId: listingId, locationRepository: Core.locationRepository)
    }

    init(listingId: String?, locationRepository: LocationRepository) {
        self.listingId = listingId
        self.locationRepository = locationRepository
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
            retrieveSuggestedLocations()
        }
    }

    // MARK: Public methods

    func suggestedLocationAtIndex(indexPath: IndexPath) -> SuggestedLocation? {
        guard 0 <= indexPath.row, indexPath.row < suggestedLocations.value.count else { return nil }
        return suggestedLocations.value[indexPath.row]
    }

    func selectSuggestedLocationAtIndex(indexPath: IndexPath) {
        guard 0 <= indexPath.row, indexPath.row < suggestedLocations.value.count else { return }
        selectedLocation.value = suggestedLocations.value[indexPath.row]

        self.locationName.value = selectedLocation.value?.locationName

        let postalAddress = PostalAddress(address: selectedLocation.value?.locationAddress, city: nil, zipCode: nil, state: nil, countryCode: nil, country: nil)
        selectedPlace = Place(postalAddress: postalAddress, location: selectedLocation.value?.locationCoords)
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

        if meetingIsSafe(selectedLocation: selectedLocation.value, time: date.value) {
            dataDelegate?.sendMeeting(meeting: meeting)
            navigator?.meetingCreationDidFinish()
        } else {
            navigator?.openMeetingTipsWith(closingCompletion: { [weak self] in
                self?.dataDelegate?.sendMeeting(meeting: meeting)
                self?.navigator?.meetingCreationDidFinish()
            })
        }
    }

    func cancelMeetingCreation() {
        navigator?.meetingCreationDidFinish()
    }

    func openMeetingTips() {
        navigator?.openMeetingTipsWith(closingCompletion: nil)
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
        locationRepository.retrieveSuggestedLocationsForListing(listingId: listingId) { [weak self] result in
                self?.activityIndicatorActive.value = false
            var receivedSuggestions: [SuggestedLocation?] = []
            if let value = result.value {
                receivedSuggestions = value
            }
            else {
                receivedSuggestions = (self?.hardCodedSuggestedLocations)! // 🦄
            }
            receivedSuggestions.append(nil)
            self?.suggestedLocations.value = receivedSuggestions
        }
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
