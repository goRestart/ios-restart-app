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
            params[.LocationType] = location.type.rawValue
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
        params.addLoginParamsWithSource(source)
        return TrackerEvent(name: .LoginVisit, params: params)
    }
    
    public static func loginAbandon(source: EventParameterLoginSourceValue) -> TrackerEvent {
        var params = EventParameters()
        params.addLoginParamsWithSource(source)
        return TrackerEvent(name: .LoginAbandon, params: params)
    }
    
    public static func loginFB(source: EventParameterLoginSourceValue) -> TrackerEvent {
        var params = EventParameters()
        params.addLoginParamsWithSource(source)
        return TrackerEvent(name: .LoginFB, params: params)
    }
    
    public static func loginEmail(source: EventParameterLoginSourceValue) -> TrackerEvent {
        var params = EventParameters()
        params.addLoginParamsWithSource(source)
        return TrackerEvent(name: .LoginEmail, params: params)
    }
    
    public static func signupEmail(source: EventParameterLoginSourceValue) -> TrackerEvent {
        var params = EventParameters()
        params.addLoginParamsWithSource(source)
        return TrackerEvent(name: .SignupEmail, params: params)
    }
    
    public static func logout() -> TrackerEvent {
        return TrackerEvent(name: .Logout, params: nil)
    }
    
    public static func productList(user: User?, categories: [ProductCategory]?, searchQuery: String?, pageNumber: UInt) -> TrackerEvent {
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
        // Page number
        params[.PageNumber] = pageNumber
        
        return TrackerEvent(name: .ProductList, params: params)
    }
    
    public static func searchStart(user: User?) -> TrackerEvent {
        let params = EventParameters()
        
        return TrackerEvent(name: .SearchStart, params: params)
    }
    
    public static func searchComplete(user: User?, searchQuery: String) -> TrackerEvent {
        var params = EventParameters()
        // Search query
        params[.SearchString] = searchQuery
        
        return TrackerEvent(name: .SearchComplete, params: params)
    }
    
    public static func productDetailVisit(product: Product, user: User?) -> TrackerEvent {
        var params = EventParameters()
        // Product
        params.addProductParamsWithProduct(product, user: user)
        return TrackerEvent(name: .ProductDetailVisit, params: params)
    }
    
    public static func productFavorite(product: Product, user: User?) -> TrackerEvent {
        var params = EventParameters()
        // Product
        params.addProductParamsWithProduct(product, user: user)
        return TrackerEvent(name: .ProductFavorite, params: params)
    }
    
    public static func productShare(product: Product, user: User?, network: String, buttonPosition: String) -> TrackerEvent {
        var params = EventParameters()
        // Product
        params.addProductParamsWithProduct(product, user: user)
        params[.ShareNetwork] = network
        params[.ButtonPosition] = buttonPosition
        return TrackerEvent(name: .ProductShare, params: params)
    }
    
    public static func productShareFbCancel(product: Product) -> TrackerEvent {
        var params = EventParameters()
        // Product
        if let productUser = product.user {
            params[.ProductType] = productUser.isDummy ? EventParameterProductItemType.Dummy.rawValue : EventParameterProductItemType.Real.rawValue
        }
        return TrackerEvent(name: .ProductShareFbCancel, params: params)
    }

    public static func productShareFbComplete(product: Product) -> TrackerEvent {
        var params = EventParameters()
        // Product
        if let productUser = product.user {
            params[.ProductType] = productUser.isDummy ? EventParameterProductItemType.Dummy.rawValue : EventParameterProductItemType.Real.rawValue
        }
        return TrackerEvent(name: .ProductShareFbComplete, params: params)
    }

    
    public static func productOffer(product: Product, user: User?, amount: Double) -> TrackerEvent {
        var params = EventParameters()
        // Product
        params.addProductParamsWithProduct(product, user: user)
        // Offer
        params[.ProductOfferAmount] = amount
        return TrackerEvent(name: .ProductOffer, params: params)
    }
    
    public static func productAskQuestion(product: Product, user: User?) -> TrackerEvent {
        var params = EventParameters()
        // Product
        params.addProductParamsWithProduct(product, user: user)
        return TrackerEvent(name: .ProductAskQuestion, params: params)
    }

    public static func productMarkAsSold(source: EventParameterSellSourceValue, product: Product, user: User?) -> TrackerEvent {
        var params = EventParameters()

        // Product
        if let productId = product.objectId {
            params[.ProductId] = productId
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
        return TrackerEvent(name: .ProductMarkAsSold, params: params)
    }
    
    public static func productReport(product: Product, user: User?) -> TrackerEvent {
        var params = EventParameters()
        // Product
        params.addProductParamsWithProduct(product, user: user)
        return TrackerEvent(name: .ProductReport, params: params)
    }
    
    public static func productSellStart(user: User?) -> TrackerEvent {
        let params = EventParameters()
        return TrackerEvent(name: .ProductSellStart, params: params)
    }
    
    public static func productSellFormValidationFailed(user: User?, description: String) -> TrackerEvent {
        var params = EventParameters()
        // Validation failure description
        params[.Description] = description
        return TrackerEvent(name: .ProductSellFormValidationFailed, params: params)
    }
    
    public static func productSellSharedFB(user: User?, product: Product?) -> TrackerEvent {
        var params = EventParameters()
        // Product name
        if let productId = product?.objectId {
            params[.ProductId] = productId
        }
        return TrackerEvent(name: .ProductSellSharedFB, params: params)
    }
    
    public static func productSellComplete(user: User?, product: Product) -> TrackerEvent {
        var params = EventParameters()
        // Product name
        params[.ProductId] = product.objectId ?? ""
        // Category
        params[.CategoryId] = product.categoryId
        return TrackerEvent(name: .ProductSellComplete, params: params)
    }
    
    public static func productEditStart(user: User?, product: Product) -> TrackerEvent {
        var params = EventParameters()
        // Product
        params[.ProductId] = product.objectId
        return TrackerEvent(name: .ProductEditStart, params: params)
    }
    
    public static func productEditFormValidationFailed(user: User?, product: Product, description: String) -> TrackerEvent {
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
    
    public static func productEditComplete(user: User?, product: Product, category: ProductCategory?) -> TrackerEvent {
        var params = EventParameters()
        // Product
        params[.ProductId] = product.objectId
        // Category
        params[.CategoryId] = category?.rawValue ?? 0
        return TrackerEvent(name: .ProductEditComplete, params: params)
    }
    
    public static func productDeleteStart(product: Product, user: User?) -> TrackerEvent {
        var params = EventParameters()
        // Product
        params[.ProductId] = product.objectId
        return TrackerEvent(name: .ProductDeleteStart, params: params)
    }
    
    public static func productDeleteComplete(product: Product, user: User?) -> TrackerEvent {
        var params = EventParameters()
        // Product
        params[.ProductId] = product.objectId
        return TrackerEvent(name: .ProductDeleteComplete, params: params)
    }

    public static func userMessageSent(product: Product, user: User?) -> TrackerEvent {
        var params = EventParameters()
        // Product
        params.addProductParamsWithProduct(product, user: user)
        return TrackerEvent(name: .UserMessageSent, params: params)
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
            params[.LocationType] = location.type.rawValue
        }
        return TrackerEvent(name: .ProfileEditEditLocation, params: params)
    }
    
    public static func profileEditEditPicture() -> TrackerEvent {
        let params = EventParameters()
        return TrackerEvent(name: .ProfileEditEditPicture, params: params)
    }
    
    public static func appRatingStart() -> TrackerEvent {
        let params = EventParameters()
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
    
    
    public static func locationMapShown() -> TrackerEvent {
        let params = EventParameters()
        return TrackerEvent(name: .LocationMap, params: params)
    }

    
    // MARK: - Private methods
    
    private static func eventParameterLocationTypeForLocation(location: LGLocation) -> EventParameterLocationType? {
        let locationTypeParamValue: EventParameterLocationType?
        switch (location.type) {
        case .Manual:
            locationTypeParamValue = .Manual
        case .Sensor:
            locationTypeParamValue = .Sensor
        case .IPLookup:
            locationTypeParamValue = .IPLookUp
        case .Regional:
            locationTypeParamValue = .Regional
        case .LastSaved:
            locationTypeParamValue = nil
        }
        return locationTypeParamValue
    }
}
