//
//  TrackerEvent.swift
//  LetGo
//
//  Created by Albert Hernández López on 05/08/15.
//  Copyright (c) 2015 Ambatana. All rights reserved.
//

import LGCoreKit

public struct TrackerEvent {
    private(set) var name: EventName
    var actualName: String {
        get {
            return name.actualEventName
        }
    }
    private(set) var params: EventParameters?

    static func location(location: LGLocation, locationServiceStatus: LocationServiceStatus) -> TrackerEvent {
        var params = EventParameters()
        let locationTypeParamValue = eventParameterLocationTypeForLocation(location)
        if let _ = locationTypeParamValue {
            params[.LocationType] = location.type?.rawValue
        }
        let enabled: Bool
        let allowed: Bool
        switch locationServiceStatus {
        case .Enabled(let authStatus):
            enabled = true
            switch authStatus {
            case .Authorized:
                allowed = true
            case .NotDetermined, .Restricted, .Denied:
                allowed = false
            }
        case .Disabled:
            enabled = false
            allowed = false
            break
        }
        params[.LocationEnabled] = enabled
        params[.LocationAllowed] = allowed
        return TrackerEvent(name: .Location, params: params)
    }

    static func loginVisit(source: EventParameterLoginSourceValue, rememberedAccount: Bool) -> TrackerEvent {
        var params = EventParameters()
        params.addLoginParams(source, rememberedAccount: rememberedAccount)
        return TrackerEvent(name: .LoginVisit, params: params)
    }

    static func loginAbandon(source: EventParameterLoginSourceValue) -> TrackerEvent {
        var params = EventParameters()
        params.addLoginParams(source)
        return TrackerEvent(name: .LoginAbandon, params: params)
    }

    static func loginFB(source: EventParameterLoginSourceValue, rememberedAccount: Bool) -> TrackerEvent {
        var params = EventParameters()
        params.addLoginParams(source, rememberedAccount: rememberedAccount)
        return TrackerEvent(name: .LoginFB, params: params)
    }
    
    static func loginGoogle(source: EventParameterLoginSourceValue, rememberedAccount: Bool) -> TrackerEvent {
        var params = EventParameters()
        params.addLoginParams(source, rememberedAccount: rememberedAccount)
        return TrackerEvent(name: .LoginGoogle, params: params)
    }

    static func loginEmail(source: EventParameterLoginSourceValue, rememberedAccount: Bool) -> TrackerEvent {
        var params = EventParameters()
        params.addLoginParams(source, rememberedAccount: rememberedAccount)
        return TrackerEvent(name: .LoginEmail, params: params)
    }

    static func signupEmail(source: EventParameterLoginSourceValue, newsletter: EventParameterNewsletter)
        -> TrackerEvent {
            var params = EventParameters()
            params.addLoginParams(source)
            params[.Newsletter] = newsletter.rawValue
            return TrackerEvent(name: .SignupEmail, params: params)
    }

    static func logout() -> TrackerEvent {
        return TrackerEvent(name: .Logout, params: nil)
    }

    static func loginEmailError(errorDescription: EventParameterLoginError) -> TrackerEvent {
        var params = EventParameters()

        params[.ErrorDescription] = errorDescription.description
        params[.ErrorDetails] = errorDescription.details

        return TrackerEvent(name: .LoginEmailError, params: params)
    }

    static func loginFBError(errorDescription: EventParameterLoginError) -> TrackerEvent {
        var params = EventParameters()

        params[.ErrorDescription] = errorDescription.description
        params[.ErrorDetails] = errorDescription.details

        return TrackerEvent(name: .LoginFBError, params: params)
    }

    static func loginGoogleError(errorDescription: EventParameterLoginError) -> TrackerEvent {
        var params = EventParameters()

        params[.ErrorDescription] = errorDescription.description
        params[.ErrorDetails] = errorDescription.details

        return TrackerEvent(name: .LoginGoogleError, params: params)
    }

    static func signupError(errorDescription: EventParameterLoginError) -> TrackerEvent {
        var params = EventParameters()

        params[.ErrorDescription] = errorDescription.description
        params[.ErrorDetails] = errorDescription.details

        return TrackerEvent(name: .SignupError, params: params)
    }

    static func passwordResetError(errorDescription: EventParameterLoginError) -> TrackerEvent {
        var params = EventParameters()

        params[.ErrorDescription] = errorDescription.description
        params[.ErrorDetails] = errorDescription.details

        return TrackerEvent(name: .PasswordResetError, params: params)
    }

    static func loginBlockedAccountStart(network: EventParameterAccountNetwork) -> TrackerEvent {
        var params = EventParameters()
        params[.AccountNetwork] = network.rawValue
        return TrackerEvent(name: .LoginBlockedAccountStart, params: params)
    }

    static func loginBlockedAccountContactUs(network: EventParameterAccountNetwork) -> TrackerEvent {
        var params = EventParameters()
        params[.AccountNetwork] = network.rawValue
        return TrackerEvent(name: .LoginBlockedAccountContactUs, params: params)
    }

