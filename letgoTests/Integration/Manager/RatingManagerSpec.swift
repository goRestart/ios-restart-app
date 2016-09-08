//
//  RatingManagerSpec.swift
//  LetGo
//
//  Created by Albert Hernández López on 09/05/16.
//  Copyright © 2016 Ambatana. All rights reserved.
//

@testable import LetGo
import LGCoreKit
import Quick
import Nimble
import SwiftyUserDefaults

private class MockUserProvider: UserProvider {
    var myUser: MyUser?
}

private class MockMyUser: MyUser {
    var objectId: String?
    var name: String?
    var avatar: File?
    var postalAddress: PostalAddress = PostalAddress(address: nil, city: nil, zipCode: nil, countryCode: nil, country: nil)
    var accounts: [Account]?
    var ratingCount: Int?
    var ratingAverage: Float?
    var status: UserStatus = .Active

    var isDummy: Bool = false
    var email: String?
    var location: LGLocation?
    var localeIdentifier: String?
}

class RatingManagerSpec: QuickSpec {
    override func spec() {
        var sut: RatingManager!

        var mockUserProvider: MockUserProvider!
        var keyValueStorage: KeyValueStorage!
        var crashManager: CrashManager!

        describe("Rating Manager") {
            beforeEach {
                let mockStorage = MockKeyValueStorage()
                mockUserProvider = MockUserProvider()
                let myUser = MockMyUser()
                myUser.objectId = "12345"
                mockUserProvider.myUser = myUser
                keyValueStorage = KeyValueStorage(storage: mockStorage, userProvider: mockUserProvider)
            }

            describe("app crashed w/o any update") {
                beforeEach {
                    let versionChange = VersionChange.None
                    crashManager = CrashManager(appCrashed: true, versionChange: versionChange)
                    sut = RatingManager(keyValueStorage: keyValueStorage, crashManager: crashManager,
                        versionChange: versionChange)
                }
                it("should not show rating") {
                    expect(sut.shouldShowRating) == false
                }
                it("should not show rating banner at product list") {
                    expect(sut.shouldShowRatingProductListBanner) == false
                }
            }

            describe("previously not rated, no remind later") {
                beforeEach {
                    keyValueStorage.userRatingAlreadyRated = false
                    keyValueStorage.userRatingRemindMeLaterDate = nil
                    keyValueStorage.userRatingShowProductListBanner = true
                }

                context("new install") {
                    beforeEach {
                        let versionChange = VersionChange.NewInstall
                        crashManager = CrashManager(appCrashed: false, versionChange: versionChange)
                        sut = RatingManager(keyValueStorage: keyValueStorage, crashManager: crashManager,
                            versionChange: versionChange)
                    }
                    it("key storage indicates that user did not rate") {
                        expect(keyValueStorage.userRatingAlreadyRated) == false
                    }
                    it("key storage has not remind me later date") {
                        expect(keyValueStorage.userRatingRemindMeLaterDate).to(beNil())
                    }
                    it("should show rating") {
                        expect(sut.shouldShowRating) == true
                    }
                    it("should not show rating banner at product list") {
                        expect(sut.shouldShowRatingProductListBanner) == false
                    }
                }
                context("new session") {
                    beforeEach {
                        let versionChange = VersionChange.None
                        crashManager = CrashManager(appCrashed: false, versionChange: versionChange)
                        sut = RatingManager(keyValueStorage: keyValueStorage, crashManager: crashManager,
                            versionChange: versionChange)
                    }
                    it("key storage indicates that user did not rate") {
                        expect(keyValueStorage.userRatingAlreadyRated) == false
                    }
                    it("key storage has not remind me later date") {
                        expect(keyValueStorage.userRatingRemindMeLaterDate).to(beNil())
                    }
                    it("should show rating") {
                        expect(sut.shouldShowRating) == true
                    }
                    it("should show rating banner at product list") {
                        expect(sut.shouldShowRatingProductListBanner) == true
                    }
                }
                context("major update") {
                    beforeEach {
                        let versionChange = VersionChange.Major
                        crashManager = CrashManager(appCrashed: false, versionChange: versionChange)
                        sut = RatingManager(keyValueStorage: keyValueStorage, crashManager: crashManager,
                            versionChange: versionChange)
                    }
                    it("key storage indicates that user did not rate") {
                        expect(keyValueStorage.userRatingAlreadyRated) == false
                    }
                    it("key storage has not remind me later date") {
                        expect(keyValueStorage.userRatingRemindMeLaterDate).to(beNil())
                    }
                    it("should show rating") {
                        expect(sut.shouldShowRating) == true
                    }
                    it("should not show rating banner at product list") {
                        expect(sut.shouldShowRatingProductListBanner) == false
                    }
                }
                context("minor update") {
                    beforeEach {
                        let versionChange = VersionChange.Minor
                        crashManager = CrashManager(appCrashed: false, versionChange: versionChange)
                        sut = RatingManager(keyValueStorage: keyValueStorage, crashManager: crashManager,
                            versionChange: versionChange)
                    }
                    it("key storage indicates that user did not rate") {
                        expect(keyValueStorage.userRatingAlreadyRated) == false
                    }
                    it("key storage has not remind me later date") {
                        expect(keyValueStorage.userRatingRemindMeLaterDate).to(beNil())
                    }
                    it("should show rating") {
                        expect(sut.shouldShowRating) == true
                    }
                    it("should not show rating banner at product list") {
                        expect(sut.shouldShowRatingProductListBanner) == false
                    }
                }
                context("patch update") {
                    beforeEach {
                        let versionChange = VersionChange.Patch
                        crashManager = CrashManager(appCrashed: false, versionChange: versionChange)
                        sut = RatingManager(keyValueStorage: keyValueStorage, crashManager: crashManager,
                            versionChange: versionChange)
                    }
                    it("key storage indicates that user did not rate") {
                        expect(keyValueStorage.userRatingAlreadyRated) == false
                    }
                    it("key storage has not remind me later date") {
                        expect(keyValueStorage.userRatingRemindMeLaterDate).to(beNil())
                    }
                    it("should show rating") {
                        expect(sut.shouldShowRating) == true
                    }
                    it("should show rating banner at product list") {
                        expect(sut.shouldShowRatingProductListBanner) == true
                    }
                }
            }

            describe("previously not rated, remind later") {
                beforeEach {
                    keyValueStorage.userRatingAlreadyRated = false
                    keyValueStorage.userRatingRemindMeLaterDate = NSDate.distantPast()
                    keyValueStorage.userRatingShowProductListBanner = true
                }

                context("new install") {
                    beforeEach {
                        let versionChange = VersionChange.NewInstall
                        crashManager = CrashManager(appCrashed: false, versionChange: versionChange)
                        sut = RatingManager(keyValueStorage: keyValueStorage, crashManager: crashManager,
                            versionChange: versionChange)
                    }
                    it("key storage indicates that user did not rate") {
                        expect(keyValueStorage.userRatingAlreadyRated) == false
                    }
                    it("key storage has not remind me later date") {
                        expect(keyValueStorage.userRatingRemindMeLaterDate).to(beNil())
                    }
                    it("should show rating") {
                        expect(sut.shouldShowRating) == true
                    }
                    it("should not show rating banner at product list") {
                        expect(sut.shouldShowRatingProductListBanner) == false
                    }
                }
                context("new session") {
                    beforeEach {
                        let versionChange = VersionChange.None
                        crashManager = CrashManager(appCrashed: false, versionChange: versionChange)
                        sut = RatingManager(keyValueStorage: keyValueStorage, crashManager: crashManager,
                            versionChange: versionChange)
                    }
                    it("key storage indicates that user did not rate") {
                        expect(keyValueStorage.userRatingAlreadyRated) == false
                    }
                    it("key storage has a remind me later date") {
                        expect(keyValueStorage.userRatingRemindMeLaterDate).notTo(beNil())
                    }
                    it("should show rating") {
                        expect(sut.shouldShowRating) == true
                    }
                    it("should show rating banner at product list") {
                        expect(sut.shouldShowRatingProductListBanner) == true
                    }
                }
                context("major update") {
                    beforeEach {
                        let versionChange = VersionChange.Major
                        crashManager = CrashManager(appCrashed: false, versionChange: versionChange)
                        sut = RatingManager(keyValueStorage: keyValueStorage, crashManager: crashManager,
                            versionChange: versionChange)
                    }
                    it("key storage indicates that user did not rate") {
                        expect(keyValueStorage.userRatingAlreadyRated) == false
                    }
                    it("key storage has not remind me later date") {
                        expect(keyValueStorage.userRatingRemindMeLaterDate).to(beNil())
                    }
                    it("should show rating") {
                        expect(sut.shouldShowRating) == true
                    }
                    it("should not show rating banner at product list") {
                        expect(sut.shouldShowRatingProductListBanner) == false
                    }
                }
                context("minor update") {
                    beforeEach {
                        let versionChange = VersionChange.Minor
                        crashManager = CrashManager(appCrashed: false, versionChange: versionChange)
                        sut = RatingManager(keyValueStorage: keyValueStorage, crashManager: crashManager,
                            versionChange: versionChange)
                    }
                    it("key storage indicates that user did not rate") {
                        expect(keyValueStorage.userRatingAlreadyRated) == false
                    }
                    it("key storage has not remind me later date") {
                        expect(keyValueStorage.userRatingRemindMeLaterDate).to(beNil())
                    }
                    it("should show rating") {
                        expect(sut.shouldShowRating) == true
                    }
                    it("should not show rating banner at product list") {
                        expect(sut.shouldShowRatingProductListBanner) == false
                    }
                }
                context("patch update") {
                    beforeEach {
                        let versionChange = VersionChange.Patch
                        crashManager = CrashManager(appCrashed: false, versionChange: versionChange)
                        sut = RatingManager(keyValueStorage: keyValueStorage, crashManager: crashManager,
                            versionChange: versionChange)
                    }
                    it("key storage indicates that user did not rate") {
                        expect(keyValueStorage.userRatingAlreadyRated) == false
                    }
                    it("key storage has not remind me later date") {
                        expect(keyValueStorage.userRatingRemindMeLaterDate).to(beNil())
                    }
                    it("should show rating") {
                        expect(sut.shouldShowRating) == true
                    }
                    it("should show rating banner at product list") {
                        expect(sut.shouldShowRatingProductListBanner) == true
                    }
                }
            }

            describe("previously rated") {
                beforeEach {
                    keyValueStorage.userRatingAlreadyRated = true
                    keyValueStorage.userRatingRemindMeLaterDate = nil
                    keyValueStorage.userRatingShowProductListBanner = false
                }

                context("new install") {
                    beforeEach {
                        let versionChange = VersionChange.NewInstall
                        crashManager = CrashManager(appCrashed: false, versionChange: versionChange)
                        sut = RatingManager(keyValueStorage: keyValueStorage, crashManager: crashManager,
                            versionChange: versionChange)
                    }
                    it("key storage indicates that user did not rate") {
                        expect(keyValueStorage.userRatingAlreadyRated) == false
                    }
                    it("key storage has not remind me later date") {
                        expect(keyValueStorage.userRatingRemindMeLaterDate).to(beNil())
                    }
                    it("should show rating") {
                        expect(sut.shouldShowRating) == true
                    }
                    it("should not show rating banner at product list") {
                        expect(sut.shouldShowRatingProductListBanner) == false
                    }
                }
                context("new session") {
                    beforeEach {
                        let versionChange = VersionChange.None
                        crashManager = CrashManager(appCrashed: false, versionChange: versionChange)
                        sut = RatingManager(keyValueStorage: keyValueStorage, crashManager: crashManager,
                            versionChange: versionChange)
                    }
                    it("key storage indicates that user did rate") {
                        expect(keyValueStorage.userRatingAlreadyRated) == true
                    }
                    it("key storage has not a remind me later date") {
                        expect(keyValueStorage.userRatingRemindMeLaterDate).to(beNil())
                    }
                    it("should not show rating") {
                        expect(sut.shouldShowRating) == false
                    }
                    it("should not show rating banner at product list") {
                        expect(sut.shouldShowRatingProductListBanner) == false
                    }
                }
                context("major update") {
                    beforeEach {
                        let versionChange = VersionChange.Major
                        crashManager = CrashManager(appCrashed: false, versionChange: versionChange)
                        sut = RatingManager(keyValueStorage: keyValueStorage, crashManager: crashManager,
                            versionChange: versionChange)
                    }
                    it("key storage indicates that user did not rate") {
                        expect(keyValueStorage.userRatingAlreadyRated) == false
                    }
                    it("key storage has not remind me later date") {
                        expect(keyValueStorage.userRatingRemindMeLaterDate).to(beNil())
                    }
                    it("should show rating") {
                        expect(sut.shouldShowRating) == true
                    }
                    it("should not show rating banner at product list") {
                        expect(sut.shouldShowRatingProductListBanner) == false
                    }
                }
                context("minor update") {
                    beforeEach {
                        let versionChange = VersionChange.Minor
                        crashManager = CrashManager(appCrashed: false, versionChange: versionChange)
                        sut = RatingManager(keyValueStorage: keyValueStorage, crashManager: crashManager,
                            versionChange: versionChange)
                    }
                    it("key storage indicates that user did not rate") {
                        expect(keyValueStorage.userRatingAlreadyRated) == false
                    }
                    it("key storage has not remind me later date") {
                        expect(keyValueStorage.userRatingRemindMeLaterDate).to(beNil())
                    }
                    it("should show rating") {
                        expect(sut.shouldShowRating) == true
                    }
                    it("should not show rating banner at product list") {
                        expect(sut.shouldShowRatingProductListBanner) == false
                    }
                }
                context("patch update") {
                    beforeEach {
                        let versionChange = VersionChange.Patch
                        crashManager = CrashManager(appCrashed: false, versionChange: versionChange)
                        sut = RatingManager(keyValueStorage: keyValueStorage, crashManager: crashManager,
                            versionChange: versionChange)
                    }
                    it("key storage indicates that user did rate") {
                        expect(keyValueStorage.userRatingAlreadyRated) == true
                    }
                    it("key storage has not remind me later date") {
                        expect(keyValueStorage.userRatingRemindMeLaterDate).to(beNil())
                    }
                    it("should show not rating") {
                        expect(sut.shouldShowRating) == false
                    }
                    it("should not show rating banner at product list") {
                        expect(sut.shouldShowRatingProductListBanner) == false
                    }
                }
            }

            describe("user did rate") {
                beforeEach {
                    keyValueStorage.userRatingAlreadyRated = false

                    let versionChange = VersionChange.NewInstall
                    crashManager = CrashManager(appCrashed: false, versionChange: versionChange)
                    sut = RatingManager(keyValueStorage: keyValueStorage, crashManager: crashManager,
                        versionChange: versionChange)
                    sut.userDidRate()
                }
                it("updates already rated in storage") {
                    expect(keyValueStorage.userRatingAlreadyRated) == true
                }
                it("should not show rating banner at product list") {
                    expect(sut.shouldShowRatingProductListBanner) == false
                }
                it("should not show rating banner at product list") {
                    expect(sut.shouldShowRatingProductListBanner) == false
                }
            }

            describe("user did remind later, source is not the banner") {
                beforeEach {
                    keyValueStorage.userRatingRemindMeLaterDate = nil

                    let versionChange = VersionChange.None
                    crashManager = CrashManager(appCrashed: false, versionChange: versionChange)
                    sut = RatingManager(keyValueStorage: keyValueStorage, crashManager: crashManager,
                        versionChange: versionChange)
                    sut.userDidRemindLater(sourceIsBanner: false)
                }
                it("updates remind me later in storage") {
                    expect(keyValueStorage.userRatingRemindMeLaterDate).notTo(beNil())
                }
                it("should show rating banner at product list") {
                    expect(sut.shouldShowRatingProductListBanner) == true
                }
            }

            describe("user did remind later, source is not the banner") {
                var date: NSDate!

                beforeEach {
                    date = NSDate.distantFuture()

                    keyValueStorage.userRatingRemindMeLaterDate = date

                    let versionChange = VersionChange.None
                    crashManager = CrashManager(appCrashed: false, versionChange: versionChange)
                    sut = RatingManager(keyValueStorage: keyValueStorage, crashManager: crashManager,
                        versionChange: versionChange)
                    sut.userDidRemindLater(sourceIsBanner: true)
                }
                it("does not update remind me later date in storage") {
                    expect(keyValueStorage.userRatingRemindMeLaterDate) == date
                }
            }
        }
    }
}
