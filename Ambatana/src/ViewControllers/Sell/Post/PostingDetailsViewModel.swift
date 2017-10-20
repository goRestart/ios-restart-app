//
//  PostingDetailsViewModel.swift
//  LetGo
//
//  Created by Juan Iglesias on 04/10/2017.
//  Copyright © 2017 Ambatana. All rights reserved.
//

import RxSwift
import LGCoreKit


class PostingDetailsViewModel : BaseViewModel, PostingAddDetailTableViewDelegate {
    
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
            values = NumberOfBathrooms.allValues.flatMap { $0.value }
        case .bedrooms:
            values = NumberOfBedrooms.allValues.flatMap { $0.value }
        case .offerType:
            values = RealEstateOfferType.allValues.flatMap { $0.value }
        case .propertyType:
            values = RealEstatePropertyType.allValues.flatMap { $0.value }
        case .price:
            return UIView()
        case .summary:
            var currencySymbol: String? = nil
            if let countryCode = locationManager.currentLocation?.countryCode {
                currencySymbol = currencyHelper.currencyWithCountryCode(countryCode).symbol
            }
            return PostAddDetailPriceView(currencySymbol: currencySymbol,
                                          freeEnabled: featureFlags.freePostingModeAllowed, frame: CGRect.zero)
        }
        let view: PostingAddDetailTableView = PostingAddDetailTableView(values: values)
        view.delegate = self
        return view
    }
    
    
    private let tracker: Tracker
    private let currencyHelper: CurrencyHelper
    private let locationManager: LocationManager
    private let featureFlags: FeatureFlags
    
    private let step: PostingDetailStep
    private var postListingState: PostListingState
    private var uploadedImageSource: EventParameterPictureSource?
    private let postingSource: PostingSource
    
    weak var navigator: PostListingNavigator?
    
    // MARK: - LifeCycle
    
    convenience init(step: PostingDetailStep,
                     postListingState: PostListingState,
                     uploadedImageSource: EventParameterPictureSource?,
                     postingSource: PostingSource) {
        self.init(step: step,
                  postListingState: postListingState,
                  uploadedImageSource: uploadedImageSource,
                  postingSource: postingSource,
                  tracker: TrackerProxy.sharedInstance,
                  currencyHelper: Core.currencyHelper,
                  locationManager: Core.locationManager,
                  featureFlags: FeatureFlags.sharedInstance)
    }
    
    init(step: PostingDetailStep,
         postListingState: PostListingState,
         uploadedImageSource: EventParameterPictureSource?,
         postingSource: PostingSource,
         tracker: Tracker,
         currencyHelper: CurrencyHelper,
         locationManager: LocationManager,
         featureFlags: FeatureFlags) {
        self.step = step
        self.postListingState = postListingState
        self.uploadedImageSource = uploadedImageSource
        self.postingSource = postingSource
        self.tracker = tracker
        self.currencyHelper = currencyHelper
        self.locationManager = locationManager
        self.featureFlags = featureFlags
    }
    
    func closeButtonPressed() {
        navigator?.cancelPostListing()
    }
    
    func nextbuttonPressed() {
        guard let next = step.nextStep else {
            postListing()
            return
        }
        navigator?.nextPostingDetailStep(step: next, postListingState: postListingState, uploadedImageSource: uploadedImageSource, postingSource: postingSource)
    }
    
    private func postListing() {
        guard let location = locationManager.currentLocation?.location else {
            navigator?.cancelPostListing()
            return
        }
        let postalAddress = locationManager.currentLocation?.postalAddress ?? PostalAddress.emptyAddress()
        let currency = currencyHelper.currencyWithCountryCode(postalAddress.countryCode ?? Constants.currencyDefault)
        let listingCreationParams =  ListingCreationParams.make(title: "", description: "", currency: currency, location: location, postalAddress: postalAddress, postListingState: postListingState)
        
        let trackingInfo: PostListingTrackingInfo = PostListingTrackingInfo(buttonName: .summary, sellButtonPosition: postingSource.sellButtonPosition, imageSource: uploadedImageSource, price: String(describing: postListingState.price?.value))
        navigator?.closePostProductAndPostInBackground(params: listingCreationParams, trackingInfo: trackingInfo)
        navigator?.cancelPostListing()
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

        var realEstateInfo = postListingState.realEstateInfo ?? RealEstateAttributes.emptyRealEstateAttributes()
        realEstateInfo = realEstateInfo.updating(propertyType: realEstatePropertyType,
                                                 offerType: realEstateOfferType,
                                                 bedrooms: numberOfBedrooms?.rawValue,
                                                 bathrooms: numberOfBathrooms?.rawValue)
        postListingState = postListingState.updating(realEstateInfo: realEstateInfo)
        delay(0.3) { [weak self] in
            self?.nextbuttonPressed()
        }
    }
}
