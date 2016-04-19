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
            productRequester.userObjectId = user?.objectId
            reset()
        }
    }
    public var emptyStateTitle: String?
    public var emptyStateButtonTitle: String?
    public var emptyStateButtonAction: (() -> ())?

    private let type: ProfileProductListViewType

    // Repositories
    let productRepository: ProductRepository
    let productRequester: ProfileProductListRequester


    // MARK: - Lifecycle
    
    public init(myUserRepository: MyUserRepository, user: User?, type: ProfileProductListViewType,
        locationManager: LocationManager, productRepository: ProductRepository) {
            self.user = user ?? myUserRepository.myUser
            self.type = type
            self.productRepository = productRepository
            self.productRequester = ProfileProductListRequester(type: type, productRepository: productRepository,
                                                                locationManager: locationManager)

        super.init(requester: self.productRequester, locationManager: locationManager, productRepository: productRepository,
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
            super.productsRetrieval(offset: offset, completion: completion)
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


class ProfileProductListRequester: ProductListRequester {

    let type: ProfileProductListViewType
    let productRepository: ProductRepository
    let locationManager: LocationManager

    var userObjectId: String? = nil

    private var queryCoordinates: LGLocationCoordinates2D? {
        guard let currentLocation = locationManager.currentLocation else { return nil }
        return LGLocationCoordinates2D(location: currentLocation)
    }
    private var retrieveProductsParams: RetrieveProductsParams {
        var params: RetrieveProductsParams = RetrieveProductsParams()
        params.coordinates = queryCoordinates
        params.countryCode = locationManager.currentPostalAddress?.countryCode
        params.sortCriteria = .Creation
        switch type {
        case .Selling:
            params.statuses = [.Pending, .Approved]
        case .Sold:
            params.statuses = [.Sold, .SoldOld]
        case .Favorites:
            break
        }
        params.userObjectId = userObjectId
        return params
    }


    init(type: ProfileProductListViewType, productRepository: ProductRepository, locationManager: LocationManager) {
        self.productRepository = productRepository
        self.locationManager = locationManager
        self.type = type
    }

    func productsRetrieval(offset offset: Int, completion: ProductsCompletion?) {
        guard let userId = userObjectId else { return }

        switch type {
        case .Selling, .Sold:
            productRepository.index(retrieveProductsParams, pageOffset: offset, completion: completion)
        case .Favorites:
            productRepository.indexFavorites(userId, completion: completion)
        }
    }

    func isLastPage(resultCount: Int) -> Bool {
        switch type {
        case .Selling, .Sold:
            return resultCount == 0
        case .Favorites:
            return false
        }
    }
}

