//
//  TrackerEvent.swift
//  LetGo
//
//  Created by Albert Hernández López on 05/08/15.
//  Copyright (c) 2015 Ambatana. All rights reserved.
//

import LGCoreKit

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
            params[.LocationType] = location.type?.rawValue
        }
        let enabled: Bool
        let allowed: Bool
        switch locationServiceStatus {
        case .enabled(let authStatus):
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

    static func loginVisit(_ source: EventParameterLoginSourceValue, rememberedAccount: Bool) -> TrackerEvent {
        var params = EventParameters()
        params.addLoginParams(source, rememberedAccount: rememberedAccount)
        return TrackerEvent(name: .LoginVisit, params: params)
    }

    static func loginAbandon(_ source: EventParameterLoginSourceValue) -> TrackerEvent {
        var params = EventParameters()
        params.addLoginParams(source)
        return TrackerEvent(name: .LoginAbandon, params: params)
    }

    static func loginFB(_ source: EventParameterLoginSourceValue, rememberedAccount: Bool) -> TrackerEvent {
        var params = EventParameters()
        params.addLoginParams(source, rememberedAccount: rememberedAccount)
        return TrackerEvent(name: .LoginFB, params: params)
    }
    
    static func loginGoogle(_ source: EventParameterLoginSourceValue, rememberedAccount: Bool) -> TrackerEvent {
        var params = EventParameters()
        params.addLoginParams(source, rememberedAccount: rememberedAccount)
        return TrackerEvent(name: .LoginGoogle, params: params)
    }

    static func loginEmail(_ source: EventParameterLoginSourceValue, rememberedAccount: Bool) -> TrackerEvent {
        var params = EventParameters()
        params.addLoginParams(source, rememberedAccount: rememberedAccount)
        return TrackerEvent(name: .LoginEmail, params: params)
    }

    static func signupEmail(_ source: EventParameterLoginSourceValue, newsletter: EventParameterNewsletter)
        -> TrackerEvent {
            var params = EventParameters()
            params.addLoginParams(source)
            params[.Newsletter] = newsletter.rawValue
            return TrackerEvent(name: .SignupEmail, params: params)
    }

    static func logout() -> TrackerEvent {
        return TrackerEvent(name: .logout, params: nil)
    }

    static func loginEmailError(_ errorDescription: EventParameterLoginError) -> TrackerEvent {
        var params = EventParameters()

        params[.ErrorDescription] = errorDescription.description
        params[.ErrorDetails] = errorDescription.details

        return TrackerEvent(name: .LoginEmailError, params: params)
    }

    static func loginFBError(_ errorDescription: EventParameterLoginError) -> TrackerEvent {
        var params = EventParameters()

        params[.ErrorDescription] = errorDescription.description
        params[.ErrorDetails] = errorDescription.details

        return TrackerEvent(name: .LoginFBError, params: params)
    }

    static func loginGoogleError(_ errorDescription: EventParameterLoginError) -> TrackerEvent {
        var params = EventParameters()

        params[.ErrorDescription] = errorDescription.description
        params[.ErrorDetails] = errorDescription.details

        return TrackerEvent(name: .LoginGoogleError, params: params)
    }

    static func signupError(_ errorDescription: EventParameterLoginError) -> TrackerEvent {
        var params = EventParameters()

        params[.ErrorDescription] = errorDescription.description
        params[.ErrorDetails] = errorDescription.details

        return TrackerEvent(name: .SignupError, params: params)
    }

    static func passwordResetError(_ errorDescription: EventParameterLoginError) -> TrackerEvent {
        var params = EventParameters()

        params[.ErrorDescription] = errorDescription.description
        params[.ErrorDetails] = errorDescription.details

        return TrackerEvent(name: .PasswordResetError, params: params)
    }

    static func loginBlockedAccountStart(_ network: EventParameterAccountNetwork) -> TrackerEvent {
        var params = EventParameters()
        params[.AccountNetwork] = network.rawValue
        return TrackerEvent(name: .LoginBlockedAccountStart, params: params)
    }

    static func loginBlockedAccountContactUs(_ network: EventParameterAccountNetwork) -> TrackerEvent {
        var params = EventParameters()
        params[.AccountNetwork] = network.rawValue
        return TrackerEvent(name: .LoginBlockedAccountContactUs, params: params)
    }

    static func loginBlockedAccountKeepBrowsing(_ network: EventParameterAccountNetwork) -> TrackerEvent {
        var params = EventParameters()
        params[.AccountNetwork] = network.rawValue
        return TrackerEvent(name: .LoginBlockedAccountKeepBrowsing, params: params)
    }

    static func productList(_ user: User?, categories: [ProductCategory]?, searchQuery: String?) -> TrackerEvent {
        var params = EventParameters()

        // Categories
        var categoryIds: [String] = []
        if let actualCategories = categories {
            for category in actualCategories {
                categoryIds.append(String(category.rawValue))
            }
        }
        params[.categoryId] = categoryIds.isEmpty ? "0" : categoryIds.joined(separator: ",")

        // Search query
        if let actualSearchQuery = searchQuery {
            params[.SearchString] = actualSearchQuery
        }

        return TrackerEvent(name: .ProductList, params: params)
    }

    static func exploreCollection(_ collectionTitle: String) -> TrackerEvent {
        var params = EventParameters()
        params[.CollectionTitle] = collectionTitle
        return TrackerEvent(name: .ExploreCollection, params: params)
    }

    static func searchStart(_ user: User?) -> TrackerEvent {
        let params = EventParameters()

        return TrackerEvent(name: .SearchStart, params: params)
    }

    static func searchComplete(_ user: User?, searchQuery: String, isTrending: Bool, success: EventParameterSearchCompleteSuccess, isLastSearch: Bool)
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

    static func filterComplete(_ coordinates: LGLocationCoordinates2D?, distanceRadius: Int?,
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
        params[.FilterDistanceRadius] = distanceRadius? ?? "default"
        params[.FilterDistanceUnit] = distanceUnit.string

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

    static func productDetailVisit(_ product: Product, visitUserAction: ProductVisitUserAction, source: EventParameterProductVisitSource) -> TrackerEvent {
        var params = EventParameters()
        params.addProductParams(product)
        params[.UserAction] = visitUserAction.rawValue
        params[.ProductVisitSource] = source.rawValue
        return TrackerEvent(name: .ProductDetailVisit, params: params)
    }

    static func productDetailVisitMoreInfo(_ product: Product) -> TrackerEvent {
        var params = EventParameters()
        params.addProductParams(product)
        return TrackerEvent(name: .ProductDetailVisitMoreInfo, params: params)
    }

    static func moreInfoRelatedItemsComplete(_ product: Product, itemPosition: Int) -> TrackerEvent {
        var params = EventParameters()
        params.addProductParams(product)
        params[.ItemPosition] = itemPosition
        return TrackerEvent(name: .MoreInfoRelatedItemsComplete, params: params)
    }

    static func moreInfoRelatedItemsViewMore(_ product: Product) -> TrackerEvent {
        var params = EventParameters()
        params.addProductParams(product)
        return TrackerEvent(name: .MoreInfoRelatedItemsViewMore, params: params)
    }

    static func productFavorite(_ product: Product, typePage: EventParameterTypePage) -> TrackerEvent {
        var params = EventParameters()
        params.addProductParams(product)
        params[.TypePage] = typePage.rawValue
        return TrackerEvent(name: .ProductFavorite, params: params)
    }

    static func productShare(_ product: Product, network: EventParameterShareNetwork?,
                             buttonPosition: EventParameterButtonPosition,
                             typePage: EventParameterTypePage) -> TrackerEvent {
        var params = EventParameters()
        params.addProductParams(product)

        // When starting share if native then the network is considered as N/A
        var actualNetwork = network ?? .notAvailable
        switch actualNetwork {
        case .Native:
            actualNetwork = .notAvailable
        case .Email, .Facebook, .Whatsapp, .Twitter, .FBMessenger, .Telegram, .SMS, .CopyLink, .notAvailable:
            break
        }
        params[.ShareNetwork] = actualNetwork.rawValue
        params[.ButtonPosition] = buttonPosition.rawValue
        params[.TypePage] = typePage.rawValue
        return TrackerEvent(name: .ProductShare, params: params)
    }

    static func productShareCancel(_ product: Product, network: EventParameterShareNetwork,
        typePage: EventParameterTypePage) -> TrackerEvent {
            var params = EventParameters()
            params.addProductParams(product)
            params[.ProductType] = product.user.isDummy ?
                EventParameterProductItemType.Dummy.rawValue : EventParameterProductItemType.Real.rawValue
            params[.ShareNetwork] = network.rawValue
            params[.TypePage] = typePage.rawValue
            return TrackerEvent(name: .ProductShareCancel, params: params)
    }

    static func productShareComplete(_ product: Product, network: EventParameterShareNetwork,
        typePage: EventParameterTypePage) -> TrackerEvent {
            var params = EventParameters()
            params.addProductParams(product)
            params[.ProductType] = product.user.isDummy ?
                EventParameterProductItemType.Dummy.rawValue : EventParameterProductItemType.Real.rawValue
            params[.ShareNetwork] = network.rawValue
            params[.TypePage] = typePage.rawValue
            return TrackerEvent(name: .ProductShareComplete, params: params)
    }

    static func firstMessage(_ product: Product, messageType: EventParameterMessageType,
                                          typePage: EventParameterTypePage, sellerRating: Float? = nil) -> TrackerEvent {
        var params = EventParameters()
        params.addProductParams(product)
        params[.MessageType] = messageType.rawValue
        params[.TypePage] = typePage.rawValue
        params[.SellerUserRating] = sellerRating
        return TrackerEvent(name: .FirstMessage, params: params)
    }
    
    // Duplicated method from the one above to support tracking using ChatProduct model
    static func firstMessage(_ product: ChatProduct, messageType: EventParameterMessageType,
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

    static func productDetailOpenChat(_ product: Product, typePage: EventParameterTypePage) -> TrackerEvent {
        var params = EventParameters()
        params[.ProductId] = product.objectId
        params[.TypePage] = typePage.rawValue
        return TrackerEvent(name: .ProductOpenChat, params: params)
    }

    static func productMarkAsSold(_ source: EventParameterSellSourceValue, product: Product, freePostingModeAllowed: Bool)
        -> TrackerEvent {
            var params = EventParameters()

            // Product
            if let productId = product.objectId {
                params[.ProductId] = productId
            }
            params[.ProductPrice] = product.price.value
            params[.ProductCurrency] = product.currency.code
            params[.categoryId] = product.category.rawValue
            params[.FreePosting] = eventParameterFreePostingWithPrice(freePostingModeAllowed, price: product.price).rawValue
            return TrackerEvent(name: .ProductMarkAsSold, params: params)
    }

    static func productMarkAsUnsold(_ product: Product) -> TrackerEvent {
        var params = EventParameters()
        if let productId = product.objectId {
            params[.ProductId] = productId
        }
        params[.ProductPrice] = product.price.value
        params[.ProductCurrency] = product.currency.code
        params[.categoryId] = product.category.rawValue
        return TrackerEvent(name: .ProductMarkAsUnsold, params: params)
    }

    static func productReport(_ product: Product) -> TrackerEvent {
        var params = EventParameters()
        params.addProductParams(product)
        return TrackerEvent(name: .ProductReport, params: params)
    }

    static func productSellStart(_ typePage: EventParameterTypePage,
                                 buttonName: EventParameterButtonNameType?, sellButtonPosition: EventParameterSellButtonPosition) -> TrackerEvent {
        var params = EventParameters()
        params[.TypePage] = typePage.rawValue
        params[.ButtonName] = buttonName?.rawValue
        params[.SellButtonPosition] = sellButtonPosition.rawValue
        return TrackerEvent(name: .ProductSellStart, params: params)
    }

    static func productSellSharedFB(_ product: Product?) -> TrackerEvent {
        var params = EventParameters()
        // Product name
        if let productId = product?.objectId {
            params[.ProductId] = productId
        }
        return TrackerEvent(name: .ProductSellSharedFB, params: params)
    }

    static func productSellComplete(_ product: Product, buttonName: EventParameterButtonNameType?,
                                    sellButtonPosition: EventParameterSellButtonPosition?, negotiable: EventParameterNegotiablePrice?,
                                    pictureSource: EventParameterPictureSource?, freePostingModeAllowed: Bool) -> TrackerEvent {
        var params = EventParameters()
        params[.FreePosting] = eventParameterFreePostingWithPrice(freePostingModeAllowed, price: product.price).rawValue
        params[.ProductId] = product.objectId? ?? ""
        params[.categoryId] = product.category.rawValue
        params[.ProductName] = product.name? ?? ""
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
        return TrackerEvent(name: .productSellComplete, params: params)
    }
    
    static func productSellComplete24h(_ product: Product) -> TrackerEvent {
        var params = EventParameters()
        params[.ProductId] = product.objectId? ?? ""
        return TrackerEvent(name: .ProductSellComplete24h, params: params)
    }

    static func productSellError(_ error: EventParameterPostProductError) -> TrackerEvent {
        var params = EventParameters()
        params[.ErrorDescription] = error.description
        return TrackerEvent(name: .ProductSellError, params: params)
    }

    static func productSellErrorClose(_ error: EventParameterPostProductError) -> TrackerEvent {
        var params = EventParameters()
        params[.ErrorDescription] = error.description
        return TrackerEvent(name: .ProductSellErrorClose, params: params)
    }

    static func productSellErrorPost(_ error: EventParameterPostProductError) -> TrackerEvent {
        var params = EventParameters()
        params[.ErrorDescription] = error.description
        return TrackerEvent(name: .ProductSellErrorPost, params: params)
    }

    static func productSellErrorData(_ error: EventParameterPostProductError) -> TrackerEvent {
        var params = EventParameters()
        params[.ErrorDescription] = error.description
        params[.ErrorDetails] = error.details
        return TrackerEvent(name: .ProductSellErrorData, params: params)
    }

    static func productSellConfirmation(_ product: Product) -> TrackerEvent {
        var params = EventParameters()
        params[.ProductId] = product.objectId? ?? ""
        return TrackerEvent(name: .ProductSellConfirmation, params: params)
    }

    static func productSellConfirmationPost(_ product: Product, buttonType: EventParameterButtonType) -> TrackerEvent {
        var params = EventParameters()
        params[.ProductId] = product.objectId? ?? ""
        params[.ButtonType] = buttonType.rawValue
        return TrackerEvent(name: .ProductSellConfirmationPost, params: params)
    }

    static func productSellConfirmationEdit(_ product: Product) -> TrackerEvent {
        var params = EventParameters()
        params[.ProductId] = product.objectId? ?? ""
        return TrackerEvent(name: .ProductSellConfirmationEdit, params: params)
    }

    static func productSellConfirmationClose(_ product: Product) -> TrackerEvent {
        var params = EventParameters()
        params[.ProductId] = product.objectId? ?? ""
        return TrackerEvent(name: .ProductSellConfirmationClose, params: params)
    }

    static func productSellConfirmationShare(_ product: Product, network: EventParameterShareNetwork)
        -> TrackerEvent {
            var params = EventParameters()
            params[.ProductId] = product.objectId? ?? ""
            params[.ShareNetwork] = network.rawValue
            return TrackerEvent(name: .ProductSellConfirmationShare, params: params)
    }

    static func productSellConfirmationShareCancel(_ product: Product,
        network: EventParameterShareNetwork) -> TrackerEvent {
            var params = EventParameters()
            params[.ProductId] = product.objectId? ?? ""
            params[.ShareNetwork] = network.rawValue
            return TrackerEvent(name: .ProductSellConfirmationShareCancel, params: params)
    }

    static func productSellConfirmationShareComplete(_ product: Product,
        network: EventParameterShareNetwork) -> TrackerEvent {
            var params = EventParameters()
            params[.ProductId] = product.objectId? ?? ""
            params[.ShareNetwork] = network.rawValue
            return TrackerEvent(name: .ProductSellConfirmationShareComplete, params: params)
    }

    static func productEditStart(_ user: User?, product: Product) -> TrackerEvent {
        var params = EventParameters()
        // Product
        params[.ProductId] = product.objectId
        return TrackerEvent(name: .ProductEditStart, params: params)
    }

    static func productEditFormValidationFailed(_ user: User?, product: Product, description: String)
        -> TrackerEvent {
            var params = EventParameters()
            // Product
            params[.ProductId] = product.objectId
            // Validation failure description
            params[.Description] = description
            return TrackerEvent(name: .ProductEditFormValidationFailed, params: params)
    }

    static func productEditSharedFB(_ user: User?, product: Product?) -> TrackerEvent {
        var params = EventParameters()
        // Product
        if let productId = product?.objectId {
            params[.ProductId] = productId
        }
        return TrackerEvent(name: .ProductEditSharedFB, params: params)
    }

    static func productEditComplete(_ user: User?, product: Product, category: ProductCategory?,
        editedFields: [EventParameterEditedFields]) -> TrackerEvent {
            var params = EventParameters()
            // Product
            params[.ProductId] = product.objectId
            params[.categoryId] = category?.rawValue? ?? 0
            params[.EditedFields] = editedFields.map({$0.rawValue}).joined(separator: ",")

            return TrackerEvent(name: .ProductEditComplete, params: params)
    }

    static func productDeleteStart(_ product: Product) -> TrackerEvent {
        var params = EventParameters()
        params[.ProductId] = product.objectId
        return TrackerEvent(name: .ProductDeleteStart, params: params)
    }

    static func productDeleteComplete(_ product: Product) -> TrackerEvent {
        var params = EventParameters()
        params[.ProductId] = product.objectId
        return TrackerEvent(name: .ProductDeleteComplete, params: params)
    }

    static func userMessageSent(_ product: Product, userTo: User?, messageType: EventParameterMessageType,
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
    static func userMessageSent(_ product: ChatProduct, userToId: String?, messageType: EventParameterMessageType,
                                       isQuickAnswer: EventParameterQuickAnswerValue, typePage: EventParameterTypePage) -> TrackerEvent {
        var params = EventParameters()
        params.addChatProductParams(product)
        params[.UserToId] = userToId
        params[.MessageType] = messageType.rawValue
        params[.QuickAnswer] = isQuickAnswer.rawValue
        params[.TypePage] = typePage.rawValue
        return TrackerEvent(name: .UserMessageSent, params: params)
    }

    static func chatRelatedItemsStart(_ shownReason: EventParameterRelatedShownReason) -> TrackerEvent {
        var params = EventParameters()
        params[.ShownReason] = shownReason.rawValue
        return TrackerEvent(name: .ChatRelatedItemsStart, params: params)
    }

    static func chatRelatedItemsComplete(_ itemPosition: Int, shownReason: EventParameterRelatedShownReason) -> TrackerEvent {
        var params = EventParameters()
        params[.ItemPosition] = itemPosition
        params[.ShownReason] = shownReason.rawValue
        return TrackerEvent(name: .ChatRelatedItemsComplete, params: params)
    }

    static func profileVisit(_ user: User, profileType: EventParameterProfileType, typePage: EventParameterTypePage, tab: EventParameterTab)
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

    static func profileEditEditLocation(_ location: LGLocation) -> TrackerEvent {
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

    static func profileShareStart(_ type: EventParameterProfileType)  -> TrackerEvent {
        var params = EventParameters()
        params[.ProfileType] = type.rawValue
        return TrackerEvent(name: .ProfileShareStart, params: params)
    }

    static func profileShareComplete(_ type: EventParameterProfileType, shareNetwork: EventParameterShareNetwork)
        -> TrackerEvent {
        var params = EventParameters()
        params[.ProfileType] = type.rawValue
        params[.ShareNetwork] = shareNetwork.rawValue
        return TrackerEvent(name: .ProfileShareComplete, params: params)
    }

    static func appInviteFriendStart(_ typePage: EventParameterTypePage) -> TrackerEvent {
            var params = EventParameters()
            params[.TypePage] = typePage.rawValue
            return TrackerEvent(name: .AppInviteFriendStart, params: params)
    }

    static func appInviteFriend(_ network: EventParameterShareNetwork, typePage: EventParameterTypePage)
        -> TrackerEvent {
            var params = EventParameters()
            params[.ShareNetwork] = network.rawValue
            params[.TypePage] = typePage.rawValue
            return TrackerEvent(name: .AppInviteFriend, params: params)
    }

    static func appInviteFriendCancel(_ network: EventParameterShareNetwork, typePage: EventParameterTypePage)
        -> TrackerEvent {
            var params = EventParameters()
            params[.ShareNetwork] = network.rawValue
            params[.TypePage] = typePage.rawValue
            return TrackerEvent(name: .AppInviteFriendCancel, params: params)
    }

    static func appInviteFriendDontAsk(_ typePage: EventParameterTypePage)
        -> TrackerEvent {
            var params = EventParameters()
            params[.TypePage] = typePage.rawValue
            return TrackerEvent(name: .AppInviteFriendDontAsk, params: params)
    }

    static func appInviteFriendComplete(_ network: EventParameterShareNetwork, typePage: EventParameterTypePage)
        -> TrackerEvent {
            var params = EventParameters()
            params[.ShareNetwork] = network.rawValue
            params[.TypePage] = typePage.rawValue
            return TrackerEvent(name: .AppInviteFriendComplete, params: params)
    }

    static func appRatingStart(_ source: EventParameterRatingSource) -> TrackerEvent {
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

    static func permissionAlertStart(_ permissionType: EventParameterPermissionType,
        typePage: EventParameterTypePage, alertType: EventParameterPermissionAlertType,
        permissionGoToSettings: EventParameterPermissionGoToSettings) -> TrackerEvent {
            var params = EventParameters()
            params[.PermissionType] = permissionType.rawValue
            params[.TypePage] = typePage.rawValue
            params[.AlertType] = alertType.rawValue
            params[.PermissionGoToSettings] = permissionGoToSettings.rawValue
            return TrackerEvent(name: .PermissionAlertStart, params: params)
    }

    static func permissionAlertCancel(_ permissionType: EventParameterPermissionType,
        typePage: EventParameterTypePage, alertType: EventParameterPermissionAlertType,
        permissionGoToSettings: EventParameterPermissionGoToSettings) -> TrackerEvent {
            var params = EventParameters()
            params[.PermissionType] = permissionType.rawValue
            params[.TypePage] = typePage.rawValue
            params[.AlertType] = alertType.rawValue
            params[.PermissionGoToSettings] = permissionGoToSettings.rawValue
            return TrackerEvent(name: .PermissionAlertCancel, params: params)
    }

    static func permissionAlertComplete(_ permissionType: EventParameterPermissionType,
        typePage: EventParameterTypePage, alertType: EventParameterPermissionAlertType,
        permissionGoToSettings: EventParameterPermissionGoToSettings) -> TrackerEvent {
            var params = EventParameters()
            params[.PermissionType] = permissionType.rawValue
            params[.TypePage] = typePage.rawValue
            params[.AlertType] = alertType.rawValue
            params[.PermissionGoToSettings] = permissionGoToSettings.rawValue
            return TrackerEvent(name: .PermissionAlertComplete, params: params)
    }

    static func permissionSystemStart(_ permissionType: EventParameterPermissionType,
        typePage: EventParameterTypePage) -> TrackerEvent {
            var params = EventParameters()
            params[.PermissionType] = permissionType.rawValue
            params[.TypePage] = typePage.rawValue
            return TrackerEvent(name: .PermissionSystemStart, params: params)
    }

    static func permissionSystemCancel(_ permissionType: EventParameterPermissionType,
        typePage: EventParameterTypePage) -> TrackerEvent {
            var params = EventParameters()
            params[.PermissionType] = permissionType.rawValue
            params[.TypePage] = typePage.rawValue
            return TrackerEvent(name: .PermissionSystemCancel, params: params)
    }

    static func permissionSystemComplete(_ permissionType: EventParameterPermissionType,
        typePage: EventParameterTypePage) -> TrackerEvent {
            var params = EventParameters()
            params[.PermissionType] = permissionType.rawValue
            params[.TypePage] = typePage.rawValue
            return TrackerEvent(name: .PermissionSystemComplete, params: params)
    }

    static func profileReport(_ typePage: EventParameterTypePage, reportedUserId: String,
        reason: EventParameterReportReason) -> TrackerEvent{
            var params = EventParameters()
            params[.ReportReason] = reason.rawValue
            params[.TypePage] = typePage.rawValue
            params[.UserToId] = reportedUserId
            return TrackerEvent(name: .ProfileReport, params: params)
    }

    static func profileBlock(_ typePage: EventParameterTypePage, blockedUsersIds: [String]) -> TrackerEvent{
        var params = EventParameters()
        params[.TypePage] = typePage.rawValue
        params[.UserToId] = blockedUsersIds.joined(separator: ",")
        return TrackerEvent(name: .ProfileBlock, params: params)
    }

    static func profileUnblock(_ typePage: EventParameterTypePage, unblockedUsersIds: [String]) -> TrackerEvent{
        var params = EventParameters()
        params[.TypePage] = typePage.rawValue
        params[.UserToId] = unblockedUsersIds.joined(separator: ",")
        return TrackerEvent(name: .ProfileUnblock, params: params)
    }

    static func commercializerStart(_ productId: String?, typePage: EventParameterTypePage) -> TrackerEvent {
        var params = EventParameters()
        params[.ProductId] = productId? ?? ""
        params[.TypePage] = typePage.rawValue
        return TrackerEvent(name: .CommercializerStart, params: params)
    }

    static func commercializerError(_ productId: String?, typePage: EventParameterTypePage,
        error: EventParameterCommercializerError) -> TrackerEvent {
            var params = EventParameters()
            params[.ProductId] = productId? ?? ""
            params[.TypePage] = typePage.rawValue
            params[.ErrorDescription] = error.rawValue
            return TrackerEvent(name: .CommercializerError, params: params)
    }

    static func commercializerComplete(_ productId: String?, typePage: EventParameterTypePage,
        template: String) -> TrackerEvent {
            var params = EventParameters()
            params[.ProductId] = productId? ?? ""
            params[.TypePage] = typePage.rawValue
            params[.Template] = template
            return TrackerEvent(name: .CommercializerComplete, params: params)
    }

    static func commercializerOpen(_ productId: String?, typePage: EventParameterTypePage,
        template: String) -> TrackerEvent {
            var params = EventParameters()
            params[.ProductId] = productId? ?? ""
            params[.TypePage] = typePage.rawValue
            params[.Template] = template
            return TrackerEvent(name: .CommercializerOpen, params: params)
    }

    static func commercializerShareStart(_ productId: String?, typePage: EventParameterTypePage, template: String,
        shareNetwork: EventParameterShareNetwork) -> TrackerEvent {
            var params = EventParameters()
            params[.ProductId] = productId? ?? ""
            params[.TypePage] = typePage.rawValue
            params[.Template] = template
            params[.ShareNetwork] = shareNetwork.rawValue
            return TrackerEvent(name: .CommercializerShareStart, params: params)
    }

    static func commercializerShareComplete(_ productId: String?, typePage: EventParameterTypePage, template: String,
                                                shareNetwork: EventParameterShareNetwork) -> TrackerEvent {
        var params = EventParameters()
        params[.ProductId] = productId? ?? ""
        params[.TypePage] = typePage.rawValue
        params[.Template] = template
        params[.ShareNetwork] = shareNetwork.rawValue
        return TrackerEvent(name: .CommercializerShareComplete, params: params)
    }

    static func userRatingStart(_ userId: String, typePage: EventParameterTypePage) -> TrackerEvent {
        var params = EventParameters()
        params[.UserToId] = userId
        params[.TypePage] = typePage.rawValue
        return TrackerEvent(name: .UserRatingStart, params: params)
    }

    static func userRatingComplete(_ userId: String, typePage: EventParameterTypePage,
                                          rating: Int, hasComments: Bool) -> TrackerEvent {
        var params = EventParameters()
        params[.UserToId] = userId
        params[.TypePage] = typePage.rawValue
        params[.RatingStars] = rating
        params[.RatingComments] = hasComments
        return TrackerEvent(name: .UserRatingComplete, params: params)
    }

    static func openAppExternal(_ campaign: String? = nil, medium: String? = nil, source: DeepLinkSource) -> TrackerEvent {
        var params = EventParameters()
        params[.Campaign] = campaign
        params[.Medium] = medium
        switch source {
        case let .external(theSource):
            params[.Source] = theSource
        case .push:
            params[.Source] = "push"
        case .none:
            break
        }
        return TrackerEvent(name: .openApp, params: params)
    }

    static func expressChatStart(_ trigger: EventParameterExpressChatTrigger) -> TrackerEvent {
        var params = EventParameters()
        params[.ExpressChatTrigger] = trigger.rawValue
        return TrackerEvent(name: .ExpressChatStart, params: params)
    }

    static func expressChatComplete(_ numConversations: Int, trigger: EventParameterExpressChatTrigger) -> TrackerEvent {
        var params = EventParameters()
        params[.ExpressConversations] = numConversations
        params[.ExpressChatTrigger] = trigger.rawValue
        return TrackerEvent(name: .ExpressChatComplete, params: params)
    }

    static func expressChatDontAsk(_ trigger: EventParameterExpressChatTrigger) -> TrackerEvent {
        var params = EventParameters()
        params[.ExpressChatTrigger] = trigger.rawValue
        return TrackerEvent(name: .ExpressChatDontAsk, params: params)
    }

    static func productDetailInterestedUsers(_ number: Int, productId: String)  -> TrackerEvent {
        var params = EventParameters()
        params[.NumberOfUsers] = number
        params[.ProductId] = productId
        return TrackerEvent(name: .ProductDetailInterestedUsers, params: params)
    }
    
    static func npsStart() -> TrackerEvent {
        return TrackerEvent(name: .NPSStart, params: nil)
    }
    
    static func npsComplete(_ score: Int) -> TrackerEvent {
        var params = EventParameters()
        params[.NPSScore] = score
        return TrackerEvent(name: .NPSComplete, params: params)
    }

    static func verifyAccountStart(_ typePage: EventParameterTypePage) -> TrackerEvent {
        var params = EventParameters()
        params[.TypePage] = typePage.rawValue
        return TrackerEvent(name: .VerifyAccountStart, params: params)
    }

    static func verifyAccountComplete(_ typePage: EventParameterTypePage, network: EventParameterAccountNetwork) -> TrackerEvent {
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

    static func notificationCenterComplete(_ type: EventParameterNotificationType) -> TrackerEvent {
        var params = EventParameters()
        params[.NotificationType] = type.rawValue
        return TrackerEvent(name: .NotificationCenterComplete, params: params)
    }

    static func marketingPushNotifications(_ userId: String?, enabled: Bool) -> TrackerEvent {
        var params = EventParameters()
        params[.UserId] = userId
        params[.enabled] = enabled
        return TrackerEvent(name: .MarketingPushNotifications, params: params)
    }


    // MARK: - Private methods

    private static func eventParameterLocationTypeForLocation(_ location: LGLocation) -> EventParameterLocationType? {
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

    private static func eventParameterSortByTypeForSorting(_ sorting: ProductSortCriteria?) -> EventParameterSortBy? {
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

    private static func eventParameterPostedWithinForTime(_ time: ProductTimeCriteria?) -> EventParameterPostedWithin? {
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

    private static func eventParameterHasPriceFilter(_ price: Int?) -> EventParameterHasPriceFilter {
        return price != nil ? .True : .False
    }
    
    private static func eventParameterFreePostingWithPrice(_ freePostingModeAllowed: Bool, price: ProductPrice) -> EventParameterFreePosting {
        guard freePostingModeAllowed else {return .Unset}
        return price.free ? .True : .False
    }
    
    private static func eventParameterFreePostingWithPriceRange(_ freePostingModeAllowed: Bool, priceRange: FilterPriceRange) -> EventParameterFreePosting {
        guard freePostingModeAllowed else {return .Unset}
        return priceRange.free ? .True : .False
    }
}
