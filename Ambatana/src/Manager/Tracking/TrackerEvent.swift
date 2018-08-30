import LGComponents
import LGCoreKit

func ==(a: TrackerEvent, b: TrackerEvent) -> Bool {
    if a.name == b.name && a.actualName == b.actualName,
        let paramsA = a.params, let paramsB = b.params {
        return paramsA.stringKeyParams.keys.count == paramsB.stringKeyParams.keys.count
    }
    return false
}

struct TrackerEvent {
    static let notApply: String = "N/A"
    static let defaultValue = "default"
    static let itemsCountThreshold = 50

    private(set) var name: EventName
    var actualName: String {
        return name.rawValue
    }
    private(set) var params: EventParameters?

    static func location(locationType: LGLocationType?,
                         locationServiceStatus: LocationServiceStatus,
                         typePage: EventParamenterLocationTypePage,
                         zipCodeFilled: Bool?,
                         distanceRadius: Int?) -> TrackerEvent {
        var params = EventParameters()
        if let locationType = locationType {
            params[.locationType] = locationType.rawValue
        }
        params[.typePage] = typePage.rawValue
        if let zipCodeFilled = zipCodeFilled {
            params[.zipCode] = zipCodeFilled ? EventParameterBoolean.trueParameter.rawValue : EventParameterBoolean.falseParameter.rawValue
        } else {
            params[.zipCode] = EventParameterBoolean.notAvailable.rawValue
        }
        if let distanceRadius = distanceRadius {
            params[.filterDistanceRadius] = distanceRadius
        } else {
            params[.filterDistanceRadius] = "default"
        }
        let enabled: Bool
        let allowed: Bool
        switch locationServiceStatus {
        case .enabled(let authStatus):
            enabled = true
            switch authStatus {
            case .authorizedWhenInUse, .authorizedAlways:
                allowed = true
            case .notDetermined, .restricted, .denied:
                allowed = false
            }
        case .disabled:
            enabled = false
            allowed = false
            break
        }
        params[.locationEnabled] = enabled
        params[.locationAllowed] = allowed
        return TrackerEvent(name: .location, params: params)
    }

    static func loginVisit(_ source: EventParameterLoginSourceValue, rememberedAccount: Bool) -> TrackerEvent {
        var params = EventParameters()
        params.addLoginParams(source, rememberedAccount: rememberedAccount)
        return TrackerEvent(name: .loginVisit, params: params)
    }

    static func loginAbandon(_ source: EventParameterLoginSourceValue) -> TrackerEvent {
        var params = EventParameters()
        params.addLoginParams(source)
        return TrackerEvent(name: .loginAbandon, params: params)
    }

    static func loginFB(_ source: EventParameterLoginSourceValue, rememberedAccount: Bool) -> TrackerEvent {
        var params = EventParameters()
        params.addLoginParams(source, rememberedAccount: rememberedAccount)
        return TrackerEvent(name: .loginFB, params: params)
    }
    
    static func loginGoogle(_ source: EventParameterLoginSourceValue, rememberedAccount: Bool) -> TrackerEvent {
        var params = EventParameters()
        params.addLoginParams(source, rememberedAccount: rememberedAccount)
        return TrackerEvent(name: .loginGoogle, params: params)
    }

    static func loginEmail(_ source: EventParameterLoginSourceValue, rememberedAccount: Bool) -> TrackerEvent {
        var params = EventParameters()
        params.addLoginParams(source, rememberedAccount: rememberedAccount)
        return TrackerEvent(name: .loginEmail, params: params)
    }

    static func signupEmail(_ source: EventParameterLoginSourceValue, newsletter: EventParameterBoolean)
        -> TrackerEvent {
            var params = EventParameters()
            params.addLoginParams(source)
            params[.newsletter] = newsletter.rawValue
            return TrackerEvent(name: .signupEmail, params: params)
    }

    static func logout() -> TrackerEvent {
        return TrackerEvent(name: .logout, params: nil)
    }

    static func passwordResetVisit() -> TrackerEvent {
        return TrackerEvent(name: .passwordResetVisit, params: nil)
    }

    static func loginEmailError(_ errorDescription: EventParameterLoginError) -> TrackerEvent {
        var params = EventParameters()

        params[.errorDescription] = errorDescription.description
        params[.errorDetails] = errorDescription.details

        return TrackerEvent(name: .loginEmailError, params: params)
    }

    static func loginFBError(_ errorDescription: EventParameterLoginError) -> TrackerEvent {
        var params = EventParameters()

        params[.errorDescription] = errorDescription.description
        params[.errorDetails] = errorDescription.details

        return TrackerEvent(name: .loginFBError, params: params)
    }

    static func loginGoogleError(_ errorDescription: EventParameterLoginError) -> TrackerEvent {
        var params = EventParameters()

        params[.errorDescription] = errorDescription.description
        params[.errorDetails] = errorDescription.details

        return TrackerEvent(name: .loginGoogleError, params: params)
    }

    static func signupError(_ errorDescription: EventParameterLoginError) -> TrackerEvent {
        var params = EventParameters()

        params[.errorDescription] = errorDescription.description
        params[.errorDetails] = errorDescription.details

        return TrackerEvent(name: .signupError, params: params)
    }

    static func passwordResetError(_ errorDescription: EventParameterLoginError) -> TrackerEvent {
        var params = EventParameters()

        params[.errorDescription] = errorDescription.description
        params[.errorDetails] = errorDescription.details

        return TrackerEvent(name: .passwordResetError, params: params)
    }

    static func loginBlockedAccountStart(_ network: EventParameterAccountNetwork, reason: EventParameterBlockedAccountReason) -> TrackerEvent {
        var params = EventParameters()
        params[.accountNetwork] = network.rawValue
        params[.reason] = reason.rawValue
        return TrackerEvent(name: .loginBlockedAccountStart, params: params)
    }

    static func loginBlockedAccountContactUs(_ network: EventParameterAccountNetwork, reason: EventParameterBlockedAccountReason) -> TrackerEvent {
        var params = EventParameters()
        params[.accountNetwork] = network.rawValue
        params[.reason] = reason.rawValue
        return TrackerEvent(name: .loginBlockedAccountContactUs, params: params)
    }

    static func loginBlockedAccountKeepBrowsing(_ network: EventParameterAccountNetwork, reason: EventParameterBlockedAccountReason) -> TrackerEvent {
        var params = EventParameters()
        params[.accountNetwork] = network.rawValue
        params[.reason] = reason.rawValue
        return TrackerEvent(name: .loginBlockedAccountKeepBrowsing, params: params)
    }

    static func listingList(_ user: User?,
                            categories: [ListingCategory]?,
                            searchQuery: String?,
                            resultsCount: ItemsCount?,
                            feedSource: EventParameterFeedSource,
                            success: EventParameterBoolean,
                            recentItems: EventParameterBoolean) -> TrackerEvent {
        var params = EventParameters()

        params[.feedSource] = feedSource.rawValue
        params[.categoryId] = (categories ?? [.unassigned]).trackValue
        params[.keywordName] = TrackerEvent.notApply
        // Search query
        if let actualSearchQuery = searchQuery {
            params[.searchString] = actualSearchQuery
        }
        if let count = resultsCount {
            params[.numberOfItems] = count.value
        }
        params[.listSuccess] = success.rawValue
        params[.recentItems] = recentItems.rawValue
        return TrackerEvent(name: .listingList, params: params)
    }
    
    static func listingListSectionedFeed(_ user: User?,
                                         categories: [ListingCategory]?,
                                         searchQuery: String?,
                                         sectionItemCount: Int,
                                         inifiteSectionItemCount: Int,
                                         sectionNamesShown: [String],
                                         feedSource: EventParameterFeedSource,
                                         success: EventParameterBoolean) -> TrackerEvent {
        var params = EventParameters()
        
        params[.feedSource] = feedSource.rawValue
        params[.categoryId] = (categories ?? [.unassigned]).trackValue
        params[.keywordName] = TrackerEvent.notApply

        if let actualSearchQuery = searchQuery {
            params[.searchString] = actualSearchQuery
        }
        params[.numberOfItems] = "\(inifiteSectionItemCount)"
        params[.numberOfItemsInSection] = "\(sectionItemCount)"
        params[.sectionShown] = sectionNamesShown.joined(separator: ",")

        params[.listSuccess] = success.rawValue
        return TrackerEvent(name: .listingList, params: params)
    }
    
    static func listingListVertical(category: ListingCategory,
                                    keywords: [String],
                                    matchingFields: [String]) -> TrackerEvent {
        var params = EventParameters()
        params[.categoryId] = String(category.rawValue)
        params[.verticalKeyword] = keywords.isEmpty ? TrackerEvent.notApply : keywords.joined(separator: "_")
        params[.verticalMatchingFields] = matchingFields.isEmpty ? TrackerEvent.notApply : matchingFields.joined(separator: ",")

        return TrackerEvent(name: .listingListVertical, params: params)
    }

    static func exploreCollection(_ collectionTitle: String) -> TrackerEvent {
        var params = EventParameters()
        params[.collectionTitle] = collectionTitle
        return TrackerEvent(name: .exploreCollection, params: params)
    }

    static func searchStart(_ user: User?) -> TrackerEvent {
        let params = EventParameters()

        return TrackerEvent(name: .searchStart, params: params)
    }

