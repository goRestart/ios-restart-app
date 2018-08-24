@testable import LetGoGodMode
import LGCoreKit
import Quick
import Nimble
final class InterestedStateUpdaterSpec: QuickSpec {
    override func spec() {
        
        var sut: InterestedStateUpdater!
        var keyValueStorage: KeyValueStorage!
        describe("Interation with values in keyValueStorage") {
            context("Add listing to contacted interested list") {
                beforeEach {
                    sut = makeSut(withInterestedIds: ["1", "2"],
                                  contactedProUsersIds: ["3"])
                }
                
                it("should insert listing Id to keyvalue storage") {
                    let listing = makeListing(withObjectId: "8")
                    sut.addInterestedState(forListing: listing, completion: nil)
                    expect(keyValueStorage.interestingListingIDs.contains("8")).to(beTrue())
                }
                
                it("should delete listing Id from keyvalue storage"){
                    let listing = makeListing(withObjectId: "2")
                    sut.removeInterestedState(forListing: listing, completion: nil)
                    expect(keyValueStorage.interestingListingIDs.contains("2")).toNot(beTrue())
                }
            }
        }
        
        describe("properties calculated from values in keyValueStorage") {
            
            context("Check if listing Id is part of contacted PRO Listing") {
                beforeEach {
                    sut = makeSut(withInterestedIds: ["1", "2", "3"],
                                  contactedProUsersIds: ["4", "5"])
                }
                
                it("has listing Id in the stored contacted pro listing array") {
                    let listing = makeListing(withObjectId: "5")
                    expect(sut.hasContactedProListing(listing)).to(beTrue())
                }
                
                it("doesnot have listing Id in the stored contact pro listing array"){
                    let listing = makeListing(withObjectId: "6")
                    expect(sut.hasContactedProListing(listing)).toNot(beTrue())
                }
            }
            
            context("Check if listing Id is part of contacted Listing") {
                beforeEach {
                    sut = makeSut(withInterestedIds: ["1", "2", "3"],
                                  contactedProUsersIds: [])
                }
                
                it("has listing Id in the stored contacted listing array") {
                    let listing = makeListing(withObjectId: "1")
                    expect(sut.hasContactedListing(listing)).to(beTrue())
                }
                
                it("doesnot have listing Id in the stored contact listing array"){
                    let listing = makeListing(withObjectId: "6")
                    expect(sut.hasContactedListing(listing)).toNot(beTrue())
                }
            }
        }
        
        func makeSut(withInterestedIds interestedIds: [String], contactedProUsersIds: [String]) -> InterestedStateUpdater {
            let mockKeyValueStorage = MockKeyValueStorage()
            let myUserRepository = MockMyUserRepository()
            var myUser = MockMyUser.makeMock()
            myUser.objectId = "12345"
            myUserRepository.myUserVar.value = myUser
            keyValueStorage = KeyValueStorage(storage: mockKeyValueStorage,
                                              myUserRepository: myUserRepository)
            keyValueStorage.interestingListingIDs = Set(interestedIds)
            keyValueStorage.proSellerAlreadySentPhoneInChat = contactedProUsersIds
            return LGInterestedStateUpdater(myUserRepository: myUserRepository, keyValueStorage: keyValueStorage)
        }
        
        func makeListing(withObjectId id: String) -> Listing {
            var product: MockProduct = MockProduct.makeMock()
            product.objectId = id
            return Listing.product(product)
        }
        
    }
}
