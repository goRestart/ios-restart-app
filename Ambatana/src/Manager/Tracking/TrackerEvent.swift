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
        let locationTypeParamValue = eventParameterLocationTypeForLocation(location)
        if let _ = locationTypeParamValue {
            params[.locationType] = location.type?.rawValue
        }
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
                        collapsedEmail: EventParameterCollapsedEmailField?) -> TrackerEvent {
        var params = EventParameters()
        params.addLoginParams(source, rememberedAccount: rememberedAccount, collapsedEmail: collapsedEmail)
        return TrackerEvent(name: .loginFB, params: params)
    }
    
    static func loginGoogle(_ source: EventParameterLoginSourceValue, rememberedAccount: Bool,
                            collapsedEmail: EventParameterCollapsedEmailField?) -> TrackerEvent {
        var params = EventParameters()
        params.addLoginParams(source, rememberedAccount: rememberedAccount, collapsedEmail: collapsedEmail)
        return TrackerEvent(name: .loginGoogle, params: params)
    }

    static func loginEmail(_ source: EventParameterLoginSourceValue, rememberedAccount: Bool,
                           collapsedEmail: EventParameterCollapsedEmailField?) -> TrackerEvent {
        var params = EventParameters()
        params.addLoginParams(source, rememberedAccount: rememberedAccount, collapsedEmail: collapsedEmail)
        return TrackerEvent(name: .loginEmail, params: params)
    }

    static func signupEmail(_ source: EventParameterLoginSourceValue, newsletter: EventParameterNewsletter,
                            collapsedEmail: EventParameterCollapsedEmailField?)
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

    static func loginBlockedAccountStart(_ network: EventParameterAccountNetwork) -> TrackerEvent {
        var params = EventParameters()
        params[.accountNetwork] = network.rawValue
        return TrackerEvent(name: .loginBlockedAccountStart, params: params)
    }

    static func loginBlockedAccountContactUs(_ network: EventParameterAccountNetwork) -> TrackerEvent {
        var params = EventParameters()
        params[.accountNetwork] = network.rawValue
        return TrackerEvent(name: .loginBlockedAccountContactUs, params: params)
    }

    static func loginBlockedAccountKeepBrowsing(_ network: EventParameterAccountNetwork) -> TrackerEvent {
        var params = EventParameters()
        params[.accountNetwork] = network.rawValue
        return TrackerEvent(name: .loginBlockedAccountKeepBrowsing, params: params)
    }

    static func productList(_ user: User?, categories: [ProductCategory]?, searchQuery: String?, feedSource: EventParameterFeedSource) -> TrackerEvent {
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

    static func filterComplete(_ coordinates: LGLocationCoordinates2D?, distanceRadius: Int?,
                               distanceUnit: DistanceType, categories: [ProductCategory]?, sortBy: ProductSortCriteria?,
                               postedWithin: ProductTimeCriteria?, priceRange: FilterPriceRange, freePostingModeAllowed: Bool) -> TrackerEvent {
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

        return TrackerEvent(name: .filterComplete, params: params)
    }

    static func productDetailVisit(_ product: Product, visitUserAction: ProductVisitUserAction, source: EventParameterProductVisitSource, feedPosition: EventParameterFeedPosition) -> TrackerEvent {
        var params = EventParameters()
        params.addProductParams(product)
        params[.userAction] = visitUserAction.rawValue
        params[.productVisitSource] = source.rawValue
        params[.feedPosition] = feedPosition.value
        return TrackerEvent(name: .productDetailVisit, params: params)
    }

    static func productDetailVisitMoreInfo(_ product: Product) -> TrackerEvent {
        var params = EventParameters()
        params.addProductParams(product)
        return TrackerEvent(name: .productDetailVisitMoreInfo, params: params)
    }

    static func productFavorite(_ product: Product, typePage: EventParameterTypePage) -> TrackerEvent {
        var params = EventParameters()
        params.addProductParams(product)
        params[.typePage] = typePage.rawValue
        return TrackerEvent(name: .productFavorite, params: params)
    }

    static func productShare(_ product: Product, network: EventParameterShareNetwork?,
                             buttonPosition: EventParameterButtonPosition,
                             typePage: EventParameterTypePage) -> TrackerEvent {
        var params = EventParameters()
        params.addProductParams(product)

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
        return TrackerEvent(name: .productShare, params: params)
    }

    static func productShareCancel(_ product: Product, network: EventParameterShareNetwork,
        typePage: EventParameterTypePage) -> TrackerEvent {
            var params = EventParameters()
            params.addProductParams(product)
            params[.shareNetwork] = network.rawValue
            params[.typePage] = typePage.rawValue
            return TrackerEvent(name: .productShareCancel, params: params)
    }

    static func productShareComplete(_ product: Product, network: EventParameterShareNetwork,
        typePage: EventParameterTypePage) -> TrackerEvent {
            var params = EventParameters()
            params.addProductParams(product)
            params[.shareNetwork] = network.rawValue
            params[.typePage] = typePage.rawValue
            return TrackerEvent(name: .productShareComplete, params: params)
    }

    static func firstMessage(_ product: Product, messageType: EventParameterMessageType,
                                          typePage: EventParameterTypePage, sellerRating: Float? = nil) -> TrackerEvent {
        var params = EventParameters()
        params.addProductParams(product)
        params[.messageType] = messageType.rawValue
        params[.typePage] = typePage.rawValue
        params[.sellerUserRating] = sellerRating
        return TrackerEvent(name: .firstMessage, params: params)
    }
    
    // Duplicated method from the one above to support tracking using ChatProduct model
    static func firstMessage(_ product: ChatProduct, messageType: EventParameterMessageType,
                                          interlocutorId: String?, typePage: EventParameterTypePage,
                                          sellerRating: Float? = nil) -> TrackerEvent {
        // Note: does not have: category-id, product-lat, product-lng
        var params = EventParameters()
        params.addChatProductParams(product)
        params[.messageType] = messageType.rawValue
        params[.typePage] = typePage.rawValue
        params[.userToId] = interlocutorId
        params[.sellerUserRating] = sellerRating
        return TrackerEvent(name: .firstMessage, params: params)
    }

    static func productDetailOpenChat(_ product: Product, typePage: EventParameterTypePage) -> TrackerEvent {
        var params = EventParameters()
        params[.productId] = product.objectId
        params[.typePage] = typePage.rawValue
        return TrackerEvent(name: .productOpenChat, params: params)
    }

    static func productMarkAsSold(_ source: EventParameterSellSourceValue, product: Product, freePostingModeAllowed: Bool)
        -> TrackerEvent {
            var params = EventParameters()

            // Product
            if let productId = product.objectId {
                params[.productId] = productId
            }
            params[.productPrice] = product.price.value
            params[.productCurrency] = product.currency.code
            params[.categoryId] = product.category.rawValue
            params[.freePosting] = eventParameterFreePostingWithPrice(freePostingModeAllowed, price: product.price).rawValue
            return TrackerEvent(name: .productMarkAsSold, params: params)
    }

    static func productMarkAsUnsold(_ product: Product) -> TrackerEvent {
        var params = EventParameters()
        if let productId = product.objectId {
            params[.productId] = productId
        }
        params[.productPrice] = product.price.value
        params[.productCurrency] = product.currency.code
        params[.categoryId] = product.category.rawValue
        return TrackerEvent(name: .productMarkAsUnsold, params: params)
    }

    static func productReport(_ product: Product) -> TrackerEvent {
        var params = EventParameters()
        params.addProductParams(product)
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
        // Product name
        if let productId = product?.objectId {
            params[.productId] = productId
        }
        return TrackerEvent(name: .productSellSharedFB, params: params)
    }

    static func productSellComplete(_ product: Product, buttonName: EventParameterButtonNameType?,
                                    sellButtonPosition: EventParameterSellButtonPosition?, negotiable: EventParameterNegotiablePrice?,
                                    pictureSource: EventParameterPictureSource?, freePostingModeAllowed: Bool) -> TrackerEvent {
        var params = EventParameters()
        params[.freePosting] = eventParameterFreePostingWithPrice(freePostingModeAllowed, price: product.price).rawValue
        params[.productId] = product.objectId ?? ""
        params[.categoryId] = product.category.rawValue
        params[.productName] = product.name ?? ""
        params[.numberPhotosPosting] = product.images.count
        params[.sellButtonPosition] = sellButtonPosition?.rawValue
        params[.productDescription] = !(product.descr?.isEmpty ?? true)
        if let buttonName = buttonName {
            params[.buttonName] = buttonName.rawValue
        }
        if let negotiable = negotiable {
            params[.negotiablePrice] = negotiable.rawValue
        }
        if let pictureSource = pictureSource {
            params[.pictureSource] = pictureSource.rawValue
        }
        return TrackerEvent(name: .productSellComplete, params: params)
    }
    
    static func productSellComplete24h(_ product: Product) -> TrackerEvent {
        var params = EventParameters()
        params[.productId] = product.objectId ?? ""
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

    static func productSellConfirmation(_ product: Product) -> TrackerEvent {
        var params = EventParameters()
        params[.productId] = product.objectId ?? ""
        return TrackerEvent(name: .productSellConfirmation, params: params)
    }

    static func productSellConfirmationPost(_ product: Product, buttonType: EventParameterButtonType) -> TrackerEvent {
        var params = EventParameters()
        params[.productId] = product.objectId ?? ""
        params[.buttonType] = buttonType.rawValue
        return TrackerEvent(name: .productSellConfirmationPost, params: params)
    }

    static func productSellConfirmationEdit(_ product: Product) -> TrackerEvent {
        var params = EventParameters()
        params[.productId] = product.objectId ?? ""
        return TrackerEvent(name: .productSellConfirmationEdit, params: params)
    }

    static func productSellConfirmationClose(_ product: Product) -> TrackerEvent {
        var params = EventParameters()
        params[.productId] = product.objectId ?? ""
        return TrackerEvent(name: .productSellConfirmationClose, params: params)
    }

    static func productSellConfirmationShare(_ product: Product, network: EventParameterShareNetwork)
        -> TrackerEvent {
            var params = EventParameters()
            params[.productId] = product.objectId ?? ""
            params[.shareNetwork] = network.rawValue
            return TrackerEvent(name: .productSellConfirmationShare, params: params)
    }

    static func productSellConfirmationShareCancel(_ product: Product,
        network: EventParameterShareNetwork) -> TrackerEvent {
            var params = EventParameters()
            params[.productId] = product.objectId ?? ""
            params[.shareNetwork] = network.rawValue
            return TrackerEvent(name: .productSellConfirmationShareCancel, params: params)
    }

    static func productSellConfirmationShareComplete(_ product: Product,
        network: EventParameterShareNetwork) -> TrackerEvent {
            var params = EventParameters()
            params[.productId] = product.objectId ?? ""
            params[.shareNetwork] = network.rawValue
            return TrackerEvent(name: .productSellConfirmationShareComplete, params: params)
    }

    static func productEditStart(_ user: User?, product: Product) -> TrackerEvent {
        var params = EventParameters()
        // Product
        params[.productId] = product.objectId
        return TrackerEvent(name: .productEditStart, params: params)
    }

    static func productEditFormValidationFailed(_ user: User?, product: Product, description: String)
        -> TrackerEvent {
            var params = EventParameters()
            // Product
            params[.productId] = product.objectId
            // Validation failure description
            params[.description] = description
            return TrackerEvent(name: .productEditFormValidationFailed, params: params)
    }

    static func productEditSharedFB(_ user: User?, product: Product?) -> TrackerEvent {
        var params = EventParameters()
        // Product
        if let productId = product?.objectId {
            params[.productId] = productId
        }
        return TrackerEvent(name: .productEditSharedFB, params: params)
    }

    static func productEditComplete(_ user: User?, product: Product, category: ProductCategory?,
        editedFields: [EventParameterEditedFields]) -> TrackerEvent {
            var params = EventParameters()
            // Product
            params[.productId] = product.objectId
            params[.categoryId] = category?.rawValue ?? 0
            params[.editedFields] = editedFields.map({$0.rawValue}).joined(separator: ",")

            return TrackerEvent(name: .productEditComplete, params: params)
    }

    static func productDeleteStart(_ product: Product) -> TrackerEvent {
        var params = EventParameters()
        params[.productId] = product.objectId
        return TrackerEvent(name: .productDeleteStart, params: params)
    }

    static func productDeleteComplete(_ product: Product) -> TrackerEvent {
        var params = EventParameters()
        params[.productId] = product.objectId
        return TrackerEvent(name: .productDeleteComplete, params: params)
    }

    static func userMessageSent(_ product: Product, userTo: UserProduct?, messageType: EventParameterMessageType,
                                isQuickAnswer: EventParameterQuickAnswerValue, typePage: EventParameterTypePage) -> TrackerEvent {
        var params = EventParameters()
        params.addProductParams(product)
        params.addUserParams(userTo)
        params[.messageType] = messageType.rawValue
        params[.quickAnswer] = isQuickAnswer.rawValue
        params[.typePage] = typePage.rawValue
        return TrackerEvent(name: .userMessageSent, params: params)
    }
    
    // Duplicated method from the one above to support tracking using ChatProduct model
    static func userMessageSent(_ product: ChatProduct, userToId: String?, messageType: EventParameterMessageType,
                                       isQuickAnswer: EventParameterQuickAnswerValue, typePage: EventParameterTypePage) -> TrackerEvent {
        var params = EventParameters()
        params.addChatProductParams(product)
        params[.userToId] = userToId
        params[.messageType] = messageType.rawValue
        params[.quickAnswer] = isQuickAnswer.rawValue
        params[.typePage] = typePage.rawValue
        return TrackerEvent(name: .userMessageSent, params: params)
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
        let params = EventParameters()
        return TrackerEvent(name: .profileEditStart, params: params)
    }

    static func profileEditEditName() -> TrackerEvent {
        let params = EventParameters()
        return TrackerEvent(name: .profileEditEditName, params: params)
    }

    static func profileEditEditLocation(_ location: LGLocation) -> TrackerEvent {
        var params = EventParameters()
        let locationTypeParamValue = eventParameterLocationTypeForLocation(location)
        if let _ = locationTypeParamValue {
            params[.locationType] = location.type?.rawValue
        }
        return TrackerEvent(name: .profileEditEditLocation, params: params)
    }

    static func profileEditEditPicture() -> TrackerEvent {
        let params = EventParameters()
        return TrackerEvent(name: .profileEditEditPicture, params: params)
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
        permissionGoToSettings: EventParameterPermissionGoToSettings) -> TrackerEvent {
            var params = EventParameters()
            params[.permissionType] = permissionType.rawValue
            params[.typePage] = typePage.rawValue
            params[.alertType] = alertType.rawValue
            params[.permissionGoToSettings] = permissionGoToSettings.rawValue
            return TrackerEvent(name: .permissionAlertStart, params: params)
    }

    static func permissionAlertCancel(_ permissionType: EventParameterPermissionType,
        typePage: EventParameterTypePage, alertType: EventParameterPermissionAlertType,
        permissionGoToSettings: EventParameterPermissionGoToSettings) -> TrackerEvent {
            var params = EventParameters()
            params[.permissionType] = permissionType.rawValue
            params[.typePage] = typePage.rawValue
            params[.alertType] = alertType.rawValue
            params[.permissionGoToSettings] = permissionGoToSettings.rawValue
            return TrackerEvent(name: .permissionAlertCancel, params: params)
    }

    static func permissionAlertComplete(_ permissionType: EventParameterPermissionType,
        typePage: EventParameterTypePage, alertType: EventParameterPermissionAlertType,
        permissionGoToSettings: EventParameterPermissionGoToSettings) -> TrackerEvent {
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

    static func profileBlock(_ typePage: EventParameterTypePage, blockedUsersIds: [String]) -> TrackerEvent{
        var params = EventParameters()
        params[.typePage] = typePage.rawValue
        params[.userToId] = blockedUsersIds.joined(separator: ",")
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

    static func notificationCenterComplete(_ type: EventParameterNotificationType) -> TrackerEvent {
        var params = EventParameters()
        params[.notificationType] = type.rawValue
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

    static func productBumpUpStart(_ product: Product, price: EventParameterBumpUpPrice) -> TrackerEvent {
        var params = EventParameters()
        params.addProductParams(product)

        params[.bumpUpPrice] = price.description
        return TrackerEvent(name: .bumpUpStart, params: params)
    }

    static func productBumpUpComplete(_ product: Product, price: EventParameterBumpUpPrice,
                                      network: EventParameterShareNetwork) -> TrackerEvent {
        var params = EventParameters()
        params.addProductParams(product)
        params[.bumpUpPrice] = price.description
        params[.shareNetwork] = network.rawValue
        return TrackerEvent(name: .bumpUpComplete, params: params)
    }


    // MARK: - Private methods

    private static func eventParameterLocationTypeForLocation(_ location: LGLocation) -> EventParameterLocationType? {
        let locationTypeParamValue: EventParameterLocationType?
        guard let locationType = location.type else { return nil }
        switch (locationType) {
        case .manual:
            locationTypeParamValue = .manual
        case .sensor:
            locationTypeParamValue = .sensor
        case .ipLookup:
            locationTypeParamValue = .ipLookUp
        case .regional:
            locationTypeParamValue = .regional
        }
        return locationTypeParamValue
    }

    private static func eventParameterSortByTypeForSorting(_ sorting: ProductSortCriteria?) -> EventParameterSortBy? {
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

    private static func eventParameterPostedWithinForTime(_ time: ProductTimeCriteria?) -> EventParameterPostedWithin? {
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

    private static func eventParameterHasPriceFilter(_ price: Int?) -> EventParameterHasPriceFilter {
        return price != nil ? .trueParameter : .falseParameter
    }
    
    private static func eventParameterFreePostingWithPrice(_ freePostingModeAllowed: Bool, price: ProductPrice) -> EventParameterFreePosting {
        guard freePostingModeAllowed else {return .unset}
        return price.free ? .trueParameter : .falseParameter
    }
    
    private static func eventParameterFreePostingWithPriceRange(_ freePostingModeAllowed: Bool, priceRange: FilterPriceRange) -> EventParameterFreePosting {
        guard freePostingModeAllowed else {return .unset}
        return priceRange.free ? .trueParameter : .falseParameter
    }
}