    static func searchComplete(_ user: User?, searchQuery: String, isTrending: Bool, success: EventParameterSearchCompleteSuccess, isLastSearch: Bool, isSuggestiveSearch: Bool, suggestiveSearchIndex: Int?, searchRelatedItems: Bool)
        -> TrackerEvent {
            var params = EventParameters()
            params[.searchString] = searchQuery
            params[.searchSuccess] = success.rawValue
            params[.trendingSearch] = isTrending
            params[.lastSearch] = isLastSearch
            params[.searchSuggestion] = isSuggestiveSearch
            params[.searchRelatedItems] = searchRelatedItems
            
            if let suggestiveSearchPosition = suggestiveSearchIndex {
                params[.searchSuggestionPosition] = suggestiveSearchPosition
            }

            return TrackerEvent(name: .searchComplete, params: params)
    }

    static func filterStart() -> TrackerEvent {
        return TrackerEvent(name: .filterStart, params: nil)
    }

    static func filterLocationStart() -> TrackerEvent {
        return TrackerEvent(name: .filterLocationStart, params: nil)
    }

    static func filterComplete(_ filters: ListingFilters, carSellerType: String?, freePostingModeAllowed: Bool) -> TrackerEvent {
        var params = filters.trackingParams
        
        params[.freePosting] = eventParameterFreePostingWithPriceRange(freePostingModeAllowed,
                                                                       priceRange: filters.priceRange).rawValue
        
        if let carSellerType = carSellerType {
            params[.carSellerType] = carSellerType
        }

        return TrackerEvent(name: .filterComplete, params: params)
    }

    static func searchAlertSwitchChanged(userId: String?,
                                         searchKeyword: String?,
                                         enabled: EventParameterBoolean,
                                         source: EventParameterSearchAlertSource) -> TrackerEvent {
        var params = EventParameters()
        params[.userId] = userId
        params[.searchString] = searchKeyword
        params[.enabled] = enabled.rawValue
        params[.searchAlertSource] = source.rawValue
        return TrackerEvent(name: .searchAlertSwitchChanged, params: params)
    }

    static func listingVisitPhotoViewer(_ listing: Listing,
                                        source: EventParameterListingVisitSource,
                                        numberOfPictures: Int) -> TrackerEvent {
        var params = EventParameters()
        params.addListingParams(listing)
        params[.listingVisitSource] = source.rawValue
        params[.photoViewerNumberOfPhotos] = numberOfPictures
        return TrackerEvent(name: .listingVisitPhotoViewer, params: params)
    }

    static func listingVisitPhotoChat(_ listing: Listing,
                                        source: EventParameterListingVisitSource) -> TrackerEvent {
        var params = EventParameters()
        params.addListingParams(listing)
        params[.listingVisitSource] = source.rawValue
        return TrackerEvent(name: .listingVisitPhotoChat, params: params)
    }

    static func listingDetailVisit(_ listing: Listing,
                                   visitUserAction: ListingVisitUserAction,
                                   source: EventParameterListingVisitSource,
                                   feedPosition: EventParameterFeedPosition,
                                   isBumpedUp: EventParameterBoolean,
                                   sellerBadge: EventParameterUserBadge,
                                   isMine: EventParameterBoolean,
                                   containsVideo: EventParameterBoolean,
                                   sectionName: EventParameterSectionName?) -> TrackerEvent {
        var params = EventParameters()
        params.addListingParams(listing)
        params[.userAction] = visitUserAction.rawValue
        params[.listingVisitSource] = source.rawValue
        params[.isBumpedUp] = isBumpedUp.rawValue
        params[.sellerReputationBadge] = sellerBadge.rawValue
        params[.isMine] = isMine.rawValue
        params[.isVideo] = containsVideo.rawValue
        if let sectionName = sectionName?.value {
            params[.sectionPosition] = feedPosition.value
            params[.sectionIdentifier] = sectionName
        } else {
            params[.feedPosition] = feedPosition.value
        }
        return TrackerEvent(name: .listingDetailVisit, params: params)
    }

    static func listingDetailPlayVideo(_ listing: Listing, source: EventParameterListingVisitSource) -> TrackerEvent {
        var params = EventParameters()
        params.addListingParams(listing)
        params[.listingVisitSource] = source.rawValue
        return TrackerEvent(name: .productDetailPlayVideo, params: params)
    }

    static func listingDetailCall(_ listing: Listing,
                                  source: EventParameterListingVisitSource,
                                  typePage: EventParameterTypePage,
                                  sellerAverageUserRating: Float?,
                                  feedPosition: EventParameterFeedPosition,
                                  isFreePosting: EventParameterBoolean,
                                  isBumpedUp: EventParameterBoolean) -> TrackerEvent {
        var params = EventParameters()
        params.addListingParams(listing)
        params[.listingVisitSource] = source.rawValue
        params[.sellerUserRating] = sellerAverageUserRating
        params[.typePage] = typePage.rawValue
        params[.feedPosition] = feedPosition.value
        params[.freePosting] = isFreePosting.rawValue
        params[.isBumpedUp] = isBumpedUp.rawValue
        return TrackerEvent(name: .listingDetailCall, params: params)
    }

    static func chatBannerCall(_ chatListing: ChatListing,
                               source: EventParameterListingVisitSource,
                               typePage: EventParameterTypePage,
                               sellerAverageUserRating: Float?,
                               isFreePosting: EventParameterBoolean,
                               isBumpedUp: EventParameterBoolean) -> TrackerEvent {
        var params = EventParameters()
        params.addChatListingParams(chatListing)
        params[.listingVisitSource] = source.rawValue
        params[.sellerUserRating] = sellerAverageUserRating
        params[.typePage] = typePage.rawValue
        params[.feedPosition] = EventParameterFeedPosition.none.value
        params[.freePosting] = isFreePosting.rawValue
        params[.isBumpedUp] = isBumpedUp.rawValue
        return TrackerEvent(name: .listingDetailCall, params: params)
    }

    static func listingNotAvailable(_ source: EventParameterListingVisitSource, reason: EventParameterNotAvailableReason) -> TrackerEvent {
        var params = EventParameters()
        params[.listingVisitSource] = source.rawValue
        params[.notAvailableReason] = reason.rawValue
        return TrackerEvent(name: .listingNotAvailable, params: params)
    }

    static func listingDetailVisitMoreInfo(_ listing: Listing,
                                           isMine: EventParameterBoolean,
                                           adShown: EventParameterBoolean,
                                           adType: EventParameterAdType?,
                                           queryType: EventParameterAdQueryType?,
                                           query: String?,
                                           visibility: EventParameterAdVisibility?,
                                           errorReason: EventParameterAdSenseRequestErrorReason?) -> TrackerEvent {
        var params = EventParameters()
        params.addListingParams(listing)

        params[.isMine] = isMine.rawValue
        params[.adShown] = adShown.rawValue
        params[.adType] = adType?.stringValue ?? TrackerEvent.notApply
        params[.adQueryType] = queryType?.rawValue ?? TrackerEvent.notApply
        params[.adQuery] = query ?? TrackerEvent.notApply
        params[.adVisibility] = visibility?.rawValue ?? TrackerEvent.notApply
        params[.reason] = errorReason?.rawValue ?? TrackerEvent.notApply

        return TrackerEvent(name: .listingDetailVisitMoreInfo, params: params)
    }

    static func adTapped(listingId: String?,
                                 adType: EventParameterAdType?,
                                 isMine: EventParameterBoolean,
                                 queryType: EventParameterAdQueryType?,
                                 query: String?,
                                 willLeaveApp: EventParameterBoolean,
                                 typePage: EventParameterTypePage,
                                 categories: [ListingCategory]?,
                                 feedPosition: EventParameterFeedPosition) -> TrackerEvent {
        var params = EventParameters()

        params[.listingId] = listingId ?? TrackerEvent.notApply
        params[.adType] = adType?.stringValue ?? TrackerEvent.notApply
        params[.isMine] = isMine.rawValue
        params[.adQueryType] = queryType?.rawValue ?? TrackerEvent.notApply
        params[.adQuery] = query ?? TrackerEvent.notApply
        params[.adActionLeftApp] = willLeaveApp.rawValue
        params[.typePage] = typePage.rawValue
        params[.feedPosition] = feedPosition.value
        params[.categoryId] = (categories ?? [.unassigned]).trackValue

        return TrackerEvent(name: .adTapped, params: params)
    }
    
    static func adShown(listingId: String?,
                         adType: EventParameterAdType?,
                         isMine: EventParameterBoolean,
                         queryType: EventParameterAdQueryType?,
                         query: String?,
                         adShown: EventParameterBoolean,
                         typePage: EventParameterTypePage,
                         categories: [ListingCategory]?,
                         feedPosition: EventParameterFeedPosition) -> TrackerEvent {
        var params = EventParameters()
        
        params[.listingId] = listingId ?? TrackerEvent.notApply
        params[.adType] = adType?.stringValue ?? TrackerEvent.notApply
        params[.isMine] = isMine.rawValue
        params[.adQueryType] = queryType?.rawValue ?? TrackerEvent.notApply
        params[.adQuery] = query ?? TrackerEvent.notApply
        params[.adShown] = adShown.rawValue
        params[.typePage] = typePage.rawValue
        params[.feedPosition] = feedPosition.value
        params[.categoryId] = (categories ?? [.unassigned]).trackValue
        
        return TrackerEvent(name: .adShown, params: params)
    }

