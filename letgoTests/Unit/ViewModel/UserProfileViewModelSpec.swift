//
//  UserProfileViewModelSpec.swift
//  letgoTests
//
//  Created by Isaac Roldan on 14/3/18.
//  Copyright © 2018 Ambatana. All rights reserved.
//

import Foundation

@testable import LetGoGodMode
import LGCoreKit
import Quick
import Nimble
import RxSwift

final class UserProfileViewModelSpec: BaseViewModelSpec, ProfileTabNavigator, UserProfileViewModelDelegate {

    var openSettingsCalled: Bool = false
    var openEditBioCalled: Bool = false
    var openUserReportCalled: Bool = false
    var openVerifyAccountsCalled: Bool = false
    var openMostSearchedItemsCalled: Bool = false
    var showAlertCalled: Bool = false
    var showNativeShareCalled: Bool = false

    override func spec() {
        var sut: UserProfileViewModel!

        var tracker: MockTracker!
        var featureFlags: MockFeatureFlags!
        var myUserRepository: MockMyUserRepository!
        var userRepository: MockUserRepository!
        var listingRepository: MockListingRepository!
        var sessionManager: MockSessionManager!
        let user = MockUser.makeMock()
        let disposeBag = DisposeBag()

        describe("UserProfileViewModelSpec") {
            func buildPrivateUserProfileViewModel() {
                sut = UserProfileViewModel(sessionManager: sessionManager,
                                           myUserRepository: myUserRepository,
                                           userRepository: userRepository,
                                           listingRepository: listingRepository,
                                           tracker: tracker,
                                           featureFlags: featureFlags,
                                           notificationsManager: nil,
                                           user: nil,
                                           source: .tabBar,
                                           isPrivateProfile: true)

                sut.profileNavigator = self
                sut.delegate = self
            }

            func buildPublicUserProfileViewModel() {
                sut = UserProfileViewModel(sessionManager: sessionManager,
                                           myUserRepository: myUserRepository,
                                           userRepository: userRepository,
                                           listingRepository: listingRepository,
                                           tracker: tracker,
                                           featureFlags: featureFlags,
                                           notificationsManager: nil,
                                           user: user,
                                           source: .tabBar,
                                           isPrivateProfile: false)

                sut.navigator = self
                sut.delegate = self
            }

            beforeEach {
                sut = nil
                tracker = MockTracker()
                featureFlags = MockFeatureFlags()
                myUserRepository = MockMyUserRepository.makeMock()
                sessionManager = MockSessionManager()
                userRepository = MockUserRepository.makeMock()
                listingRepository = MockListingRepository.makeMock()

                self.openSettingsCalled = false
                self.openEditBioCalled = false
                self.openUserReportCalled = false
                self.openVerifyAccountsCalled = false
                self.openMostSearchedItemsCalled = false
                self.showAlertCalled = false
                self.showNativeShareCalled = false

                var myUser = MockMyUser.makeMock()
                myUser.name = "whatever"
                myUser.objectId = "12345"
                myUser.accounts = []
                myUser.type = .pro
                var file = MockFile.makeMock()
                file.fileURL = URL.makeRandom()
                myUser.avatar = file
                myUser.biography = "bio"
                myUser.ratingAverage = 1.2
                myUserRepository.myUserVar.value = myUser
            }

            context("Init with private profile") {
                beforeEach {
                    buildPrivateUserProfileViewModel()
                }

                it("is private profile") {
                    expect(sut.isPrivateProfile) == true
                }

                it ("is my user") {
                    expect(sut.isMyUser.value) == true
                }

                it ("username driver expose correct name") {
                    var result: String? = nil
                    sut.userName.drive(onNext: { (username) in
                        result = username
                    }).disposed(by: disposeBag)
                    expect(result).toEventuallyNot(beNil())
                    expect(result) == myUserRepository.myUser?.name
                }

                it ("userAvatarURL driver expose correct userAvatarURL") {
                    var result: URL? = nil
                    sut.userAvatarURL.drive(onNext: { (userAvatarURL) in
                        result = userAvatarURL
                    }).disposed(by: disposeBag)
                    expect(result).toEventuallyNot(beNil())
                    expect(result) == myUserRepository.myUser?.avatar?.fileURL
                }

                it ("userIsDummy driver expose correct type") {
                    var result: Bool? = nil
                    sut.userIsDummy.drive(onNext: { (userIsDummy) in
                        result = userIsDummy
                    }).disposed(by: disposeBag)
                    expect(result).toEventuallyNot(beNil())
                    expect(result) == false
                }

                it ("userLocation driver expose correct userLocation") {
                    var result: String? = nil
                    sut.userLocation.drive(onNext: { (userLocation) in
                        result = userLocation
                    }).disposed(by: disposeBag)
                    expect(result).toEventuallyNot(beNil())
                    expect(result) == myUserRepository.myUser?.postalAddress.cityStateString
                }

                it ("userAccounts driver expose correct userAccounts") {
                    var result: UserViewHeaderAccounts? = nil
                    sut.userAccounts.drive(onNext: { (userAccounts) in
                        result = userAccounts
                    }).disposed(by: disposeBag)
                    expect(result).toEventuallyNot(beNil())
                    expect(result?.facebookVerified) == false
                    expect(result?.googleVerified) == false
                    expect(result?.emailVerified) == false
                }

                it ("userRatingAverage driver expose correct userRatingAverage") {
                    var result: Float? = nil
                    sut.userRatingAverage.drive(onNext: { (userRatingAverage) in
                        result = userRatingAverage
                    }).disposed(by: disposeBag)
                    expect(result).toEventuallyNot(beNil())
                    expect(result) == myUserRepository.myUser?.ratingAverage
                }

                it ("userIsProfessional driver expose correct type") {
                    var result: Bool? = nil
                    sut.userIsProfessional.drive(onNext: { (userIsProfessional) in
                        result = userIsProfessional
                    }).disposed(by: disposeBag)
                    expect(result).toEventuallyNot(beNil())
                    expect(result) == true
                }

                it ("userBio driver exposes correct userBio") {
                    var result: String? = nil
                    sut.userBio.drive(onNext: { (userBio) in
                        result = userBio
                    }).disposed(by: disposeBag)
                    expect(result).toEventuallyNot(beNil())
                    expect(result) == "bio"
                }

                context("press settings button") {
                    beforeEach {
                        sut.didTapSettingsButton()
                    }
                    it("calls navigator to open settings") {
                        expect(self.openSettingsCalled) == true
                    }
                }

                context("press edit bio button") {
                    beforeEach {
                        sut.didTapEditBioButton()
                    }
                    it("calls navigator to open settings") {
                        expect(self.openEditBioCalled) == true
                    }
                }

                context("press report user button") {
                    beforeEach {
                        sut.didTapReportUserButton()
                    }
                    it("doesn't calls navigator to open user report") {
                        expect(self.openUserReportCalled) == true
                    }
                }

                context("open verify accounts") {
                    beforeEach {
                        sut.didTapBuildTrustButton()
                    }
                    it("calls navigator to open verify accounts") {
                        expect(self.openVerifyAccountsCalled) == true
                    }
                }

                context("open most searched items") {
                    beforeEach {
                        sut.didTapMostSearchedItems()
                    }
                    it("calls navigator to open most searched items") {
                        expect(self.openMostSearchedItemsCalled) == true
                    }
                }

                context("open push permission alert") {
                    beforeEach {
                        sut.didTapPushPermissionsBanner()
                    }
                    it("calls delegate to show push permission alert") {
                        expect(self.showAlertCalled) == true
                    }
                }
            }

            context("Init with public profile") {
                beforeEach {
                    buildPublicUserProfileViewModel()
                }

                it("is not private profile") {
                    expect(sut.isPrivateProfile) == false
                }

                it ("is not my user") {
                    expect(sut.isMyUser.value) == false
                }

                context("press settings button") {
                    beforeEach {
                        sut.didTapSettingsButton()
                    }
                    it("doesn't calls navigator to open settings") {
                        expect(self.openSettingsCalled) == false
                    }
                }

                context("press edit bio button") {
                    beforeEach {
                        sut.didTapEditBioButton()
                    }
                    it("doesn't calls navigator to open settings") {
                        expect(self.openEditBioCalled) == false
                    }
                }

                context("press report user button") {
                    beforeEach {
                        sut.didTapReportUserButton()
                    }
                    it("calls navigator to open report") {
                        expect(self.openUserReportCalled) == true
                    }
                }

                context("open verify accounts") {
                    beforeEach {
                        sut.didTapBuildTrustButton()
                    }
                    it("doesn't calls navigator to open verify accounts") {
                        expect(self.openVerifyAccountsCalled) == false
                    }
                }

                context("open most searched items") {
                    beforeEach {
                        sut.didTapMostSearchedItems()
                    }
                    it("calls navigator to open most searched items") {
                        expect(self.openMostSearchedItemsCalled) == true
                    }
                }

                context("open share") {
                    beforeEach {
                        sut.didTapShareButton()
                    }
                    it("calls navigator to open most searched items") {
                        expect(self.showNativeShareCalled) == true
                    }
                }

                context("open push permission alert") {
                    beforeEach {
                        sut.didTapPushPermissionsBanner()
                    }
                    it("calls delegate to show push permission alert") {
                        expect(self.showAlertCalled) == true
                    }
                }
            }
        }
    }

    func openSettings() {
        openSettingsCalled = true
    }

    func openEditUserBio() {
        openEditBioCalled = true
    }

    override func openVerifyAccounts(_ types: [VerificationType], source: VerifyAccountsSource, completionBlock: (() -> Void)?) {
        openVerifyAccountsCalled = true
    }

    override func openMostSearchedItems(source: PostingSource, enableSearch: Bool) {
        openMostSearchedItemsCalled = true
    }

    override func openUserReport(source: EventParameterTypePage, userReportedId: String) {
        openUserReportCalled = true
    }

    override func vmShowAlertWithTitle(_ title: String?, text: String, alertType: AlertType, actions: [UIAction]?) {
        showAlertCalled = true
    }

    func vmShowNativeShare(_ socialMessage: SocialMessage) {
        showNativeShareCalled = true
    }

    func editListing(_ listing: Listing, pageType: EventParameterTypePage?) {}
}
