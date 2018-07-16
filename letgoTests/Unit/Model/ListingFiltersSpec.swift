
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
                    sut?.carMakeId = nil
                    sut?.carModelId = nil
                    sut?.carYearStart = nil
                    sut?.carYearEnd = nil
                    sut?.carMileageStart = nil
                    sut?.carMileageEnd = nil
                    sut?.carNumberOfSeatsStart = nil
                    sut?.carNumberOfSeatsEnd = nil
                    sut?.carBodyTypes = []
                    sut?.carDriveTrainTypes = []
                    sut?.carFuelTypes = []
                    sut?.carTransmissionTypes = []
                    sut?.carSellerTypes = []
                }
                
                context("no car attributes are set") {
                    
                    it("hasAnyCarAttributes should be false") {
                        expect(sut?.hasAnyCarAttributes).to(beFalse())
                    }
                }
                
                context("only car one attribute is set") {
                    
                    beforeEach {
                        sut?.carMileageStart = 7
                    }
                    
                    it("hasAnyCarAttributes should be true") {
                        expect(sut?.hasAnyCarAttributes).to(beTrue())
                    }
                }
                
                context("one array has an item") {
                    
                    beforeEach {
                        sut?.carBodyTypes = [CarBodyType.coupe]
                    }
                    
                    it("hasAnyCarAttributes should be true") {
                        expect(sut?.hasAnyCarAttributes).to(beTrue())
                    }
                }
            }
            
            context("test hasAnyRealEstateAttributes") {
                beforeEach {
                    sut = ListingFilters.makeMock()
                    sut?.realEstateOfferTypes = []
                    sut?.realEstatePropertyType = nil
                    sut?.realEstateNumberOfBathrooms = nil
                    sut?.realEstateNumberOfBedrooms = nil
                    sut?.realEstateNumberOfRooms = nil
                    sut?.realEstateSizeRange = SizeRange(min: nil, max: nil)
                }
                
                context("no realEstate attributes are set") {
                    
                    it("hasAnyRealEstateAttributes should be false") {
                        expect(sut?.hasAnyRealEstateAttributes).to(beFalse())
                    }
                }
                
                context("only realEstate one attribute is set") {
                    
                    beforeEach {
                        sut?.realEstatePropertyType = RealEstatePropertyType.flat
                    }
                    
                    it("hasAnyRealEstateAttributes should be true") {
                        expect(sut?.hasAnyRealEstateAttributes).to(beTrue())
                    }
                }
                
                context("one array has an item") {
                    
                    beforeEach {
                        sut?.realEstateOfferTypes = [RealEstateOfferType.rent]
                    }
                    
                    it("hasAnyRealEstateAttributes should be true") {
                        expect(sut?.hasAnyRealEstateAttributes).to(beTrue())
                    }
                }
                
                context("real estate size has a value") {
                    
                    beforeEach {
                        sut?.realEstateSizeRange = SizeRange(min: 0, max: nil)
                    }
                    
                    it("hasAnyRealEstateAttributes should be true") {
                        expect(sut?.hasAnyRealEstateAttributes).to(beTrue())
                    }
                }
            }
            
            context("test hasAnyServicesAttributes") {
                beforeEach {
                    sut = ListingFilters.makeMock()
                    sut?.servicesType = nil
                    sut?.servicesSubtypes = nil
                }
                
                context("no service attributes are set") {
                    
                    it("hasAnyServicesAttributes should be false") {
                        expect(sut?.hasAnyServicesAttributes).to(beFalse())
                    }
                }
                
                context("only service one attribute is set") {
                    
                    beforeEach {
                        sut?.servicesType = MockServiceType.makeMock()
                    }
                    
                    it("hasAnyServicesAttributes should be true") {
                        expect(sut?.hasAnyServicesAttributes).to(beTrue())
                    }
                }
                
                context("one array has an item") {
                    
                    beforeEach {
                        sut?.servicesSubtypes = [MockServiceSubtype.makeMock()]
                    }
                    
                    it("hasAnyServicesAttributes should be true") {
                        expect(sut?.hasAnyServicesAttributes).to(beTrue())
                    }
                }
            }
        }
    }
}
