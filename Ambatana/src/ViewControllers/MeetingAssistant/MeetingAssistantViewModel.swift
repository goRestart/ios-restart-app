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

protocol SuggestedLocationsDelegate: class {
    func suggestedLocationDidStart()
    func suggestedLocationDidSuccess()
    func suggestedLocationDidFail()
}

protocol MeetingAssistantDataDelegate: class {
    func sendMeeting(meeting: AssistantMeeting)
}

struct SuggestedLocation {
    var locationId: String?
    var locationName: String
    var locationCoords: LGLocationCoordinates2D
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

    var hardCodedSuggestedLocations: [SuggestedLocation]? {

        let mock1 = MockSuggestedLocation(id: "1221", name: "Starbucks", coords: LGLocationCoordinates2D(latitude: 41.38, longitude: 2.18))
        let mock2 = MockSuggestedLocation(id: "46464", name: "City Hall", coords: LGLocationCoordinates2D(latitude: 41.388, longitude: 2.18))
        let mock3 = MockSuggestedLocation(id: "g4e4", name: "Honest Coffe Place", coords: LGLocationCoordinates2D(latitude: 41.38, longitude: 2.17))
        let mock4 = MockSuggestedLocation(id: "br6j766jb", name: "Papa's", coords: LGLocationCoordinates2D(latitude: 41.388, longitude: 2.17))

        return [mock1, mock2, mock3, mock4]
    }

    var suggestedLocations: [SuggestedLocation]?

    var buyerId: String?
    var sellerId: String?

    let locationName = Variable<String?>(nil)

    var selectedPlace: Place?
    let selectedLocation = Variable<SuggestedLocation?>(nil)

    weak var navigator: MeetingAssistantNavigator?
    weak var dataDelegate: MeetingAssistantDataDelegate?
    weak var sugLocDelegate: SuggestedLocationsDelegate?

    let activityIndicatorActive = Variable<Bool>(false)

    let date = Variable<Date?>(nil)
    let saveButtonEnabled = Variable<Bool>(false)

    let disposeBag = DisposeBag()

    let chatRepository: ChatRepository

    // MARK: - lifecycle

    convenience init(buyerId: String?, sellerId: String?) {
        self.init(buyerId: buyerId, sellerId: sellerId, chatRepository: Core.chatRepository)
    }

    init(buyerId: String?, sellerId: String?, chatRepository: ChatRepository) {
        self.buyerId = buyerId
        self.sellerId = sellerId
        self.chatRepository = chatRepository
        super.init()
        setupRx()
    }

    func setupRx() {
        Observable.combineLatest(date.asObservable(), locationName.asObservable()) { ($0, $1) }
            .bindNext { [weak self] (date, locationName) in
                if let _ = date, let _ = locationName {
                    self?.saveButtonEnabled.value = true
                } else {
                    self?.saveButtonEnabled.value = false
                }
            }.addDisposableTo(disposeBag)
    }

    override func didBecomeActive(_ firstTime: Bool) {
        if firstTime {
            retrieveSuggestedLocations()
        }
    }

    // MARK: Public methods

    func suggestedLocationAtIndex(indexPath: IndexPath) -> SuggestedLocation? {
        guard let suggestedLocations = suggestedLocations else { return nil }
        guard 0 <= indexPath.row, indexPath.row < suggestedLocations.count else { return nil }
        return suggestedLocations[indexPath.row]
    }

    func selectSuggestedLocationAtIndex(indexPath: IndexPath) {
        guard let suggestedLocations = suggestedLocations else { return }
        guard 0 <= indexPath.row, indexPath.row < suggestedLocations.count else { return }
        selectedLocation.value = suggestedLocations[indexPath.row]

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
                                                         locationId: selectedLocation.value?.locationId,
                                                         location: coords,
                                                         status: .pending,
                                                         meetingId: nil,
                                                         buyerId: buyerId,
                                                         sellerId: sellerId)
        dataDelegate?.sendMeeting(meeting: meeting)
    }


    // private methods

    fileprivate func retrieveSuggestedLocations() {
        guard let buyerId = buyerId, let sellerId = sellerId else {
            sugLocDelegate?.suggestedLocationDidFail()
            return
        }
        sugLocDelegate?.suggestedLocationDidStart()
        activityIndicatorActive.value = true
        chatRepository.retrieveSuggestedLocationsForBuyer(
            buyerId: buyerId,
            sellerId: sellerId) { [weak self] result in
                self?.activityIndicatorActive.value = false
                if let value = result.value {
                    self?.suggestedLocations = value
                    self?.sugLocDelegate?.suggestedLocationDidSuccess()
                } else if let error = result.error {
                    print("💥 \(error)")

                    self?.suggestedLocations = self?.hardCodedSuggestedLocations
                    self?.sugLocDelegate?.suggestedLocationDidSuccess()

//                    self?.sugLocDelegate?.suggestedLocationDidFail()
                }
        }
    }
}

extension MeetingAssistantViewModel: EditLocationDelegate {
    func editLocationDidSelectPlace(_ place: Place, distanceRadius: Int?) {
        selectedPlace = place
        locationName.value = place.name
    }
}
