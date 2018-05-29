@testable import LetGoGodMode
import Quick
import Nimble

class RequesterFactorySpec: QuickSpec {

    var sut: RequesterFactory!

    let featureFlags = MockFeatureFlags()
    var dependency: RequesterDependencyContainer!
    var listRequesterArray: [ListingListRequester] = []

    override func spec() {
        describe("requester array generation") {
            beforeEach {
                self.dependency = self.buildDependencyContainer()
                self.listRequesterArray = []
                self.sut = SearchRequesterFactory(dependencyContainer: self.dependency,
                                                  featureFlags: self.featureFlags)
            }

            context("set emptySearchImprovements featureFlags to .control") {
                beforeEach {
                    self.setUp(withEmptySearchFlag: .control)
                }

                it ("the requester is a search requester") {
                    let searchRequester = self.buildSearchRequester(with: self.dependency)
                    let factoryRequester = self.listRequesterArray.first
                    expect(factoryRequester?.isEqual(toRequester: searchRequester)).to(beTrue())
                }
            }

            context("set emptySearchImprovements featureFlags to .baseline") {
                beforeEach {
                    self.setUp(withEmptySearchFlag: .baseline)
                }

                it ("the requester is a search requester") {
                    let searchRequester = self.buildSearchRequester(with: self.dependency)

                    let factoryRequester = self.listRequesterArray.first
                    expect(factoryRequester?.isEqual(toRequester: searchRequester)).to(beTrue())
                }
            }

            context("set emptySearchImprovements featureFlags to .popularNearYou") {
                beforeEach {
                    self.setUp(withEmptySearchFlag: .popularNearYou)
                }

                it ("requesters are [search, feed]") {
                    let searchRequester = self.buildSearchRequester(with: self.dependency)
                    let feedRequester = self.buildFeedRequester(with: self.dependency)

                    let factoryRequesters = self.listRequesterArray
                    expect(factoryRequesters.first?.isEqual(toRequester: searchRequester)).to(beTrue())
                    expect(factoryRequesters.last?.isEqual(toRequester: feedRequester)).to(beTrue())
                }
            }

            context("set emptySearchImprovements featureFlags to .similarQueries") {
                beforeEach {
                    self.setUp(withEmptySearchFlag: .similarQueries)
                }

                it ("requesters are [search, similar, feed]") {
                    let searchRequester = self.buildSearchRequester(with: self.dependency)
                    let feedRequester = self.buildFeedRequester(with: self.dependency)
                    let similarRequester = self.buildSimilarRequester(with: self.dependency)

                    expect(self.listRequesterArray[safeAt: 0]?.isEqual(toRequester: searchRequester)).to(beTrue())
                    expect(self.listRequesterArray[safeAt: 1]?.isEqual(toRequester: similarRequester)).to(beTrue())
                    expect(self.listRequesterArray[safeAt: 2]?.isEqual(toRequester: feedRequester)).to(beTrue())
                }
            }
        }
    }
}

fileprivate extension RequesterFactorySpec {
    private func buildDependencyContainer() -> RequesterDependencyContainer {
        return RequesterDependencyContainer(itemsPerPage: 50,
                                            filters: ListingFilters(),
                                            queryString: "abc",
                                            carSearchActive: false)
    }

    private func setUp(withEmptySearchFlag featureFlag: EmptySearchImprovements) {
        self.featureFlags.emptySearchImprovements = featureFlag
        self.listRequesterArray = self.sut.buildRequesterList()
    }

    private func buildSearchRequester(with dependency: RequesterDependencyContainer) -> ListingListMultiRequester {
        return FilterListingListRequesterFactory
            .generateRequester(withFilters: dependency.filters,
                               queryString:dependency.queryString,
                               itemsPerPage: dependency.itemsPerPage,
                               carSearchActive: dependency.carSearchActive)
    }

    private func buildFeedRequester(with dependency: RequesterDependencyContainer) -> ListingListMultiRequester {
        return FilterListingListRequesterFactory
            .generateDefaultFeedRequester(itemsPerPage: dependency.itemsPerPage)
    }

    private func buildSimilarRequester(with dependency: RequesterDependencyContainer) -> ListingListMultiRequester {
        return FilterListingListRequesterFactory
            .generateDefaultFeedRequester(itemsPerPage: dependency.itemsPerPage) // FIXME: Change after implementing similar requester
    }
}
