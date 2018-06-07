import RxSwift
import LGCoreKit
import LGComponents

protocol PostingDetailsViewModelDelegate: BaseViewModelDelegate {}

class PostingDetailsViewModel : BaseViewModel, ListingAttributePickerTableViewDelegate, PostingAddDetailSummaryTableViewDelegate {
    
    weak var delegate: PostingDetailsViewModelDelegate?
    
    var title: String {
        return step.title
    }
    
    var subtitle: String? {
        return step.subtitle
    }
    
    var buttonTitle: String {
        switch step {
        case .bathrooms, .bedrooms, .rooms, .offerType, .propertyType, .make, .model, .year:
            return  previousStepIsSummary ? R.Strings.productPostDone : R.Strings.postingButtonSkip
        case .price, .summary:
            return R.Strings.productPostDone
        case .location:
            return R.Strings.changeLocationApplyButton
        case .sizeSquareMeters:
            let value = previousStepIsSummary ? R.Strings.productPostDone : R.Strings.postingButtonSkip
            return sizeListing.value == nil ? value : R.Strings.productPostDone
        case .servicesSubtypes:
            return R.Strings.productPostUsePhoto
        }
    }
    
    var shouldFollowKeyboard: Bool {
        switch step {
        case .bathrooms, .bedrooms, .rooms, .sizeSquareMeters, .offerType, .price, .propertyType, .make, .model, .year, .summary, .servicesSubtypes:
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
        case .location, .summary, .price, .servicesSubtypes:
            return .primary(fontSize: .medium)
        case .sizeSquareMeters:
            return sizeListing.value == nil ? .postingFlow : .primary(fontSize: .medium)
        }
    }
    
    var buttonFullWidth: Bool {
        switch step {
        case .bathrooms, .bedrooms, .rooms, .sizeSquareMeters, .offerType, .propertyType, .make, .model, .year, .price, .servicesSubtypes:
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
            values = RealEstatePropertyType.allValues(postingFlowType: featureFlags.postingFlowType).flatMap { $0.localizedString }
        case .sizeSquareMeters:
            let sizeView = PostingAddDetailSizeView(frame: CGRect.zero)
            sizeView.sizeListingObservable.bind(to: sizeListing).disposed(by: disposeBag)
            return sizeView
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
        case .year, .make, .model:
            return nil
        case .servicesSubtypes:
            // TODO: ABIOS-4290 update with all subtypes 
            let serviceSubtypes = servicesInfoRepository.serviceSubtypes(forServiceTypeId: "c883a0d2-476c-47b0-b08f-9cb8c5c5ced2")
            let postServicesView = PostingMultiSelectionView(theme: .light, subtypes: serviceSubtypes)
            return postServicesView
        }
        let view = PostingAttributePickerTableView(values: values, selectedIndexes: [], delegate: self)
        return view
    }
    
    var currentPrice: ListingPrice? {
        return postListingState.price
    }
    
    var currentSizeSquareMeters: Int? {
        return postListingState.sizeSquareMeters
    }
    
    var currentLocation: LGLocationCoordinates2D? {
        return postListingState.place?.location
    }
    
    var sizeListingObservable: Observable<Int?> {
        return sizeListing.asObservable()
    }
    
    private let tracker: Tracker
    private let currencyHelper: CurrencyHelper
    private let locationManager: LocationManager
    private let featureFlags: FeatureFlaggeable
    private let myUserRepository: MyUserRepository
    private let imageMultiplierRepository: ImageMultiplierRepository
    private let sessionManager: SessionManager
    
    private let step: PostingDetailStep
    private var postListingState: PostListingState
    private var uploadedImageSource: EventParameterPictureSource?
    private var uploadedVideoLength: TimeInterval?
    private let postingSource: PostingSource
    private let postListingBasicInfo: PostListingBasicDetailViewModel
    private let priceListing = Variable<ListingPrice>(Constants.defaultPrice)
    private let sizeListing = Variable<Int?>(nil)
    private let placeSelected = Variable<Place?>(nil)
    private let previousStepIsSummary: Bool
    private let servicesInfoRepository: ServicesInfoRepository
    
    weak var navigator: PostListingNavigator?
    private let disposeBag = DisposeBag()
    
    // MARK: - LifeCycle
    