    static func listingFavorite(_ listing: Listing, typePage: EventParameterTypePage,
                                isBumpedUp: EventParameterBoolean) -> TrackerEvent {
        var params = EventParameters()
        params.addListingParams(listing)
        params[.typePage] = typePage.rawValue
        params[.isBumpedUp] = isBumpedUp.rawValue
        return TrackerEvent(name: .listingFavorite, params: params)
    }

    static func listingShare(_ listing: Listing, network: EventParameterShareNetwork?,
                             buttonPosition: EventParameterButtonPosition,
                             typePage: EventParameterTypePage, isBumpedUp: EventParameterBoolean) -> TrackerEvent {
        var params = EventParameters()
        params.addListingParams(listing)

        // When starting share if native then the network is considered as N/A
        var actualNetwork = network ?? .notAvailable
        switch actualNetwork {
        case .native:
            actualNetwork = .notAvailable
        case .email, .facebook, .whatsapp, .twitter, .fbMessenger, .telegram, .sms, .copyLink, .notAvailable:
            break
        }
        params[.shareNetwork] = actualNetwork.rawValue
        params[.buttonPosition] = buttonPosition.rawValue
        params[.typePage] = typePage.rawValue
        params[.isBumpedUp] = isBumpedUp.rawValue
        return TrackerEvent(name: .listingShare, params: params)
    }

    static func listingShareCancel(_ listing: Listing, network: EventParameterShareNetwork,
        typePage: EventParameterTypePage) -> TrackerEvent {
            var params = EventParameters()
            params.addListingParams(listing)
            params[.shareNetwork] = network.rawValue
            params[.typePage] = typePage.rawValue
            return TrackerEvent(name: .listingShareCancel, params: params)
    }

    static func listingShareComplete(_ listing: Listing, network: EventParameterShareNetwork,
        typePage: EventParameterTypePage) -> TrackerEvent {
            var params = EventParameters()
            params.addListingParams(listing)
            params[.shareNetwork] = network.rawValue
            params[.typePage] = typePage.rawValue
            return TrackerEvent(name: .listingShareComplete, params: params)
    }

    static func listingDetailOpenChat(_ listing: Listing, typePage: EventParameterTypePage) -> TrackerEvent {
        var params = EventParameters()
        params[.listingId] = listing.objectId
        params[.typePage] = typePage.rawValue
        return TrackerEvent(name: .listingOpenChat, params: params)
    }

    static func listingMarkAsSold(trackingInfo: MarkAsSoldTrackingInfo) -> TrackerEvent {
        let params = trackingInfo.makeEventParameters()
        return TrackerEvent(name: .listingMarkAsSold, params: params)
    }
    
    static func listingMarkAsSoldAtLetgo(trackingInfo: MarkAsSoldTrackingInfo) -> TrackerEvent {
        let params = trackingInfo.makeEventParameters()
        return TrackerEvent(name: .listingMarkAsSoldAtLetgo, params: params)
    }
    
    static func listingMarkAsSoldOutsideLetgo(trackingInfo: MarkAsSoldTrackingInfo) -> TrackerEvent {
        let params = trackingInfo.makeEventParameters()
        return TrackerEvent(name: .listingMarkAsSoldOutsideLetgo, params: params)
    }

    static func listingMarkAsUnsold(_ listing: Listing) -> TrackerEvent {
        var params = EventParameters()
        params[.listingId] = listing.objectId
        params[.listingPrice] = listing.price.value
        params[.listingCurrency] = listing.currency.code
        params[.categoryId] = listing.category.rawValue
        return TrackerEvent(name: .listingMarkAsUnsold, params: params)
    }

    static func listingReport(_ listing: Listing) -> TrackerEvent {
        var params = EventParameters()
        params.addListingParams(listing)
        return TrackerEvent(name: .listingReport, params: params)
    }
    
    static func listingReportError(_ reportError: EventParameterProductReportError) -> TrackerEvent {
        var params = EventParameters()
        params.addRepositoryErrorParams(reportError)
        return TrackerEvent(name: .listingReportError, params: params)
    }

    static func listingSellStart(typePage: EventParameterTypePage,
                                 buttonName: EventParameterButtonNameType?,
                                 sellButtonPosition: EventParameterSellButtonPosition,
                                 category: ListingCategory?) -> TrackerEvent {
        var params = EventParameters()
        params[.typePage] = typePage.rawValue
        params[.listingVisitSource] = typePage.rawValue
        params[.buttonName] = buttonName?.rawValue
        params[.sellButtonPosition] = sellButtonPosition.rawValue
        params[.categoryId] = category?.rawValue ?? TrackerEvent.notApply
        return TrackerEvent(name: .listingSellStart, params: params)
    }
    
    static func listingSellComplete(_ listing: Listing,
                                    buttonName: EventParameterButtonNameType?,
                                    sellButtonPosition: EventParameterSellButtonPosition?,
                                    negotiable: EventParameterNegotiablePrice?,
                                    pictureSource: EventParameterMediaSource?,
                                    videoLength: TimeInterval?,
                                    freePostingModeAllowed: Bool,
                                    typePage: EventParameterTypePage,
                                    machineLearningTrackingInfo: MachineLearningTrackingInfo) -> TrackerEvent {
        var params = EventParameters()
        params[.freePosting] = listing.price.allowFreeFilters(freePostingModeAllowed: freePostingModeAllowed).rawValue
        params[.listingId] = listing.objectId ?? ""
        params[.categoryId] = listing.category.rawValue
        params[.listingName] = listing.name ?? ""
        params[.numberPhotosPosting] = listing.images.count
        params[.sellButtonPosition] = sellButtonPosition?.rawValue
        params[.listingDescription] = !(listing.descr?.isEmpty ?? true)
        params[.typePage] = typePage.rawValue
        if let buttonName = buttonName {
            params[.buttonName] = buttonName.rawValue
        }
        if let negotiable = negotiable {
            params[.negotiablePrice] = negotiable.rawValue
        }
        if let pictureSource = pictureSource {
            params[.pictureSource] = pictureSource.rawValue
        }

        if let videoLength = videoLength {
            params[.videoLength] = videoLength
        }

        switch listing {
        case .car:
            params[.postingType] = EventParameterPostingType.car.rawValue
        case .product:
            params[.postingType] = EventParameterPostingType.stuff.rawValue
        case .realEstate:
            params[.postingType] = EventParameterPostingType.realEstate.rawValue
        case .service:
            params[.postingType] = EventParameterPostingType.service.rawValue
        }
        
        params[.make] = EventParameterMake.make(name: listing.car?.carAttributes.make).name
        params[.model] = EventParameterModel.model(name: listing.car?.carAttributes.model).name
        params[.year] = EventParameterYear.year(year: listing.car?.carAttributes.year).year
        
        params[.mileage] = listing.car?.carAttributes.mileage ?? SharedConstants.parameterNotApply
        params[.bodyType] = listing.car?.carAttributes.bodyType?.rawValue ?? SharedConstants.parameterNotApply
        params[.transmission] = listing.car?.carAttributes.transmission?.rawValue ?? SharedConstants.parameterNotApply
        params[.fuelType] = listing.car?.carAttributes.fuelType?.rawValue ?? SharedConstants.parameterNotApply
        params[.drivetrain] = listing.car?.carAttributes.driveTrain?.rawValue ?? SharedConstants.parameterNotApply
        params[.seats] = listing.car?.carAttributes.seats ?? SharedConstants.parameterNotApply 

        
        if let realEstateAttributes = listing.realEstate?.realEstateAttributes {
            params[.propertyType] = EventParameterStringRealEstate.realEstateParam(name: realEstateAttributes.propertyType?.rawValue).name
            params[.offerType] = EventParameterStringRealEstate.realEstateParam(name: realEstateAttributes.offerType?.rawValue).name
            params[.bathrooms] = EventParameterBathroomsRealEstate.bathrooms(value: realEstateAttributes.bathrooms).name
            params[.bedrooms] = EventParameterBedroomsRealEstate.bedrooms(value: realEstateAttributes.bedrooms).name
            params[.rooms] = EventParameterRoomsRealEstate.rooms(bedrooms: realEstateAttributes.bedrooms, livingRooms: realEstateAttributes.livingRooms).name
            params[.sizeSqrMeters] = EventParameterSizeRealEstate.size(value: realEstateAttributes.sizeSquareMeters).name
        } else {
            params[.propertyType] = EventParameterStringRealEstate.notApply.name
            params[.offerType] = EventParameterStringRealEstate.notApply.name
            params[.bathrooms] = EventParameterBathroomsRealEstate.notApply.name
            params[.bedrooms] = EventParameterBedroomsRealEstate.notApply.name
            params[.rooms] = EventParameterRoomsRealEstate.notApply.name
            params[.sizeSqrMeters] = EventParameterSizeRealEstate.notApply.name
        }
    
        params[.mlPredictiveFlow] = machineLearningTrackingInfo.predictiveFlow
        params[.mlPredictionActive] = machineLearningTrackingInfo.predictionActive
        if let machineLearningData = machineLearningTrackingInfo.data {
            params[.mlPredictedTitle] = machineLearningData.predictedTitle
            params[.mlPredictedPrice] = machineLearningData.predictedPrice
            params[.mlPredictedCategory] = machineLearningData.predictedCategory?.rawValue ?? nil
            params[.listingName] = machineLearningData.title
            params[.listingPrice] = machineLearningData.price
            params[.mlListingCategory] = machineLearningData.category?.rawValue ?? nil
        }
        
        params[.serviceType] = listing.service?.servicesAttributes.typeId ?? SharedConstants.parameterNotApply
        params[.serviceSubtype] = listing.service?.servicesAttributes.subtypeId ?? SharedConstants.parameterNotApply
        params[.serviceListingType] = listing.service?.servicesAttributes.listingType?.rawValue ?? SharedConstants.parameterNotApply
        
        return TrackerEvent(name: .listingSellComplete, params: params)
    }
    