    static func loginBlockedAccountKeepBrowsing(network: EventParameterAccountNetwork) -> TrackerEvent {
        var params = EventParameters()
        params[.AccountNetwork] = network.rawValue
        return TrackerEvent(name: .LoginBlockedAccountKeepBrowsing, params: params)
    }

    static func productList(user: User?, categories: [ProductCategory]?, searchQuery: String?) -> TrackerEvent {
        var params = EventParameters()

        // Categories
        var categoryIds: [String] = []
        if let actualCategories = categories {
            for category in actualCategories {
                categoryIds.append(String(category.rawValue))
            }
        }
        params[.CategoryId] = categoryIds.isEmpty ? "0" : categoryIds.joinWithSeparator(",")

        // Search query
        if let actualSearchQuery = searchQuery {
            params[.SearchString] = actualSearchQuery
        }

        return TrackerEvent(name: .ProductList, params: params)
    }

    static func exploreCollection(collectionTitle: String) -> TrackerEvent {
        var params = EventParameters()
        params[.CollectionTitle] = collectionTitle
        return TrackerEvent(name: .ExploreCollection, params: params)
    }

    static func searchStart(user: User?) -> TrackerEvent {
        let params = EventParameters()

        return TrackerEvent(name: .SearchStart, params: params)
    }

    static func searchComplete(user: User?, searchQuery: String, isTrending: Bool, success: EventParameterSearchCompleteSuccess, isLastSearch: Bool)
        -> TrackerEvent {
            var params = EventParameters()
            params[.SearchString] = searchQuery
            params[.SearchSuccess] = success.rawValue
            params[.TrendingSearch] = isTrending
            params[.LastSearch] = isLastSearch
            return TrackerEvent(name: .SearchComplete, params: params)
    }

    static func filterStart() -> TrackerEvent {
        return TrackerEvent(name: .FilterStart, params: nil)
    }

    static func filterComplete(coordinates: LGLocationCoordinates2D?, distanceRadius: Int?,
                               distanceUnit: DistanceType, categories: [ProductCategory]?, sortBy: ProductSortCriteria?,
                               postedWithin: ProductTimeCriteria?, priceRange: FilterPriceRange, freePostingModeAllowed: Bool) -> TrackerEvent {
        var params = EventParameters()

        // Filter Coordinates
        if let actualCoords = coordinates {
            params[.FilterLat] = actualCoords.latitude
            params[.FilterLng] = actualCoords.longitude
        } else {
            params[.FilterLat] = "default"
            params[.FilterLng] = "default"
        }

        // Distance
        params[.FilterDistanceRadius] = distanceRadius ?? "default"
        params[.FilterDistanceUnit] = distanceUnit.string

        // Categories
        var categoryIds: [String] = []
        if let actualCategories = categories {
            for category in actualCategories {
                categoryIds.append(String(category.rawValue))
            }
        }
        params[.CategoryId] = categoryIds.isEmpty ? "0" : categoryIds.joinWithSeparator(",")

        // Sorting
        if let sortByParam = eventParameterSortByTypeForSorting(sortBy) {
            params[.FilterSortBy] = sortByParam.rawValue
        }
        if let postedWithin = eventParameterPostedWithinForTime(postedWithin) {
            params[.FilterPostedWithin] = postedWithin.rawValue
        }

        params[.PriceFrom] = eventParameterHasPriceFilter(priceRange.min).rawValue
        params[.PriceTo] = eventParameterHasPriceFilter(priceRange.max).rawValue
        
        params[.FreePosting] = eventParameterFreePostingWithPriceRange(freePostingModeAllowed, priceRange: priceRange).rawValue

        return TrackerEvent(name: .FilterComplete, params: params)
    }

    static func productDetailVisit(product: Product, visitUserAction: ProductVisitUserAction, source: EventParameterProductVisitSource) -> TrackerEvent {
        var params = EventParameters()
        params.addProductParams(product)
        params[.UserAction] = visitUserAction.rawValue
        params[.ProductVisitSource] = source.rawValue
        return TrackerEvent(name: .ProductDetailVisit, params: params)
    }

    static func productDetailVisitMoreInfo(product: Product) -> TrackerEvent {
        var params = EventParameters()
        params.addProductParams(product)
        return TrackerEvent(name: .ProductDetailVisitMoreInfo, params: params)
    }

    static func moreInfoRelatedItemsComplete(product: Product, itemPosition: Int) -> TrackerEvent {
        var params = EventParameters()
        params.addProductParams(product)
        params[.ItemPosition] = itemPosition
        return TrackerEvent(name: .MoreInfoRelatedItemsComplete, params: params)
    }

    static func moreInfoRelatedItemsViewMore(product: Product) -> TrackerEvent {
        var params = EventParameters()
        params.addProductParams(product)
        return TrackerEvent(name: .MoreInfoRelatedItemsViewMore, params: params)
    }

    static func productFavorite(product: Product, typePage: EventParameterTypePage) -> TrackerEvent {
        var params = EventParameters()
        params.addProductParams(product)
        params[.TypePage] = typePage.rawValue
        return TrackerEvent(name: .ProductFavorite, params: params)
    }

