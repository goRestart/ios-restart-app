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

class RatingManagerSpec: QuickSpec {
    override func spec() {
        var sut: RatingManager!

        var mockUserProvider: MockMyUserRepository!
        var keyValueStorage: KeyValueStorage!
        var crashManager: CrashManager!

        describe("Rating Manager") {
            beforeEach {
                let mockStorage = MockKeyValueStorage()
                mockUserProvider = MockMyUserRepository()
                var myUser = MockMyUser.makeMock()
                myUser.objectId = "12345"
                mockUserProvider.myUserVar.value = myUser
                keyValueStorage = KeyValueStorage(storage: mockStorage, myUserRepository: mockUserProvider)
            }

            describe("app crashed w/o any update") {
                beforeEach {
                    let versionChange = VersionChange.none
                    crashManager = CrashManager(appCrashed: true, versionChange: versionChange)
                    sut = RatingManager(keyValueStorage: keyValueStorage, crashManager: crashManager,
                        versionChange: versionChange)
                }
                it("should not show rating") {
                    expect(sut.shouldShowRating) == false
                }
            }

            describe("previously not rated, no remind later") {
                beforeEach {
                    keyValueStorage.userRatingAlreadyRated = false
                    keyValueStorage.userRatingRemindMeLaterDate = nil
                }

                context("new install") {
                    beforeEach {
                        let versionChange = VersionChange.newInstall
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
                }
                context("new session") {
                    beforeEach {
                        let versionChange = VersionChange.none
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
                }
                context("major update") {
                    beforeEach {
                        let versionChange = VersionChange.major
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
                }
                context("minor update") {
                    beforeEach {
                        let versionChange = VersionChange.minor
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
                }
                context("patch update") {
                    beforeEach {
                        let versionChange = VersionChange.patch
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
                }
            }

            describe("previously not rated, remind later") {
                beforeEach {
                    keyValueStorage.userRatingAlreadyRated = false
                    keyValueStorage.userRatingRemindMeLaterDate = NSDate.distantPast
                }

                context("new install") {
                    beforeEach {
                        let versionChange = VersionChange.newInstall
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
                }
                context("new session") {
                    beforeEach {
                        let versionChange = VersionChange.none
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
                }
                context("major update") {
                    beforeEach {
                        let versionChange = VersionChange.major
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
                }
                context("minor update") {
                    beforeEach {
                        let versionChange = VersionChange.minor
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
                }
                context("patch update") {
                    beforeEach {
                        let versionChange = VersionChange.patch
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
                }
            }

            describe("previously rated") {
                beforeEach {
                    keyValueStorage.userRatingAlreadyRated = true
                    keyValueStorage.userRatingRemindMeLaterDate = nil
                }

                context("new install") {
                    beforeEach {
                        let versionChange = VersionChange.newInstall
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
                }
                context("new session") {
                    beforeEach {
                        let versionChange = VersionChange.none
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
                }
                context("major update") {
                    beforeEach {
                        let versionChange = VersionChange.major
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
                }
                context("minor update") {
                    beforeEach {
                        let versionChange = VersionChange.minor
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
                }
                context("patch update") {
                    beforeEach {
                        let versionChange = VersionChange.patch
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
                }
            }

            describe("user did rate") {
                beforeEach {
                    keyValueStorage.userRatingAlreadyRated = false

                    let versionChange = VersionChange.newInstall
                    crashManager = CrashManager(appCrashed: false, versionChange: versionChange)
                    sut = RatingManager(keyValueStorage: keyValueStorage, crashManager: crashManager,
                        versionChange: versionChange)
                    sut.userDidRate()
                }
                it("updates already rated in storage") {
                    expect(keyValueStorage.userRatingAlreadyRated) == true
                }
            }

            describe("user did remind later") {
                beforeEach {
                    keyValueStorage.userRatingRemindMeLaterDate = nil

                    let versionChange = VersionChange.none
                    crashManager = CrashManager(appCrashed: false, versionChange: versionChange)
                    sut = RatingManager(keyValueStorage: keyValueStorage, crashManager: crashManager,
                        versionChange: versionChange)
                    sut.userDidRemindLater()
                }
                it("updates remind me later in storage") {
                    expect(keyValueStorage.userRatingRemindMeLaterDate).notTo(beNil())
                }
            }
        }
    }
}