    static func predictedPosting(data: MLPredictionDetailsViewData) -> TrackerEvent {
        var params = EventParameters()
        params[.mlPredictedTitle] = data.predictedTitle
        params[.mlPredictedPrice] = data.predictedPrice
        params[.mlPredictedCategory] = data.predictedCategory?.rawValue ?? nil
        return TrackerEvent(name: .predictedPosting, params: params)
    }
    
    static func listingSellComplete24h(_ listing: Listing) -> TrackerEvent {
        var params = EventParameters()
        params[.listingId] = listing.objectId ?? ""
        return TrackerEvent(name: .listingSellComplete24h, params: params)
    }

    static func listingSellError(_ error: EventParameterPostListingError,
                                 withCategoryId categoryId: Int?) -> TrackerEvent {
        var params = EventParameters()
        params[.errorDescription] = error.description
        params[.categoryId] = categoryId ?? 0
        return TrackerEvent(name: .listingSellError, params: params)
    }

    static func listingSellErrorClose(_ error: EventParameterPostListingError) -> TrackerEvent {
        var params = EventParameters()
        params[.errorDescription] = error.description
        return TrackerEvent(name: .listingSellErrorClose, params: params)
    }

    static func listingSellErrorPost(_ error: EventParameterPostListingError) -> TrackerEvent {
        var params = EventParameters()
        params[.errorDescription] = error.description
        return TrackerEvent(name: .listingSellErrorPost, params: params)
    }

    static func listingSellErrorData(_ error: EventParameterPostListingError) -> TrackerEvent {
        var params = EventParameters()
        params[.errorDescription] = error.description
        params[.errorDetails] = error.details
        return TrackerEvent(name: .listingSellErrorData, params: params)
    }

    static func listingSellConfirmation(_ listing: Listing) -> TrackerEvent {
        var params = EventParameters()
        params[.listingId] = listing.objectId ?? ""
        return TrackerEvent(name: .listingSellConfirmation, params: params)
    }
    
    static func listingsSellConfirmation(listingIds: [String]) -> TrackerEvent {
        var params = EventParameters()
        params[.listingId] = listingIds.joined(separator: ",")
        params[.productCounter] = listingIds.count
        return TrackerEvent(name: .listingSellConfirmation, params: params)
    }

    static func listingSellConfirmationPost(_ listing: Listing, buttonType: EventParameterButtonType) -> TrackerEvent {
        var params = EventParameters()
        params[.listingId] = listing.objectId ?? ""
        params[.buttonType] = buttonType.rawValue
        return TrackerEvent(name: .listingSellConfirmationPost, params: params)
    }

    static func listingSellConfirmationEdit(_ listing: Listing) -> TrackerEvent {
        var params = EventParameters()
        params[.listingId] = listing.objectId ?? ""
        return TrackerEvent(name: .listingSellConfirmationEdit, params: params)
    }

    static func listingSellConfirmationClose(_ listing: Listing) -> TrackerEvent {
        var params = EventParameters()
        params[.listingId] = listing.objectId ?? ""
        return TrackerEvent(name: .listingSellConfirmationClose, params: params)
    }

    static func listingSellConfirmationShare(_ listing: Listing, network: EventParameterShareNetwork)
        -> TrackerEvent {
            var params = EventParameters()
            params[.listingId] = listing.objectId ?? ""
            params[.shareNetwork] = network.rawValue
            return TrackerEvent(name: .listingSellConfirmationShare, params: params)
    }

    static func listingSellConfirmationShareCancel(_ listing: Listing,
        network: EventParameterShareNetwork) -> TrackerEvent {
            var params = EventParameters()
            params[.listingId] = listing.objectId ?? ""
            params[.shareNetwork] = network.rawValue
            return TrackerEvent(name: .listingSellConfirmationShareCancel, params: params)
    }

    static func listingSellConfirmationShareComplete(_ listing: Listing,
        network: EventParameterShareNetwork) -> TrackerEvent {
            var params = EventParameters()
            params[.listingId] = listing.objectId ?? ""
            params[.shareNetwork] = network.rawValue
            return TrackerEvent(name: .listingSellConfirmationShareComplete, params: params)
    }
    
    static func listingSellAbandon(abandonStep: EventParameterPostingAbandonStep,
                                   pictureUploaded: EventParameterBoolean,
                                   loggedUser: EventParameterBoolean,
                                   buttonName: EventParameterButtonNameType) -> TrackerEvent {
        var params = EventParameters()
        params[.abandonStep] = abandonStep.rawValue
        params[.pictureUploaded] = pictureUploaded.rawValue
        params[.loggedUser] = loggedUser.rawValue
        params[.buttonName] = buttonName.rawValue
        return TrackerEvent(name: .listingSellAbandon, params: params)
    }

    static func listingSellPermissionsGrant(type: EventParameterPermissionType) -> TrackerEvent {
        var params = EventParameters()
        params[.permissionType] = type.rawValue
        return TrackerEvent(name: .listingSellPermissionsGrant, params: params)
    }

    static func listingSellCategorySelect(typePage: EventParameterTypePage,
                                          postingType: EventParameterPostingType,
                                          category: ListingCategory) -> TrackerEvent {
        var params = EventParameters()
        params[.listingVisitSource] = typePage.rawValue
        params[.postingType] = postingType.rawValue
        params[.categoryId] = category.rawValue
        return TrackerEvent(name: .listingSellCategorySelect, params: params)
    }

    static func listingSellMediaSource(source: EventParameterMediaSource,
                                       previousSource: EventParameterMediaSource?,
                                       predictiveFlow: Bool) -> TrackerEvent {
        var params = EventParameters()
        params[.source] = source.rawValue
        params[.previousSource] = previousSource?.rawValue ?? ""
        params[.mlPredictiveFlow] = EventParameterBoolean(bool: predictiveFlow).rawValue
        return TrackerEvent(name: .listingSellMediaSource, params: params)
    }

    static func listingSellMediaCapture(source: EventParameterMediaSource,
                                        cameraSide: EventParameterCameraSide? = nil,
                                        fileCount: Int = 1,
                                        hasError: EventParameterBoolean = .falseParameter,
                                        predictiveFlow: EventParameterBoolean) -> TrackerEvent {
        var params = EventParameters()
        params[.mediaType] = source.rawValue
        params[.cameraSide] = cameraSide?.rawValue ?? ""
        params[.hasError] = hasError.rawValue
        params[.fileCount] = fileCount
        params[.mlPredictiveFlow] = predictiveFlow.rawValue
        return TrackerEvent(name: .listingSellMediaCapture, params: params)
    }

    static func listingSellMediaChange(source: EventParameterMediaSource) -> TrackerEvent {
        var params = EventParameters()
        params[.mediaType] = source.rawValue
        return TrackerEvent(name: .listingSellMediaChange, params: params)
    }

    static func listingSellMediaPublish(source: EventParameterMediaSource, size: Int?) -> TrackerEvent {
        var params = EventParameters()
        params[.mediaType] = source.rawValue
        params[.originalFileSize] = size ?? 0
        return TrackerEvent(name: .listingSellMediaPublish, params: params)
    }    
    
    static func listingEditError(_ user: User?,
                                 listing: Listing?,
                                 errorDescription: String?) -> TrackerEvent {
        var params = EventParameters()
        params[.categoryId] = listing?.category.rawValue ?? 0
        params[.listingId] = listing?.objectId ?? ""
        params[.userId] = user?.objectId ?? ""
        params[.errorDescription] = errorDescription ?? ""
        
        return TrackerEvent(name: .listingEditError, params: params)
    }

    static func listingEditStart(_ user: User?, listing: Listing, pageType: EventParameterTypePage?) -> TrackerEvent {
        var params = EventParameters()
        // Product
        params[.listingId] = listing.objectId
        if let pageType = pageType {
            params[.typePage] = pageType.rawValue
        }
        return TrackerEvent(name: .listingEditStart, params: params)
    }

    static func listingEditFormValidationFailed(_ user: User?, listing: Listing, description: String)
        -> TrackerEvent {
            var params = EventParameters()
            // Product
            params[.listingId] = listing.objectId
            // Validation failure description
            params[.description] = description
            return TrackerEvent(name: .listingEditFormValidationFailed, params: params)
    }

    static func listingEditSharedFB(_ user: User?, listing: Listing?) -> TrackerEvent {
        var params = EventParameters()
        // Product
        if let productId = listing?.objectId {
            params[.listingId] = productId
        }
        return TrackerEvent(name: .listingEditSharedFB, params: params)
    }

