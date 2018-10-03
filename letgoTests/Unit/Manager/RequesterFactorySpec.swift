@testable import LetGoGodMode
import Quick
import Nimble

class RequesterFactorySpec: QuickSpec {

    override func spec() {
        
        var sut: RequesterFactory!
        
        var dependency: RequesterDependencyContainer!
        var listingRequester: ListingListRequester?
        
        beforeEach {
            listingRequester = nil
        }
        
        describe("Search Requester generation") {

            context("build product search requester") {
                beforeEach {
                    dependency = buildDependency()
                    sut = buildSut()
                    listingRequester = sut.buildSearchRequester()
                }

                it ("is a search requester") {
                    let searchRequester = buildSearchRequester(with: dependency)
                    expect(listingRequester?.isEqual(toRequester: searchRequester)).to(beTrue())
                }
            }
        }
        
        func buildSut() -> SearchRequesterFactory {
            let dependency = buildDependency()
            return SearchRequesterFactory(dependencyContainer: dependency)
        }
        
        func buildDependency() -> RequesterDependencyContainer {
            return RequesterDependencyContainer(itemsPerPage: 50,
                                                filters: ListingFilters(),
                                                queryString: "abc")
        }
        

        func buildSearchRequester(with dependency: RequesterDependencyContainer) -> ListingListMultiRequester {
            return FilterListingListRequesterFactory
                .generateRequester(withFilters: dependency.filters,
                                   queryString:dependency.queryString,
                                   itemsPerPage: dependency.itemsPerPage)
        }
    }
}