    static func productShare(product: Product, network: EventParameterShareNetwork?,
                             buttonPosition: EventParameterButtonPosition,
                             typePage: EventParameterTypePage) -> TrackerEvent {
        var params = EventParameters()
        params.addProductParams(product)

        // When starting share if native then the network is considered as N/A
        var actualNetwork = network ?? .NotAvailable
        switch actualNetwork {
        case .Native:
            actualNetwork = .NotAvailable
        case .Email, .Facebook, .Whatsapp, .Twitter, .FBMessenger, .Telegram, .SMS, .CopyLink, .NotAvailable:
            break
        }
        params[.ShareNetwork] = actualNetwork.rawValue
        params[.ButtonPosition] = buttonPosition.rawValue
        params[.TypePage] = typePage.rawValue
        return TrackerEvent(name: .ProductShare, params: params)
    }

    static func productShareCancel(product: Product, network: EventParameterShareNetwork,
        typePage: EventParameterTypePage) -> TrackerEvent {
            var params = EventParameters()
            params.addProductParams(product)
            params[.ProductType] = product.user.isDummy ?
                EventParameterProductItemType.Dummy.rawValue : EventParameterProductItemType.Real.rawValue
            params[.ShareNetwork] = network.rawValue
            params[.TypePage] = typePage.rawValue
            return TrackerEvent(name: .ProductShareCancel, params: params)
    }

    static func productShareComplete(product: Product, network: EventParameterShareNetwork,
        typePage: EventParameterTypePage) -> TrackerEvent {
            var params = EventParameters()
            params.addProductParams(product)
            params[.ProductType] = product.user.isDummy ?
                EventParameterProductItemType.Dummy.rawValue : EventParameterProductItemType.Real.rawValue
            params[.ShareNetwork] = network.rawValue
            params[.TypePage] = typePage.rawValue
            return TrackerEvent(name: .ProductShareComplete, params: params)
    }

    static func firstMessage(product: Product, messageType: EventParameterMessageType,
                                          typePage: EventParameterTypePage, sellerRating: Float? = nil) -> TrackerEvent {
        var params = EventParameters()
        params.addProductParams(product)
        params[.MessageType] = messageType.rawValue
        params[.TypePage] = typePage.rawValue
        params[.SellerUserRating] = sellerRating
        return TrackerEvent(name: .FirstMessage, params: params)
    }
    
    // Duplicated method from the one above to support tracking using ChatProduct model
    static func firstMessage(product: ChatProduct, messageType: EventParameterMessageType,
                                          interlocutorId: String?, typePage: EventParameterTypePage,
                                          sellerRating: Float? = nil) -> TrackerEvent {
        // Note: does not have: category-id, product-lat, product-lng
        var params = EventParameters()
        params.addChatProductParams(product)
        params[.MessageType] = messageType.rawValue
        params[.TypePage] = typePage.rawValue
        params[.UserToId] = interlocutorId
        params[.SellerUserRating] = sellerRating
        return TrackerEvent(name: .FirstMessage, params: params)
    }

    static func productDetailOpenChat(product: Product, typePage: EventParameterTypePage) -> TrackerEvent {
        var params = EventParameters()
        params[.ProductId] = product.objectId
        params[.TypePage] = typePage.rawValue
        return TrackerEvent(name: .ProductOpenChat, params: params)
    }

    static func productMarkAsSold(source: EventParameterSellSourceValue, product: Product, freePostingModeAllowed: Bool)
        -> TrackerEvent {
            var params = EventParameters()

            // Product
            if let productId = product.objectId {
                params[.ProductId] = productId
            }
            params[.ProductPrice] = product.price.value
            params[.ProductCurrency] = product.currency.code
            params[.CategoryId] = product.category.rawValue
            params[.FreePosting] = eventParameterFreePostingWithPrice(freePostingModeAllowed, price: product.price).rawValue
            return TrackerEvent(name: .ProductMarkAsSold, params: params)
    }

    static func productMarkAsUnsold(product: Product) -> TrackerEvent {
        var params = EventParameters()
        if let productId = product.objectId {
            params[.ProductId] = productId
        }
        params[.ProductPrice] = product.price.value
        params[.ProductCurrency] = product.currency.code
        params[.CategoryId] = product.category.rawValue
        return TrackerEvent(name: .ProductMarkAsUnsold, params: params)
    }

    static func productReport(product: Product) -> TrackerEvent {
        var params = EventParameters()
        params.addProductParams(product)
        return TrackerEvent(name: .ProductReport, params: params)
    }

    static func productSellStart(typePage: EventParameterTypePage,
                                 buttonName: EventParameterButtonNameType?, sellButtonPosition: EventParameterSellButtonPosition) -> TrackerEvent {
        var params = EventParameters()
        params[.TypePage] = typePage.rawValue
        params[.ButtonName] = buttonName?.rawValue
        params[.SellButtonPosition] = sellButtonPosition.rawValue
        return TrackerEvent(name: .ProductSellStart, params: params)
    }

    static func productSellFormValidationFailed(description: String) -> TrackerEvent {
        var params = EventParameters()
        // Validation failure description
        params[.Description] = description
        return TrackerEvent(name: .ProductSellFormValidationFailed, params: params)
    }