    static func listingEditComplete(_ user: User?,
                                    listing: Listing,
                                    category: ListingCategory?,
                                    editedFields: [EventParameterEditedFields],
                                    pageType: EventParameterTypePage?
                                    ) -> TrackerEvent {
        var params = EventParameters()
        // Product
        params[.listingId] = listing.objectId
        params[.categoryId] = category?.rawValue ?? 0
        params[.editedFields] = editedFields.map({$0.rawValue}).joined(separator: ",")

        params[.make] = EventParameterMake.make(name: listing.car?.carAttributes.make).name
        params[.model] = EventParameterModel.model(name: listing.car?.carAttributes.model).name
        params[.year] = EventParameterYear.year(year: listing.car?.carAttributes.year).year
        
        params[.mileage] = listing.car?.carAttributes.mileage
        params[.bodyType] = listing.car?.carAttributes.bodyType?.rawValue
        params[.transmission] = listing.car?.carAttributes.transmission?.rawValue
        params[.fuelType] = listing.car?.carAttributes.fuelType?.rawValue
        params[.drivetrain] = listing.car?.carAttributes.driveTrain?.rawValue
        params[.seats] = listing.car?.carAttributes.seats
        
        if let servicesAttributes = listing.service?.servicesAttributes {
            params[.serviceType] = servicesAttributes.typeId ?? SharedConstants.parameterNotApply
            params[.serviceSubtype] = servicesAttributes.subtypeId ?? SharedConstants.parameterNotApply
            params[.serviceListingType] = servicesAttributes.listingType?.rawValue ?? SharedConstants.parameterNotApply
            params[.paymentFrequency] = servicesAttributes.paymentFrequency?.rawValue
        }
        
        if let realEstateAttributes = listing.realEstate?.realEstateAttributes {
            params[.propertyType] = EventParameterStringRealEstate.realEstateParam(name: realEstateAttributes.propertyType?.rawValue).name
            params[.offerType] = EventParameterStringRealEstate.realEstateParam(name: realEstateAttributes.offerType?.rawValue).name
            params[.bathrooms] = EventParameterBathroomsRealEstate.bathrooms(value: realEstateAttributes.bathrooms).name
            params[.bedrooms] = EventParameterBedroomsRealEstate.bedrooms(value: realEstateAttributes.bedrooms).name
            params[.rooms] = EventParameterRoomsRealEstate.rooms(bedrooms: realEstateAttributes.bedrooms, livingRooms: realEstateAttributes.livingRooms).name
            params[.sizeSqrMeters] = EventParameterSizeRealEstate.size(value: realEstateAttributes.sizeSquareMeters).name
        } else {
            params[.propertyType] = EventParameterStringRealEstate.notApply.name
            params[.offerType] = EventParameterStringRealEstate.notApply.name
            params[.bathrooms] = EventParameterBathroomsRealEstate.notApply.name
            params[.bedrooms] = EventParameterBedroomsRealEstate.notApply.name
            params[.rooms] = EventParameterRoomsRealEstate.notApply.name
            params[.sizeSqrMeters] = EventParameterSizeRealEstate.notApply.name
        }
        if let pageType = pageType {
            params[.typePage] = pageType.rawValue
        }
        return TrackerEvent(name: .listingEditComplete, params: params)
    }

    static func listingDeleteStart(_ listing: Listing) -> TrackerEvent {
        var params = EventParameters()
        params[.listingId] = listing.objectId
        return TrackerEvent(name: .listingDeleteStart, params: params)
    }

    static func listingDeleteComplete(_ listing: Listing) -> TrackerEvent {
        var params = EventParameters()
        params[.listingId] = listing.objectId
        return TrackerEvent(name: .listingDeleteComplete, params: params)
    }

    static func relatedListings(listingId: String,
                                source: EventParameterRelatedListingsVisitSource?) -> TrackerEvent {
        var params = EventParameters()
        params[.listingId] = listingId
        if let src = source {
            params[.relatedSource] = src.rawValue
        }
        return TrackerEvent(name: .relatedListings, params: params)
    }
    
    static func relatedListings(listing: Listing,
                                source: EventParameterRelatedListingsVisitSource?) -> TrackerEvent {
        var params = EventParameters()
        params.addListingParams(listing)
        if let src = source {
            params[.relatedSource] = src.rawValue
        }
        return TrackerEvent(name: .relatedListings, params: params)
    }

    static func phoneNumberRequest(typePage: EventParameterTypePage) -> TrackerEvent {
        var params = EventParameters()
        params[.typePage] = typePage.rawValue
        return TrackerEvent(name: .phoneNumberRequest, params: params)
    }

    static func phoneNumberSent(typePage: EventParameterTypePage) -> TrackerEvent {
        var params = EventParameters()
        params[.typePage] = typePage.rawValue
        return TrackerEvent(name: .phoneNumberSent, params: params)
    }

    static func phoneNumberNotNow(typePage: EventParameterTypePage) -> TrackerEvent {
        var params = EventParameters()
        params[.typePage] = typePage.rawValue
        return TrackerEvent(name: .phoneNumberNotNow, params: params)
    }

    static func firstMessage(info: SendMessageTrackingInfo,
                             listingVisitSource: EventParameterListingVisitSource,
                             feedPosition: EventParameterFeedPosition,
                             userBadge: EventParameterUserBadge,
                             containsVideo: EventParameterBoolean,
                             isProfessional: Bool?,
                             sectionName: EventParameterSectionName?) -> TrackerEvent {
        info.set(isProfessional:isProfessional)
        var params = info.params
        params[.listingVisitSource] = listingVisitSource.rawValue
        if let sectionName = sectionName?.value {
            params[.sectionPosition] = feedPosition.value
            params[.sectionIdentifier] = sectionName
        } else {
            params[.feedPosition] = feedPosition.value
        }
        params[.sellerReputationBadge] = userBadge.rawValue
        params[.isVideo] = containsVideo.rawValue
        return TrackerEvent(name: .firstMessage, params: params)
    }

    static func userMessageSent(info: SendMessageTrackingInfo, isProfessional: Bool?) -> TrackerEvent {
        info.set(isProfessional: isProfessional)
        return TrackerEvent(name: .userMessageSent, params: info.params)
    }

    static func undoSentMessage() -> TrackerEvent {
        return TrackerEvent(name: .undoMessageSent, params: nil)
    }

    static func userMessageSentError(info: SendMessageTrackingInfo) -> TrackerEvent {
        return TrackerEvent(name: .userMessageSentError, params: info.params)
    }

    static func chatRelatedItemsStart(_ shownReason: EventParameterRelatedShownReason) -> TrackerEvent {
        var params = EventParameters()
        params[.shownReason] = shownReason.rawValue
        return TrackerEvent(name: .chatRelatedItemsStart, params: params)
    }

    static func chatRelatedItemsComplete(_ itemPosition: Int, shownReason: EventParameterRelatedShownReason) -> TrackerEvent {
        var params = EventParameters()
        params[.itemPosition] = itemPosition
        params[.shownReason] = shownReason.rawValue
        return TrackerEvent(name: .chatRelatedItemsComplete, params: params)
    }
    
    static func chatLetgoServiceQuestionReceived(questionKey: String, listingId: String) -> TrackerEvent {
        var params = EventParameters()
        params[.messageGoal] = questionKey
        params[.listingId] = listingId
        return TrackerEvent(name: .chatLetgoServiceQuestionReceived, params: params)
    }
    
    static func chatLetgoServiceCTAReceived(questionKey: String, listingId: String) -> TrackerEvent {
        var params = EventParameters()
        params[.messageGoal] = questionKey
        params[.listingId] = listingId
        return TrackerEvent(name: .chatLetgoServiceCTAReceived, params: params)
    }

    static func chatCallToActionTapped(ctaKey: String, isLetgoAssistant: EventParameterBoolean) -> TrackerEvent {
        var params = EventParameters()
        params[.messageActionKey] = ctaKey
        params[.isLetgoAssistant] = isLetgoAssistant.rawValue
        return TrackerEvent(name: .chatCallToActionTapped, params: params)
    }

    static func profileVisit(_ user: User, profileType: EventParameterProfileType, typePage: EventParameterTypePage, tab: EventParameterTab)
        -> TrackerEvent {
            var params = EventParameters()
            params[.typePage] = typePage.rawValue
            params[.userToId] = user.objectId
            params[.tab] = tab.rawValue
            params[.profileType] = profileType.rawValue
            params[.sellerReputationBadge] = EventParameterUserBadge(userBadge: user.reputationBadge).rawValue
            return TrackerEvent(name: .profileVisit, params: params)
    }

    static func profileEditStart() -> TrackerEvent {
        return TrackerEvent(name: .profileEditStart, params: nil)
    }

    static func profileEditEditName() -> TrackerEvent {
        return TrackerEvent(name: .profileEditEditName, params: nil)
    }

    static func profileEditEditLocationStart() -> TrackerEvent {
        return TrackerEvent(name: .profileEditEditLocationStart, params: nil)
    }

    static func profileEditEditPicture() -> TrackerEvent {
        return TrackerEvent(name: .profileEditEditPicture, params: nil)
    }

    static func profileOpenPictureDetail() -> TrackerEvent {
        return TrackerEvent(name: .profileOpenUserPicture, params: nil)
    }

