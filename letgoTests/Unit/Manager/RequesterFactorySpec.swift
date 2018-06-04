@testable import LetGoGodMode
import Quick
import Nimble

class RequesterFactorySpec: QuickSpec {

    override func spec() {
        
        var sut: RequesterFactory!
        
        var dependency: RequesterDependencyContainer!
        var listRequesterArray: [ListingListRequester]!
        
        beforeEach {
            listRequesterArray = []
        }
        
        describe("requester array generation") {

            context("set emptySearchImprovements featureFlags to .baseline") {
                beforeEach {
                    dependency = buildDependency(for: .baseline)
                    sut = buildSut(for: .baseline)
                    listRequesterArray = sut.buildRequesterList()
                }
                
                it("factory builds only 1 requester") {
                    expect(listRequesterArray.count).to(be(1))
                }

                it ("the requester built by factory is a search requester") {
                    let searchRequester = buildSearchRequester(with: dependency)
                    expect(listRequesterArray).to(equal(expectedRequesters: [searchRequester]))
                }
            }

            context("set emptySearchImprovements featureFlags to .popularNearYou") {
                beforeEach {
                    dependency = buildDependency(for: .popularNearYou)
                    sut = buildSut(for: .popularNearYou)
                    listRequesterArray = sut.buildRequesterList()
                }

                it ("requesters are [search, feed]") {
                    let searchRequester = buildSearchRequester(with: dependency)
                    let feedRequester = buildFeedRequester(with: dependency)
                    expect(listRequesterArray).to(equal(expectedRequesters: [searchRequester, feedRequester]))
                }
            }

            context("set emptySearchImprovements featureFlags to .similarQueries") {
                beforeEach {
                    dependency = buildDependency(for: .similarQueries)
                    sut = buildSut(for: .similarQueries)
                    listRequesterArray = sut.buildRequesterList()
                }

                it ("requesters are [search, similar, feed]") {
                    let searchRequester = buildSearchRequester(with: dependency)
                    let feedRequester = buildFeedRequester(with: dependency)
                    let similarRequester = buildSimilarRequester(with: dependency)
                    
                    expect(listRequesterArray).to(equal(expectedRequesters: [searchRequester, similarRequester, feedRequester]))
                }
            }
            
            context("set emptySearchImprovements featureFlags to .similarQueriesWhenFewResults") {
                beforeEach {
                    dependency = buildDependency(for: .similarQueriesWhenFewResults)
                    sut = buildSut(for: .similarQueriesWhenFewResults)
                    listRequesterArray = sut.buildRequesterList()
                }
                
                it ("requesters are [search, search+similar, feed]") {
                    let searchRequester = buildSearchRequester(with: dependency)
                    let feedRequester = buildFeedRequester(with: dependency)
                    let searchAndSimilarRequester = buildSearchAndSimilarRequester(with: dependency)
                    
                    expect(listRequesterArray).to(equal(expectedRequesters: [searchRequester, searchAndSimilarRequester, feedRequester]))
                }
            }
            
            context("set emptySearchImprovements featureFlags to .alwaysSimilar") {
                beforeEach {
                    dependency = buildDependency(for: .alwaysSimilar)
                    sut = buildSut(for: .alwaysSimilar)
                    listRequesterArray = sut.buildRequesterList()
                }
                
                it ("requesters are [search+similar, feed]") {
                    let feedRequester = buildFeedRequester(with: dependency)
                    let searchAndSimilarRequester = buildSearchAndSimilarRequester(with: dependency)
                    
                    expect(listRequesterArray).to(equal(expectedRequesters: [searchAndSimilarRequester, feedRequester]))
                }
            }
        }
        
        func buildSut(for flag: EmptySearchImprovements) -> SearchRequesterFactory {
            let dependency = buildDependency(for: flag)
            let featureFlags = MockFeatureFlags()
            featureFlags.emptySearchImprovements = flag
            return SearchRequesterFactory(dependencyContainer: dependency,
                                                 featureFlags: featureFlags)
        }
        
        func buildDependency(for flag: EmptySearchImprovements) -> RequesterDependencyContainer {
            let similarSearchActive = flag == .similarQueries ? true : false
            return RequesterDependencyContainer(itemsPerPage: 50,
                                                          filters: ListingFilters(),
                                                          queryString: "abc",
                                                          carSearchActive: false,
                                                          similarSearchActive: similarSearchActive)
        }
        
        func buildSearchRequester(with dependency: RequesterDependencyContainer) -> ListingListMultiRequester {
            return FilterListingListRequesterFactory
                .generateRequester(withFilters: dependency.filters,
                                   queryString:dependency.queryString,
                                   itemsPerPage: dependency.itemsPerPage,
                                   carSearchActive: dependency.carSearchActive)
        }
        
        func buildFeedRequester(with dependency: RequesterDependencyContainer) -> ListingListMultiRequester {
            return FilterListingListRequesterFactory
                .generateDefaultFeedRequester(itemsPerPage: dependency.itemsPerPage)
        }
        
        func buildSimilarRequester(with dependency: RequesterDependencyContainer) -> ListingListMultiRequester {
            return FilterListingListRequesterFactory
                .generateRequester(withFilters: dependency.filters,
                                   queryString: dependency.queryString,
                                   itemsPerPage: dependency.itemsPerPage,
                                   carSearchActive: dependency.carSearchActive,
                                   similarSearchActive: dependency.similarSearchActive)
        }
        
        func buildSearchAndSimilarRequester(with dependency: RequesterDependencyContainer) -> ListingListMultiRequester {
            return FilterListingListRequesterFactory
                .generateCombinedSearchAndSimilar(withFilters: dependency.filters,
                                                  queryString: dependency.queryString,
                                                  itemsPerPage: dependency.itemsPerPage,
                                                  carSearchActive: dependency.carSearchActive)
        }
    }
}


