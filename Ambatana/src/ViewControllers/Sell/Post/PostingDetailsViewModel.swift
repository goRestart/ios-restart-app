//
//  PostingDetailsViewModel.swift
//  LetGo
//
//  Created by Juan Iglesias on 04/10/2017.
//  Copyright © 2017 Ambatana. All rights reserved.
//

import RxSwift
import LGCoreKit

protocol PostingDetailsViewModelDelegate: BaseViewModelDelegate {}

class PostingDetailsViewModel : BaseViewModel, ListingAttributePickerTableViewDelegate, PostingAddDetailSummaryTableViewDelegate {
    
    weak var delegate: PostingDetailsViewModelDelegate?
    
    var title: String {
        return step.title
    }
    
    var buttonTitle: String {
        switch step {
        case .bathrooms, .bedrooms, .rooms, .sizeSquareMeters, .offerType, .propertyType, .make, .model, .year:
            return  previousStepIsSummary ? LGLocalizedString.productPostDone : LGLocalizedString.postingButtonSkip
        case .price, .summary:
            return LGLocalizedString.productPostDone
        case .location:
            return LGLocalizedString.changeLocationApplyButton
        }
    }
    
    var shouldFollowKeyboard: Bool {
        switch step {
        case .bathrooms, .bedrooms, .rooms, .sizeSquareMeters, .offerType, .price, .propertyType, .make, .model, .year, .summary:
            return  true
        case .location:
            return false
        }
    }
    
    var isSummaryStep: Bool {
        switch step {
        case .summary:
            return  true
        default:
            return false
        }
    }
    
    var doneButtonStyle: ButtonStyle {
        switch step {
        case .bathrooms, .bedrooms, .rooms, .offerType, .propertyType, .make, .model, .year:
            return .postingFlow
        case .location, .sizeSquareMeters, .summary, .price:
            return .primary(fontSize: .medium)
        }
    }
    
    var buttonFullWidth: Bool {
        switch step {
        case .bathrooms, .bedrooms, .rooms, .sizeSquareMeters, .offerType, .propertyType, .make, .model, .year, .price:
            return false
        case .location, .summary:
            return true
        }
    }
    
    private var currencySymbol: String? {
        guard let countryCode = locationManager.currentLocation?.countryCode else { return nil }
        return currencyHelper.currencyWithCountryCode(countryCode).symbol
    }
    
    private var countryCode: String? {
        return locationManager.currentLocation?.countryCode
    }
    
    func makeContentView(viewControllerDelegate: LGSearchMapViewControllerModelDelegate) -> PostingViewConfigurable? {
        var values: [String]
        switch step {
        case .bathrooms:
            values = NumberOfBathrooms.allValues.flatMap { $0.localizedString }
        case .bedrooms:
            values = NumberOfBedrooms.allValues.flatMap { $0.localizedString }
        case .rooms:
            values = NumberOfRooms.allValues.flatMap { $0.localizedString }
        case .offerType:
            values = RealEstateOfferType.allValues.flatMap { $0.localizedString }
        case .propertyType:
            values = RealEstatePropertyType.allValues.flatMap { $0.localizedString }
        // case .sizeSquareMeters:
            // TODO: add sizeSquareMeters view
        case .price:
            let priceView = PostingAddDetailPriceView(currencySymbol: currencySymbol,
                                                      freeEnabled: featureFlags.freePostingModeAllowed, frame: CGRect.zero)
            priceView.priceListing.asObservable().bind(to: priceListing).disposed(by: disposeBag)
            return priceView
        case .summary:
            let summaryView = PostingAddDetailSummaryTableView(postCategory: postListingState.category, postingFlowType: featureFlags.postingFlowType)
            summaryView.delegate = self
            return summaryView
        case .location:
            let locationView = PostingAddDetailLocation(viewControllerDelegate: viewControllerDelegate,
                                                        currentPlace: postListingState.place)
            locationView.locationSelected.asObservable().bind(to: placeSelected).disposed(by: disposeBag)
            return locationView
        case .year, .make, .model, .sizeSquareMeters:
            return nil
        }
        let view = PostingAttributePickerTableView(values: values, selectedIndex: nil, delegate: self)
        return view
    }
    
    var currentPrice: ListingPrice? {
        return postListingState.price
    }
    
    var currentLocation: LGLocationCoordinates2D? {
        return postListingState.place?.location
    }
    
    private let tracker: Tracker
    private let currencyHelper: CurrencyHelper
    private let locationManager: LocationManager
    private let featureFlags: FeatureFlaggeable
    private let myUserRepository: MyUserRepository
    private let sessionManager: SessionManager
    