    static func profileShareStart(_ type: EventParameterProfileType)  -> TrackerEvent {
        var params = EventParameters()
        params[.profileType] = type.rawValue
        return TrackerEvent(name: .profileShareStart, params: params)
    }

    static func profileShareComplete(_ type: EventParameterProfileType, shareNetwork: EventParameterShareNetwork)
        -> TrackerEvent {
        var params = EventParameters()
        params[.profileType] = type.rawValue
        params[.shareNetwork] = shareNetwork.rawValue
        return TrackerEvent(name: .profileShareComplete, params: params)
    }
    
    static func profileEditEmailStart(withUserId userId: String) -> TrackerEvent {
        var params = EventParameters()
        params[.userId] = userId
        return TrackerEvent(name: .profileEditEmailStart, params: params)
    }
    
    static func profileEditEmailComplete(withUserId userId: String) -> TrackerEvent {
        var params = EventParameters()
        params[.userId] = userId
        return TrackerEvent(name: .profileEditEmailComplete, params: params)
    }

    static func profileEditBioComplete(userId: String) -> TrackerEvent {
        var params = EventParameters()
        params[.userId] = userId
        return TrackerEvent(name: .profileEditBioComplete, params: params)
    }

    static func appInviteFriendStart(_ typePage: EventParameterTypePage) -> TrackerEvent {
            var params = EventParameters()
            params[.typePage] = typePage.rawValue
            return TrackerEvent(name: .appInviteFriendStart, params: params)
    }

    static func appInviteFriend(_ network: EventParameterShareNetwork, typePage: EventParameterTypePage)
        -> TrackerEvent {
            var params = EventParameters()
            params[.shareNetwork] = network.rawValue
            params[.typePage] = typePage.rawValue
            return TrackerEvent(name: .appInviteFriend, params: params)
    }

    static func appInviteFriendCancel(_ network: EventParameterShareNetwork, typePage: EventParameterTypePage)
        -> TrackerEvent {
            var params = EventParameters()
            params[.shareNetwork] = network.rawValue
            params[.typePage] = typePage.rawValue
            return TrackerEvent(name: .appInviteFriendCancel, params: params)
    }

    static func appInviteFriendDontAsk(_ typePage: EventParameterTypePage)
        -> TrackerEvent {
            var params = EventParameters()
            params[.typePage] = typePage.rawValue
            return TrackerEvent(name: .appInviteFriendDontAsk, params: params)
    }

    static func appInviteFriendComplete(_ network: EventParameterShareNetwork, typePage: EventParameterTypePage)
        -> TrackerEvent {
            var params = EventParameters()
            params[.shareNetwork] = network.rawValue
            params[.typePage] = typePage.rawValue
            return TrackerEvent(name: .appInviteFriendComplete, params: params)
    }

    static func appRatingStart(_ source: EventParameterRatingSource) -> TrackerEvent {
        var params = EventParameters()
        params[.appRatingSource] = source.rawValue
        return TrackerEvent(name: .appRatingStart, params: params)
    }

    static func appRatingRate(reason: EventParameterUserDidRateReason?) -> TrackerEvent {
        if let aReason = reason {
            var params = EventParameters()
            params[.appRatingReason] = aReason.rawValue
            return TrackerEvent(name: .appRatingRate, params: params)
        }
        return TrackerEvent(name: .appRatingRate, params: nil)
    }

    static func appRatingSuggest() -> TrackerEvent {
        let params = EventParameters()
        return TrackerEvent(name: .appRatingSuggest, params: params)
    }

    static func appRatingDontAsk() -> TrackerEvent {
        let params = EventParameters()
        return TrackerEvent(name: .appRatingDontAsk, params: params)
    }

    static func appRatingRemindMeLater() -> TrackerEvent {
        let params = EventParameters()
        return TrackerEvent(name: .appRatingRemindMeLater, params: params)
    }

    static func permissionAlertStart(_ permissionType: EventParameterPermissionType,
        typePage: EventParameterTypePage, alertType: EventParameterPermissionAlertType,
        permissionGoToSettings: EventParameterBoolean) -> TrackerEvent {
            var params = EventParameters()
            params[.permissionType] = permissionType.rawValue
            params[.typePage] = typePage.rawValue
            params[.alertType] = alertType.rawValue
            params[.permissionGoToSettings] = permissionGoToSettings.rawValue
            return TrackerEvent(name: .permissionAlertStart, params: params)
    }

    static func permissionAlertCancel(_ permissionType: EventParameterPermissionType,
        typePage: EventParameterTypePage, alertType: EventParameterPermissionAlertType,
        permissionGoToSettings: EventParameterBoolean) -> TrackerEvent {
            var params = EventParameters()
            params[.permissionType] = permissionType.rawValue
            params[.typePage] = typePage.rawValue
            params[.alertType] = alertType.rawValue
            params[.permissionGoToSettings] = permissionGoToSettings.rawValue
            return TrackerEvent(name: .permissionAlertCancel, params: params)
    }

    static func permissionAlertComplete(_ permissionType: EventParameterPermissionType,
        typePage: EventParameterTypePage, alertType: EventParameterPermissionAlertType,
        permissionGoToSettings: EventParameterBoolean) -> TrackerEvent {
            var params = EventParameters()
            params[.permissionType] = permissionType.rawValue
            params[.typePage] = typePage.rawValue
            params[.alertType] = alertType.rawValue
            params[.permissionGoToSettings] = permissionGoToSettings.rawValue
            return TrackerEvent(name: .permissionAlertComplete, params: params)
    }

    static func permissionSystemStart(_ permissionType: EventParameterPermissionType,
        typePage: EventParameterTypePage) -> TrackerEvent {
            var params = EventParameters()
            params[.permissionType] = permissionType.rawValue
            params[.typePage] = typePage.rawValue
            return TrackerEvent(name: .permissionSystemStart, params: params)
    }

    static func permissionSystemCancel(_ permissionType: EventParameterPermissionType,
        typePage: EventParameterTypePage) -> TrackerEvent {
            var params = EventParameters()
            params[.permissionType] = permissionType.rawValue
            params[.typePage] = typePage.rawValue
            return TrackerEvent(name: .permissionSystemCancel, params: params)
    }

    static func permissionSystemComplete(_ permissionType: EventParameterPermissionType,
        typePage: EventParameterTypePage) -> TrackerEvent {
            var params = EventParameters()
            params[.permissionType] = permissionType.rawValue
            params[.typePage] = typePage.rawValue
            return TrackerEvent(name: .permissionSystemComplete, params: params)
    }

    static func profileReport(_ typePage: EventParameterTypePage, reportedUserId: String,
        reason: EventParameterReportReason) -> TrackerEvent{
            var params = EventParameters()
            params[.reportReason] = reason.rawValue
            params[.typePage] = typePage.rawValue
            params[.userToId] = reportedUserId
            return TrackerEvent(name: .profileReport, params: params)
    }

    static func profileBlock(_ typePage: EventParameterTypePage, blockedUsersIds: [String],
                             buttonPosition: EventParameterBlockButtonPosition) -> TrackerEvent{
        var params = EventParameters()
        params[.typePage] = typePage.rawValue
        params[.userToId] = blockedUsersIds.joined(separator: ",")
        params[.blockButtonPosition] = buttonPosition.rawValue
        return TrackerEvent(name: .profileBlock, params: params)
    }

    static func profileUnblock(_ typePage: EventParameterTypePage, unblockedUsersIds: [String]) -> TrackerEvent{
        var params = EventParameters()
        params[.typePage] = typePage.rawValue
        params[.userToId] = unblockedUsersIds.joined(separator: ",")
        return TrackerEvent(name: .profileUnblock, params: params)
    }

    static func userRatingStart(_ userId: String, typePage: EventParameterTypePage) -> TrackerEvent {
        var params = EventParameters()
        params[.userToId] = userId
        params[.typePage] = typePage.rawValue
        return TrackerEvent(name: .userRatingStart, params: params)
    }

    static func userRatingComplete(_ userId: String, typePage: EventParameterTypePage,
                                          rating: Int, hasComments: Bool) -> TrackerEvent {
        var params = EventParameters()
        params[.userToId] = userId
        params[.typePage] = typePage.rawValue
        params[.ratingStars] = rating
        params[.ratingComments] = hasComments
        return TrackerEvent(name: .userRatingComplete, params: params)
    }

    static func openAppExternal(_ campaign: String? = nil, medium: String? = nil, source: DeepLinkSource) -> TrackerEvent {
        var params = EventParameters()
        params[.campaign] = campaign
        params[.medium] = medium
        switch source {
        case let .external(theSource):
            params[.source] = theSource
        case .push:
            params[.source] = "push"
        case .none:
            break
        }
        return TrackerEvent(name: .openApp, params: params)
    }

    static func chatDeleteComplete(numberOfConversations: Int, isInactiveConversation: Bool) -> TrackerEvent {
        var params = EventParameters()
        params[.chatsDeleted] = numberOfConversations
        params[.inactiveConversations] = isInactiveConversation
        return TrackerEvent(name: .chatDeleteComplete, params: params)
    }
    
    static func chatViewInactiveConversations() -> TrackerEvent {
        return TrackerEvent(name: .chatViewInactiveConversations, params: EventParameters())
    }
    
    static func chatInactiveConversationsShown() -> TrackerEvent {
        return TrackerEvent(name: .chatInactiveConversationsShown, params: EventParameters())
    }
    
