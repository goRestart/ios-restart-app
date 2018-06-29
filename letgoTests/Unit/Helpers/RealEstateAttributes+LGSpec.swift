@testable import LetGoGodMode
import Quick
import Nimble
import LGCoreKit
import LGComponents

private struct RealEstateSpecResult {
    static let other = R.Strings.realEstateTitleGeneratorPropertyTypeOther.localizedUppercase
    static let forRent = R.Strings.realEstateTitleGeneratorOfferTypeRent.capitalizedFirstLetterOnly
    static let threeBathrooms = NumberOfBathrooms(rawValue: 3)?.shortLocalizedString.localizedUppercase ?? ""
    static let zeroBedrooms = NumberOfBedrooms(rawValue: 0)?.shortLocalizedString.localizedUppercase ?? ""
    static let zeroBathrooms = R.Strings.realEstateAttributeTagBathroom0.localizedUppercase
    static let house = R.Strings.realEstateTypePropertyHouse.uppercased()
    static let flat = R.Strings.realEstateTypePropertyFlat.uppercased()
    static let studio = R.Strings.realEstateRoomsStudio.capitalized
    static let overTen = R.Strings.realEstateRoomsOverTen
}


final class RealEstateAttributesLGSpec: QuickSpec {
    override func spec() {
        var sut: RealEstateAttributes!
        
        describe("Generate real estate .standard posting") {
            context("with no data on attributes") {
                beforeEach {
                    sut = RealEstateAttributes(propertyType: nil,
                                               offerType: nil,
                                               bedrooms: nil,
                                               bathrooms: nil,
                                               livingRooms: nil,
                                               sizeSquareMeters: nil)
                }
                it ("returns empty title") {
                    expect(sut.generateTitle(postingFlowType: .standard)) == ""
                }
                context("attributes with property and offertype") {
                    beforeEach {
                        sut = RealEstateAttributes(propertyType: .other,
                                                   offerType: .rent,
                                                   bedrooms: nil,
                                                   bathrooms: nil,
                                                   livingRooms: nil,
                                                   sizeSquareMeters: nil)
                    }
                    it ("result should equal: OTHER For rent") {
                        expect(sut.generateTitle(postingFlowType: .standard)) == [RealEstateSpecResult.other,
                                                                                  RealEstateSpecResult.forRent].joined(separator: " ")
                    }
                }
                context("attributes with bedrooms") {
                    beforeEach {
                        sut = RealEstateAttributes(propertyType: nil,
                                                   offerType: nil,
                                                   bedrooms: 0,
                                                   bathrooms: nil,
                                                   livingRooms: nil,
                                                   sizeSquareMeters: nil)
                    }
                    it ("result should equal: 3BR") {
                        expect(sut.generateTitle(postingFlowType: .standard)) == RealEstateSpecResult.zeroBedrooms
                    }
                }
                context("attributes with bathrooms") {
                    beforeEach {
                        sut = RealEstateAttributes(propertyType: .other,
                                                   offerType: .rent,
                                                   bedrooms: nil,
                                                   bathrooms: 3,
                                                   livingRooms: nil,
                                                   sizeSquareMeters: nil)
                    }
                    it ("result should equal: OTHER For rent 3BA") {
                        expect(sut.generateTitle(postingFlowType: .standard)) == [RealEstateSpecResult.other,
                                                                                  RealEstateSpecResult.forRent,
                                                                                  RealEstateSpecResult.threeBathrooms].joined(separator: " ")
                    }
                }
            }
        }
        
        describe("Generate real estate .turkish posting") {
            context("with no data on attributes") {
                beforeEach {
                    sut = RealEstateAttributes(propertyType: nil,
                                               offerType: nil,
                                               bedrooms: nil,
                                               bathrooms: nil,
                                               livingRooms: nil,
                                               sizeSquareMeters: nil)
                }
                it ("returns empty title") {
                    expect(sut.generateTitle(postingFlowType: .turkish)) == ""
                }
                context("attributes with property and offertype") {
                    beforeEach {
                        sut = RealEstateAttributes(propertyType: .other,
                                                   offerType: .rent,
                                                   bedrooms: nil,
                                                   bathrooms: nil,
                                                   livingRooms: nil,
                                                   sizeSquareMeters: nil)
                    }
                    it ("result should equal: OTHER For rent") {
                        expect(sut.generateTitle(postingFlowType: .turkish)) == [RealEstateSpecResult.forRent,
                                                                                 RealEstateSpecResult.other].joined(separator: " ")
                    }
                }
                context("attributes with studio (1+0)") {
                    beforeEach {
                        sut = RealEstateAttributes(propertyType: .flat,
                                                   offerType: nil,
                                                   bedrooms: 1,
                                                   bathrooms: nil,
                                                   livingRooms: 0,
                                                   sizeSquareMeters: nil)
                    }
                    it ("result should equal: studio (1+0)") {
                        expect(sut.generateTitle(postingFlowType: .turkish)) == [RealEstateSpecResult.flat,
                                                                                 RealEstateSpecResult.studio].joined(separator: " ")
                    }
                }
                context("attributes with over 10 rooms") {
                    beforeEach {
                        sut = RealEstateAttributes(propertyType: .other,
                                                   offerType: .rent,
                                                   bedrooms: 10,
                                                   bathrooms: nil,
                                                   livingRooms: 0,
                                                   sizeSquareMeters: nil)
                    }
                    it ("result should equal: OTHER For rent Over 10") {
                        expect(sut.generateTitle(postingFlowType: .turkish)) == [RealEstateSpecResult.forRent,
                                                                                 RealEstateSpecResult.other,
                                                                                 RealEstateSpecResult.overTen].joined(separator: " ")
                    }
                }
            }
        }
        
        describe("Generate real estate attribute tags standard") {
            context("standard posting flow") {
                context("with attributes") {
                    beforeEach {
                        sut = RealEstateAttributes(propertyType: nil,
                                                   offerType: nil,
                                                   bedrooms: nil,
                                                   bathrooms: nil,
                                                   livingRooms: nil,
                                                   sizeSquareMeters: nil)
                    }
                    it ("returns empty array") {
                        expect(sut.generateTags(postingFlowType: .standard).count).to(equal(0))
                    }
                }
                context("with 0 bathrooms") {
                    beforeEach {
                        sut = RealEstateAttributes(propertyType: nil,
                                                   offerType: nil,
                                                   bedrooms: nil,
                                                   bathrooms: 0,
                                                   livingRooms: nil,
                                                   sizeSquareMeters: nil)
                    }
                    it ("returns 1 tag") {
                        let tags = sut.generateTags(postingFlowType: .standard)
                        expect(tags.count).to(equal(1))
                        expect(tags[0]).to(equal(RealEstateSpecResult.zeroBathrooms))
                    }
                }
                context("with all attributes") {
                    beforeEach {
                        sut = RealEstateAttributes(propertyType: .house,
                                                   offerType: .rent,
                                                   bedrooms: 0,
                                                   bathrooms: 3,
                                                   livingRooms: nil,
                                                   sizeSquareMeters: nil)
                    }
                    it ("returns 4 tags") {
                        let tags = sut.generateTags(postingFlowType: .standard)
                        expect(tags.count).to(equal(4))
                        expect(tags[0]).to(equal(RealEstateSpecResult.house))
                        expect(tags[1]).to(equal(RealEstateSpecResult.forRent.localizedCapitalized))
                        expect(tags[2]).to(equal(RealEstateSpecResult.zeroBedrooms))
                        expect(tags[3]).to(equal(RealEstateSpecResult.threeBathrooms))
                    }
                }
            }
            context("turkish posting flow") {
                context("with attributes") {
                    beforeEach {
                        sut = RealEstateAttributes(propertyType: nil,
                                                   offerType: nil,
                                                   bedrooms: nil,
                                                   bathrooms: nil,
                                                   livingRooms: nil,
                                                   sizeSquareMeters: nil)
                    }
                    it ("returns empty array") {
                        expect(sut.generateTags(postingFlowType: .turkish).count).to(equal(0))
                    }
                }
                context("with 2+1 rooms") {
                    beforeEach {
                        sut = RealEstateAttributes(propertyType: nil,
                                                   offerType: nil,
                                                   bedrooms: 2,
                                                   bathrooms: nil,
                                                   livingRooms: 1,
                                                   sizeSquareMeters: nil)
                    }
                    it ("returns 1 tag") {
                        let tags = sut.generateTags(postingFlowType: .turkish)
                        expect(tags.count).to(equal(1))
                        expect(tags[0]).to(equal("2 + 1"))
                    }
                }
                context("with all attributes") {
                    beforeEach {
                        sut = RealEstateAttributes(propertyType: .house,
                                                   offerType: .rent,
                                                   bedrooms: 2,
                                                   bathrooms: 1,
                                                   livingRooms: 2,
                                                   sizeSquareMeters: 100)
                    }
                    it ("returns 4 tags") {
                        let tags = sut.generateTags(postingFlowType: .turkish)
                        expect(tags.count).to(equal(4))
                        expect(tags[0]).to(equal(RealEstateSpecResult.house))
                        expect(tags[2]).to(equal("2 + 2"))
                        expect(tags[3]).to(equal("100 \(SharedConstants.sizeSquareMetersUnit)"))
                    }
                }
            }
        }
        
    }
}