    static func productSellSharedFB(product: Product?) -> TrackerEvent {
        var params = EventParameters()
        // Product name
        if let productId = product?.objectId {
            params[.ProductId] = productId
        }
        return TrackerEvent(name: .ProductSellSharedFB, params: params)
    }

    static func productSellComplete(product: Product, buttonName: EventParameterButtonNameType?,
                                    sellButtonPosition: EventParameterSellButtonPosition?, negotiable: EventParameterNegotiablePrice?,
                                    pictureSource: EventParameterPictureSource?, freePostingModeAllowed: Bool) -> TrackerEvent {
        var params = EventParameters()
        params[.FreePosting] = eventParameterFreePostingWithPrice(freePostingModeAllowed, price: product.price).rawValue
        params[.ProductId] = product.objectId ?? ""
        params[.CategoryId] = product.category.rawValue
        params[.ProductName] = product.name ?? ""
        params[.NumberPhotosPosting] = product.images.count
        params[.SellButtonPosition] = sellButtonPosition?.rawValue
        params[.ProductDescription] = !(product.descr?.isEmpty ?? true)
        if let buttonName = buttonName {
            params[.ButtonName] = buttonName.rawValue
        }
        if let negotiable = negotiable {
            params[.NegotiablePrice] = negotiable.rawValue
        }
        if let pictureSource = pictureSource {
            params[.PictureSource] = pictureSource.rawValue
        }
        return TrackerEvent(name: .ProductSellComplete, params: params)
    }
    
    static func productSellComplete24h(product: Product) -> TrackerEvent {
        var params = EventParameters()
        params[.ProductId] = product.objectId ?? ""
        return TrackerEvent(name: .ProductSellComplete24h, params: params)
    }

    static func productSellError(error: EventParameterPostProductError) -> TrackerEvent {
        var params = EventParameters()
        params[.ErrorDescription] = error.description
        return TrackerEvent(name: .ProductSellError, params: params)
    }

    static func productSellErrorClose(error: EventParameterPostProductError) -> TrackerEvent {
        var params = EventParameters()
        params[.ErrorDescription] = error.description
        return TrackerEvent(name: .ProductSellErrorClose, params: params)
    }

    static func productSellErrorPost(error: EventParameterPostProductError) -> TrackerEvent {
        var params = EventParameters()
        params[.ErrorDescription] = error.description
        return TrackerEvent(name: .ProductSellErrorPost, params: params)
    }

    static func productSellErrorData(error: EventParameterPostProductError) -> TrackerEvent {
        var params = EventParameters()
        params[.ErrorDescription] = error.description
        params[.ErrorDetails] = error.details
        return TrackerEvent(name: .ProductSellErrorData, params: params)
    }

    static func productSellConfirmation(product: Product) -> TrackerEvent {
        var params = EventParameters()
        params[.ProductId] = product.objectId ?? ""
        return TrackerEvent(name: .ProductSellConfirmation, params: params)
    }

    static func productSellConfirmationPost(product: Product, buttonType: EventParameterButtonType) -> TrackerEvent {
        var params = EventParameters()
        params[.ProductId] = product.objectId ?? ""
        params[.ButtonType] = buttonType.rawValue
        return TrackerEvent(name: .ProductSellConfirmationPost, params: params)
    }

    static func productSellConfirmationEdit(product: Product) -> TrackerEvent {
        var params = EventParameters()
        params[.ProductId] = product.objectId ?? ""
        return TrackerEvent(name: .ProductSellConfirmationEdit, params: params)
    }

    static func productSellConfirmationClose(product: Product) -> TrackerEvent {
        var params = EventParameters()
        params[.ProductId] = product.objectId ?? ""
        return TrackerEvent(name: .ProductSellConfirmationClose, params: params)
    }

    static func productSellConfirmationShare(product: Product, network: EventParameterShareNetwork)
        -> TrackerEvent {
            var params = EventParameters()
            params[.ProductId] = product.objectId ?? ""
            params[.ShareNetwork] = network.rawValue
            return TrackerEvent(name: .ProductSellConfirmationShare, params: params)
    }

    static func productSellConfirmationShareCancel(product: Product,
        network: EventParameterShareNetwork) -> TrackerEvent {
            var params = EventParameters()
            params[.ProductId] = product.objectId ?? ""
            params[.ShareNetwork] = network.rawValue
            return TrackerEvent(name: .ProductSellConfirmationShareCancel, params: params)
    }

    static func productSellConfirmationShareComplete(product: Product,
        network: EventParameterShareNetwork) -> TrackerEvent {
            var params = EventParameters()
            params[.ProductId] = product.objectId ?? ""
            params[.ShareNetwork] = network.rawValue
            return TrackerEvent(name: .ProductSellConfirmationShareComplete, params: params)
    }

    static func productEditStart(user: User?, product: Product) -> TrackerEvent {
        var params = EventParameters()
        // Product
        params[.ProductId] = product.objectId
        return TrackerEvent(name: .ProductEditStart, params: params)
    }

    static func productEditFormValidationFailed(user: User?, product: Product, description: String)
        -> TrackerEvent {
            var params = EventParameters()
            // Product
            params[.ProductId] = product.objectId
            // Validation failure description
            params[.Description] = description
            return TrackerEvent(name: .ProductEditFormValidationFailed, params: params)
    }