    convenience init(step: PostingDetailStep,
                     postListingState: PostListingState,
                     uploadedImageSource: EventParameterPictureSource?,
                     uploadedVideoLength: TimeInterval?,
                     postingSource: PostingSource,
                     postListingBasicInfo: PostListingBasicDetailViewModel,
                     previousStepIsSummary: Bool) {
        self.init(step: step,
                  postListingState: postListingState,
                  uploadedImageSource: uploadedImageSource,
                  uploadedVideoLength: uploadedVideoLength,
                  postingSource: postingSource,
                  postListingBasicInfo: postListingBasicInfo,
                  previousStepIsSummary: previousStepIsSummary,
                  tracker: TrackerProxy.sharedInstance,
                  currencyHelper: Core.currencyHelper,
                  locationManager: Core.locationManager,
                  featureFlags: FeatureFlags.sharedInstance,
                  myUserRepository: Core.myUserRepository,
                  sessionManager: Core.sessionManager,
                  imageMultiplierRepository: Core.imageMultiplierRepository,
                  servicesInfoRepository: Core.servicesInfoRepository)
    }
    
    init(step: PostingDetailStep,
         postListingState: PostListingState,
         uploadedImageSource: EventParameterPictureSource?,
         uploadedVideoLength: TimeInterval?,
         postingSource: PostingSource,
         postListingBasicInfo: PostListingBasicDetailViewModel,
         previousStepIsSummary: Bool,
         tracker: Tracker,
         currencyHelper: CurrencyHelper,
         locationManager: LocationManager,
         featureFlags: FeatureFlaggeable,
         myUserRepository: MyUserRepository,
         sessionManager: SessionManager,
         imageMultiplierRepository: ImageMultiplierRepository,
         servicesInfoRepository: ServicesInfoRepository) {
        
        self.step = step
        self.postListingState = postListingState
        self.uploadedImageSource = uploadedImageSource
        self.uploadedVideoLength = uploadedVideoLength
        self.postingSource = postingSource
        self.postListingBasicInfo = postListingBasicInfo
        self.previousStepIsSummary = previousStepIsSummary
        self.tracker = tracker
        self.currencyHelper = currencyHelper
        self.locationManager = locationManager
        self.featureFlags = featureFlags
        self.myUserRepository = myUserRepository
        self.sessionManager = sessionManager
        self.imageMultiplierRepository = imageMultiplierRepository
        self.servicesInfoRepository = servicesInfoRepository
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
        if priceListing.value != Constants.defaultPrice || previousStepIsSummary {
            set(price: priceListing.value)
        }
        case .location:
            update(place: placeSelected.value)
        case .sizeSquareMeters:
            update(sizeSquareMeters: sizeListing.value)
        case .bathrooms, .bedrooms, .make, .model, .year, .offerType, .propertyType, .summary, .rooms, .servicesSubtypes:
            break
        }
        let nextStep = previousStepIsSummary ? .summary : next
        advanceNextStep(next: nextStep)
    }
    
    private func closeAndPost() {
        if featureFlags.removeCategoryWhenClosingPosting.isActive {
            postListingState = postListingState.removeRealEstateCategory()
        }
        if postListingState.pendingToUploadMedia {
            openPostAbandonAlertNotLoggedIn()
        } else {
            guard let _ = postListingState.lastImagesUploadResult?.value,
                let listingParams = retrieveListingParams() else {
                navigator?.cancelPostListing()
                return
            }

            if featureFlags.showServicesFeatures.isActive && postListingState.category?.isService ?? false {
                // TODO: update with new params ABIOS-4290
                navigator?.closePostProductAndPostInBackground(params: listingParams, trackingInfo: postListingTrackingInfo)
            } else {
                navigator?.closePostProductAndPostInBackground(params: listingParams, trackingInfo: postListingTrackingInfo)
            }
        }
    }
    
    private func closeAndMultipostInBackground(params: [ListingCreationParams],
                                               trackingInfo: PostListingTrackingInfo) {
        
        // TODO: include image id and number of images for this ABIOS-4290
        imageMultiplierRepository.imageMultiplier(ImageMultiplierParams(imageId: "", times: 3)) { [weak self] result in
            
            guard let imagesIds = result.value,
                let modifiedParams = self?.updatedParams(with: params, imagesIds) else {
                let error = result.error ?? RepositoryError.internalError(message: "")
                self?.navigator?.showConfirmation(listingResult: ListingResult(error: error),
                                                  trackingInfo: trackingInfo, modalStyle: true)
                return
            }
            self?.navigator?.closePostServicesAndPostInBackground(params: modifiedParams, trackingInfo: trackingInfo)
        }
    }
    
    private func updatedParams(with params: [ListingCreationParams], _ imagesIds: [String]) -> [ListingCreationParams] {
        // TODO: update params, part of ABIOS-4290
        return params
    }
    
    private var postListingTrackingInfo: PostListingTrackingInfo {
        return PostListingTrackingInfo(buttonName: .close,
                                       sellButtonPosition: postingSource.sellButtonPosition,
                                       imageSource: uploadedImageSource,
                                       videoLength: uploadedVideoLength,
                                       price: String.fromPriceDouble(postListingState.price?.value ?? 0),
                                       typePage: postingSource.typePage,
                                       mostSearchedButton: postingSource.mostSearchedButton,
                                       machineLearningInfo: MachineLearningTrackingInfo.defaultValues())
    }
    
    private func openPostAbandonAlertNotLoggedIn() {
        let title = R.Strings.productPostCloseAlertTitle
        let message = R.Strings.productPostCloseAlertDescription
        let cancelAction = UIAction(interface: .text(R.Strings.productPostCloseAlertCloseButton), action: { [weak self] in
            self?.navigator?.cancelPostListing()
        })
        let postAction = UIAction(interface: .text(R.Strings.productPostCloseAlertOkButton), action: { [weak self] in
            self?.postListing(buttonNameType: .close)
        })
        delegate?.vmShowAlert(title, message: message, actions: [cancelAction, postAction])
    }
    
    private  func postListing(buttonNameType: EventParameterButtonNameType) {
        let trackingInfo = PostListingTrackingInfo(buttonName: buttonNameType,
                                                   sellButtonPosition: postingSource.sellButtonPosition,
                                                   imageSource: uploadedImageSource,
                                                   videoLength: uploadedVideoLength,
                                                   price: String.fromPriceDouble(postListingState.price?.value ?? 0),
                                                   typePage: postingSource.typePage,
                                                   mostSearchedButton: postingSource.mostSearchedButton,
                                                   machineLearningInfo: MachineLearningTrackingInfo.defaultValues())
        if sessionManager.loggedIn {
            openListingPosting(trackingInfo: trackingInfo)
        } else if postListingState.pendingToUploadMedia {
            let loggedInAction: (() -> Void) = { [weak self] in
                self?.postActionAfterLogin(images: self?.postListingState.pendingToUploadImages,
                                           video: self?.postListingState.pendingToUploadVideo, trackingInfo: trackingInfo)
            }
            let cancelAction: (() -> Void) = { [weak self] in
                self?.cancelPostListing()
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
    
    private func postActionAfterLogin(images: [UIImage]?, video: RecordedVideo?, trackingInfo: PostListingTrackingInfo) {        
        guard let listingParams = retrieveListingParams(), let images = images else { return }
        navigator?.closePostProductAndPostLater(params: listingParams,
                                                      images: images,
                                                      video: video,
                                                      trackingInfo: trackingInfo)
    }
    
    private func advanceNextStep(next: PostingDetailStep) {
        navigator?.nextPostingDetailStep(step: next, postListingState: postListingState,
                                         uploadedImageSource: uploadedImageSource, uploadedVideoLength: uploadedVideoLength,
                                         postingSource: postingSource, postListingBasicInfo: postListingBasicInfo,
                                         previousStepIsSummary: false)
    }
    
    private func set(price: ListingPrice) {
        postListingState = postListingState.updating(price: price)
    }
    
    private func retrieveListingParams() -> ListingCreationParams? {
        guard let location = locationManager.currentLocation?.location else { return nil }
        
        let postalAddress = locationManager.currentLocation?.postalAddress ?? PostalAddress.emptyAddress()
        let currency = currencyHelper.currencyWithCountryCode(postalAddress.countryCode ?? Constants.currencyDefault)
        let title = postListingBasicInfo.title.value.isEmpty ? postListingState.verticalAttributes?.generatedTitle(postingFlowType: featureFlags.postingFlowType) : postListingBasicInfo.title.value
        return ListingCreationParams.make(title: title,
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
    
    private func update(sizeSquareMeters: Int?) {
        var realEstateAttributes = postListingState.verticalAttributes?.realEstateAttributes ?? RealEstateAttributes.emptyRealEstateAttributes()
        realEstateAttributes = realEstateAttributes.updating( sizeSquareMeters: sizeSquareMeters)
        postListingState = postListingState.updating(realEstateInfo: realEstateAttributes)
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
            numberOfBedrooms = NumberOfRooms.allValues[index].numberOfBedrooms
            numberOfLivingRooms = NumberOfRooms.allValues[index].numberOfLivingRooms
        case .offerType:
            realEstateOfferType = RealEstateOfferType.allValues[index]
        case .propertyType:
            realEstatePropertyType = RealEstatePropertyType.allValues(postingFlowType: featureFlags.postingFlowType)[index]
        case .price, .sizeSquareMeters, .summary, .location, .make, .model, .year, .servicesSubtypes:
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
        case .price, .sizeSquareMeters, .summary, .location, .make, .model, .year, .servicesSubtypes:
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
            positionSelected = postListingState.verticalAttributes?.realEstateAttributes?.propertyType?.position(postingFlowType: featureFlags.postingFlowType)
        case .offerType:
            positionSelected = postListingState.verticalAttributes?.realEstateAttributes?.offerType?.position
        case .bedrooms:
            if let bedrooms = postListingState.verticalAttributes?.realEstateAttributes?.bedrooms {
                positionSelected = NumberOfBedrooms(rawValue: bedrooms)?.position
            }
        case .rooms:
            if let bedrooms = postListingState.verticalAttributes?.realEstateAttributes?.bedrooms,
                let livingRooms = postListingState.verticalAttributes?.realEstateAttributes?.livingRooms {
                let numberOfRooms = NumberOfRooms(numberOfBedrooms: bedrooms,
                                                  numberOfLivingRooms: livingRooms)
                positionSelected = numberOfRooms.positionIn(allValues: NumberOfRooms.allValues)
            }
        case .bathrooms:
            if let bathrooms = postListingState.verticalAttributes?.realEstateAttributes?.bathrooms {
                positionSelected = NumberOfBathrooms(rawValue:bathrooms)?.position
            }
        case .price, .make, .model, .sizeSquareMeters, .year, .location, .summary, .servicesSubtypes:
            return nil
        }
        return positionSelected
    }
    
    
    // MARK: - PostingAddDetailSummaryTableViewDelegate
    
    func postingAddDetailSummary(_ postingAddDetailSummary: PostingAddDetailSummaryTableView, didSelectIndex: PostingSummaryOption) {
        
        let event = TrackerEvent.openOptionOnSummary(fieldOpen: EventParameterOptionSummary(optionSelected: didSelectIndex),
                                                     postingType: EventParameterPostingType(category: postListingState.category ?? .otherItems(listingCategory: nil)))
        tracker.trackEvent(event)
        navigator?.nextPostingDetailStep(step: didSelectIndex.postingDetailStep, postListingState: postListingState,
                                         uploadedImageSource: uploadedImageSource, uploadedVideoLength: uploadedVideoLength,
                                         postingSource: postingSource, postListingBasicInfo: postListingBasicInfo,
                                         previousStepIsSummary: true)
    }
    
    func valueFor(section: PostingSummaryOption) -> String? {
        var value: String?
        switch section {
        case .price:
            if let countryCodeValue = countryCode, let price = postListingState.price?.stringValue(currency: currencyHelper.currencyWithCountryCode(countryCodeValue),
                                                                                                  isFreeEnabled: featureFlags.freePostingModeAllowed) {
                value = R.Strings.realEstateSummaryPriceTitle(price)
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
            if let bedrooms = postListingState.verticalAttributes?.realEstateAttributes?.bedrooms,
                let livingRooms = postListingState.verticalAttributes?.realEstateAttributes?.livingRooms {
                value = NumberOfRooms(numberOfBedrooms: bedrooms, numberOfLivingRooms: livingRooms).localizedString
            }
        case .bathrooms:
            if let bathrooms = postListingState.verticalAttributes?.realEstateAttributes?.bathrooms {
                value = NumberOfBathrooms(rawValue:bathrooms)?.summaryLocalizedString
            }
        case .sizeSquareMeters:
            if let size = postListingState.sizeSquareMeters {
                value = String(size).addingSquareMeterUnit
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

