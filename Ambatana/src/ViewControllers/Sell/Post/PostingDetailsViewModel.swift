//
//  PostingDetailsViewModel.swift
//  LetGo
//
//  Created by Juan Iglesias on 04/10/2017.
//  Copyright © 2017 Ambatana. All rights reserved.
//

import RxSwift
import LGCoreKit


class PostingDetailsViewModel : BaseViewModel, PostingAddDetailTableViewDelegate, PostingAddDetailSummaryTableViewDelegate {
    
    var title: String {
        return step.title
    }
    
    var buttonTitle: String {
        switch step {
        case .bathrooms, .bedrooms, .offerType, .price, .propertyType:
            return LGLocalizedString.postingButtonSkip
        default:
            return LGLocalizedString.productPostDone
        }
    }
    
    var makeContentView: UIView {
        var values: [String]
        switch step {
        case .bathrooms:
            values = NumberOfBathrooms.allValues.flatMap { $0.localizedString }
        case .bedrooms:
            values = NumberOfBedrooms.allValues.flatMap { $0.localizedString }
        case .offerType:
            values = RealEstateOfferType.allValues.flatMap { $0.localizedString }
        case .propertyType:
            values = RealEstatePropertyType.allValues.flatMap { $0.localizedString }
        case .price:
            var currencySymbol: String? = nil
            if let countryCode = locationManager.currentLocation?.countryCode {
                currencySymbol = currencyHelper.currencyWithCountryCode(countryCode).symbol
            }
            let priceView = PostingAddDetailPriceView(currencySymbol: currencySymbol,
                                                      freeEnabled: featureFlags.freePostingModeAllowed, frame: CGRect.zero)
            priceView.priceListing.asObservable().bindTo(priceListing).addDisposableTo(disposeBag)
            return priceView
        case .summary:
            let summaryView = PostingAddDetailSummaryTableView(postCategory: postListingState.category)
            summaryView.delegate = self
            return summaryView
        }
        let view: PostingAddDetailTableView = PostingAddDetailTableView(values: values)
        view.delegate = self
        return view
    }
    
    private let tracker: Tracker
    private let currencyHelper: CurrencyHelper
    private let locationManager: LocationManager
    private let featureFlags: FeatureFlaggeable
    private let myUserRepository: MyUserRepository
    
    private let step: PostingDetailStep
    private var postListingState: PostListingState
    private var uploadedImageSource: EventParameterPictureSource?
    private let postingSource: PostingSource
    private let postListingBasicInfo: PostListingBasicDetailViewModel
    private let priceListing = Variable<ListingPrice>(Constants.defaultPrice)
    
    weak var navigator: PostListingNavigator?
    private let disposeBag = DisposeBag()
    
    // MARK: - LifeCycle
    
    convenience init(step: PostingDetailStep,
                     postListingState: PostListingState,
                     uploadedImageSource: EventParameterPictureSource?,
                     postingSource: PostingSource,
                     postListingBasicInfo: PostListingBasicDetailViewModel) {
        self.init(step: step,
                  postListingState: postListingState,
                  uploadedImageSource: uploadedImageSource,
                  postingSource: postingSource,
                  postListingBasicInfo: postListingBasicInfo,
                  tracker: TrackerProxy.sharedInstance,
                  currencyHelper: Core.currencyHelper,
                  locationManager: Core.locationManager,
                  featureFlags: FeatureFlags.sharedInstance,
                  myUserRepository: Core.myUserRepository)
    }
    
    init(step: PostingDetailStep,
         postListingState: PostListingState,
         uploadedImageSource: EventParameterPictureSource?,
         postingSource: PostingSource,
         postListingBasicInfo: PostListingBasicDetailViewModel,
         tracker: Tracker,
         currencyHelper: CurrencyHelper,
         locationManager: LocationManager,
         featureFlags: FeatureFlaggeable,
         myUserRepository: MyUserRepository) {
        self.step = step
        self.postListingState = postListingState
        self.uploadedImageSource = uploadedImageSource
        self.postingSource = postingSource
        self.postListingBasicInfo = postListingBasicInfo
        self.tracker = tracker
        self.currencyHelper = currencyHelper
        self.locationManager = locationManager
        self.featureFlags = featureFlags
        self.myUserRepository = myUserRepository
    }
    
    func closeButtonPressed() {
        postAndClose()
    }
    
    func nextbuttonPressed() {
        guard let next = step.nextStep else {
            postAndClose()
            return
        }
        if step == .price {
            set(price: priceListing.value)
        }
        advanceNextStep(next: next)
    }
    
    private func postAndClose() {
        navigator?.openLoginIfNeededFromListingPosted(from: .sell, loggedInAction: { [weak self] in
            self?.postListing()
        }, cancelAction: { [weak self] in
            self?.navigator?.cancelPostListing()
        })
    }
    