    static func productEditSharedFB(user: User?, product: Product?) -> TrackerEvent {
        var params = EventParameters()
        // Product
        if let productId = product?.objectId {
            params[.ProductId] = productId
        }
        return TrackerEvent(name: .ProductEditSharedFB, params: params)
    }

    static func productEditComplete(user: User?, product: Product, category: ProductCategory?,
        editedFields: [EventParameterEditedFields]) -> TrackerEvent {
            var params = EventParameters()
            // Product
            params[.ProductId] = product.objectId
            params[.CategoryId] = category?.rawValue ?? 0
            params[.EditedFields] = editedFields.map({$0.rawValue}).joinWithSeparator(",")

            return TrackerEvent(name: .ProductEditComplete, params: params)
    }

    static func productDeleteStart(product: Product) -> TrackerEvent {
        var params = EventParameters()
        params[.ProductId] = product.objectId
        return TrackerEvent(name: .ProductDeleteStart, params: params)
    }

    static func productDeleteComplete(product: Product) -> TrackerEvent {
        var params = EventParameters()
        params[.ProductId] = product.objectId
        return TrackerEvent(name: .ProductDeleteComplete, params: params)
    }

    static func userMessageSent(product: Product, userTo: User?, messageType: EventParameterMessageType,
                                isQuickAnswer: EventParameterQuickAnswerValue, typePage: EventParameterTypePage) -> TrackerEvent {
        var params = EventParameters()
        params.addProductParams(product)
        params.addUserParams(userTo)
        params[.MessageType] = messageType.rawValue
        params[.QuickAnswer] = isQuickAnswer.rawValue
        params[.TypePage] = typePage.rawValue
        return TrackerEvent(name: .UserMessageSent, params: params)
    }
    
    // Duplicated method from the one above to support tracking using ChatProduct model
    static func userMessageSent(product: ChatProduct, userToId: String?, messageType: EventParameterMessageType,
                                       isQuickAnswer: EventParameterQuickAnswerValue, typePage: EventParameterTypePage) -> TrackerEvent {
        var params = EventParameters()
        params.addChatProductParams(product)
        params[.UserToId] = userToId
        params[.MessageType] = messageType.rawValue
        params[.QuickAnswer] = isQuickAnswer.rawValue
        params[.TypePage] = typePage.rawValue
        return TrackerEvent(name: .UserMessageSent, params: params)
    }

    static func chatRelatedItemsStart(shownReason: EventParameterRelatedShownReason) -> TrackerEvent {
        var params = EventParameters()
        params[.ShownReason] = shownReason.rawValue
        return TrackerEvent(name: .ChatRelatedItemsStart, params: params)
    }

    static func chatRelatedItemsComplete(itemPosition: Int, shownReason: EventParameterRelatedShownReason) -> TrackerEvent {
        var params = EventParameters()
        params[.ItemPosition] = itemPosition
        params[.ShownReason] = shownReason.rawValue
        return TrackerEvent(name: .ChatRelatedItemsComplete, params: params)
    }

    static func profileVisit(user: User, profileType: EventParameterProfileType, typePage: EventParameterTypePage, tab: EventParameterTab)
        -> TrackerEvent {
            var params = EventParameters()
            params[.TypePage] = typePage.rawValue
            params[.UserToId] = user.objectId
            params[.Tab] = tab.rawValue
            params[.ProfileType] = profileType.rawValue
            return TrackerEvent(name: .ProfileVisit, params: params)
    }

    static func profileEditStart() -> TrackerEvent {
        let params = EventParameters()
        return TrackerEvent(name: .ProfileEditStart, params: params)
    }

    static func profileEditEditName() -> TrackerEvent {
        let params = EventParameters()
        return TrackerEvent(name: .ProfileEditEditName, params: params)
    }

    static func profileEditEditLocation(location: LGLocation) -> TrackerEvent {
        var params = EventParameters()
        let locationTypeParamValue = eventParameterLocationTypeForLocation(location)
        if let _ = locationTypeParamValue {
            params[.LocationType] = location.type?.rawValue
        }
        return TrackerEvent(name: .ProfileEditEditLocation, params: params)
    }

    static func profileEditEditPicture() -> TrackerEvent {
        let params = EventParameters()
        return TrackerEvent(name: .ProfileEditEditPicture, params: params)
    }

    static func profileShareStart(type: EventParameterProfileType)  -> TrackerEvent {
        var params = EventParameters()
        params[.ProfileType] = type.rawValue
        return TrackerEvent(name: .ProfileShareStart, params: params)
    }

    static func profileShareComplete(type: EventParameterProfileType, shareNetwork: EventParameterShareNetwork)
        -> TrackerEvent {
        var params = EventParameters()
        params[.ProfileType] = type.rawValue
        params[.ShareNetwork] = shareNetwork.rawValue
        return TrackerEvent(name: .ProfileShareComplete, params: params)
    }

    static func appInviteFriendStart(typePage: EventParameterTypePage) -> TrackerEvent {
            var params = EventParameters()
            params[.TypePage] = typePage.rawValue
            return TrackerEvent(name: .AppInviteFriendStart, params: params)
    }