    static func chatMarkMessagesAsRead() -> TrackerEvent {
        return TrackerEvent(name: .markMessagesAsRead, params: EventParameters())
    }
    
    static func chatUpdateAppWarningShow() -> TrackerEvent {
        return TrackerEvent(name: .chatUpdateAppWarningShow, params: EventParameters())
    }
    
    static func expressChatStart(_ trigger: EventParameterExpressChatTrigger) -> TrackerEvent {
        var params = EventParameters()
        params[.expressChatTrigger] = trigger.rawValue
        return TrackerEvent(name: .expressChatStart, params: params)
    }

    static func expressChatComplete(_ numConversations: Int, trigger: EventParameterExpressChatTrigger) -> TrackerEvent {
        var params = EventParameters()
        params[.expressConversations] = numConversations
        params[.expressChatTrigger] = trigger.rawValue
        return TrackerEvent(name: .expressChatComplete, params: params)
    }

    static func expressChatDontAsk(_ trigger: EventParameterExpressChatTrigger) -> TrackerEvent {
        var params = EventParameters()
        params[.expressChatTrigger] = trigger.rawValue
        return TrackerEvent(name: .expressChatDontAsk, params: params)
    }

    static func surveyStart(userId: String?, surveyUrl: String) -> TrackerEvent {
        var params = EventParameters()
        params[.userId] = userId
        params[.surveyUrl] = surveyUrl
        return TrackerEvent(name: .surveyStart, params: params)
    }

    static func surveyCompleted(userId: String?, surveyUrl: String) -> TrackerEvent {
        var params = EventParameters()
        params[.userId] = userId
        params[.surveyUrl] = surveyUrl
        return TrackerEvent(name: .surveyCompleted, params: params)
    }

    static func verifyAccountStart(_ typePage: EventParameterTypePage) -> TrackerEvent {
        var params = EventParameters()
        params[.typePage] = typePage.rawValue
        return TrackerEvent(name: .verifyAccountStart, params: params)
    }

    static func verifyAccountSelectNetwork(_ typePage: EventParameterTypePage, network: EventParameterAccountNetwork) -> TrackerEvent {
        var params = EventParameters()
        params[.typePage] = typePage.rawValue
        params[.accountNetwork] = network.rawValue
        return TrackerEvent(name: .verifyAccountSelectNetwork, params: params)
    }

    static func verifyAccountComplete(_ typePage: EventParameterTypePage, network: EventParameterAccountNetwork) -> TrackerEvent {
        var params = EventParameters()
        params[.typePage] = typePage.rawValue
        params[.accountNetwork] = network.rawValue
        return TrackerEvent(name: .verifyAccountComplete, params: params)
    }

    static func inappChatNotificationStart() -> TrackerEvent {
        return TrackerEvent(name: .inappChatNotificationStart, params: EventParameters())
    }

    static func inappChatNotificationComplete() -> TrackerEvent {
        return TrackerEvent(name: .inappChatNotificationComplete, params: EventParameters())
    }

    static func signupCaptcha() -> TrackerEvent {
        return TrackerEvent(name: .signupCaptcha, params: EventParameters())
    }
    
    static func loginCaptcha() -> TrackerEvent {
        return TrackerEvent(name: .loginCaptcha, params: EventParameters())
    }

    static func notificationCenterStart() -> TrackerEvent {
        return TrackerEvent(name: .notificationCenterStart, params: EventParameters())
    }

    static func notificationCenterComplete(source: EventParameterNotificationClickArea, cardAction: String?,
                                           notificationCampaign: String?) -> TrackerEvent {
        var params = EventParameters()
        params[.notificationClickArea] = source.name
        // cardAction is passed as string instead of EventParameterCardAction type as retention could send anything on the query parameter.
        params[.notificationAction] = cardAction ?? TrackerEvent.notApply
        params[.notificationCampaign] = notificationCampaign ?? TrackerEvent.notApply
        return TrackerEvent(name: .notificationCenterComplete, params: params)
    }

    static func marketingPushNotifications(_ userId: String?, enabled: Bool) -> TrackerEvent {
        var params = EventParameters()
        params[.userId] = userId
        params[.enabled] = enabled
        return TrackerEvent(name: .marketingPushNotifications, params: params)
    }

    static func bumpBannerShow(type: EventParameterBumpUpType,
                               listingId: String?,
                               storeProductId: String?,
                               isBoost: EventParameterBoolean) -> TrackerEvent {
        var params = EventParameters()
        params[.bumpUpType] = type.rawValue
        params[.listingId] = listingId ?? ""
        params[.storeProductId] = storeProductId ?? TrackerEvent.notApply
        params[.boost] = isBoost.rawValue
        return TrackerEvent(name: .bumpBannerShow, params: params)
    }

    static func bumpBannerInfoShown(type: EventParameterBumpUpType,
                                    listingId: String?,
                                    storeProductId: String?,
                                    typePage: EventParameterTypePage?,
                                    isBoost: EventParameterBoolean) -> TrackerEvent {
        var params = EventParameters()
        params[.bumpUpType] = type.rawValue
        params[.listingId] = listingId ?? ""
        params[.storeProductId] = storeProductId ?? TrackerEvent.notApply
        if let typePage = typePage {
            params[.typePage] = typePage.rawValue
        }
        params[.boost] = isBoost.rawValue
        return TrackerEvent(name: .bumpInfoShown, params: params)
    }

    static func listingBumpUpStart(_ listing: Listing, price: EventParameterBumpUpPrice,
                                   type: EventParameterBumpUpType,
                                   storeProductId: String?,
                                   isPromotedBump: EventParameterBoolean,
                                   typePage: EventParameterTypePage?,
                                   isBoost: EventParameterBoolean) -> TrackerEvent {
        var params = EventParameters()
        params.addListingParams(listing)

        params[.bumpUpPrice] = price.description
        params[.bumpUpType] = type.rawValue
        params[.storeProductId] = storeProductId ?? TrackerEvent.notApply
        params[.promotedBump] = isPromotedBump.rawValue
        if let typePage = typePage {
            params[.typePage] = typePage.rawValue
        }
        params[.boost] = isBoost.rawValue
        return TrackerEvent(name: .bumpUpStart, params: params)
    }

    static func listingBumpUpComplete(_ listing: Listing, price: EventParameterBumpUpPrice,
                                      type: EventParameterBumpUpType,
                                      restoreRetriesCount: Int,
                                      network: EventParameterShareNetwork,
                                      transactionStatus: EventParameterTransactionStatus?,
                                      storeProductId: String?,
                                      isPromotedBump: EventParameterBoolean,
                                      typePage: EventParameterTypePage?,
                                      isBoost: EventParameterBoolean,
                                      paymentId: String?) -> TrackerEvent {
        var params = EventParameters()
        params.addListingParams(listing)
        params[.bumpUpPrice] = price.description
        params[.bumpUpType] = type.rawValue
        params[.retriesNumber] = restoreRetriesCount
        params[.shareNetwork] = network.rawValue
        params[.transactionStatus] = transactionStatus?.rawValue ?? TrackerEvent.notApply
        params[.storeProductId] = storeProductId ?? TrackerEvent.notApply
        params[.promotedBump] = isPromotedBump.rawValue
        if let typePage = typePage {
            params[.typePage] = typePage.rawValue
        }
        params[.boost] = isBoost.rawValue
        params[.paymentId] = paymentId
        return TrackerEvent(name: .bumpUpComplete, params: params)
    }

    static func listingBumpUpFail(type: EventParameterBumpUpType,
                                  listingId: String?,
                                  transactionStatus: EventParameterTransactionStatus?,
                                  storeProductId: String?,
                                  typePage: EventParameterTypePage?,
                                  isBoost: EventParameterBoolean) -> TrackerEvent {
        var params = EventParameters()
        params[.bumpUpType] = type.rawValue
        params[.listingId] = listingId ?? ""
        params[.transactionStatus] = transactionStatus?.rawValue ?? TrackerEvent.notApply
        params[.storeProductId] = storeProductId ?? TrackerEvent.notApply
        if let typePage = typePage {
            params[.typePage] = typePage.rawValue
        }
        params[.boost] = isBoost.rawValue
        return TrackerEvent(name: .bumpUpFail, params: params)
    }

    static func mobilePaymentComplete(paymentId: String, listingId: String?,
                                      transactionStatus: EventParameterTransactionStatus) -> TrackerEvent {
        var params = EventParameters()
        params[.paymentId] = paymentId
        params[.listingId] = listingId ?? ""
        params[.transactionStatus] = transactionStatus.rawValue
        return TrackerEvent(name: .mobilePaymentComplete, params: params)
    }

    static func mobilePaymentFail(reason: String?, listingId: String?,
                                  transactionStatus: EventParameterTransactionStatus) -> TrackerEvent {
        var params = EventParameters()
        params[.reason] = reason ?? ""
        params[.listingId] = listingId ?? ""
        params[.transactionStatus] = transactionStatus.rawValue
        return TrackerEvent(name: .mobilePaymentFail, params: params)
    }

    static func bumpUpNotAllowed(_ reason: EventParameterBumpUpNotAllowedReason) -> TrackerEvent {
        var params = EventParameters()
        params[.reason] = reason.rawValue
        return TrackerEvent(name: .bumpNotAllowed, params: params)
    }