    private func advanceNextStep(next: PostingDetailStep) {
        navigator?.nextPostingDetailStep(step: next, postListingState: postListingState, uploadedImageSource: uploadedImageSource, postingSource: postingSource, postListingBasicInfo: postListingBasicInfo)
    }
    
    private func postListing() {
        guard let location = locationManager.currentLocation?.location else {
            navigator?.cancelPostListing()
            return
        }
        let postalAddress = locationManager.currentLocation?.postalAddress ?? PostalAddress.emptyAddress()
        let currency = currencyHelper.currencyWithCountryCode(postalAddress.countryCode ?? Constants.currencyDefault)
        let listingCreationParams =  ListingCreationParams.make(title: postListingBasicInfo.title.value,
                                                                description: postListingBasicInfo.description.value,
                                                                currency: currency,
                                                                location: location,
                                                                postalAddress: postalAddress,
                                                                postListingState: postListingState)
        
        let trackingInfo: PostListingTrackingInfo = PostListingTrackingInfo(buttonName: .summary, sellButtonPosition: postingSource.sellButtonPosition, imageSource: uploadedImageSource, price: String(describing: postListingState.price?.value))
        navigator?.closePostProductAndPostInBackground(params: listingCreationParams, trackingInfo: trackingInfo)
    }
    
    private func set(price: ListingPrice) {
        postListingState = postListingState.updating(price: price)
    }
    
    // MARK: - PostingAddDetailTableViewDelegate 
    
    func indexSelected(index: Int) {
        var numberOfBathrooms: NumberOfBathrooms? = nil
        var numberOfBedrooms: NumberOfBedrooms? = nil
        var realEstatePropertyType: RealEstatePropertyType? = nil
        var realEstateOfferType: RealEstateOfferType? = nil
        
        switch step {
        case .bathrooms:
            numberOfBathrooms = NumberOfBathrooms.allValues[index]
        case .bedrooms:
            numberOfBedrooms = NumberOfBedrooms.allValues[index]
        case .offerType:
            realEstateOfferType = RealEstateOfferType.allValues[index]
        case .propertyType:
            realEstatePropertyType = RealEstatePropertyType.allValues[index]
        case .price:
            return
        case .summary:
            return
        }

        var realEstateInfo = postListingState.verticalAttributes?.realEstateAttributes ?? RealEstateAttributes.emptyRealEstateAttributes()
        realEstateInfo = realEstateInfo.updating(propertyType: realEstatePropertyType,
                                                 offerType: realEstateOfferType,
                                                 bedrooms: numberOfBedrooms?.rawValue,
                                                 bathrooms: numberOfBathrooms?.rawValue)
        postListingState = postListingState.updating(realEstateInfo: realEstateInfo)
        delay(0.3) { [weak self] in
            guard let next = self?.step.nextStep else { return }
            self?.advanceNextStep(next: next)
        }
    }
    
    func indexDeselected(index: Int) {
        var removeBathrooms = false
        var removeBedrooms = false
        var removePropertyType = false
        var removeOfferType = false
        
        switch step {
        case .bathrooms:
            removeBathrooms = true
        case .bedrooms:
            removeBedrooms = true
        case .offerType:
            removeOfferType = true
        case .propertyType:
            removePropertyType = true
        case .price:
            return
        case .summary:
            return
        }
        if let realEstateInfo = postListingState.verticalAttributes?.realEstateAttributes {
            let realEstateInfo = realEstateInfo.removing(propertyType: removePropertyType, offerType: removeOfferType, bedrooms: removeBedrooms, bathrooms: removeBathrooms)
            postListingState = postListingState.updating(realEstateInfo: realEstateInfo)
        }
    }
    
    
    // MARK: - PostingAddDetailSummaryTableViewDelegate
    
    func postingAddDetailSummary(_ postingAddDetailSummary: PostingAddDetailSummaryTableView, didSelectIndex: Int) {
        navigator?.cancelPostListing()
    }
    
    func valueFor(section: PostingSummaryOption) -> String {
        var value: String?
        switch section {
        case .price:
            value = "missing price"
        case .propertyType:
            value = postListingState.verticalAttributes?.realEstateAttributes?.propertyType?.localizedString
        case .offerType:
            value = postListingState.verticalAttributes?.realEstateAttributes?.offerType?.localizedString
        case .bedrooms:
            value = String(describing: postListingState.verticalAttributes?.realEstateAttributes?.bedrooms)
        case .bathrooms:
            value = String(describing: postListingState.verticalAttributes?.realEstateAttributes?.bathrooms)
        case .location:
            value = myUserRepository.myUser?.location?.postalAddress?.cityStateString
        case .make:
            value = postListingState.verticalAttributes?.carAttributes?.make
        case .model:
            value = postListingState.verticalAttributes?.carAttributes?.model
        case .year:
            value = String(describing: postListingState.verticalAttributes?.carAttributes?.year)
        }
        return value ?? section.emptyLocalizeString
    }
}