    private let step: PostingDetailStep
    private var postListingState: PostListingState
    private var uploadedImageSource: EventParameterPictureSource?
    private let postingSource: PostingSource
    private let postListingBasicInfo: PostListingBasicDetailViewModel
    private let priceListing = Variable<ListingPrice>(Constants.defaultPrice)
    private let placeSelected = Variable<Place?>(nil)
    private let previousStepIsSummary: Bool
    
    weak var navigator: PostListingNavigator?
    private let disposeBag = DisposeBag()
    
    // MARK: - LifeCycle
    
    convenience init(step: PostingDetailStep,
                     postListingState: PostListingState,
                     uploadedImageSource: EventParameterPictureSource?,
                     postingSource: PostingSource,
                     postListingBasicInfo: PostListingBasicDetailViewModel,
                     previousStepIsSummary: Bool) {
        self.init(step: step,
                  postListingState: postListingState,
                  uploadedImageSource: uploadedImageSource,
                  postingSource: postingSource,
                  postListingBasicInfo: postListingBasicInfo,
                  previousStepIsSummary: previousStepIsSummary,
                  tracker: TrackerProxy.sharedInstance,
                  currencyHelper: Core.currencyHelper,
                  locationManager: Core.locationManager,
                  featureFlags: FeatureFlags.sharedInstance,
                  myUserRepository: Core.myUserRepository,
                  sessionManager: Core.sessionManager)
    }
    
    init(step: PostingDetailStep,
         postListingState: PostListingState,
         uploadedImageSource: EventParameterPictureSource?,
         postingSource: PostingSource,
         postListingBasicInfo: PostListingBasicDetailViewModel,
         previousStepIsSummary: Bool,
         tracker: Tracker,
         currencyHelper: CurrencyHelper,
         locationManager: LocationManager,
         featureFlags: FeatureFlaggeable,
         myUserRepository: MyUserRepository,
         sessionManager: SessionManager) {
        self.step = step
        self.postListingState = postListingState
        self.uploadedImageSource = uploadedImageSource
        self.postingSource = postingSource
        self.postListingBasicInfo = postListingBasicInfo
        self.previousStepIsSummary = previousStepIsSummary
        self.tracker = tracker
        self.currencyHelper = currencyHelper
        self.locationManager = locationManager
        self.featureFlags = featureFlags
        self.myUserRepository = myUserRepository
        self.sessionManager = sessionManager
    }
    
    func closeButtonPressed() {
        closeAndPost()
    }
    
    func nextbuttonPressed() {
        guard let next = step.nextStep(postingFlowType: featureFlags.postingFlowType) else {
            postListing(buttonNameType: .summary)
            return
        }
        switch step {
        case .price:
            set(price: priceListing.value)
        case .location:
            update(place: placeSelected.value)
        case .bathrooms, .bedrooms, .make, .model, .year, .offerType, .propertyType, .summary, .sizeSquareMeters, .rooms:
            break
        }
        let nextStep = previousStepIsSummary ? .summary : next
        advanceNextStep(next: nextStep)
    }
    
    
    private func closeAndPost() {
        if postListingState.pendingToUploadImages != nil {
            openPostAbandonAlertNotLoggedIn()
        } else {
            guard let _ = postListingState.lastImagesUploadResult?.value else {
                navigator?.cancelPostListing()
                return
            }
            if let listingParams = retrieveListingParams() {
                let trackingInfo = PostListingTrackingInfo(buttonName: .close,
                                                           sellButtonPosition: postingSource.sellButtonPosition,
                                                           imageSource: uploadedImageSource,
                                                           price: String.fromPriceDouble(postListingState.price?.value ?? 0))
                navigator?.closePostProductAndPostInBackground(params: listingParams,
                                                               trackingInfo: trackingInfo)
            } else {
                navigator?.cancelPostListing()
            }
        }
    }
    
    private func openPostAbandonAlertNotLoggedIn() {
        let title = LGLocalizedString.productPostCloseAlertTitle
        let message = LGLocalizedString.productPostCloseAlertDescription
        let cancelAction = UIAction(interface: .text(LGLocalizedString.productPostCloseAlertCloseButton), action: { [weak self] in
            self?.navigator?.cancelPostListing()
        })
        let postAction = UIAction(interface: .text(LGLocalizedString.productPostCloseAlertOkButton), action: { [weak self] in
            self?.postListing(buttonNameType: .close)
        })
        delegate?.vmShowAlert(title, message: message, actions: [cancelAction, postAction])
    }
    
