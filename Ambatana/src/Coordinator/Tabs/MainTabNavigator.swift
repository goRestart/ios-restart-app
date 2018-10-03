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
    func openAffiliation(source: AffiliationChallengesSource)
    func openAffiliationOnboarding(data: ReferrerInfo)
    func openWrongCountryModal()
}
