//
//  ProfileProductListViewModel.swift
//  LetGo
//
//  Created by AHL on 25/7/15.
//  Copyright (c) 2015 Ambatana. All rights reserved.
//

import Curry
import LGCoreKit

public class ProfileProductListViewModel: ProductListViewModel {
   
    // Input
    public var user: User? {
        didSet {
            userObjectId = user?.objectId
            reset()
        }
    }
    public var emptyStateTitle: String?
    public var emptyStateButtonTitle: String?
    public var emptyStateButtonAction: (() -> ())?

    private let type: ProfileProductListViewType

    // Repositories
    let productRepository: ProductRepository


    // MARK: - Lifecycle
    
    public init(myUserRepository: MyUserRepository, user: User?, type: ProfileProductListViewType,
        locationManager: LocationManager, productRepository: ProductRepository) {
            self.user = user ?? myUserRepository.myUser
            self.type = type
            self.productRepository = productRepository

            super.init(locationManager: locationManager, productRepository: productRepository,
                myUserRepository: myUserRepository, cellDrawer: ProductCellDrawerFactory.drawerForProduct(false))

            switch type {
            case .Selling:
                statuses = [.Pending, .Approved]
            case .Sold:
                statuses = [.Sold, .SoldOld]
            case .Favorites:
                break
            }

            sortCriteria = .Creation
    }
    
    public convenience init(user: User? = nil, type: ProfileProductListViewType = .Selling) {
        let myUserRepository = Core.myUserRepository
        let locationManager = Core.locationManager
        let productRepository = Core.productRepository
        self.init(myUserRepository: myUserRepository, user: user, type: type,
            locationManager: locationManager, productRepository: productRepository)
    }


    // MARK: - Public methods

    override func productsRetrieval(offset offset: Int, completion: ProductsCompletion?) {
        guard let userId = user?.objectId else { return }

        switch type {
        case .Selling, .Sold:
            return super.productsRetrieval(offset: offset, completion: completion)
        case .Favorites:
            productRepository.indexFavorites(userId, completion: completion)
        }
    }

    override func didSucceedRetrievingProducts() {
        super.didSucceedRetrievingProducts()

        switch type {
        case .Selling, .Sold:
            break
        case .Favorites:
            isLastPage = true
        }
    }
}
