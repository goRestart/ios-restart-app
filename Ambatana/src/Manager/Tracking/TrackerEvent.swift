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
    
    public static func signupEmail(source: EventParameterLoginSourceValue, email: String) -> TrackerEvent {
        var params = EventParameters()
        params.addLoginParamsWithSource(source)
        params[.UserEmail] = email
        return TrackerEvent(name: .SignupEmail, params: params)
    }
    
    public static func resetPassword(source: EventParameterLoginSourceValue) -> TrackerEvent {
        var params = EventParameters()
        params.addLoginParamsWithSource(source)
        return TrackerEvent(name: .ResetPassword, params: params)
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
        params[.CategoryId] = categoryIds.isEmpty ? "0" : ",".join(categoryIds)
        // User
        params.addUserParamsWithUser(user)
        // Search query
        if let actualSearchQuery = searchQuery {
            params[.SearchString] = actualSearchQuery
        }
        // Page number
        params[.PageNumber] = pageNumber
        
        return TrackerEvent(name: .ProductList, params: params)
    }
    
    public static func searchStart(user: User?) -> TrackerEvent {
        // User
        var params = EventParameters()
        params.addUserParamsWithUser(user)
        
        return TrackerEvent(name: .SearchStart, params: params)
    }
    
    public static func searchComplete(user: User?, searchQuery: String) -> TrackerEvent {
        var params = EventParameters()
        // User
        params.addUserParamsWithUser(user)
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
        params.addProductParamsWithProduct(product, user: user)
        // Source
        params[.MarkAsSoldSource] = source.rawValue
        return TrackerEvent(name: .ProductMarkAsSold, params: params)
    }
    
    public static func productSellStart(user: User?) -> TrackerEvent {
        var params = EventParameters()
        // User
        params.addUserParamsWithUser(user)
        return TrackerEvent(name: .ProductSellStart, params: params)
    }
    
    public static func productSellAddPicture(user: User?, imageCount: Int) -> TrackerEvent {
        var params = EventParameters()
        // User
        params.addUserParamsWithUser(user)
        // Image number
        params[.Number] = imageCount
        return TrackerEvent(name: .ProductSellAddPicture, params: params)
    }
    
    public static func productSellEditTitle(user: User?) -> TrackerEvent {
        var params = EventParameters()
        // User
        params.addUserParamsWithUser(user)
        return TrackerEvent(name: .ProductSellEditTitle, params: params)
    }
    
    public static func productSellEditPrice(user: User?) -> TrackerEvent {
        var params = EventParameters()
        // User
        params.addUserParamsWithUser(user)
        return TrackerEvent(name: .ProductSellEditPrice, params: params)
    }
    
    public static func productSellEditDescription(user: User?) -> TrackerEvent {
        var params = EventParameters()
        // User
        params.addUserParamsWithUser(user)
        return TrackerEvent(name: .ProductSellEditDescription, params: params)
    }
    
    public static func productSellEditCategory(user: User?, category: ProductCategory?) -> TrackerEvent {
        var params = EventParameters()
        // User
        params.addUserParamsWithUser(user)
        // Category
        params[.CategoryId] = category?.rawValue ?? 0
        
        return TrackerEvent(name: .ProductSellEditCategory, params: params)
    }
    
    public static func productSellEditShareFB(user: User?, enabled: Bool) -> TrackerEvent {
        var params = EventParameters()
        // User
        params.addUserParamsWithUser(user)
        // FB check enabled
        params[.Enabled] = enabled
        return TrackerEvent(name: .ProductEditEditShareFB, params: params)
    }
    
    public static func productSellFormValidationFailed(user: User?, description: String) -> TrackerEvent {
        var params = EventParameters()
        // User
        params.addUserParamsWithUser(user)
        // Validation failure description
        params[.Description] = description
        return TrackerEvent(name: .ProductSellFormValidationFailed, params: params)
    }
    
    public static func productSellSharedFB(user: User?, product: Product) -> TrackerEvent {
        var params = EventParameters()
        // User
        params.addUserParamsWithUser(user)
        // Product name
        params[.ProductName] = product.name ?? "none"
        return TrackerEvent(name: .ProductSellSharedFB, params: params)
    }
    
    public static func productSellAbandon(user: User?) -> TrackerEvent {
        var params = EventParameters()
        // User
        params.addUserParamsWithUser(user)
        return TrackerEvent(name: .ProductSellAbandon, params: params)
    }
    
    public static func productSellComplete(user: User?, product: Product) -> TrackerEvent {
        var params = EventParameters()
        // User
        params.addUserParamsWithUser(user)
        // Product name
        params[.ProductName] = product.name ?? "none"
        // Category
        params[.CategoryId] = product.categoryId
        return TrackerEvent(name: .ProductSellComplete, params: params)
    }
    
    public static func productEditStart(user: User?, product: Product) -> TrackerEvent {
        var params = EventParameters()
        // User
        params.addUserParamsWithUser(user)
        // Product
        params[.ProductId] = product.objectId
        return TrackerEvent(name: .ProductEditStart, params: params)
    }
    
    public static func productEditAddPicture(user: User?, product: Product, imageCount: Int) -> TrackerEvent {
        var params = EventParameters()
        // User
        params.addUserParamsWithUser(user)
        // Product
        params[.ProductId] = product.objectId
        // Image number
        params[.Number] = imageCount
        return TrackerEvent(name: .ProductEditAddPicture, params: params)
    }
    
    public static func productEditEditTitle(user: User?, product: Product) -> TrackerEvent {
        var params = EventParameters()
        // User
        params.addUserParamsWithUser(user)
        // Product
        params[.ProductId] = product.objectId
        return TrackerEvent(name: .ProductEditEditTitle, params: params)
    }
    
    public static func productEditEditPrice(user: User?, product: Product) -> TrackerEvent {
        var params = EventParameters()
        // User
        params.addUserParamsWithUser(user)
        // Product
        params[.ProductId] = product.objectId
        return TrackerEvent(name: .ProductEditEditPrice, params: params)
    }
    
    public static func productEditEditDescription(user: User?, product: Product) -> TrackerEvent {
        var params = EventParameters()
        // User
        params.addUserParamsWithUser(user)
        // Product
        params[.ProductId] = product.objectId
        return TrackerEvent(name: .ProductEditEditDescription, params: params)
    }
    
    public static func productEditEditCategory(user: User?, product: Product, category: ProductCategory?) -> TrackerEvent {
        var params = EventParameters()
        // User
        params.addUserParamsWithUser(user)
        // Product
        params[.ProductId] = product.objectId
        // Category
        params[.CategoryId] = category?.rawValue ?? 0
        
        return TrackerEvent(name: .ProductEditEditCategory, params: params)
    }
    
    public static func productEditEditShareFB(user: User?, product: Product, enabled: Bool) -> TrackerEvent {
        var params = EventParameters()
        // User
        params.addUserParamsWithUser(user)
        // Product
        params[.ProductId] = product.objectId
        // FB check enabled
        params[.Enabled] = enabled
        return TrackerEvent(name: .ProductEditEditShareFB, params: params)
    }
    
    public static func productEditFormValidationFailed(user: User?, product: Product, description: String) -> TrackerEvent {
        var params = EventParameters()
        // User
        params.addUserParamsWithUser(user)
        // Product
        params[.ProductId] = product.objectId
        // Validation failure description
        params[.Description] = description
        return TrackerEvent(name: .ProductEditFormValidationFailed, params: params)
    }
    
    public static func productEditSharedFB(user: User?, product: Product, name: String) -> TrackerEvent {
        var params = EventParameters()
        // User
        params.addUserParamsWithUser(user)
        // Product
        params[.ProductId] = product.objectId
        params[.ProductName] = name.isEmpty ? "none" : name
        return TrackerEvent(name: .ProductEditSharedFB, params: params)
    }
    
    public static func productEditAbandon(user: User?, product: Product) -> TrackerEvent {
        var params = EventParameters()
        // User
        params.addUserParamsWithUser(user)
        // Product
        params[.ProductId] = product.objectId
        return TrackerEvent(name: .ProductEditAbandon, params: params)
    }
    
    public static func productEditComplete(user: User?, product: Product, name: String, category: ProductCategory?) -> TrackerEvent {
        var params = EventParameters()
        // User
        params.addUserParamsWithUser(user)
        // Product
        params[.ProductId] = product.objectId
        params[.ProductName] = name.isEmpty ? "none" : name
        // Category
        params[.CategoryId] = category?.rawValue ?? 0
        return TrackerEvent(name: .ProductEditComplete, params: params)
    }
    
    public static func productDeleteStart(product: Product, user: User?) -> TrackerEvent {
        var params = EventParameters()
        // User
        params.addUserParamsWithUser(user)
        // Product
        params[.ProductId] = product.objectId
        return TrackerEvent(name: .ProductDeleteStart, params: params)
    }
    
    public static func productDeleteAbandon(product: Product, user: User?) -> TrackerEvent {
        var params = EventParameters()
        // User
        params.addUserParamsWithUser(user)
        // Product
        params[.ProductId] = product.objectId
        return TrackerEvent(name: .ProductDeleteAbandon, params: params)
    }
    
    public static func productDeleteComplete(product: Product, user: User?) -> TrackerEvent {
        var params = EventParameters()
        // User
        params.addUserParamsWithUser(user)
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
}