    static func appInviteFriend(network: EventParameterShareNetwork, typePage: EventParameterTypePage)
        -> TrackerEvent {
            var params = EventParameters()
            params[.ShareNetwork] = network.rawValue
            params[.TypePage] = typePage.rawValue
            return TrackerEvent(name: .AppInviteFriend, params: params)
    }

    static func appInviteFriendCancel(network: EventParameterShareNetwork, typePage: EventParameterTypePage)
        -> TrackerEvent {
            var params = EventParameters()
            params[.ShareNetwork] = network.rawValue
            params[.TypePage] = typePage.rawValue
            return TrackerEvent(name: .AppInviteFriendCancel, params: params)
    }

    static func appInviteFriendDontAsk(typePage: EventParameterTypePage)
        -> TrackerEvent {
            var params = EventParameters()
            params[.TypePage] = typePage.rawValue
            return TrackerEvent(name: .AppInviteFriendDontAsk, params: params)
    }

    static func appInviteFriendComplete(network: EventParameterShareNetwork, typePage: EventParameterTypePage)
        -> TrackerEvent {
            var params = EventParameters()
            params[.ShareNetwork] = network.rawValue
            params[.TypePage] = typePage.rawValue
            return TrackerEvent(name: .AppInviteFriendComplete, params: params)
    }

    static func appRatingStart(source: EventParameterRatingSource) -> TrackerEvent {
        var params = EventParameters()
        params[.AppRatingSource] = source.rawValue
        return TrackerEvent(name: .AppRatingStart, params: params)
    }

    static func appRatingRate() -> TrackerEvent {
        let params = EventParameters()
        return TrackerEvent(name: .AppRatingRate, params: params)
    }

    static func appRatingSuggest() -> TrackerEvent {
        let params = EventParameters()
        return TrackerEvent(name: .AppRatingSuggest, params: params)
    }

    static func appRatingDontAsk() -> TrackerEvent {
        let params = EventParameters()
        return TrackerEvent(name: .AppRatingDontAsk, params: params)
    }

    static func appRatingRemindMeLater() -> TrackerEvent {
        let params = EventParameters()
        return TrackerEvent(name: .AppRatingRemindMeLater, params: params)
    }

    static func permissionAlertStart(permissionType: EventParameterPermissionType,
        typePage: EventParameterTypePage, alertType: EventParameterPermissionAlertType,
        permissionGoToSettings: EventParameterPermissionGoToSettings) -> TrackerEvent {
            var params = EventParameters()
            params[.PermissionType] = permissionType.rawValue
            params[.TypePage] = typePage.rawValue
            params[.AlertType] = alertType.rawValue
            params[.PermissionGoToSettings] = permissionGoToSettings.rawValue
            return TrackerEvent(name: .PermissionAlertStart, params: params)
    }

    static func permissionAlertCancel(permissionType: EventParameterPermissionType,
        typePage: EventParameterTypePage, alertType: EventParameterPermissionAlertType,
        permissionGoToSettings: EventParameterPermissionGoToSettings) -> TrackerEvent {
            var params = EventParameters()
            params[.PermissionType] = permissionType.rawValue
            params[.TypePage] = typePage.rawValue
            params[.AlertType] = alertType.rawValue
            params[.PermissionGoToSettings] = permissionGoToSettings.rawValue
            return TrackerEvent(name: .PermissionAlertCancel, params: params)
    }

    static func permissionAlertComplete(permissionType: EventParameterPermissionType,
        typePage: EventParameterTypePage, alertType: EventParameterPermissionAlertType,
        permissionGoToSettings: EventParameterPermissionGoToSettings) -> TrackerEvent {
            var params = EventParameters()
            params[.PermissionType] = permissionType.rawValue
            params[.TypePage] = typePage.rawValue
            params[.AlertType] = alertType.rawValue
            params[.PermissionGoToSettings] = permissionGoToSettings.rawValue
            return TrackerEvent(name: .PermissionAlertComplete, params: params)
    }

    static func permissionSystemStart(permissionType: EventParameterPermissionType,
        typePage: EventParameterTypePage) -> TrackerEvent {
            var params = EventParameters()
            params[.PermissionType] = permissionType.rawValue
            params[.TypePage] = typePage.rawValue
            return TrackerEvent(name: .PermissionSystemStart, params: params)
    }

    static func permissionSystemCancel(permissionType: EventParameterPermissionType,
        typePage: EventParameterTypePage) -> TrackerEvent {
            var params = EventParameters()
            params[.PermissionType] = permissionType.rawValue
            params[.TypePage] = typePage.rawValue
            return TrackerEvent(name: .PermissionSystemCancel, params: params)
    }

    static func permissionSystemComplete(permissionType: EventParameterPermissionType,
        typePage: EventParameterTypePage) -> TrackerEvent {
            var params = EventParameters()
            params[.PermissionType] = permissionType.rawValue
            params[.TypePage] = typePage.rawValue
            return TrackerEvent(name: .PermissionSystemComplete, params: params)
    }

