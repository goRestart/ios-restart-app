//
//  TrackerEventDataTypes.swift
//  LetGo
//
//  Created by Albert Hernández López on 06/08/15.
//  Copyright (c) 2015 Ambatana. All rights reserved.
//

import LGCoreKit

public enum EventName: String {
    case LoginVisit                         = "login-screen"
    case LoginAbandon                       = "login-abandon"
    case LoginFB                            = "login-fb"
    case LoginEmail                         = "login-email"
    case SignupEmail                        = "signup-email"
    case ResetPassword                      = "login-reset-password"
    case Logout                             = "logout"
    case ProductList                        = "product-list"
    
    case SearchStart                        = "search-start"
    case SearchComplete                     = "search-complete"
    
    case ProductDetailVisit                 = "product-detail-visit"
    case ProductOffer                       = "product-detail-offer"
    case ProductAskQuestion                 = "product-detail-ask-question"
    case ProductMarkAsSold                  = "product-detail-sold"
    
    case ProductSellStart                   = "product-sell-start"
    case ProductSellAddPicture              = "product-sell-add-picture"
    case ProductSellEditTitle               = "product-sell-edit-title"
    case ProductSellEditPrice               = "product-sell-edit-price"
    case ProductSellEditDescription         = "product-sell-edit-description"
    case ProductSellEditCategory            = "product-sell-edit-category"
    case ProductSellEditShareFB             = "product-sell-edit-share-fb"
    case ProductSellFormValidationFailed    = "product-sell-form-validation-failed"
    case ProductSellSharedFB                = "product-sell-shared-fb"
    case ProductSellAbandon                 = "product-sell-abandon"
    case ProductSellComplete                = "product-sell-complete"
    
    case ProductEditStart                   = "product-edit-start"
    case ProductEditAddPicture              = "product-edit-add-picture"
    case ProductEditEditTitle               = "product-edit-edit-title"
    case ProductEditEditPrice               = "product-edit-edit-price"
    case ProductEditEditCategory            = "product-edit-edit-category"
//    case ProductEditEditCurrency            = "product-edit-edit-currency"
    case ProductEditEditDescription         = "product-edit-edit-description"
    case ProductEditEditShareFB             = "product-edit-edit-share-fb"
    case ProductEditFormValidationFailed    = "product-edit-form-validation-failed"
    case ProductEditSharedFB                = "product-edit-shared-fb"
    case ProductEditAbandon                 = "product-edit-abandon"
    case ProductEditComplete                = "product-edit-complete"
    
    case ProductDeleteStart                 = "product-delete-start"
    case ProductDeleteAbandon               = "product-delete-abandon"
    case ProductDeleteComplete              = "product-delete-complete"
    
    case UserMessageSent                    = "user-sent-message"
    
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

internal enum EventParameterName: String {
    case UserEmail            = "user-email"
    case CategoryId           = "category-id"       // 0 if there's no category
    case ProductId            = "product-id"
    case ProductCity          = "product-city"
    case ProductCountry       = "product-country"
    case ProductZipCode       = "product-zipcode"
    case ProductName          = "product-name"
    case ProductType          = "item-type"         // real / dummy.
    case PageNumber           = "page-number"
    case UserId               = "user-id"
    case UserToId             = "user-to-id"
    case UserCity             = "user-city"
    case UserCountry          = "user-country"
    case UserZipCode          = "user-zipcode"
    case SearchString         = "search-keyword"
    case Number               = "number"            // the number/index of the picture
    case Enabled              = "enabled"           // true/false. if a checkbox / switch is changed to enabled or disabled
    case Description          = "description"       // error description: why form validation failure.
    case LoginSource          = "login-type"        // the login source
}

public enum EventParameterLoginSourceValue: String {
    //    case EditProfile = "edit-profile"     // not used in iOS
    case Sell = "posting"
    case Chats = "messages"
    case Profile = "view-profile"
    
    case Favourite = "favourite"
    case MakeOffer = "offer"
    case MarkAsSold = "mark-as-sold"
    case AskQuestion = "question"
    case ReportFraud = "report-fraud"
}

public enum EventParameterProductItemType: String {
    case Real = "real"
    case Dummy = "dummy"
}

public struct EventParameters {
    private var params: [EventParameterName : AnyObject] = [:]
    
    // transforms the params to [String: AnyObject]
    var stringKeyParams: [String: AnyObject] {
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
    
    internal mutating func addUserParamsWithUser(user: User?) {
        if let actualUser = user {
            if let userId = actualUser.objectId {
                params[.UserId] = userId
            }
            if let userCity = actualUser.postalAddress.city {
                params[.UserCity] = userCity
            }
            if let userCountry = actualUser.postalAddress.countryCode {
                params[.UserCountry] = userCountry
            }
            if let userZipCode = actualUser.postalAddress.zipCode {
                params[.UserZipCode] = userZipCode
            }
        }
    }
    
    internal mutating func addProductParamsWithProduct(product: Product, user: User?) {
        
        // Product
        if let city = product.postalAddress.city {
            params[.ProductCity] = city
        }
        if let countryCode = product.postalAddress.countryCode {
            params[.ProductCountry] = countryCode
        }
        if let zipCode = product.postalAddress.zipCode {
            params[.ProductZipCode] = zipCode
        }
        if let categoryId = product.categoryId {
            params[.CategoryId] = categoryId.stringValue
        }
        if let productName = product.name {
            params[.ProductName] = productName
        }
        if let productUser = product.user {
            params[.ProductType] = TrackingHelper.productTypeParamValue(productUser.isDummy) // TODO: !!
        }
        if let productId = product.objectId {
            params[.ProductId] = productId
        }
        if let productUser = product.user, let productUserId = productUser.objectId  {
            params[.UserToId] = productUserId
        }
        if let actualUser = user, let userId = actualUser.objectId {
            params[.UserId] = userId
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