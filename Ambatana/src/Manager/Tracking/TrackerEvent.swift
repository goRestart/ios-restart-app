//
//  TrackerEvent.swift
//  LetGo
//
//  Created by Albert Hernández López on 05/08/15.
//  Copyright (c) 2015 Ambatana. All rights reserved.
//

import LGCoreKit

public struct TrackerEvent {
    public private(set) var name: EventName
    public var actualName: String {
        get {
            return name.actualEventName
        }
    }
    public private(set) var params: EventParameters?

    public static func location(location: LGLocation, locationServiceStatus: LocationServiceStatus) -> TrackerEvent {
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

    public static func loginVisit(source: EventParameterLoginSourceValue) -> TrackerEvent {
        var params = EventParameters()
        params.addLoginParams(source)
        return TrackerEvent(name: .LoginVisit, params: params)
    }

    public static func loginAbandon(source: EventParameterLoginSourceValue) -> TrackerEvent {
        var params = EventParameters()
        params.addLoginParams(source)
        return TrackerEvent(name: .LoginAbandon, params: params)
    }

    public static func loginFB(source: EventParameterLoginSourceValue) -> TrackerEvent {
        var params = EventParameters()
        params.addLoginParams(source)
        return TrackerEvent(name: .LoginFB, params: params)
    }
    
    public static func loginGoogle(source: EventParameterLoginSourceValue) -> TrackerEvent {
        var params = EventParameters()
        params.addLoginParams(source)
        return TrackerEvent(name: .LoginGoogle, params: params)
    }

    public static func loginEmail(source: EventParameterLoginSourceValue) -> TrackerEvent {
        var params = EventParameters()
        params.addLoginParams(source)
        return TrackerEvent(name: .LoginEmail, params: params)
    }

    public static func signupEmail(source: EventParameterLoginSourceValue, newsletter: EventParameterNewsletter)
        -> TrackerEvent {
            var params = EventParameters()
            params.addLoginParams(source)
            params[.Newsletter] = newsletter.rawValue
            return TrackerEvent(name: .SignupEmail, params: params)
    }

    public static func logout() -> TrackerEvent {
        return TrackerEvent(name: .Logout, params: nil)
    }

    public static func loginEmailError(errorDescription: EventParameterLoginError) -> TrackerEvent {
        var params = EventParameters()

        params[.ErrorDescription] = errorDescription.description
        params[.ErrorDetails] = errorDescription.details

        return TrackerEvent(name: .LoginEmailError, params: params)
    }

    public static func loginFBError(errorDescription: EventParameterLoginError) -> TrackerEvent {
        var params = EventParameters()

        params[.ErrorDescription] = errorDescription.description
        params[.ErrorDetails] = errorDescription.details

        return TrackerEvent(name: .LoginFBError, params: params)
    }

    public static func loginGoogleError(errorDescription: EventParameterLoginError) -> TrackerEvent {
        var params = EventParameters()

        params[.ErrorDescription] = errorDescription.description
        params[.ErrorDetails] = errorDescription.details

        return TrackerEvent(name: .LoginGoogleError, params: params)
    }

    public static func signupError(errorDescription: EventParameterLoginError) -> TrackerEvent {
        var params = EventParameters()

        params[.ErrorDescription] = errorDescription.description
        params[.ErrorDetails] = errorDescription.details

        return TrackerEvent(name: .SignupError, params: params)
    }

    public static func passwordResetError(errorDescription: EventParameterLoginError) -> TrackerEvent {
        var params = EventParameters()

        params[.ErrorDescription] = errorDescription.description
        params[.ErrorDetails] = errorDescription.details

        return TrackerEvent(name: .PasswordResetError, params: params)
    }

    public static func productList(user: User?, categories: [ProductCategory]?, searchQuery: String?) -> TrackerEvent {
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

    public static func searchStart(user: User?) -> TrackerEvent {
        let params = EventParameters()

        return TrackerEvent(name: .SearchStart, params: params)
    }

    public static func searchComplete(user: User?, searchQuery: String, success: EventParameterSearchCompleteSuccess)
        -> TrackerEvent {
            var params = EventParameters()
            // Search query
            params[.SearchString] = searchQuery
            params[.SearchSuccess] = success.rawValue
            return TrackerEvent(name: .SearchComplete, params: params)
    }

    public static func filterStart() -> TrackerEvent {
        return TrackerEvent(name: .FilterStart, params: nil)
    }

    public static func filterComplete(coordinates: LGLocationCoordinates2D?, distanceRadius: Int?,
        distanceUnit: DistanceType, categories: [ProductCategory]?, sortBy: ProductSortCriteria?) -> TrackerEvent {
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

            return TrackerEvent(name: .FilterComplete, params: params)
    }

    public static func productDetailVisit(product: Product, visitUserAction: ProductVisitUserAction) -> TrackerEvent {
        var params = EventParameters()
        params.addProductParams(product)
        params[.UserAction] = visitUserAction.rawValue
        return TrackerEvent(name: .ProductDetailVisit, params: params)
    }
    
    public static func productDetailVisitMoreInfo(product: Product) -> TrackerEvent {
        var params = EventParameters()
        params.addProductParams(product)
        return TrackerEvent(name: .ProductDetailVisitMoreInfo, params: params)
    }

    public static func productFavorite(product: Product, typePage: EventParameterTypePage) -> TrackerEvent {
        var params = EventParameters()
        params.addProductParams(product)
        params[.TypePage] = typePage.rawValue
        return TrackerEvent(name: .ProductFavorite, params: params)
    }

    public static func productShare(product: Product, network: EventParameterShareNetwork,
        buttonPosition: EventParameterButtonPosition, typePage: EventParameterTypePage) -> TrackerEvent {
            var params = EventParameters()
            params.addProductParams(product)
            params[.ShareNetwork] = network.rawValue
            params[.ButtonPosition] = buttonPosition.rawValue
            params[.TypePage] = typePage.rawValue
            return TrackerEvent(name: .ProductShare, params: params)
    }

    public static func productShareCancel(product: Product, network: EventParameterShareNetwork,
        typePage: EventParameterTypePage) -> TrackerEvent {
            var params = EventParameters()
            params.addProductParams(product)
            params[.ProductType] = product.user.isDummy ?
                EventParameterProductItemType.Dummy.rawValue : EventParameterProductItemType.Real.rawValue
            params[.ShareNetwork] = network.rawValue
            params[.TypePage] = typePage.rawValue
            return TrackerEvent(name: .ProductShareCancel, params: params)
    }

    public static func productShareComplete(product: Product, network: EventParameterShareNetwork,
        typePage: EventParameterTypePage) -> TrackerEvent {
            var params = EventParameters()
            params.addProductParams(product)
            params[.ProductType] = product.user.isDummy ?
                EventParameterProductItemType.Dummy.rawValue : EventParameterProductItemType.Real.rawValue
            params[.ShareNetwork] = network.rawValue
            params[.TypePage] = typePage.rawValue
            return TrackerEvent(name: .ProductShareComplete, params: params)
    }

    public static func productAskQuestion(product: Product, messageType: EventParameterMessageType,
                                          typePage: EventParameterTypePage, sellerRating: Float? = nil) -> TrackerEvent {
        var params = EventParameters()
        params.addProductParams(product)
        params[.MessageType] = messageType.rawValue
        params[.TypePage] = typePage.rawValue
        params[.SellerUserRating] = sellerRating
        return TrackerEvent(name: .ProductAskQuestion, params: params)
    }
    
    // Duplicated method from the one above to support tracking using ChatProduct model
    public static func productAskQuestion(product: ChatProduct, messageType: EventParameterMessageType,
                                          interlocutorId: String?, typePage: EventParameterTypePage,
                                          sellerRating: Float? = nil) -> TrackerEvent {
        // Note: does not have: category-id, product-lat, product-lng
        var params = EventParameters()
        params.addChatProductParams(product)
        params[.MessageType] = messageType.rawValue
        params[.TypePage] = typePage.rawValue
        params[.UserToId] = interlocutorId
        params[.SellerUserRating] = sellerRating
        return TrackerEvent(name: .ProductAskQuestion, params: params)
    }

    public static func productDetailContinueChatting(product: Product) -> TrackerEvent {
        var params = EventParameters()
        params.addProductParams(product)
        return TrackerEvent(name: .ProductContinueChatting, params: params)
    }

    public static func productDetailChatButton(product: Product) -> TrackerEvent {
        var params = EventParameters()
        params[.ProductId] = product.objectId
        return TrackerEvent(name: .ProductChatButton, params: params)
    }

    public static func productMarkAsSold(source: EventParameterSellSourceValue, product: Product)
        -> TrackerEvent {
            var params = EventParameters()

            // Product
            if let productId = product.objectId {
                params[.ProductId] = productId
            }
            if let productPrice = product.price {
                params[.ProductPrice] = productPrice
            }
            params[.ProductCurrency] = product.currency.code
            params[.CategoryId] = product.category.rawValue
            return TrackerEvent(name: .ProductMarkAsSold, params: params)
    }

    public static func productMarkAsUnsold(product: Product) -> TrackerEvent {
        var params = EventParameters()
        if let productId = product.objectId {
            params[.ProductId] = productId
        }
        if let productPrice = product.price {
            params[.ProductPrice] = productPrice
        }
        params[.ProductCurrency] = product.currency.code
        params[.CategoryId] = product.category.rawValue
        return TrackerEvent(name: .ProductMarkAsUnsold, params: params)
    }

    public static func productReport(product: Product) -> TrackerEvent {
        var params = EventParameters()
        params.addProductParams(product)
        return TrackerEvent(name: .ProductReport, params: params)
    }

    public static func productSellStart(typePage: EventParameterTypePage, designType: String? = nil) -> TrackerEvent {
        var params = EventParameters()
        params[.TypePage] = typePage.rawValue
        params[.DesignType] = designType
        return TrackerEvent(name: .ProductSellStart, params: params)
    }

    public static func productSellFormValidationFailed(description: String) -> TrackerEvent {
        var params = EventParameters()
        // Validation failure description
        params[.Description] = description
        return TrackerEvent(name: .ProductSellFormValidationFailed, params: params)
    }

    public static func productSellSharedFB(product: Product?) -> TrackerEvent {
        var params = EventParameters()
        // Product name
        if let productId = product?.objectId {
            params[.ProductId] = productId
        }
        return TrackerEvent(name: .ProductSellSharedFB, params: params)
    }

    public static func productSellComplete(product: Product) -> TrackerEvent {
        return productSellComplete(product, buttonName: nil, negotiable: nil, pictureSource: nil)
    }

    public static func productSellComplete(product: Product, buttonName: EventParameterButtonNameType?,
        negotiable: EventParameterNegotiablePrice?, pictureSource: EventParameterPictureSource?) -> TrackerEvent {
            var params = EventParameters()
            params[.ProductId] = product.objectId ?? ""
            params[.CategoryId] = product.category.rawValue
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
    
    public static func productSellComplete24h(product: Product) -> TrackerEvent {
        var params = EventParameters()
        params[.ProductId] = product.objectId ?? ""
        return TrackerEvent(name: .ProductSellComplete24h, params: params)
    }

    public static func productSellError(error: EventParameterPostProductError) -> TrackerEvent {
        var params = EventParameters()
        params[.ErrorDescription] = error.rawValue
        return TrackerEvent(name: .ProductSellError, params: params)
    }

    public static func productSellErrorClose(error: EventParameterPostProductError) -> TrackerEvent {
        var params = EventParameters()
        params[.ErrorDescription] = error.rawValue
        return TrackerEvent(name: .ProductSellErrorClose, params: params)
    }

    public static func productSellErrorPost(error: EventParameterPostProductError) -> TrackerEvent {
        var params = EventParameters()
        params[.ErrorDescription] = error.rawValue
        return TrackerEvent(name: .ProductSellErrorPost, params: params)
    }

    public static func productSellConfirmation(product: Product) -> TrackerEvent {
        var params = EventParameters()
        params[.ProductId] = product.objectId ?? ""
        return TrackerEvent(name: .ProductSellConfirmation, params: params)
    }

    public static func productSellConfirmationPost(product: Product) -> TrackerEvent {
        var params = EventParameters()
        params[.ProductId] = product.objectId ?? ""
        return TrackerEvent(name: .ProductSellConfirmationPost, params: params)
    }

    public static func productSellConfirmationEdit(product: Product) -> TrackerEvent {
        var params = EventParameters()
        params[.ProductId] = product.objectId ?? ""
        return TrackerEvent(name: .ProductSellConfirmationEdit, params: params)
    }

    public static func productSellConfirmationClose(product: Product) -> TrackerEvent {
        var params = EventParameters()
        params[.ProductId] = product.objectId ?? ""
        return TrackerEvent(name: .ProductSellConfirmationClose, params: params)
    }

    public static func productSellConfirmationShare(product: Product, network: EventParameterShareNetwork)
        -> TrackerEvent {
            var params = EventParameters()
            params[.ProductId] = product.objectId ?? ""
            params[.ShareNetwork] = network.rawValue
            return TrackerEvent(name: .ProductSellConfirmationShare, params: params)
    }

    public static func productSellConfirmationShareCancel(product: Product,
        network: EventParameterShareNetwork) -> TrackerEvent {
            var params = EventParameters()
            params[.ProductId] = product.objectId ?? ""
            params[.ShareNetwork] = network.rawValue
            return TrackerEvent(name: .ProductSellConfirmationShareCancel, params: params)
    }

    public static func productSellConfirmationShareComplete(product: Product,
        network: EventParameterShareNetwork) -> TrackerEvent {
            var params = EventParameters()
            params[.ProductId] = product.objectId ?? ""
            params[.ShareNetwork] = network.rawValue
            return TrackerEvent(name: .ProductSellConfirmationShareComplete, params: params)
    }

    public static func productEditStart(user: User?, product: Product) -> TrackerEvent {
        var params = EventParameters()
        // Product
        params[.ProductId] = product.objectId
        return TrackerEvent(name: .ProductEditStart, params: params)
    }

    public static func productEditFormValidationFailed(user: User?, product: Product, description: String)
        -> TrackerEvent {
            var params = EventParameters()
            // Product
            params[.ProductId] = product.objectId
            // Validation failure description
            params[.Description] = description
            return TrackerEvent(name: .ProductEditFormValidationFailed, params: params)
    }

    public static func productEditSharedFB(user: User?, product: Product?) -> TrackerEvent {
        var params = EventParameters()
        // Product
        if let productId = product?.objectId {
            params[.ProductId] = productId
        }
        return TrackerEvent(name: .ProductEditSharedFB, params: params)
    }

    public static func productEditComplete(user: User?, product: Product, category: ProductCategory?,
        editedFields: [EventParameterEditedFields]) -> TrackerEvent {
            var params = EventParameters()
            // Product
            params[.ProductId] = product.objectId
            params[.CategoryId] = category?.rawValue ?? 0
            params[.EditedFields] = editedFields.map({$0.value}).joinWithSeparator(",")

            return TrackerEvent(name: .ProductEditComplete, params: params)
    }

    public static func productDeleteStart(product: Product) -> TrackerEvent {
        var params = EventParameters()
        params[.ProductId] = product.objectId
        return TrackerEvent(name: .ProductDeleteStart, params: params)
    }

    public static func productDeleteComplete(product: Product) -> TrackerEvent {
        var params = EventParameters()
        params[.ProductId] = product.objectId
        return TrackerEvent(name: .ProductDeleteComplete, params: params)
    }

    public static func userMessageSent(product: Product, userTo: User?, messageType: EventParameterMessageType,
                                       isQuickAnswer: EventParameterQuickAnswerValue) -> TrackerEvent {
        var params = EventParameters()
        params.addProductParams(product)
        params.addUserParams(userTo)
        params[.MessageType] = messageType.rawValue
        params[.QuickAnswer] = isQuickAnswer.rawValue
        return TrackerEvent(name: .UserMessageSent, params: params)
    }
    
    // Duplicated method from the one above to support tracking using ChatProduct model
    public static func userMessageSent(product: ChatProduct, userToId: String?, messageType: EventParameterMessageType,
                                       isQuickAnswer: EventParameterQuickAnswerValue) -> TrackerEvent {
        var params = EventParameters()
        params.addChatProductParams(product)
        params[.UserToId] = userToId
        params[.MessageType] = messageType.rawValue
        params[.QuickAnswer] = isQuickAnswer.rawValue
        return TrackerEvent(name: .UserMessageSent, params: params)
    }

    public static func profileVisit(user: User, typePage: EventParameterTypePage, tab: EventParameterTab)
        -> TrackerEvent {
            var params = EventParameters()
            params[.TypePage] = typePage.rawValue
            params[.UserToId] = user.objectId
            params[.Tab] = tab.rawValue
            return TrackerEvent(name: .ProfileVisit, params: params)
    }

    public static func profileEditStart() -> TrackerEvent {
        let params = EventParameters()
        return TrackerEvent(name: .ProfileEditStart, params: params)
    }

    public static func profileEditEditName() -> TrackerEvent {
        let params = EventParameters()
        return TrackerEvent(name: .ProfileEditEditName, params: params)
    }

    public static func profileEditEditLocation(location: LGLocation) -> TrackerEvent {
        var params = EventParameters()
        let locationTypeParamValue = eventParameterLocationTypeForLocation(location)
        if let _ = locationTypeParamValue {
            params[.LocationType] = location.type?.rawValue
        }
        return TrackerEvent(name: .ProfileEditEditLocation, params: params)
    }

    public static func profileEditEditPicture() -> TrackerEvent {
        let params = EventParameters()
        return TrackerEvent(name: .ProfileEditEditPicture, params: params)
    }

    public static func appInviteFriendStart(typePage: EventParameterTypePage) -> TrackerEvent {
            var params = EventParameters()
            params[.TypePage] = typePage.rawValue
            return TrackerEvent(name: .AppInviteFriendStart, params: params)
    }

    public static func appInviteFriend(network: EventParameterShareNetwork, typePage: EventParameterTypePage)
        -> TrackerEvent {
            var params = EventParameters()
            params[.ShareNetwork] = network.rawValue
            params[.TypePage] = typePage.rawValue
            return TrackerEvent(name: .AppInviteFriend, params: params)
    }

    public static func appInviteFriendCancel(network: EventParameterShareNetwork, typePage: EventParameterTypePage)
        -> TrackerEvent {
            var params = EventParameters()
            params[.ShareNetwork] = network.rawValue
            params[.TypePage] = typePage.rawValue
            return TrackerEvent(name: .AppInviteFriendCancel, params: params)
    }

    public static func appInviteFriendDontAsk(typePage: EventParameterTypePage)
        -> TrackerEvent {
            var params = EventParameters()
            params[.TypePage] = typePage.rawValue
            return TrackerEvent(name: .AppInviteFriendDontAsk, params: params)
    }

    public static func appInviteFriendComplete(network: EventParameterShareNetwork, typePage: EventParameterTypePage)
        -> TrackerEvent {
            var params = EventParameters()
            params[.ShareNetwork] = network.rawValue
            params[.TypePage] = typePage.rawValue
            return TrackerEvent(name: .AppInviteFriendComplete, params: params)
    }

    public static func appRatingStart(source: EventParameterRatingSource) -> TrackerEvent {
        var params = EventParameters()
        params[.AppRatingSource] = source.rawValue
        return TrackerEvent(name: .AppRatingStart, params: params)
    }

    public static func appRatingRate() -> TrackerEvent {
        let params = EventParameters()
        return TrackerEvent(name: .AppRatingRate, params: params)
    }

    public static func appRatingSuggest() -> TrackerEvent {
        let params = EventParameters()
        return TrackerEvent(name: .AppRatingSuggest, params: params)
    }

    public static func appRatingDontAsk() -> TrackerEvent {
        let params = EventParameters()
        return TrackerEvent(name: .AppRatingDontAsk, params: params)
    }

    public static func appRatingRemindMeLater() -> TrackerEvent {
        let params = EventParameters()
        return TrackerEvent(name: .AppRatingRemindMeLater, params: params)
    }

    public static func appRatingBannerOpen() -> TrackerEvent {
        let params = EventParameters()
        return TrackerEvent(name: .AppRatingBannerOpen, params: params)
    }

    public static func appRatingBannerClose() -> TrackerEvent {
        let params = EventParameters()
        return TrackerEvent(name: .AppRatingBannerClose, params: params)
    }


    public static func permissionAlertStart(permissionType: EventParameterPermissionType,
        typePage: EventParameterTypePage, alertType: EventParameterPermissionAlertType,
        permissionGoToSettings: EventParameterPermissionGoToSettings) -> TrackerEvent {
            var params = EventParameters()
            params[.PermissionType] = permissionType.rawValue
            params[.TypePage] = typePage.rawValue
            params[.AlertType] = alertType.rawValue
            params[.PermissionGoToSettings] = permissionGoToSettings.rawValue
            return TrackerEvent(name: .PermissionAlertStart, params: params)
    }

    public static func permissionAlertCancel(permissionType: EventParameterPermissionType,
        typePage: EventParameterTypePage, alertType: EventParameterPermissionAlertType,
        permissionGoToSettings: EventParameterPermissionGoToSettings) -> TrackerEvent {
            var params = EventParameters()
            params[.PermissionType] = permissionType.rawValue
            params[.TypePage] = typePage.rawValue
            params[.AlertType] = alertType.rawValue
            params[.PermissionGoToSettings] = permissionGoToSettings.rawValue
            return TrackerEvent(name: .PermissionAlertCancel, params: params)
    }

    public static func permissionAlertComplete(permissionType: EventParameterPermissionType,
        typePage: EventParameterTypePage, alertType: EventParameterPermissionAlertType,
        permissionGoToSettings: EventParameterPermissionGoToSettings) -> TrackerEvent {
            var params = EventParameters()
            params[.PermissionType] = permissionType.rawValue
            params[.TypePage] = typePage.rawValue
            params[.AlertType] = alertType.rawValue
            params[.PermissionGoToSettings] = permissionGoToSettings.rawValue
            return TrackerEvent(name: .PermissionAlertComplete, params: params)
    }

    public static func permissionSystemStart(permissionType: EventParameterPermissionType,
        typePage: EventParameterTypePage) -> TrackerEvent {
            var params = EventParameters()
            params[.PermissionType] = permissionType.rawValue
            params[.TypePage] = typePage.rawValue
            return TrackerEvent(name: .PermissionSystemStart, params: params)
    }

    public static func permissionSystemCancel(permissionType: EventParameterPermissionType,
        typePage: EventParameterTypePage) -> TrackerEvent {
            var params = EventParameters()
            params[.PermissionType] = permissionType.rawValue
            params[.TypePage] = typePage.rawValue
            return TrackerEvent(name: .PermissionSystemCancel, params: params)
    }

    public static func permissionSystemComplete(permissionType: EventParameterPermissionType,
        typePage: EventParameterTypePage) -> TrackerEvent {
            var params = EventParameters()
            params[.PermissionType] = permissionType.rawValue
            params[.TypePage] = typePage.rawValue
            return TrackerEvent(name: .PermissionSystemComplete, params: params)
    }

    public static func profileReport(typePage: EventParameterTypePage, reportedUserId: String,
        reason: EventParameterReportReason) -> TrackerEvent{
            var params = EventParameters()
            params[.ReportReason] = reason.rawValue
            params[.TypePage] = typePage.rawValue
            params[.UserToId] = reportedUserId
            return TrackerEvent(name: .ProfileReport, params: params)
    }

    public static func profileBlock(typePage: EventParameterTypePage, blockedUsersIds: [String]) -> TrackerEvent{
        var params = EventParameters()
        params[.TypePage] = typePage.rawValue
        params[.UserToId] = blockedUsersIds.joinWithSeparator(",")
        return TrackerEvent(name: .ProfileBlock, params: params)
    }

    public static func profileUnblock(typePage: EventParameterTypePage, unblockedUsersIds: [String]) -> TrackerEvent{
        var params = EventParameters()
        params[.TypePage] = typePage.rawValue
        params[.UserToId] = unblockedUsersIds.joinWithSeparator(",")
        return TrackerEvent(name: .ProfileUnblock, params: params)
    }

    public static func locationMapShown() -> TrackerEvent {
        let params = EventParameters()
        return TrackerEvent(name: .LocationMap, params: params)
    }

    public static func commercializerStart(productId: String?, typePage: EventParameterTypePage) -> TrackerEvent {
        var params = EventParameters()
        params[.ProductId] = productId ?? ""
        params[.TypePage] = typePage.rawValue
        return TrackerEvent(name: .CommercializerStart, params: params)
    }

    public static func commercializerError(productId: String?, typePage: EventParameterTypePage,
        error: EventParameterCommercializerError) -> TrackerEvent {
            var params = EventParameters()
            params[.ProductId] = productId ?? ""
            params[.TypePage] = typePage.rawValue
            params[.ErrorDescription] = error.rawValue
            return TrackerEvent(name: .CommercializerError, params: params)
    }

    public static func commercializerComplete(productId: String?, typePage: EventParameterTypePage,
        template: String) -> TrackerEvent {
            var params = EventParameters()
            params[.ProductId] = productId ?? ""
            params[.TypePage] = typePage.rawValue
            params[.Template] = template
            return TrackerEvent(name: .CommercializerComplete, params: params)
    }

    public static func commercializerOpen(productId: String?, typePage: EventParameterTypePage,
        template: String) -> TrackerEvent {
            var params = EventParameters()
            params[.ProductId] = productId ?? ""
            params[.TypePage] = typePage.rawValue
            params[.Template] = template
            return TrackerEvent(name: .CommercializerOpen, params: params)
    }

    public static func commercializerShareStart(productId: String?, typePage: EventParameterTypePage, template: String,
        shareNetwork: EventParameterShareNetwork) -> TrackerEvent {
            var params = EventParameters()
            params[.ProductId] = productId ?? ""
            params[.TypePage] = typePage.rawValue
            params[.Template] = template
            params[.ShareNetwork] = shareNetwork.rawValue
            return TrackerEvent(name: .CommercializerShareStart, params: params)
    }

    public static func commercializerShareComplete(productId: String?, typePage: EventParameterTypePage, template: String,
                                                shareNetwork: EventParameterShareNetwork) -> TrackerEvent {
        var params = EventParameters()
        params[.ProductId] = productId ?? ""
        params[.TypePage] = typePage.rawValue
        params[.Template] = template
        params[.ShareNetwork] = shareNetwork.rawValue
        return TrackerEvent(name: .CommercializerShareComplete, params: params)
    }

    public static func userRatingStart(userId: String, typePage: EventParameterTypePage) -> TrackerEvent {
        var params = EventParameters()
        params[.UserToId] = userId
        params[.TypePage] = typePage.rawValue
        return TrackerEvent(name: .UserRatingStart, params: params)
    }

    public static func userRatingComplete(userId: String, typePage: EventParameterTypePage,
                                          rating: Int, hasComments: Bool) -> TrackerEvent {
        var params = EventParameters()
        params[.UserToId] = userId
        params[.TypePage] = typePage.rawValue
        params[.RatingStars] = rating
        params[.RatingComments] = hasComments
        return TrackerEvent(name: .UserRatingComplete, params: params)
    }

    static func openApp(campaign: String? = nil, medium: String? = nil, source: DeepLinkSource) -> TrackerEvent {
        var params = EventParameters()
        params[.Campaign] = campaign
        params[.Medium] = medium
        switch source {
        case .Direct:
            params[.Source] = "direct"
        case let .External(theSource):
            params[.Source] = theSource
        case .Push:
            params[.Source] = "push"
        case .None:
            break
        }
        return TrackerEvent(name: .OpenApp, params: params)
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
}
