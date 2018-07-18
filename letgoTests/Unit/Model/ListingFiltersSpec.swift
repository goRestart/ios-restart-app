
@testable import LetGoGodMode
import LGCoreKit
import Quick
import Nimble

class ListingFiltersSpec: QuickSpec {
    
    override func spec() {
        var sut: ListingFilters?
        
        describe("ListingFiltersSpec") {
            
            context("test hasAnyCarAttributes") {
                
                beforeEach {
                    sut = ListingFilters.makeMock()
                    sut = sut?.resetVerticalAttributes()
                }
                
                context("no car attributes are set") {
                    
                    it("hasAnyCarAttributes should be false") {
                        expect(sut?.hasAnyCarAttributes).to(beFalse())
                    }
                }
                
                context("only car one attribute is set") {
                    
                    beforeEach {
                        sut?.verticalFilters.cars.mileageStart = 7
                    }
                    
                    it("hasAnyCarAttributes should be true") {
                        expect(sut?.hasAnyCarAttributes).to(beTrue())
                    }
                }
                
                context("one array has an item") {
                    
                    beforeEach {
                        sut?.verticalFilters.cars.bodyTypes = [CarBodyType.coupe]
                    }
                    
                    it("hasAnyCarAttributes should be true") {
                        expect(sut?.hasAnyCarAttributes).to(beTrue())
                    }
                }
            }
            
            context("test hasAnyRealEstateAttributes") {
                beforeEach {
                    sut = ListingFilters.makeMock()
                    sut = sut?.resetVerticalAttributes()
                }
                
                context("no realEstate attributes are set") {
                    
                    it("hasAnyRealEstateAttributes should be false") {
                        expect(sut?.hasAnyRealEstateAttributes).to(beFalse())
                    }
                }
                
                context("only realEstate one attribute is set") {
                    
                    beforeEach {
                        sut?.verticalFilters.realEstate.propertyType = RealEstatePropertyType.flat
                    }
                    
                    it("hasAnyRealEstateAttributes should be true") {
                        expect(sut?.hasAnyRealEstateAttributes).to(beTrue())
                    }
                }
                
                context("one array has an item") {
                    
                    beforeEach {
                        sut?.verticalFilters.realEstate.offerTypes = [RealEstateOfferType.rent]
                    }
                    
                    it("hasAnyRealEstateAttributes should be true") {
                        expect(sut?.hasAnyRealEstateAttributes).to(beTrue())
                    }
                }
                
                context("real estate size has a value") {
                    
                    beforeEach {
                        sut?.verticalFilters.realEstate.sizeRange = SizeRange(min: 0, max: nil)
                    }
                    
                    it("hasAnyRealEstateAttributes should be true") {
                        expect(sut?.hasAnyRealEstateAttributes).to(beTrue())
                    }
                }
            }
            
            context("test hasAnyServicesAttributes") {
                beforeEach {
                    sut = ListingFilters.makeMock()
                    sut = sut?.resetVerticalAttributes()
                }
                
                context("no service attributes are set") {
                    
                    it("hasAnyServicesAttributes should be false") {
                        expect(sut?.hasAnyServicesAttributes).to(beFalse())
                    }
                }
                
                context("only service one attribute is set") {
                    
                    beforeEach {
                        sut?.verticalFilters.services.type = MockServiceType.makeMock()
                    }
                    
                    it("hasAnyServicesAttributes should be true") {
                        expect(sut?.hasAnyServicesAttributes).to(beTrue())
                    }
                }
                
                context("one array has an item") {
                    
                    beforeEach {
                        sut?.verticalFilters.services.subtypes = [MockServiceSubtype.makeMock()]
                    }
                    
                    it("hasAnyServicesAttributes should be true") {
                        expect(sut?.hasAnyServicesAttributes).to(beTrue())
                    }
                }
            }
        }
    }
}
