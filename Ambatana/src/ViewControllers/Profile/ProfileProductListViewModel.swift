//
//  ProfileProductListViewModel.swift
//  LetGo
//
//  Created by AHL on 25/7/15.
//  Copyright (c) 2015 Ambatana. All rights reserved.
//

import LGCoreKit

public class ProfileProductListViewModel: ProductListViewModel {
   
    // Input
    public var user: User? {
        didSet {
            if let actualUser = user {
                self.userObjectId = actualUser.objectId
            }
        }
    }
    public var type: ProfileProductListViewType {
        didSet {
            switch type {
            case .Selling:
                statuses = [.Pending, .Approved]
                break
            case .Sold:
                statuses = [.Sold, .SoldOld]
                break
            }
        }
    }
    public override var showCellActions: Bool {
        return false
    }

    // Repositories
    let myUserRepository: MyUserRepository
    
    // MARK: - Lifecycle
    
    public init(myUserRepository: MyUserRepository, user: User?, type: ProfileProductListViewType?,
        locationManager: LocationManager, productsManager: ProductsManager, productManager: ProductManager) {
        self.myUserRepository = myUserRepository
        self.user = user ?? myUserRepository.myUser
        self.type = type ?? .Selling
        super.init(locationManager: locationManager, productsManager: productsManager, productManager: productManager)
        
        self.isProfileList = true
        self.sortCriteria = .Creation
    }
    
    public convenience init(user: User? = nil, type: ProfileProductListViewType? = .Selling) {

        let productsRetrieveService = LGProductsRetrieveService()
        let userProductsRetrieveService = LGUserProductsRetrieveService()
        let productsManager = ProductsManager(productsRetrieveService: productsRetrieveService,
            userProductsRetrieveService: userProductsRetrieveService)
        let myUserRepository = MyUserRepository.sharedInstance
        self.init(myUserRepository: myUserRepository, user: user, type: type,
            locationManager: LocationManager.sharedInstance, productsManager: productsManager,
            productManager: ProductManager())
    }
    
}
