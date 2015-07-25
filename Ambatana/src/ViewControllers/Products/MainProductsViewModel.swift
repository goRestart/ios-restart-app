//
//  ProductsViewModel.swift
//  letgo
//
//  Created by AHL on 3/5/15.
//  Copyright (c) 2015 Ambatana. All rights reserved.
//

import CoreLocation
import LGCoreKit
import Result

public protocol MainProductsViewModelDelegate: class {
    func mainProductsViewModel(viewModel: MainProductsViewModel, didSearchWithViewModel searchViewModel: MainProductsViewModel)
}

public class MainProductsViewModel: BaseViewModel {

    // Input
    public var category: ProductCategory?
    public var searchString: String?
    
    // Output
    public var title: AnyObject?
    public var hasSearchButton: Bool
    
    // > Delegate
    public weak var delegate: MainProductsViewModelDelegate?
    
    // MARK: - Lifecycle
    
    public init(category: ProductCategory? = nil, searchString: String? = nil) {
        self.category = category
        self.searchString = searchString
        self.title = category?.name() ?? UIImage(named: "navbar_logo")
        self.hasSearchButton = ( searchString == nil )
        super.init()
    }
    
    // MARK: - Public methods
    
    /**
        Search action.
    */
    public func search() {
        if let actualSearchString = searchString {
            if count(actualSearchString) > 0 {

                // Tracking
                TrackingHelper.trackEvent(.SearchComplete, parameters: trackingParamsForEventType(.SearchComplete))
                
                // Notify the delegate
                delegate?.mainProductsViewModel(self, didSearchWithViewModel: viewModelForSearch())
            }
        }
    }
    
    // MARK: - Public methods
    
    /**
        Called when search button is pressed.
    */
    public func searchButtonPressed() {
        // Tracking
        TrackingHelper.trackEvent(.SearchStart, parameters: trackingParamsForEventType(.SearchStart))
    }
    
    // MARK: - Private methods
    
    /**
        Returns a view model for search.
    
        :return: A view model for search.
    */
    private func viewModelForSearch() -> MainProductsViewModel {
        return MainProductsViewModel(searchString: searchString)
    }
    
    /**
        Returns the tracking parameters key-value for the given tracking event type.
    
        :param: eventType The tracking event type.
        :return: The tracking parameters key-value for the given tracking event type.
    */
    private func trackingParamsForEventType(eventType: TrackingEvent) -> [TrackingParameter: AnyObject] {
        var properties: [TrackingParameter: AnyObject] = [:]
        
        // User data
        if let currentUser = MyUserManager.sharedInstance.myUser() {
            if let userCity = currentUser.postalAddress.city {
                properties[.UserCity] = userCity
            }
            if let userCountry = currentUser.postalAddress.countryCode {
                properties[.UserCountry] = userCountry
            }
            if let userZipCode = currentUser.postalAddress.zipCode {
                properties[.UserZipCode] = userZipCode
            }
        }
        
        // If it's a search complete, the set the search string
        if eventType == .SearchComplete {
            if let actualSearchString = searchString {
                properties[.SearchString] = actualSearchString
            }
        }
        return properties
    }
}