    private  func postListing(buttonNameType: EventParameterButtonNameType) {
        let trackingInfo = PostListingTrackingInfo(buttonName: buttonNameType, sellButtonPosition: postingSource.sellButtonPosition,
                                                   imageSource: uploadedImageSource, price: String.fromPriceDouble(postListingState.price?.value ?? 0))
        if sessionManager.loggedIn {
            openListingPosting(trackingInfo: trackingInfo)
        } else if let images = postListingState.pendingToUploadImages {
            let loggedInAction = { [weak self] in
                self?.postActionAfterLogin(images: images, trackingInfo: trackingInfo)
                return
            }
            let cancelAction = { [weak self] in
                self?.cancelPostListing()
                return
            }
            navigator?.openLoginIfNeededFromListingPosted(from: .sell, loggedInAction: loggedInAction, cancelAction: cancelAction)
        } else {
            navigator?.cancelPostListing()
        }
    }
    
    
    private func openListingPosting(trackingInfo: PostListingTrackingInfo) {
        guard let _ = postListingState.lastImagesUploadResult?.value, let listingCreationParams = retrieveListingParams() else { return }
        navigator?.openListingCreation(listingParams: listingCreationParams, trackingInfo: trackingInfo)
    }
    
    private func cancelPostListing() {
        navigator?.cancelPostListing()
    }
    
    private func postActionAfterLogin(images: [UIImage]?,
                                      trackingInfo: PostListingTrackingInfo) {
        guard let listingParams = retrieveListingParams(), let images = images else { return }
        navigator?.closePostProductAndPostLater(params: listingParams,
                                                      images: images,
                                                      trackingInfo: trackingInfo)
    }
    
    private func advanceNextStep(next: PostingDetailStep) {
        navigator?.nextPostingDetailStep(step: next, postListingState: postListingState, uploadedImageSource: uploadedImageSource, postingSource: postingSource, postListingBasicInfo: postListingBasicInfo, previousStepIsSummary: false)
    }
    
    private func set(price: ListingPrice) {
        postListingState = postListingState.updating(price: price)
    }
    
    private func retrieveListingParams() -> ListingCreationParams? {
        guard let location = locationManager.currentLocation?.location else { return nil }
        
        let postalAddress = locationManager.currentLocation?.postalAddress ?? PostalAddress.emptyAddress()
        let currency = currencyHelper.currencyWithCountryCode(postalAddress.countryCode ?? Constants.currencyDefault)
        return ListingCreationParams.make(title: postListingBasicInfo.title.value,
                                                                description: postListingBasicInfo.description.value,
                                                                currency: currency,
                                                                location: location,
                                                                postalAddress: postalAddress,
                                                                postListingState: postListingState)
    }
    
    private func update(place: Place?) {
        guard let place = place else { return }
        postListingState = postListingState.updating(place: place)
    }
    
    // MARK: - PostingAddDetailTableViewDelegate 
    
    func indexSelected(index: Int) {
        var numberOfBathrooms: Float? = nil
        var numberOfBedrooms: Int? = nil
        var numberOfLivingRooms: Int? = nil
        var realEstatePropertyType: RealEstatePropertyType? = nil
        var realEstateOfferType: RealEstateOfferType? = nil
        
        switch step {
        case .bathrooms:
            numberOfBathrooms = NumberOfBathrooms.allValues[index].rawValue
        case .bedrooms:
            numberOfBedrooms = NumberOfBedrooms.allValues[index].rawValue
        case .rooms:
            numberOfBedrooms = NumberOfRooms.allValues[index].bedrooms
            numberOfLivingRooms = NumberOfRooms.allValues[index].livingRooms
        case .offerType:
            realEstateOfferType = RealEstateOfferType.allValues[index]
        case .propertyType:
            realEstatePropertyType = RealEstatePropertyType.allValues[index]
        case .price, .sizeSquareMeters, .summary, .location, .make, .model, .year:
            return
        }
        
        var realEstateInfo = postListingState.verticalAttributes?.realEstateAttributes ?? RealEstateAttributes.emptyRealEstateAttributes()
        realEstateInfo = realEstateInfo.updating(propertyType: realEstatePropertyType,
                                                 offerType: realEstateOfferType,
                                                 bedrooms: numberOfBedrooms,
                                                 bathrooms: numberOfBathrooms,
                                                livingRooms: numberOfLivingRooms)
        postListingState = postListingState.updating(realEstateInfo: realEstateInfo)
        delay(0.3) { [weak self] in
            guard let strongSelf = self else { return }
            guard let next = strongSelf.step.nextStep(postingFlowType: strongSelf.featureFlags.postingFlowType) else { return }
            let nextStep = strongSelf.previousStepIsSummary ? .summary : next
            strongSelf.advanceNextStep(next: nextStep)
        }
    }
    