    static func bumpUpNotAllowedContactUs(_ reason: EventParameterBumpUpNotAllowedReason) -> TrackerEvent {
        var params = EventParameters()
        params[.reason] = reason.rawValue
        return TrackerEvent(name: .bumpNotAllowedContactUs, params: params)
    }

    static func bumpUpPromo() -> TrackerEvent {
        let params = EventParameters()
        return TrackerEvent(name: .bumpUpPromo, params: params)
    }

    static func chatWindowVisit(_ typePage: EventParameterTypePage, chatEnabled: Bool) -> TrackerEvent {
        var params = EventParameters()
        params[.typePage] = typePage.rawValue
        params[.chatEnabled] = chatEnabled
        return TrackerEvent(name: .chatWindowVisit, params: params)
    }

    static func chatTabOpen(tabName: EventParameterChatTabName) -> TrackerEvent {
        var params = EventParameters()
        params[.chatTabName] = tabName.rawValue
        return TrackerEvent(name: .chatTabOpen, params: params)
    }
    
    static func emptyStateVisit(typePage: EventParameterTypePage, reason: EventParameterEmptyReason,
                                errorCode:Int?, errorDescription: String?) -> TrackerEvent {
        var params = EventParameters()
        params[.typePage] = typePage.rawValue
        params[.reason] = reason.rawValue
        let errorDetails: String
        if let errorCode = errorCode {
            errorDetails = String(errorCode)
        } else if let errorDescription = errorDescription {
            errorDetails = errorDescription
        } else {
            errorDetails = TrackerEvent.notApply
        }
        params[.errorDetails] = errorDetails
        return TrackerEvent(name: .emptyStateError, params: params)
    }
    
    static func userRatingReport(userFromId: String?,
                              ratingStars: Int) -> TrackerEvent{
        var params = EventParameters()
        params[.ratingStars] = ratingStars
        params[.userFromId] = userFromId
        return TrackerEvent(name: .userRatingReport, params: params)
    }
    
    static func filterCategoryHeaderSelected(position: Int, name: String) -> TrackerEvent {
        var params = EventParameters()
        params[.bubblePosition] = position
        params[.bubbleName] = name
        return TrackerEvent(name: .filterBubble, params: params)
    }
    
    static func categoriesStart(source: EventParameterTypePage) -> TrackerEvent {
        var params = EventParameters()
        params[.typePage] = source.rawValue
        return TrackerEvent(name: .categoriesStart, params: params)
    }
    
    static func categoriesComplete(keywordName: String, source: EventParameterTypePage) -> TrackerEvent {
        var params = EventParameters()
        params[.keywordName] = keywordName
        params[.typePage] = source.rawValue
        return TrackerEvent(name: .categoriesComplete, params: params)
    }
    
    static func listingSellYourStuffButton() -> TrackerEvent {
        let params = EventParameters()
        return TrackerEvent(name: .listingSellYourStuffButton, params: params)
    }

    static func productDetailOpenFeaturedInfoForListing(listingId: String?) -> TrackerEvent {
        var params = EventParameters()
        params[.listingId] = listingId ?? ""
        return TrackerEvent(name: .featuredMoreInfo, params: params)
    }
    
    static func openOptionOnSummary(fieldOpen: EventParameterOptionSummary, postingType: EventParameterPostingType) -> TrackerEvent {
        var params = EventParameters()
        params[.openField] = fieldOpen.rawValue
        params[.postingType] = postingType.rawValue
        return TrackerEvent(name: .openOptionOnSummary, params: params)
    }
    
    static func tutorialDialogStart(typePage: EventParameterTypePage,
                                    typeTutorialDialog: EventParameterTutorialType) -> TrackerEvent {
        var params = EventParameters()
        params[.typePage] = typePage.rawValue
        params[.typeTutorialDialog] = typeTutorialDialog.rawValue
        return TrackerEvent(name: .tutorialDialogStart, params: params)
    }
    
    static func tutorialDialogComplete(typePage: EventParameterTypePage,
                                       typeTutorialDialog: EventParameterTutorialType) -> TrackerEvent {
        var params = EventParameters()
        params[.typePage] = typePage.rawValue
        params[.typeTutorialDialog] = typeTutorialDialog.rawValue
        return TrackerEvent(name: .tutorialDialogComplete, params: params)
    }
    
    static func tutorialDialogAbandon(typePage: EventParameterTypePage,
                                       typeTutorialDialog: EventParameterTutorialType,
                                       pageNumber: Int) -> TrackerEvent {
        var params = EventParameters()
        params[.typePage] = typePage.rawValue
        params[.typeTutorialDialog] = typeTutorialDialog.rawValue
        params[.pageNumber] = pageNumber
        return TrackerEvent(name: .tutorialDialogAbandon, params: params)
    }

    static func assistantMeetingStartFor(listingId: String?) -> TrackerEvent {
        var params = EventParameters()
        params[.listingId] = listingId ?? TrackerEvent.notApply
        return TrackerEvent(name: .assistantMeetingStart, params: params)
    }

    static func listingOpenListingMap(action: EventParameterMapUserAction,
                                      returnedResults: EventParameterBoolean,
                                      featuredResults: Int,
                                      filters: ListingFilters) -> TrackerEvent {
        var params = filters.trackingParams
        params[.action] = action.rawValue
        params[.returnedResults] = returnedResults.rawValue
        params[.featuredResults] = featuredResults
        return TrackerEvent(name: .productListMapShow, params: params)
    }
    
    static func listingMapOpenPreviewMap(_ listing: Listing,
                                         source: EventParameterListingVisitSource,
                                         userId: String,
                                         isMine: EventParameterBoolean) -> TrackerEvent {
        var params = EventParameters()
        params.addListingParams(listing)
        params[.listingVisitSource] = source.rawValue
        params[.isVideo] = EventParameterBoolean(bool: listing.containsVideo()).rawValue
        params[.isBumpedUp] = EventParameterBoolean(bool: listing.featured ?? false).rawValue
        params[.userToId] = userId
        params[.sellerReputationBadge] = EventParameterBoolean.notAvailable.rawValue
        params[.isMine] = isMine.rawValue
        return TrackerEvent(name: .productDetailPreview, params: params)
    }
    
    static func userDidTakeScreenshot() -> TrackerEvent {
        return TrackerEvent(name: .screenshot, params: nil)
    }

    static func sessionOneMinuteFirstWeek() -> TrackerEvent {
        return TrackerEvent(name: .sessionOneMinuteFirstWeek, params: nil)
    }
    
    static func notificationsEditStart() -> TrackerEvent {
        return TrackerEvent(name: .notificationsEditStart, params: nil)
    }
    
    static func pushNotificationsEditStart(dynamicParameters: [String: Bool],
                                           marketingNoticationsEnabled: Bool) -> TrackerEvent {
        var dynamicParams = TrackerEvent.makeDynamicEventParameters(dynamicParameters: dynamicParameters)
        dynamicParams[.marketingNotificationsEnabled] = marketingNoticationsEnabled
        return TrackerEvent(name: .pushNotificationsEditStart, params: dynamicParams)
    }
    
    static func mailNotificationsEditStart(dynamicParameters: [String: Bool]) -> TrackerEvent {
        let dynamicParams = TrackerEvent.makeDynamicEventParameters(dynamicParameters: dynamicParameters)
        return TrackerEvent(name: .emailNotificationsEditStart, params: dynamicParams)
    }
    
    static private func makeDynamicEventParameters(dynamicParameters: [String: Bool]) -> EventParameters {
        var dynamicParams = EventParameters()
        let parameterEnabledAddition = "-enabled"
        for (parameterName, boolValue) in dynamicParameters {
            dynamicParams["\(parameterName)\(parameterEnabledAddition)"] = boolValue
        }
        return dynamicParams
    }

    static func openCommunityFromProductList(showingBanner: Bool, bannerType: EventBannerType) -> TrackerEvent {
        var params = EventParameters()
        params[.showingBanner] = EventParameterBoolean(bool: showingBanner).rawValue
        params[.bannerType] = bannerType.rawValue
        return TrackerEvent(name: .openCommunity, params: params)
    }
    
    static func openCommunityFromTabBar() -> TrackerEvent {
        return TrackerEvent(name: .openCommunity, params: nil)
    }

    static func phoneNumberEditStart() -> TrackerEvent {
        return TrackerEvent(name: .phoneNumberEditStart, params: nil)
    }

    static func phoneNumberEditComplete() -> TrackerEvent {
        return TrackerEvent(name: .phoneNumberEditComplete, params: nil)
    }
    
    
    // MARK: - Private methods
    
    static func eventParameterFreePostingWithPriceRange(_ freePostingModeAllowed: Bool,
                                                                priceRange: FilterPriceRange) -> EventParameterBoolean {
        guard freePostingModeAllowed else {return .notAvailable}
        return priceRange.free ? .trueParameter : .falseParameter
    }
    
    static func showNewItemsBadge() -> TrackerEvent {
        return TrackerEvent(name: .showNewItemsBadge, params: nil)
    }
}

typealias ItemsCount = Int
fileprivate extension ItemsCount {
    var value: String {
        get {
            guard self <= TrackerEvent.itemsCountThreshold else {
                return "50"
            }
            return "\(self)"
        }
    }
}