    static func profileReport(typePage: EventParameterTypePage, reportedUserId: String,
        reason: EventParameterReportReason) -> TrackerEvent{
            var params = EventParameters()
            params[.ReportReason] = reason.rawValue
            params[.TypePage] = typePage.rawValue
            params[.UserToId] = reportedUserId
            return TrackerEvent(name: .ProfileReport, params: params)
    }

    static func profileBlock(typePage: EventParameterTypePage, blockedUsersIds: [String]) -> TrackerEvent{
        var params = EventParameters()
        params[.TypePage] = typePage.rawValue
        params[.UserToId] = blockedUsersIds.joinWithSeparator(",")
        return TrackerEvent(name: .ProfileBlock, params: params)
    }

    static func profileUnblock(typePage: EventParameterTypePage, unblockedUsersIds: [String]) -> TrackerEvent{
        var params = EventParameters()
        params[.TypePage] = typePage.rawValue
        params[.UserToId] = unblockedUsersIds.joinWithSeparator(",")
        return TrackerEvent(name: .ProfileUnblock, params: params)
    }

    static func locationMapShown() -> TrackerEvent {
        let params = EventParameters()
        return TrackerEvent(name: .LocationMap, params: params)
    }

    static func commercializerStart(productId: String?, typePage: EventParameterTypePage) -> TrackerEvent {
        var params = EventParameters()
        params[.ProductId] = productId ?? ""
        params[.TypePage] = typePage.rawValue
        return TrackerEvent(name: .CommercializerStart, params: params)
    }

    static func commercializerError(productId: String?, typePage: EventParameterTypePage,
        error: EventParameterCommercializerError) -> TrackerEvent {
            var params = EventParameters()
            params[.ProductId] = productId ?? ""
            params[.TypePage] = typePage.rawValue
            params[.ErrorDescription] = error.rawValue
            return TrackerEvent(name: .CommercializerError, params: params)
    }

    static func commercializerComplete(productId: String?, typePage: EventParameterTypePage,
        template: String) -> TrackerEvent {
            var params = EventParameters()
            params[.ProductId] = productId ?? ""
            params[.TypePage] = typePage.rawValue
            params[.Template] = template
            return TrackerEvent(name: .CommercializerComplete, params: params)
    }

    static func commercializerOpen(productId: String?, typePage: EventParameterTypePage,
        template: String) -> TrackerEvent {
            var params = EventParameters()
            params[.ProductId] = productId ?? ""
            params[.TypePage] = typePage.rawValue
            params[.Template] = template
            return TrackerEvent(name: .CommercializerOpen, params: params)
    }

    static func commercializerShareStart(productId: String?, typePage: EventParameterTypePage, template: String,
        shareNetwork: EventParameterShareNetwork) -> TrackerEvent {
            var params = EventParameters()
            params[.ProductId] = productId ?? ""
            params[.TypePage] = typePage.rawValue
            params[.Template] = template
            params[.ShareNetwork] = shareNetwork.rawValue
            return TrackerEvent(name: .CommercializerShareStart, params: params)
    }

    static func commercializerShareComplete(productId: String?, typePage: EventParameterTypePage, template: String,
                                                shareNetwork: EventParameterShareNetwork) -> TrackerEvent {
        var params = EventParameters()
        params[.ProductId] = productId ?? ""
        params[.TypePage] = typePage.rawValue
        params[.Template] = template
        params[.ShareNetwork] = shareNetwork.rawValue
        return TrackerEvent(name: .CommercializerShareComplete, params: params)
    }

    static func userRatingStart(userId: String, typePage: EventParameterTypePage) -> TrackerEvent {
        var params = EventParameters()
        params[.UserToId] = userId
        params[.TypePage] = typePage.rawValue
        return TrackerEvent(name: .UserRatingStart, params: params)
    }

    static func userRatingComplete(userId: String, typePage: EventParameterTypePage,
                                          rating: Int, hasComments: Bool) -> TrackerEvent {
        var params = EventParameters()
        params[.UserToId] = userId
        params[.TypePage] = typePage.rawValue
        params[.RatingStars] = rating
        params[.RatingComments] = hasComments
        return TrackerEvent(name: .UserRatingComplete, params: params)
    }

    static func openAppExternal(campaign: String? = nil, medium: String? = nil, source: DeepLinkSource) -> TrackerEvent {
        var params = EventParameters()
        params[.Campaign] = campaign
        params[.Medium] = medium
        switch source {
        case let .External(theSource):
            params[.Source] = theSource
        case .Push:
            params[.Source] = "push"
        case .None:
            break
        }
        return TrackerEvent(name: .OpenApp, params: params)
    }

    static func expressChatStart(trigger: EventParameterExpressChatTrigger) -> TrackerEvent {
        var params = EventParameters()
        params[.ExpressChatTrigger] = trigger.rawValue
        return TrackerEvent(name: .ExpressChatStart, params: params)
    }

    static func expressChatComplete(numConversations: Int, trigger: EventParameterExpressChatTrigger) -> TrackerEvent {
        var params = EventParameters()
        params[.ExpressConversations] = numConversations
        params[.ExpressChatTrigger] = trigger.rawValue
        return TrackerEvent(name: .ExpressChatComplete, params: params)
    }

