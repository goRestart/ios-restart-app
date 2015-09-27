//
//  TrackerEventDataTypes.swift
//  LetGo
//
//  Created by Albert Hernández López on 06/08/15.
//  Copyright (c) 2015 Ambatana. All rights reserved.
//

import LGCoreKit

public enum EventName: String {
    case Location                           = "location"
//    case IndicateLocationVisit              = "indica"
    
    case LoginVisit                         = "login-screen"
    case LoginAbandon                       = "login-abandon"
    case LoginFB                            = "login-fb"
    case LoginEmail                         = "login-email"
    case SignupEmail                        = "signup-email"
    case Logout                             = "logout"
    case ProductList                        = "product-list"
    
    case SearchStart                        = "search-start"
    case SearchComplete                     = "search-complete"
    
    case ProductDetailVisit                 = "product-detail-visit"
    
    case ProductFavorite                    = "product-detail-favorite"
    case ProductShare                       = "product-detail-share"
    case ProductShareFbCancel               = "product-detail-share-facebook-cancel"
    case ProductShareFbComplete             = "product-detail-share-facebook-complete"
    
    case ProductOffer                       = "product-detail-offer"
    case ProductAskQuestion                 = "product-detail-ask-question"
    case ProductMarkAsSold                  = "product-detail-sold"
    
    case ProductReport                      = "product-detail-report"
    
    case ProductSellStart                   = "product-sell-start"
    case ProductSellFormValidationFailed    = "product-sell-form-validation-failed"
    case ProductSellSharedFB                = "product-sell-shared-fb"
    case ProductSellComplete                = "product-sell-complete"
    
    case ProductEditStart                   = "product-edit-start"
//    case ProductEditEditCurrency            = "product-edit-edit-currency"
    case ProductEditFormValidationFailed    = "product-edit-form-validation-failed"
    case ProductEditSharedFB                = "product-edit-shared-fb"
    case ProductEditComplete                = "product-edit-complete"
    
    case ProductDeleteStart                 = "product-delete-start"
    case ProductDeleteComplete              = "product-delete-complete"
    
    case UserMessageSent                    = "user-sent-message"
    
    case ProfileEditStart                   = "profile-edit-start"
    case ProfileEditEditName                = "profile-edit-edit-name"
    case ProfileEditEditLocation            = "profile-edit-edit-location"
    case ProfileEditEditPicture             = "profile-edit-edit-picture"

    case AppRatingStart                     = "app-rating-start"
    case AppRatingRate                      = "app-rating-rate"
    case AppRatingSuggest                   = "app-rating-suggest"
    case AppRatingDontAsk                   = "app-rating-dont-ask"

    case LocationMap                        = "location-map"

    
    // Constants
    private static let eventNameDummyPrefix  = "dummy-"
    
    // Computed iVars
    var actualEventName: String {
        get {
            let eventName: String
            if let isDummyUser = MyUserManager.sharedInstance.myUser()?.isDummy {
                if isDummyUser {
                    eventName = EventName.eventNameDummyPrefix + rawValue
                }
                else {
                    eventName = rawValue
                }
            }
            else {
                eventName = rawValue
            }
            return eventName
        }
    }
}

public enum EventParameterName: String {
    case CategoryId           = "category-id"           // 0 if there's no category
    case ProductId            = "product-id"
    case ProductCity          = "product-city"
    case ProductCountry       = "product-country"
    case ProductZipCode       = "product-zipcode"
    case ProductLatitude      = "product-lat"
    case ProductLongitude     = "product-lng"
    case ProductName          = "product-name"
    case ProductPrice         = "product-price"
    case ProductCurrency      = "product-currency"
    case ProductType          = "item-type"             // real / dummy.
    case ProductOfferAmount   = "amount-offer"
    case PageNumber           = "page-number"
    case UserId               = "user-id"
    case UserToId             = "user-to-id"
    case UserEmail            = "user-email"
    case UserCity             = "user-city"
    case UserCountry          = "user-country"
    case UserZipCode          = "user-zipcode"
    case SearchString         = "search-keyword"
    case Description          = "description"           // error description: why form validation failure.
    case LoginSource          = "login-type"            // the login source
    case MarkAsSoldSource     = "type-page"             // the mark as sold action source
    case LocationType         = "location-type"
    case ShareNetwork         = "share-network"
    case ButtonPosition       = "button-position"
    case LocationEnabled      = "location-enabled"
    case LocationAllowed      = "location-allowed"
}

public enum EventParameterLoginSourceValue: String {
    case Sell = "posting"
    case Chats = "messages"
    case Profile = "view-profile"
    
    case Favourite = "favourite"
    case MakeOffer = "offer"
    case MarkAsSold = "mark-as-sold"
    case AskQuestion = "question"
    case ReportFraud = "report-fraud"
    case Delete = "delete"
}

public enum EventParameterSellSourceValue: String {
    case MarkAsSold = "product-detail"
    case Delete = "product-delete"
}

public enum EventParameterProductItemType: String {
    case Real = "real"
    case Dummy = "dummy"
}

public enum EventParameterLocationType: String {
    case Manual = "manual"
    case Sensor = "sensor"
    case IPLookUp = "iplookup"
}

public struct EventParameters {
    private var params: [EventParameterName : AnyObject] = [:]
    
    // transforms the params to [String: AnyObject]
    public var stringKeyParams: [String: AnyObject] {
        get {
            var res = [String: AnyObject]()
            for (paramName, value) in params {
                res[paramName.rawValue] = value
            }
            return res
        }
    }
    
    internal mutating func addLoginParamsWithSource(source: EventParameterLoginSourceValue) {
        params[.LoginSource] = source.rawValue
    }
    
    internal mutating func addProductParamsWithProduct(product: Product, user: User?) {
        
        // Product
        if let productId = product.objectId {
            params[.ProductId] = productId
        }
        if let lat = product.location?.latitude {
            params[.ProductLatitude] = lat
        }
        if let lng = product.location?.longitude {
            params[.ProductLongitude] = lng
        }
        if let productPrice = product.price {
            params[.ProductPrice] = productPrice
        }
        if let productCurrency = product.currency {
            params[.ProductCurrency] = productCurrency.code
        }
        if let categoryId = product.categoryId {
            params[.CategoryId] = categoryId.integerValue
        }
        
        if let productUser = product.user, let productUserId = productUser.objectId {
            if let userId = params[.UserId] as? String {
                if userId != productUserId {
                    params[.UserToId] = productUserId
                }
            }
            else {
                params[.UserToId] = productUserId
            }
        }

        if let productUser = product.user {
            params[.ProductType] = productUser.isDummy ? EventParameterProductItemType.Dummy.rawValue : EventParameterProductItemType.Real.rawValue
        }

    }
    
    internal subscript(paramName: EventParameterName) -> AnyObject? {
        get {
            return params[paramName]
        }
        set(newValue) {
            params[paramName] = newValue
        }
    }
}