//
//  ProductViewModel.swift
//  LetGo
//
//  Created by Albert Hernández López on 12/08/15.
//  Copyright (c) 2015 Ambatana. All rights reserved.
//

import LGCoreKit

public protocol ProductViewModelDelegate: class {

}

public class ProductViewModel: BaseViewModel {

    // Output
    // > Product
    public private(set) var name: String
    public private(set) var price: String
    public private(set) var descr: String
    public private(set) var distance: String
    public private(set) var address: String
    public private(set) var location: LGLocationCoordinates2D?
    public private(set) var status: ProductStatus
    
    // > User
    public private(set) var userName: String
    public private(set) var userAvatar: NSURL?
    
    // > My User
    public private(set) var isFavouritedByMe: Bool
    public private(set) var isReportedByMe: Bool
    public private(set) var isMine: Bool
    
    public var numberOfImages: Int {
        return product.images.count
    }
    
    // Delegate
    public weak var delegate: ProductViewModelDelegate?
    
    // Data
    private var product: Product
    
    // MARK: - Lifecycle
    
    public init(product: Product) {
        // Product
        self.name = product.name ?? ""
        self.price = product.formattedPrice()
        self.descr = product.descr ?? ""
        self.distance = product.formattedDistance()
        var address = ""
        if let city = product.postalAddress.city {
            if !city.isEmpty {
                address += city
            }
        }
        if let zipCode = product.postalAddress.zipCode {
            if !zipCode.isEmpty {
                if !address.isEmpty {
                    address += ", "
                }
                address += zipCode
            }
        }
        self.address = address.lg_capitalizedWord()
        self.location = product.location
        self.status = product.status
        
        // User
        self.userName = product.user?.publicUsername ?? ""
        self.userAvatar = product.user?.avatar?.fileURL
        
        // My user
        self.isFavouritedByMe = false
        self.isReportedByMe = false
        if let productUser = product.user, let productUserId = productUser.objectId, let myUser = MyUserManager.sharedInstance.myUser(), let myUserId = myUser.objectId {
            self.isMine = ( productUserId == myUserId )
        }
        else {
            self.isMine = false
        }
        
        // Data
        self.product = product
        
        super.init()
    }
    
    // MARK: - Public methods
    
    public func imageURLAtIndex(index: Int) -> NSURL? {
        return product.images[index].fileURL
    }
    
    public func report() {
        
    }
    
    public func delete() {
        
    }
    
    public func ask() {
        
    }
    
    public func offer() {
        
    }
    
    public func edit() {
        
    }
    
    public func markSold() {
        
    }
}