    static func expressChatDontAsk(trigger: EventParameterExpressChatTrigger) -> TrackerEvent {
        var params = EventParameters()
        params[.ExpressChatTrigger] = trigger.rawValue
        return TrackerEvent(name: .ExpressChatDontAsk, params: params)
    }

    static func productDetailInterestedUsers(number: Int, productId: String)  -> TrackerEvent {
        var params = EventParameters()
        params[.NumberOfUsers] = number
        params[.ProductId] = productId
        return TrackerEvent(name: .ProductDetailInterestedUsers, params: params)
    }
    
    static func npsStart() -> TrackerEvent {
        return TrackerEvent(name: .NPSStart, params: nil)
    }
    
    static func npsComplete(score: Int) -> TrackerEvent {
        var params = EventParameters()
        params[.NPSScore] = score
        return TrackerEvent(name: .NPSComplete, params: params)
    }

    static func verifyAccountStart(typePage: EventParameterTypePage) -> TrackerEvent {
        var params = EventParameters()
        params[.TypePage] = typePage.rawValue
        return TrackerEvent(name: .VerifyAccountStart, params: params)
    }

    static func verifyAccountComplete(typePage: EventParameterTypePage, network: EventParameterAccountNetwork) -> TrackerEvent {
        var params = EventParameters()
        params[.TypePage] = typePage.rawValue
        params[.AccountNetwork] = network.rawValue
        return TrackerEvent(name: .VerifyAccountComplete, params: params)
    }

    static func inappChatNotificationStart() -> TrackerEvent {
        return TrackerEvent(name: .InappChatNotificationStart, params: EventParameters())
    }

    static func inappChatNotificationComplete() -> TrackerEvent {
        return TrackerEvent(name: .InappChatNotificationComplete, params: EventParameters())
    }

    static func signupCaptcha() -> TrackerEvent {
        return TrackerEvent(name: .SignupCaptcha, params: EventParameters())
    }

    static func notificationCenterStart() -> TrackerEvent {
        return TrackerEvent(name: .NotificationCenterStart, params: EventParameters())
    }

    static func notificationCenterComplete(type: EventParameterNotificationType) -> TrackerEvent {
        var params = EventParameters()
        params[.NotificationType] = type.rawValue
        return TrackerEvent(name: .NotificationCenterComplete, params: params)
    }

    static func marketingPushNotifications(userId: String?, enabled: Bool) -> TrackerEvent {
        var params = EventParameters()
        params[.UserId] = userId
        params[.Enabled] = enabled
        return TrackerEvent(name: .MarketingPushNotifications, params: params)
    }

    static func chatHeadsStart() -> TrackerEvent {
        return TrackerEvent(name: .ChatHeadsStart, params: EventParameters())
    }

    static func chatHeadsOpen() -> TrackerEvent {
        return TrackerEvent(name: .ChatHeadsOpen, params: EventParameters())
    }

    static func chatHeadsDelete() -> TrackerEvent {
        return TrackerEvent(name: .ChatHeadsDelete, params: EventParameters())
    }


    // MARK: - Private methods

    private static func eventParameterLocationTypeForLocation(location: LGLocation) -> EventParameterLocationType? {
        let locationTypeParamValue: EventParameterLocationType?
        guard let locationType = location.type else { return nil }
        switch (locationType) {
        case .Manual:
            locationTypeParamValue = .Manual
        case .Sensor:
            locationTypeParamValue = .Sensor
        case .IPLookup:
            locationTypeParamValue = .IPLookUp
        case .Regional:
            locationTypeParamValue = .Regional
        }
        return locationTypeParamValue
    }

    private static func eventParameterSortByTypeForSorting(sorting: ProductSortCriteria?) -> EventParameterSortBy? {
        guard let sorting = sorting else { return nil }
        let sortBy: EventParameterSortBy?
        switch (sorting) {
        case .Distance:
            sortBy = EventParameterSortBy.Distance
        case .Creation:
            sortBy = EventParameterSortBy.CreationDate
        case .PriceAsc:
            sortBy = EventParameterSortBy.PriceAsc
        case .PriceDesc:
            sortBy = EventParameterSortBy.PriceDesc
        }
        
        return sortBy
    }

    private static func eventParameterPostedWithinForTime(time: ProductTimeCriteria?) -> EventParameterPostedWithin? {
        guard let time = time else { return nil }
        switch time {
        case .Day:
            return .Day
        case .Week:
            return .Week
        case .Month:
            return .Month
        case .All:
            return .All
        }
    }

    private static func eventParameterHasPriceFilter(price: Int?) -> EventParameterHasPriceFilter {
        return price != nil ? .True : .False
    }
    
    private static func eventParameterFreePostingWithPrice(freePostingModeAllowed: Bool, price: ProductPrice) -> EventParameterFreePosting {
        guard freePostingModeAllowed else {return .Unset}
        return price.free ? .True : .False
    }
    
    private static func eventParameterFreePostingWithPriceRange(freePostingModeAllowed: Bool, priceRange: FilterPriceRange) -> EventParameterFreePosting {
        guard freePostingModeAllowed else {return .Unset}
        return priceRange.free ? .True : .False
    }
}
