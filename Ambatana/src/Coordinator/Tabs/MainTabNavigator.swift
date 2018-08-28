//
//  MainTabNavigator.swift
//  LetGo
//
//  Created by Albert Hernández López on 01/08/16.
//  Copyright © 2016 Ambatana. All rights reserved.
//

import LGCoreKit

protocol MainTabNavigator: TabNavigator {
    func openMainListings(withSearchType searchType: SearchType,
                         listingFilters: ListingFilters)
    func openLoginIfNeeded(infoMessage: String, then loggedAction: @escaping (() -> Void))
    func openSearchAlertsList()
    func openAskPhoneFromMainFeedFor(listing: Listing, interlocutor: User?)
    func openListingChat(_ listing: Listing, source: EventParameterTypePage, interlocutor: User?)
    func openPrivateUserProfile()
    func openCommunity()
    func openSearches()
}