    func indexDeselected(index: Int) {
        var removeBathrooms = false
        var removeBedrooms = false
        var removePropertyType = false
        var removeOfferType = false
        var removeLivingRooms = false
        
        switch step {
        case .bathrooms:
            removeBathrooms = true
        case .bedrooms:
            removeBedrooms = true
        case .offerType:
            removeOfferType = true
        case .propertyType:
            removePropertyType = true
        case .rooms:
            removeBedrooms = true
            removeLivingRooms = true
        case .price, .sizeSquareMeters, .summary, .location, .make, .model, .year:
            return
        }
        if let realEstateInfo = postListingState.verticalAttributes?.realEstateAttributes {
            let realEstateInfo = realEstateInfo.removing(propertyType: removePropertyType,
                                                         offerType: removeOfferType,
                                                         bedrooms: removeBedrooms,
                                                         bathrooms: removeBathrooms,
                                                         livingRooms: removeLivingRooms)
            postListingState = postListingState.updating(realEstateInfo: realEstateInfo)
        }
    }
    
    func indexForValueSelected() -> Int? {
        var positionSelected: Int? = nil
        switch step {
        case .propertyType:
            positionSelected = postListingState.verticalAttributes?.realEstateAttributes?.propertyType?.position
        case .offerType:
            positionSelected = postListingState.verticalAttributes?.realEstateAttributes?.offerType?.position
        case .bedrooms:
            if let bedrooms = postListingState.verticalAttributes?.realEstateAttributes?.bedrooms {
                positionSelected = NumberOfBedrooms(rawValue: bedrooms)?.position
            }
        case .rooms:
            // TODO: think how to select bedrooms + living rooms
            return nil
        case .bathrooms:
            if let bathrooms = postListingState.verticalAttributes?.realEstateAttributes?.bathrooms {
                positionSelected = NumberOfBathrooms(rawValue:bathrooms)?.position
            }
        case .price, .make, .model, .sizeSquareMeters, .year, .location, .summary:
            return nil
        }
        return positionSelected
    }
    
    
    // MARK: - PostingAddDetailSummaryTableViewDelegate
    
    func postingAddDetailSummary(_ postingAddDetailSummary: PostingAddDetailSummaryTableView, didSelectIndex: PostingSummaryOption) {
        
        let event = TrackerEvent.openOptionOnSummary(fieldOpen: EventParameterOptionSummary(optionSelected: didSelectIndex),
                                                     postingType: EventParameterPostingType(category: postListingState.category ?? .unassigned))
        tracker.trackEvent(event)
        navigator?.nextPostingDetailStep(step: didSelectIndex.postingDetailStep, postListingState: postListingState, uploadedImageSource: uploadedImageSource, postingSource: postingSource, postListingBasicInfo: postListingBasicInfo, previousStepIsSummary: true)
    }
    
    func valueFor(section: PostingSummaryOption) -> String? {
        var value: String?
        switch section {
        case .price:
            if let countryCodeValue = countryCode, let price = postListingState.price?.stringValue(currency: currencyHelper.currencyWithCountryCode(countryCodeValue),
                                                                                                  isFreeEnabled: featureFlags.freePostingModeAllowed) {
                value = LGLocalizedString.realEstateSummaryPriceTitle(price)
            }
        case .propertyType:
            value = postListingState.verticalAttributes?.realEstateAttributes?.propertyType?.localizedString
        case .offerType:
            value = postListingState.verticalAttributes?.realEstateAttributes?.offerType?.localizedString
        case .bedrooms:
            if let bedrooms = postListingState.verticalAttributes?.realEstateAttributes?.bedrooms {
                value = NumberOfBedrooms(rawValue: bedrooms)?.summaryLocalizedString
            }
        case .rooms:
            if let bedrooms = postListingState.verticalAttributes?.realEstateAttributes?.bedrooms {
                value = NumberOfRooms(bedrooms: bedrooms, livingRooms: postListingState.verticalAttributes?.realEstateAttributes?.livingRooms).localizedString
            }
        case .bathrooms:
            if let bathrooms = postListingState.verticalAttributes?.realEstateAttributes?.bathrooms {
                value = NumberOfBathrooms(rawValue:bathrooms)?.summaryLocalizedString
            }
        case .sizeSquareMeters:
            if let size = postListingState.verticalAttributes?.realEstateAttributes?.sizeSquareMeters {
                value = String(size)
            }
        case .location:
            value = retrieveCurrentLocationSelected()
        case .make:
            value = postListingState.verticalAttributes?.carAttributes?.make
        case .model:
            value = postListingState.verticalAttributes?.carAttributes?.model
        case .year:
            value = String(describing: postListingState.verticalAttributes?.carAttributes?.year)
        }
        return value
    }
    
    private func retrieveCurrentLocationSelected() -> String? {
        return postListingState.place?.postalAddress?.address ?? myUserRepository.myUser?.location?.postalAddress?.address ?? locationManager.currentLocation?.postalAddress?.address
    }
    
}

