//
//  ProfileProductListViewModel.swift
//  LetGo
//
//  Created by AHL on 25/7/15.
//  Copyright (c) 2015 Ambatana. All rights reserved.
//

import Curry
import LGCoreKit

public enum ProfileProductListViewType {
    case Selling
    case Sold
    case Favorites
}

public class ProfileProductListViewModel: ProductListViewModel {
   
    // Input
    public var user: User? {
        didSet {
            productRequester.userObjectId = user?.objectId
            reset()
        }
    }
    public var emptyStateTitle: String?
    public var emptyStateButtonTitle: String?
    public var emptyStateButtonAction: (() -> ())?

    // Repositories
    let productRepository: ProductRepository
    let productRequester: UserProductListRequester


    // MARK: - Lifecycle
    
    public init(myUserRepository: MyUserRepository, user: User?, type: ProfileProductListViewType,
                locationManager: LocationManager, productRepository: ProductRepository) {
        self.productRepository = productRepository
        switch type {
        case .Selling:
            self.productRequester = ProfileProductListRequester(productRepository: productRepository,
                                                locationManager: locationManager, statuses: [.Pending, .Approved])
        case .Sold:
            self.productRequester = ProfileProductListRequester(productRepository: productRepository,
                                                locationManager: locationManager, statuses: [.Sold, .SoldOld])
        case .Favorites:
            self.productRequester = FavoritesProductListRequester(productRepository: productRepository,
                                                                  locationManager: locationManager)
        }
        self.user = user ?? myUserRepository.myUser

        super.init(requester: self.productRequester, locationManager: locationManager, productRepository: productRepository,
                myUserRepository: myUserRepository, cellDrawer: ProductCellDrawerFactory.drawerForProduct(false))
    }
    
    public convenience init(user: User? = nil, type: ProfileProductListViewType = .Selling) {
        let myUserRepository = Core.myUserRepository
        let locationManager = Core.locationManager
        let productRepository = Core.productRepository
        self.init(myUserRepository: myUserRepository, user: user, type: type,
            locationManager: locationManager, productRepository: productRepository)
    }
}

protocol UserProductListRequester: ProductListRequester {
    var userObjectId: String? { get set }
}

class FavoritesProductListRequester: UserProductListRequester {

    var userObjectId: String? = nil
    let productRepository: ProductRepository
    let locationManager: LocationManager

    init(productRepository: ProductRepository, locationManager: LocationManager) {
        self.productRepository = productRepository
        self.locationManager = locationManager
    }

    func productsRetrieval(offset offset: Int, completion: ProductsCompletion?) {
        guard let userId = userObjectId else { return }
        productRepository.indexFavorites(userId, completion: completion)
    }

    func isLastPage(resultCount: Int) -> Bool {
        return true
    }
}


class ProfileProductListRequester: UserProductListRequester {

    let statuses: [ProductStatus]
    let productRepository: ProductRepository
    let locationManager: LocationManager

    var userObjectId: String? = nil

    init(productRepository: ProductRepository, locationManager: LocationManager, statuses: [ProductStatus]) {
        self.productRepository = productRepository
        self.locationManager = locationManager
        self.statuses = statuses
    }

    func productsRetrieval(offset offset: Int, completion: ProductsCompletion?) {
        guard let params = retrieveProductsParams else { return }
        productRepository.index(params, pageOffset: offset, completion: completion)
    }

    func isLastPage(resultCount: Int) -> Bool {
        return resultCount == 0
    }

    private var retrieveProductsParams: RetrieveProductsParams? {
        guard let userId = userObjectId else { return nil }
        var params: RetrieveProductsParams = RetrieveProductsParams()
        if let currentLocation = locationManager.currentLocation {
            params.coordinates = LGLocationCoordinates2D(location: currentLocation)
        }
        params.countryCode = locationManager.currentPostalAddress?.countryCode
        params.sortCriteria = .Creation
        params.statuses = statuses
        params.userObjectId = userId
        return params
    }
}

