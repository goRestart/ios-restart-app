//
//  TrackerEvent.swift
//  LetGo
//
//  Created by Albert Hernández López on 05/08/15.
//  Copyright (c) 2015 Ambatana. All rights reserved.
//

import LGCoreKit

func ==(a: TrackerEvent, b: TrackerEvent) -> Bool {
    if a.name == b.name && a.actualName == b.actualName,
        let paramsA = a.params, let paramsB = b.params {
        return paramsA.stringKeyParams.keys.count == paramsB.stringKeyParams.keys.count
    }
    return false
}

struct TrackerEvent {    
    private(set) var name: EventName
    var actualName: String {
        get {
            return name.actualEventName
        }
    }
    private(set) var params: EventParameters?

    static func location(_ location: LGLocation, locationServiceStatus: LocationServiceStatus) -> TrackerEvent {
        var params = EventParameters()
        params[.locationType] = location.type.rawValue
        let enabled: Bool
        let allowed: Bool
        switch locationServiceStatus {
        case .enabled(let authStatus):
            enabled = true
            switch authStatus {
            case .authorized:
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

    static func loginFB(_ source: EventParameterLoginSourceValue, rememberedAccount: Bool,
                        collapsedEmail: EventParameterBoolean?) -> TrackerEvent {
        var params = EventParameters()
        params.addLoginParams(source, rememberedAccount: rememberedAccount, collapsedEmail: collapsedEmail)
        return TrackerEvent(name: .loginFB, params: params)
    }
    
    static func loginGoogle(_ source: EventParameterLoginSourceValue, rememberedAccount: Bool,
                            collapsedEmail: EventParameterBoolean?) -> TrackerEvent {
        var params = EventParameters()
        params.addLoginParams(source, rememberedAccount: rememberedAccount, collapsedEmail: collapsedEmail)
        return TrackerEvent(name: .loginGoogle, params: params)
    }

    static func loginEmail(_ source: EventParameterLoginSourceValue, rememberedAccount: Bool,
                           collapsedEmail: EventParameterBoolean?) -> TrackerEvent {
        var params = EventParameters()
        params.addLoginParams(source, rememberedAccount: rememberedAccount, collapsedEmail: collapsedEmail)
        return TrackerEvent(name: .loginEmail, params: params)
    }

    static func signupEmail(_ source: EventParameterLoginSourceValue, newsletter: EventParameterBoolean,
                            collapsedEmail: EventParameterBoolean?)
        -> TrackerEvent {
            var params = EventParameters()
            params.addLoginParams(source, collapsedEmail: collapsedEmail)
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

    static func productList(_ user: User?, categories: [ListingCategory]?, searchQuery: String?,
                            feedSource: EventParameterFeedSource, success: EventParameterBoolean) -> TrackerEvent {
        var params = EventParameters()

        // Categories
        var categoryIds: [String] = []
        if let actualCategories = categories {
            for category in actualCategories {
                categoryIds.append(String(category.rawValue))
            }
        }
        params[.feedSource] = feedSource.rawValue
        params[.categoryId] = categoryIds.isEmpty ? "0" : categoryIds.joined(separator: ",")

        // Search query
        if let actualSearchQuery = searchQuery {
            params[.searchString] = actualSearchQuery
        }
        params[.listSuccess] = success.rawValue
        return TrackerEvent(name: .productList, params: params)
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

    static func searchComplete(_ user: User?, searchQuery: String, isTrending: Bool, success: EventParameterSearchCompleteSuccess, isLastSearch: Bool)
        -> TrackerEvent {
            var params = EventParameters()
            params[.searchString] = searchQuery
            params[.searchSuccess] = success.rawValue
            params[.trendingSearch] = isTrending
            params[.lastSearch] = isLastSearch
            return TrackerEvent(name: .searchComplete, params: params)
    }

    static func filterStart() -> TrackerEvent {
        return TrackerEvent(name: .filterStart, params: nil)
    }

    static func filterLocationStart() -> TrackerEvent {
        return TrackerEvent(name: .filterLocationStart, params: nil)
    }

    static func filterComplete(_ coordinates: LGLocationCoordinates2D?, distanceRadius: Int?,
                               distanceUnit: DistanceType, categories: [ListingCategory]?, sortBy: ListingSortCriteria?,
                               postedWithin: ListingTimeCriteria?, priceRange: FilterPriceRange, freePostingModeAllowed: Bool,
                               carMake: String?, carModel: String?, carYearStart: Int?, carYearEnd: Int?) -> TrackerEvent {
        var params = EventParameters()

        // Filter Coordinates
        if let actualCoords = coordinates {
            params[.filterLat] = actualCoords.latitude
            params[.filterLng] = actualCoords.longitude
        } else {
            params[.filterLat] = "default"
            params[.filterLng] = "default"
        }

        // Distance
        params[.filterDistanceRadius] = distanceRadius ?? "default"
        params[.filterDistanceUnit] = distanceUnit.string

        // Categories
        var categoryIds: [String] = []
        if let actualCategories = categories {
            for category in actualCategories {
                categoryIds.append(String(category.rawValue))
            }
        }
        params[.categoryId] = categoryIds.isEmpty ? "0" : categoryIds.joined(separator: ",")

        // Sorting
        if let sortByParam = eventParameterSortByTypeForSorting(sortBy) {
            params[.filterSortBy] = sortByParam.rawValue
        }
        if let postedWithin = eventParameterPostedWithinForTime(postedWithin) {
            params[.filterPostedWithin] = postedWithin.rawValue
        }

        params[.priceFrom] = eventParameterHasPriceFilter(priceRange.min).rawValue
        params[.priceTo] = eventParameterHasPriceFilter(priceRange.max).rawValue
        
        params[.freePosting] = eventParameterFreePostingWithPriceRange(freePostingModeAllowed, priceRange: priceRange).rawValue

        params[.make] = carMake ?? "N/A"
        params[.model] = carModel ?? "N/A"
        if let carYearStart = carYearStart {
            params[.yearStart] = String(carYearStart)
        } else {
            params[.yearStart] = "N/A"
        }
        if let carYearEnd = carYearEnd {
            params[.yearEnd] = String(carYearEnd)
        } else {
            params[.yearEnd] = "N/A"
        }

        return TrackerEvent(name: .filterComplete, params: params)
    }

    static func productDetailVisit(_ listing: Listing, visitUserAction: ProductVisitUserAction, source: EventParameterProductVisitSource, feedPosition: EventParameterFeedPosition,
                                   isBumpedUp: EventParameterBoolean) -> TrackerEvent {
        var params = EventParameters()
        params.addListingParams(listing)
        params[.userAction] = visitUserAction.rawValue
        params[.productVisitSource] = source.rawValue
        params[.feedPosition] = feedPosition.value
        params[.isBumpedUp] = isBumpedUp.rawValue
        return TrackerEvent(name: .productDetailVisit, params: params)
    }
    
    static func productNotAvailable(_ source: EventParameterProductVisitSource, reason: EventParameterNotAvailableReason) -> TrackerEvent {
        var params = EventParameters()
        params[.productVisitSource] = source.rawValue
        params[.notAvailableReason] = reason.rawValue
        return TrackerEvent(name: .productNotAvailable, params: params)
    }

    static func productDetailVisitMoreInfo(_ listing: Listing) -> TrackerEvent {
        var params = EventParameters()
        params.addListingParams(listing)
        return TrackerEvent(name: .productDetailVisitMoreInfo, params: params)
    }

    static func productFavorite(_ listing: Listing, typePage: EventParameterTypePage,
                                isBumpedUp: EventParameterBoolean) -> TrackerEvent {
        var params = EventParameters()
        params.addListingParams(listing)
        params[.typePage] = typePage.rawValue
        params[.isBumpedUp] = isBumpedUp.rawValue
        return TrackerEvent(name: .productFavorite, params: params)
    }

    static func productShare(_ listing: Listing, network: EventParameterShareNetwork?,
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
        return TrackerEvent(name: .productShare, params: params)
    }

    static func productShareCancel(_ listing: Listing, network: EventParameterShareNetwork,
        typePage: EventParameterTypePage) -> TrackerEvent {
            var params = EventParameters()
            params.addListingParams(listing)
            params[.shareNetwork] = network.rawValue
            params[.typePage] = typePage.rawValue
            return TrackerEvent(name: .productShareCancel, params: params)
    }

    static func productShareComplete(_ listing: Listing, network: EventParameterShareNetwork,
        typePage: EventParameterTypePage) -> TrackerEvent {
            var params = EventParameters()
            params.addListingParams(listing)
            params[.shareNetwork] = network.rawValue
            params[.typePage] = typePage.rawValue
            return TrackerEvent(name: .productShareComplete, params: params)
    }

    static func productDetailOpenChat(_ listing: Listing, typePage: EventParameterTypePage) -> TrackerEvent {
        var params = EventParameters()
        params[.productId] = listing.objectId
        params[.typePage] = typePage.rawValue
        return TrackerEvent(name: .productOpenChat, params: params)
    }

    static func productMarkAsSold(_ product: ChatListing, typePage: EventParameterTypePage,
                                  freePostingModeAllowed: Bool, isBumpedUp: EventParameterBoolean) -> TrackerEvent {
        return productMarkAsSold(productId: product.objectId, price: product.price,
                                 currency: product.currency.code, categoryId: nil, typePage: typePage,
                                 freePostingModeAllowed: freePostingModeAllowed, isBumpedUp: isBumpedUp)
    }
    static func productMarkAsSold(_ listing: Listing, typePage: EventParameterTypePage,
                                  freePostingModeAllowed: Bool, isBumpedUp: EventParameterBoolean) -> TrackerEvent {
        return productMarkAsSold(productId: listing.objectId, price: listing.price, currency: listing.currency.code,
                                 categoryId: listing.category.rawValue, typePage: typePage,
                                 freePostingModeAllowed: freePostingModeAllowed, isBumpedUp: isBumpedUp)
    }

    private static func productMarkAsSold(productId: String?, price: ListingPrice, currency: String, categoryId: Int?,
                                          typePage: EventParameterTypePage, freePostingModeAllowed: Bool,
                                          isBumpedUp: EventParameterBoolean) -> TrackerEvent {
        var params = EventParameters()
        params[.productId] = productId
        params[.productPrice] = price.value
        params[.productCurrency] = currency
        params[.categoryId] = categoryId
        params[.typePage] = typePage.rawValue
        params[.freePosting] = eventParameterFreePostingWithPrice(freePostingModeAllowed, price: price).rawValue
        params[.isBumpedUp] = isBumpedUp.rawValue
        return TrackerEvent(name: .productMarkAsSold, params: params)
    }

    static func productMarkAsSoldAtLetgo(listing: Listing, typePage: EventParameterTypePage,
                                         freePostingModeAllowed: Bool, buyerId: String,
                                         isBumpedUp: EventParameterBoolean) -> TrackerEvent {
        return productMarkAsSoldAtLetgo(listingId: listing.objectId, price: listing.price,
                                        currency: listing.currency.code, categoryId: listing.category.rawValue,
                                        typePage: typePage, freePostingModeAllowed: freePostingModeAllowed,
                                        buyerId: buyerId, isBumpedUp: isBumpedUp)
    }
    
    static func productMarkAsSoldAtLetgo(chatListing: ChatListing, typePage: EventParameterTypePage,
                                         freePostingModeAllowed: Bool, buyerId: String,
                                         isBumpedUp: EventParameterBoolean) -> TrackerEvent {
        return productMarkAsSoldAtLetgo(listingId: chatListing.objectId, price: chatListing.price,
                                        currency: chatListing.currency.code, categoryId: nil,
                                        typePage: typePage, freePostingModeAllowed: freePostingModeAllowed,
                                        buyerId: buyerId, isBumpedUp: isBumpedUp)
    }
    
    private static func productMarkAsSoldAtLetgo(listingId: String?, price: ListingPrice, currency: String, categoryId: Int?,
                                                 typePage: EventParameterTypePage, freePostingModeAllowed: Bool,
                                                 buyerId: String, isBumpedUp: EventParameterBoolean) -> TrackerEvent {
        var params = EventParameters()
        params[.productId] = listingId
        params[.productPrice] = price.value
        params[.productCurrency] = currency
        params[.categoryId] = categoryId
        params[.typePage] = typePage.rawValue
        params[.freePosting] = eventParameterFreePostingWithPrice(freePostingModeAllowed, price: price).rawValue
        params[.userSoldTo] = buyerId
        params[.isBumpedUp] = isBumpedUp.rawValue
        return TrackerEvent(name: .productMarkAsSoldAtLetgo, params: params)
    }
    
    static func productMarkAsSoldOutsideLetgo(listing: Listing, typePage: EventParameterTypePage,
                                              freePostingModeAllowed: Bool,
                                              isBumpedUp: EventParameterBoolean) -> TrackerEvent {
        return productMarkAsSoldOutsideLetgo(listingId: listing.objectId, price: listing.price,
                                             currency: listing.currency.code, categoryId: listing.category.rawValue,
                                             typePage: typePage, freePostingModeAllowed: freePostingModeAllowed,
                                             isBumpedUp: isBumpedUp)
    }
    
    static func productMarkAsSoldOutsideLetgo(chatListing: ChatListing, typePage: EventParameterTypePage,
                                              freePostingModeAllowed: Bool,
                                              isBumpedUp: EventParameterBoolean) -> TrackerEvent {
        return productMarkAsSoldOutsideLetgo(listingId: chatListing.objectId, price: chatListing.price,
                                             currency: chatListing.currency.code, categoryId: nil,
                                             typePage: typePage, freePostingModeAllowed: freePostingModeAllowed,
                                             isBumpedUp: isBumpedUp)
    }
    
    private static func productMarkAsSoldOutsideLetgo(listingId: String?, price: ListingPrice, currency: String,
                                                      categoryId: Int?, typePage: EventParameterTypePage,
                                                      freePostingModeAllowed: Bool,
                                                      isBumpedUp: EventParameterBoolean) -> TrackerEvent {
        var params = EventParameters()
        params[.productId] = listingId
        params[.productPrice] = price.value
        params[.productCurrency] = currency
        params[.categoryId] = categoryId
        params[.typePage] = typePage.rawValue
        params[.freePosting] = eventParameterFreePostingWithPrice(freePostingModeAllowed, price: price).rawValue
        params[.isBumpedUp] = isBumpedUp.rawValue
        return TrackerEvent(name: .productMarkAsSoldOutsideLetgo, params: params)
    }

    static func productMarkAsUnsold(_ listing: Listing) -> TrackerEvent {
        var params = EventParameters()
        params[.productId] = listing.objectId
        params[.productPrice] = listing.price.value
        params[.productCurrency] = listing.currency.code
        params[.categoryId] = listing.category.rawValue
        return TrackerEvent(name: .productMarkAsUnsold, params: params)
    }

    static func productReport(_ listing: Listing) -> TrackerEvent {
        var params = EventParameters()
        params.addListingParams(listing)
        return TrackerEvent(name: .productReport, params: params)
    }

    static func productSellStart(_ typePage: EventParameterTypePage,
                                 buttonName: EventParameterButtonNameType?, sellButtonPosition: EventParameterSellButtonPosition) -> TrackerEvent {
        var params = EventParameters()
        params[.typePage] = typePage.rawValue
        params[.buttonName] = buttonName?.rawValue
        params[.sellButtonPosition] = sellButtonPosition.rawValue
        return TrackerEvent(name: .productSellStart, params: params)
    }

    static func productSellSharedFB(_ product: Product?) -> TrackerEvent {
        var params = EventParameters()
        params[.productId] = product?.objectId
        return TrackerEvent(name: .productSellSharedFB, params: params)
    }

    static func productSellComplete(_ listing: Listing, buttonName: EventParameterButtonNameType?,
                                    sellButtonPosition: EventParameterSellButtonPosition?, negotiable: EventParameterNegotiablePrice?,
                                    pictureSource: EventParameterPictureSource?, freePostingModeAllowed: Bool) -> TrackerEvent {
        var params = EventParameters()
        params[.freePosting] = eventParameterFreePostingWithPrice(freePostingModeAllowed, price: listing.price).rawValue
        params[.productId] = listing.objectId ?? ""
        params[.categoryId] = listing.category.rawValue
        params[.productName] = listing.name ?? ""
        params[.numberPhotosPosting] = listing.images.count
        params[.sellButtonPosition] = sellButtonPosition?.rawValue
        params[.productDescription] = !(listing.descr?.isEmpty ?? true)
        if let buttonName = buttonName {
            params[.buttonName] = buttonName.rawValue
        }
        if let negotiable = negotiable {
            params[.negotiablePrice] = negotiable.rawValue
        }
        if let pictureSource = pictureSource {
            params[.pictureSource] = pictureSource.rawValue
        }

        switch listing {
        case .car:
            params[.postingType] = EventParameterPostingType.car.rawValue
        case .product:
            params[.postingType] = EventParameterPostingType.stuff.rawValue
        }

        params[.make] = EventParameterMake.make(name: listing.car?.carAttributes.make).name
        params[.model] = EventParameterModel.model(name: listing.car?.carAttributes.model).name
        params[.year] = EventParameterYear.year(year: listing.car?.carAttributes.year).year

        return TrackerEvent(name: .productSellComplete, params: params)
    }
    
    static func productSellComplete24h(_ listing: Listing) -> TrackerEvent {
        var params = EventParameters()
        params[.productId] = listing.objectId ?? ""
        return TrackerEvent(name: .productSellComplete24h, params: params)
    }

    static func productSellError(_ error: EventParameterPostProductError) -> TrackerEvent {
        var params = EventParameters()
        params[.errorDescription] = error.description
        return TrackerEvent(name: .productSellError, params: params)
    }

    static func productSellErrorClose(_ error: EventParameterPostProductError) -> TrackerEvent {
        var params = EventParameters()
        params[.errorDescription] = error.description
        return TrackerEvent(name: .productSellErrorClose, params: params)
    }

    static func productSellErrorPost(_ error: EventParameterPostProductError) -> TrackerEvent {
        var params = EventParameters()
        params[.errorDescription] = error.description
        return TrackerEvent(name: .productSellErrorPost, params: params)
    }

    static func productSellErrorData(_ error: EventParameterPostProductError) -> TrackerEvent {
        var params = EventParameters()
        params[.errorDescription] = error.description
        params[.errorDetails] = error.details
        return TrackerEvent(name: .productSellErrorData, params: params)
    }

    static func productSellConfirmation(_ listing: Listing) -> TrackerEvent {
        var params = EventParameters()
        params[.productId] = listing.objectId ?? ""
        return TrackerEvent(name: .productSellConfirmation, params: params)
    }

    static func productSellConfirmationPost(_ listing: Listing, buttonType: EventParameterButtonType) -> TrackerEvent {
        var params = EventParameters()
        params[.productId] = listing.objectId ?? ""
        params[.buttonType] = buttonType.rawValue
        return TrackerEvent(name: .productSellConfirmationPost, params: params)
    }

    static func productSellConfirmationEdit(_ listing: Listing) -> TrackerEvent {
        var params = EventParameters()
        params[.productId] = listing.objectId ?? ""
        return TrackerEvent(name: .productSellConfirmationEdit, params: params)
    }

    static func productSellConfirmationClose(_ listing: Listing) -> TrackerEvent {
        var params = EventParameters()
        params[.productId] = listing.objectId ?? ""
        return TrackerEvent(name: .productSellConfirmationClose, params: params)
    }

    static func productSellConfirmationShare(_ listing: Listing, network: EventParameterShareNetwork)
        -> TrackerEvent {
            var params = EventParameters()
            params[.productId] = listing.objectId ?? ""
            params[.shareNetwork] = network.rawValue
            return TrackerEvent(name: .productSellConfirmationShare, params: params)
    }

    static func productSellConfirmationShareCancel(_ listing: Listing,
        network: EventParameterShareNetwork) -> TrackerEvent {
            var params = EventParameters()
            params[.productId] = listing.objectId ?? ""
            params[.shareNetwork] = network.rawValue
            return TrackerEvent(name: .productSellConfirmationShareCancel, params: params)
    }

    static func productSellConfirmationShareComplete(_ listing: Listing,
        network: EventParameterShareNetwork) -> TrackerEvent {
            var params = EventParameters()
            params[.productId] = listing.objectId ?? ""
            params[.shareNetwork] = network.rawValue
            return TrackerEvent(name: .productSellConfirmationShareComplete, params: params)
    }

    static func productEditStart(_ user: User?, listing: Listing) -> TrackerEvent {
        var params = EventParameters()
        // Product
        params[.productId] = listing.objectId
        return TrackerEvent(name: .productEditStart, params: params)
    }

    static func productEditFormValidationFailed(_ user: User?, listing: Listing, description: String)
        -> TrackerEvent {
            var params = EventParameters()
            // Product
            params[.productId] = listing.objectId
            // Validation failure description
            params[.description] = description
            return TrackerEvent(name: .productEditFormValidationFailed, params: params)
    }

    static func productEditSharedFB(_ user: User?, listing: Listing?) -> TrackerEvent {
        var params = EventParameters()
        // Product
        if let productId = listing?.objectId {
            params[.productId] = productId
        }
        return TrackerEvent(name: .productEditSharedFB, params: params)
    }

    static func productEditComplete(_ user: User?, listing: Listing, category: ListingCategory?,
                                    editedFields: [EventParameterEditedFields]) -> TrackerEvent {
        var params = EventParameters()
        // Product
        params[.productId] = listing.objectId
        params[.categoryId] = category?.rawValue ?? 0
        params[.editedFields] = editedFields.map({$0.rawValue}).joined(separator: ",")

        params[.make] = EventParameterMake.make(name: listing.car?.carAttributes.make).name
        params[.model] = EventParameterModel.model(name: listing.car?.carAttributes.model).name
        params[.year] = EventParameterYear.year(year: listing.car?.carAttributes.year).year

        return TrackerEvent(name: .productEditComplete, params: params)
    }

    static func productDeleteStart(_ listing: Listing) -> TrackerEvent {
        var params = EventParameters()
        params[.productId] = listing.objectId
        return TrackerEvent(name: .productDeleteStart, params: params)
    }

    static func productDeleteComplete(_ listing: Listing) -> TrackerEvent {
        var params = EventParameters()
        params[.productId] = listing.objectId
        return TrackerEvent(name: .productDeleteComplete, params: params)
    }

    static func firstMessage(info: SendMessageTrackingInfo) -> TrackerEvent {
        return TrackerEvent(name: .firstMessage, params: info.params)
    }

    static func userMessageSent(info: SendMessageTrackingInfo) -> TrackerEvent {
        return TrackerEvent(name: .userMessageSent, params: info.params)
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

    static func profileVisit(_ user: User, profileType: EventParameterProfileType, typePage: EventParameterTypePage, tab: EventParameterTab)
        -> TrackerEvent {
            var params = EventParameters()
            params[.typePage] = typePage.rawValue
            params[.userToId] = user.objectId
            params[.tab] = tab.rawValue
            params[.profileType] = profileType.rawValue
            return TrackerEvent(name: .profileVisit, params: params)
    }

    static func profileEditStart() -> TrackerEvent {
        return TrackerEvent(name: .profileEditStart, params: nil)
    }

    static func profileEditEditName() -> TrackerEvent {
        return TrackerEvent(name: .profileEditEditName, params: nil)
    }

    static func profileEditEditLocation(_ location: LGLocation) -> TrackerEvent {
        var params = EventParameters()
        params[.locationType] = location.type.rawValue
        return TrackerEvent(name: .profileEditEditLocation, params: params)
    }

    static func profileEditEditLocationStart() -> TrackerEvent {
        return TrackerEvent(name: .profileEditEditLocationStart, params: nil)
    }

    static func profileEditEditPicture() -> TrackerEvent {
        return TrackerEvent(name: .profileEditEditPicture, params: nil)
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

    static func appRatingRate(rating: Int) -> TrackerEvent {
        var params = EventParameters()
        params[.rating] = rating
        return TrackerEvent(name: .appRatingRate, params: params)
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

    static func commercializerStart(_ productId: String?, typePage: EventParameterTypePage) -> TrackerEvent {
        var params = EventParameters()
        params[.productId] = productId ?? ""
        params[.typePage] = typePage.rawValue
        return TrackerEvent(name: .commercializerStart, params: params)
    }

    static func commercializerError(_ productId: String?, typePage: EventParameterTypePage,
        error: EventParameterCommercializerError) -> TrackerEvent {
            var params = EventParameters()
            params[.productId] = productId ?? ""
            params[.typePage] = typePage.rawValue
            params[.errorDescription] = error.rawValue
            return TrackerEvent(name: .commercializerError, params: params)
    }

    static func commercializerComplete(_ productId: String?, typePage: EventParameterTypePage,
        template: String) -> TrackerEvent {
            var params = EventParameters()
            params[.productId] = productId ?? ""
            params[.typePage] = typePage.rawValue
            params[.template] = template
            return TrackerEvent(name: .commercializerComplete, params: params)
    }

    static func commercializerOpen(_ productId: String?, typePage: EventParameterTypePage,
        template: String) -> TrackerEvent {
            var params = EventParameters()
            params[.productId] = productId ?? ""
            params[.typePage] = typePage.rawValue
            params[.template] = template
            return TrackerEvent(name: .commercializerOpen, params: params)
    }

    static func commercializerShareStart(_ productId: String?, typePage: EventParameterTypePage, template: String,
        shareNetwork: EventParameterShareNetwork) -> TrackerEvent {
            var params = EventParameters()
            params[.productId] = productId ?? ""
            params[.typePage] = typePage.rawValue
            params[.template] = template
            params[.shareNetwork] = shareNetwork.rawValue
            return TrackerEvent(name: .commercializerShareStart, params: params)
    }

    static func commercializerShareComplete(_ productId: String?, typePage: EventParameterTypePage, template: String,
                                                shareNetwork: EventParameterShareNetwork) -> TrackerEvent {
        var params = EventParameters()
        params[.productId] = productId ?? ""
        params[.typePage] = typePage.rawValue
        params[.template] = template
        params[.shareNetwork] = shareNetwork.rawValue
        return TrackerEvent(name: .commercializerShareComplete, params: params)
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
    
    static func npsStart() -> TrackerEvent {
        return TrackerEvent(name: .npsStart, params: nil)
    }
    
    static func npsComplete(_ score: Int) -> TrackerEvent {
        var params = EventParameters()
        params[.npsScore] = score
        return TrackerEvent(name: .npsComplete, params: params)
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

    static func notificationCenterStart() -> TrackerEvent {
        return TrackerEvent(name: .notificationCenterStart, params: EventParameters())
    }

    static func notificationCenterComplete(_ type: EventParameterNotificationType, source: EventParameterNotificationClickArea,
                                           cardAction: String?, notificationCampaign: String?) -> TrackerEvent {
        var params = EventParameters()
        params[.notificationType] = type.rawValue
        params[.notificationClickArea] = source.rawValue
        // cardAction is passed as string instead of EventParameterCardAction type as retention could send anything on the query parameter.
        params[.notificationAction] = cardAction ?? "N/A"
        params[.notificationCampaign] = notificationCampaign ?? "N/A"
        return TrackerEvent(name: .notificationCenterComplete, params: params)
    }

    static func marketingPushNotifications(_ userId: String?, enabled: Bool) -> TrackerEvent {
        var params = EventParameters()
        params[.userId] = userId
        params[.enabled] = enabled
        return TrackerEvent(name: .marketingPushNotifications, params: params)
    }
    
    static func passiveBuyerStart(withUser userId: String?, productId: String?) -> TrackerEvent {
        var params = EventParameters()
        params[.userId] = userId ?? ""
        params[.productId] = productId ?? ""
        return TrackerEvent(name: .passiveBuyerStart, params: params)
    }
    
    static func passiveBuyerComplete(withUser userId: String?, productId: String?, passiveConversations: Int) -> TrackerEvent {
        var params = EventParameters()
        params[.userId] = userId ?? ""
        params[.productId] = productId ?? ""
        params[.passiveConversations] = passiveConversations
        return TrackerEvent(name: .passiveBuyerComplete, params: params)
    }
    
    static func passiveBuyerAbandon(withUser userId: String?, productId: String?) -> TrackerEvent {
        var params = EventParameters()
        params[.userId] = userId ?? ""
        params[.productId] = productId ?? ""
        return TrackerEvent(name: .passiveBuyerAbandon, params: params)
    }

    static func productBumpUpStart(_ listing: Listing, price: EventParameterBumpUpPrice) -> TrackerEvent {
        var params = EventParameters()
        params.addListingParams(listing)

        params[.bumpUpPrice] = price.description
        return TrackerEvent(name: .bumpUpStart, params: params)
    }

    static func productBumpUpComplete(_ listing: Listing, price: EventParameterBumpUpPrice,
                                      network: EventParameterShareNetwork) -> TrackerEvent {
        var params = EventParameters()
        params.addListingParams(listing)
        params[.bumpUpPrice] = price.description
        params[.shareNetwork] = network.rawValue
        return TrackerEvent(name: .bumpUpComplete, params: params)
    }
    
    static func chatWindowVisit(_ typePage: EventParameterTypePage, chatEnabled: Bool) -> TrackerEvent {
        var params = EventParameters()
        params[.typePage] = typePage.rawValue
        params[.chatEnabled] = chatEnabled
        return TrackerEvent(name: .chatWindowVisit, params: params)
    }
    
    static func emptyStateVisit(typePage: EventParameterTypePage, reason: EventParameterEmptyReason) -> TrackerEvent {
        var params = EventParameters()
        params[.typePage] = typePage.rawValue
        params[.reason] = reason.rawValue
        return TrackerEvent(name: .emptyStateError, params: params)
    }
    
    static func userRatingReport(userFromId: String?,
                              ratingStars: Int) -> TrackerEvent{
        var params = EventParameters()
        params[.ratingStars] = ratingStars
        params[.userFromId] = userFromId
        return TrackerEvent(name: .userRatingReport, params: params)
    }


    // MARK: - Private methods


    private static func eventParameterSortByTypeForSorting(_ sorting: ListingSortCriteria?) -> EventParameterSortBy? {
        guard let sorting = sorting else { return nil }
        let sortBy: EventParameterSortBy?
        switch (sorting) {
        case .distance:
            sortBy = EventParameterSortBy.distance
        case .creation:
            sortBy = EventParameterSortBy.creationDate
        case .priceAsc:
            sortBy = EventParameterSortBy.priceAsc
        case .priceDesc:
            sortBy = EventParameterSortBy.priceDesc
        }
        
        return sortBy
    }

    private static func eventParameterPostedWithinForTime(_ time: ListingTimeCriteria?) -> EventParameterPostedWithin? {
        guard let time = time else { return nil }
        switch time {
        case .day:
            return .day
        case .week:
            return .week
        case .month:
            return .month
        case .all:
            return .all
        }
    }

    private static func eventParameterHasPriceFilter(_ price: Int?) -> EventParameterBoolean {
        return price != nil ? .trueParameter : .falseParameter
    }
    
    static func eventParameterFreePostingWithPrice(_ freePostingModeAllowed: Bool, price: ListingPrice) -> EventParameterBoolean {
        guard freePostingModeAllowed else {return .notAvailable}
        return price.free ? .trueParameter : .falseParameter
    }
    
    private static func eventParameterFreePostingWithPriceRange(_ freePostingModeAllowed: Bool, priceRange: FilterPriceRange) -> EventParameterBoolean {
        guard freePostingModeAllowed else {return .notAvailable}
        return priceRange.free ? .trueParameter : .falseParameter
    }
}
