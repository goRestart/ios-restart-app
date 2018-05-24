//
//  ListingViewModelSpec.swift
//  LetGo
//
//  Created by Eli Kohen on 06/02/2017.
//  Copyright © 2017 Ambatana. All rights reserved.
//

@testable import LetGoGodMode
import RxTest
import RxSwift
import LGCoreKit
import Quick
import Nimble
import LGComponents

class ListingViewModelSpec: BaseViewModelSpec {

    var selectBuyersCalled: Bool?
    var shownAlertText: String?
    var shownFavoriteBubble: Bool?
    var calledLogin: Bool?
    var calledOpenFreeBumpUpView: Bool?
    var calledOpenPricedBumpUpView: Bool?
    var calledOpenBumpUpBoostView: Bool?
    var listingViewModelDelegateListingOriginValue: ListingOrigin = ListingOrigin.initial

    override func spec() {
        var sut: ListingViewModel!

        var myUserRepository: MockMyUserRepository!
        var userRepository: MockUserRepository!
        var listingRepository: MockListingRepository!
        var chatWrapper: MockChatWrapper!
        var locationManager: MockLocationManager!
        var countryHelper: CountryHelper!
        var product: MockProduct!
        var source: LetGoGodMode.EventParameterListingVisitSource!
        var featureFlags: MockFeatureFlags!
        var purchasesShopper: MockPurchasesShopper!
        var monetizationRepository: MockMonetizationRepository!
        var tracker: MockTracker!
        var keyValueStorage: MockKeyValueStorage!

        var disposeBag: DisposeBag!
        var scheduler: TestScheduler!
        var bottomButtonsObserver: TestableObserver<[UIAction]>!
        var isFavoriteObserver: TestableObserver<Bool>!
        var directChatMessagesObserver: TestableObserver<[ChatViewMessage]>!
        var sellerObserver: TestableObserver<User?>!

        describe("ListingViewModelSpec") {

            func buildListingViewModel(visitSource: LetGoGodMode.EventParameterListingVisitSource = .listingList) {
                let socialSharer = SocialSharer()
                sut = ListingViewModel(listing: .product(product),
                                       visitSource: visitSource,
                                        myUserRepository: myUserRepository,
                                        userRepository: userRepository,
                                        listingRepository: listingRepository,
                                        chatWrapper: chatWrapper,
                                        chatViewMessageAdapter: ChatViewMessageAdapter(),
                                        locationManager: locationManager,
                                        countryHelper: countryHelper,
                                        socialSharer: socialSharer,
                                        featureFlags: featureFlags,
                                        purchasesShopper: purchasesShopper,
                                        monetizationRepository: monetizationRepository,
                                        tracker: tracker,
                                        keyValueStorage: keyValueStorage)
                sut.delegate = self
                sut.navigator = self
                disposeBag = DisposeBag()

                sut.actionButtons.asObservable().bind(to: bottomButtonsObserver).disposed(by: disposeBag)
                sut.isFavorite.asObservable().bind(to: isFavoriteObserver).disposed(by: disposeBag)
                sut.directChatMessages.observable.bind(to: directChatMessagesObserver).disposed(by: disposeBag)
                sut.seller.asObservable().bind(to: sellerObserver).disposed(by: disposeBag)
            }

            beforeEach {
                sut = nil
                myUserRepository = MockMyUserRepository.makeMock()
                userRepository = MockUserRepository.makeMock()
                listingRepository = MockListingRepository.makeMock()
                chatWrapper = MockChatWrapper()
                locationManager = MockLocationManager()
                countryHelper = CountryHelper.mock()
                product = MockProduct.makeMock()
                featureFlags = MockFeatureFlags()
                purchasesShopper = MockPurchasesShopper()
                monetizationRepository = MockMonetizationRepository()
                tracker = MockTracker()
                keyValueStorage = MockKeyValueStorage()

                scheduler = TestScheduler(initialClock: 0)
                scheduler.start()
                bottomButtonsObserver = scheduler.createObserver(Array<UIAction>.self)
                isFavoriteObserver = scheduler.createObserver(Bool.self)
                directChatMessagesObserver = scheduler.createObserver(Array<ChatViewMessage>.self)
                sellerObserver = scheduler.createObserver(User?.self)

                self.resetViewModelSpec()
            }
            afterEach {
                scheduler.stop()
                disposeBag = nil
            }
            describe("mark as sold") {
                beforeEach {
                    let myUser = MockMyUser.makeMock()
                    myUserRepository.myUserVar.value = myUser
                    product = MockProduct.makeMock()
                    var userProduct = MockUserListing.makeMock()
                    userProduct.objectId = myUser.objectId
                    product.user = userProduct
                    product.status = .approved

                    listingRepository.markAsSoldVoidResult = ListingVoidResult(Void())
                    var soldProduct = MockProduct(product: product)
                    soldProduct.status = .sold
                    listingRepository.markAsSoldResult = ListingResult(.product(soldProduct))
                }
                
                context("buyer selection enabled newMarkAsSoldFlow") {
                    beforeEach {
                        let userListing = MockUserListing.makeMock()
                        listingRepository.listingBuyersResult = ListingBuyersResult([userListing])
                        buildListingViewModel()
                        sut.active = true

                        // There should appear one button
                        expect(sut.actionButtons.value.count).toEventually(equal(1))
                        sut.actionButtons.value.first?.action()

                        expect(tracker.trackedEvents.count).toEventually(equal(1))
                    }
                    it("has mark as sold twice (button updates after user show request) and then sell it again button") {
                        let buttonTexts: [String] = bottomButtonsObserver.eventValues.flatMap { $0.first?.text }
                        expect(buttonTexts) == [R.Strings.productMarkAsSoldButton,
                                                R.Strings.productMarkAsSoldButton,
                                                R.Strings.productSellAgainButton]
                    }
                    it("requests buyer selection") {
                        expect(self.selectBuyersCalled).toEventually(beTrue())
                    }
                    it("has shown mark as sold alert") {
                        expect(self.shownAlertText!) == R.Strings.productMarkAsSoldAlertMessage
                    }
                    it("calls show loading in delegate") {
                        expect(self.delegateReceivedShowLoading) == true
                    }
                    it("calls hide loading in delegate") {
                        expect(self.delegateReceivedHideLoading).toEventually(beTrue())
                    }
                }
            }
            describe("favorite") {
                var savedProduct: MockProduct!
                beforeEach {
                    let myUser = MockMyUser.makeMock()
                    myUserRepository.myUserVar.value = myUser
                    product = MockProduct.makeMock()
                    product.status = .approved
                    savedProduct = MockProduct(product: product)
                    self.shownFavoriteBubble = false
                }
                describe("add to favorites") {
                    beforeEach {
                        listingRepository.productResult = ProductResult(savedProduct)
                        buildListingViewModel()
                        sut.switchFavorite()
                        expect(isFavoriteObserver.eventValues).toEventually(equal([false, true]))
                    }
                    it("shows bubble up") {
                        expect(self.shownFavoriteBubble) == true
                    }
                    it("favorite value is true") {
                        expect(isFavoriteObserver.lastValue) == true
                    }
                }

                describe("remove from favorites") {
                    beforeEach {
                        listingRepository.productResult = ProductResult(savedProduct)
                        buildListingViewModel()
                        sut.isFavorite.value = true
                        sut.switchFavorite()
                        expect(isFavoriteObserver.eventValues).toEventually(equal([false, true, false]))
                    }
                    it("does not show bubble up") {
                        expect(self.shownFavoriteBubble) == false
                    }
                    it("favorite value is true") {
                        expect(isFavoriteObserver.lastValue) == false
                    }
                }
            }
            describe("direct messages") {
                describe("quick answer") {
                    context("success first message") {
                        beforeEach {
                            chatWrapper.results = [ChatWrapperResult(true)]
                            buildListingViewModel()
                            sut.sendQuickAnswer(quickAnswer: .meetUp)

                            expect(tracker.trackedEvents.count).toEventually(equal(2))
                        }
                        it("requests logged in") {
                            expect(self.calledLogin) == true
                        }
                        it("adds one element on directMessages") {
                            expect(directChatMessagesObserver.lastValue?.map{ $0.value }) == [QuickAnswer.meetUp.textToReply]
                        }
                        it("tracks sent first message + message sent") {
                            expect(tracker.trackedEvents.map { $0.actualName }) == ["product-detail-ask-question", "user-sent-message"]
                        }
                        it("tracks visit source as product-list") {
                            let firstMessage: LetGoGodMode.TrackerEvent = tracker.trackedEvents.filter { $0.actualName == LetGoGodMode.EventName.firstMessage.rawValue }.first!
                            let visitSourceParam = firstMessage.params!.params[EventParameterName.listingVisitSource] as! String
                            expect(visitSourceParam).to(equal("product-list"))
                        }
                    }
                    context("success first message from favourites") {
                        beforeEach {
                            chatWrapper.results = [ChatWrapperResult(true)]
                            buildListingViewModel(visitSource: .favourite)
                            sut.sendQuickAnswer(quickAnswer: .meetUp)
                            
                            expect(tracker.trackedEvents.count).toEventually(equal(2))
                        }
                        it("requests logged in") {
                            expect(self.calledLogin) == true
                        }
                        it("adds one element on directMessages") {
                            expect(directChatMessagesObserver.lastValue?.map{ $0.value }) == [QuickAnswer.meetUp.textToReply]
                        }
                        it("tracks sent first message + message sent") {
                            expect(tracker.trackedEvents.map { $0.actualName }) == ["product-detail-ask-question", "user-sent-message"]
                        }
                        it("tracks visit source as favourite") {
                            let firstMessage: LetGoGodMode.TrackerEvent = tracker.trackedEvents.filter { $0.actualName == LetGoGodMode.EventName.firstMessage.rawValue }.first!
                            let visitSourceParam = firstMessage.params!.params[EventParameterName.listingVisitSource] as! String
                            expect(visitSourceParam).to(equal("favourite"))
                        }
                    }
                    context("success first message from favourites after swiping to the next listing") {
                        beforeEach {
                            chatWrapper.results = [ChatWrapperResult(true)]
                            buildListingViewModel(visitSource: .favourite)
                            self.listingViewModelDelegateListingOriginValue = .inResponseToNextRequest
                            sut.sendQuickAnswer(quickAnswer: .meetUp)
                            
                            expect(tracker.trackedEvents.count).toEventually(equal(2))
                        }
                        it("requests logged in") {
                            expect(self.calledLogin) == true
                        }
                        it("adds one element on directMessages") {
                            expect(directChatMessagesObserver.lastValue?.map{ $0.value }) == [QuickAnswer.meetUp.textToReply]
                        }
                        it("tracks sent first message + message sent") {
                            expect(tracker.trackedEvents.map { $0.actualName }) == ["product-detail-ask-question", "user-sent-message"]
                        }
                        it("tracks visit source as next-favourite") {
                            let firstMessage: LetGoGodMode.TrackerEvent = tracker.trackedEvents.filter { $0.actualName == LetGoGodMode.EventName.firstMessage.rawValue }.first!
                            let visitSourceParam = firstMessage.params!.params[EventParameterName.listingVisitSource] as! String
                            expect(visitSourceParam).to(equal("next-favourite"))
                        }
                    }
                    context("success first message from favourites after swiping to the previous listing") {
                        beforeEach {
                            chatWrapper.results = [ChatWrapperResult(true)]
                            buildListingViewModel(visitSource: .favourite)
                            self.listingViewModelDelegateListingOriginValue = .inResponseToPreviousRequest
                            sut.sendQuickAnswer(quickAnswer: .meetUp)
                            
                            expect(tracker.trackedEvents.count).toEventually(equal(2))
                        }
                        it("requests logged in") {
                            expect(self.calledLogin) == true
                        }
                        it("adds one element on directMessages") {
                            expect(directChatMessagesObserver.lastValue?.map{ $0.value }) == [QuickAnswer.meetUp.textToReply]
                        }
                        it("tracks sent first message + message sent") {
                            expect(tracker.trackedEvents.map { $0.actualName }) == ["product-detail-ask-question", "user-sent-message"]
                        }
                        it("tracks visit source as previous-favourite") {
                            let firstMessage: LetGoGodMode.TrackerEvent = tracker.trackedEvents.filter { $0.actualName == LetGoGodMode.EventName.firstMessage.rawValue }.first!
                            let visitSourceParam = firstMessage.params!.params[EventParameterName.listingVisitSource] as! String
                            expect(visitSourceParam).to(equal("previous-favourite"))
                        }
                    }
                    context("success non first message") {
                        beforeEach {
                            chatWrapper.results = [ChatWrapperResult(false)]
                            buildListingViewModel()
                            sut.sendQuickAnswer(quickAnswer: .meetUp)

                            expect(tracker.trackedEvents.count).toEventually(equal(1))
                        }
                        it("requests logged in") {
                            expect(self.calledLogin) == true
                        }
                        it("adds one element on directMessages") {
                            expect(directChatMessagesObserver.lastValue?.map{ $0.value }) == [QuickAnswer.meetUp.textToReply]
                        }
                        it("tracks sent first message + message sent") {
                            expect(tracker.trackedEvents.map { $0.actualName }) == ["user-sent-message"]
                        }
                    }
                    context("failure") {
                        beforeEach {
                            chatWrapper.results = [ChatWrapperResult(error: .notFound)]
                            buildListingViewModel()
                            sut.sendQuickAnswer(quickAnswer: .meetUp)
                        }
                        it("requests logged in") {
                            expect(self.calledLogin) == true
                        }
                        it("adds one element on directMessages") {
                            expect(directChatMessagesObserver.lastValue?.map{ $0.value }) == [QuickAnswer.meetUp.textToReply]
                        }
                        describe("failure arrives") {
                            beforeEach {
                                expect(self.delegateReceivedShowAutoFadingMessage).toEventually(equal(true))
                            }
                            it("element is removed from directMessages") {
                                expect(directChatMessagesObserver.lastValue?.count) == 0
                            }
                            it("tracks send message error") {
                                expect(tracker.trackedEvents.map { $0.actualName }) == ["user-sent-message-error"]
                            }
                        }
                    }
                }
                describe("text message") {
                    context("success first message") {
                        beforeEach {
                            chatWrapper.results = [ChatWrapperResult(true)]
                            buildListingViewModel()
                            sut.sendDirectMessage("Hola que tal", isDefaultText: false)

                            expect(tracker.trackedEvents.count).toEventually(equal(2))
                        }
                        it("requests logged in") {
                            expect(self.calledLogin) == true
                        }
                        it("adds one element on directMessages") {
                            expect(directChatMessagesObserver.lastValue?.map{ $0.value }) == ["Hola que tal"]
                        }
                        it("tracks sent first message + message sent") {
                            expect(tracker.trackedEvents.map { $0.actualName }) == ["product-detail-ask-question", "user-sent-message"]
                        }
                    }
                    context("success non first message") {
                        beforeEach {
                            chatWrapper.results = [ChatWrapperResult(false)]
                            buildListingViewModel()
                            sut.sendDirectMessage("Hola que tal", isDefaultText: true)

                            expect(tracker.trackedEvents.count).toEventually(equal(1))
                        }
                        it("requests logged in") {
                            expect(self.calledLogin) == true
                        }
                        it("adds one element on directMessages") {
                            expect(directChatMessagesObserver.lastValue?.map{ $0.value }) == ["Hola que tal"]
                        }
                        it("tracks sent first message + message sent") {
                            expect(tracker.trackedEvents.map { $0.actualName }) == ["user-sent-message"]
                        }
                    }
                    context("failure") {
                        beforeEach {
                            chatWrapper.results = [ChatWrapperResult(error: .notFound)]
                            buildListingViewModel()
                            sut.sendDirectMessage("Hola que tal", isDefaultText: true)
                        }
                        it("requests logged in") {
                            expect(self.calledLogin) == true
                        }
                        it("adds one element on directMessages") {
                            expect(directChatMessagesObserver.lastValue?.map{ $0.value }) == ["Hola que tal"]
                        }
                        describe("failure arrives") {
                            beforeEach {
                                expect(self.delegateReceivedShowAutoFadingMessage).toEventually(equal(true))
                            }
                            it("element is removed from directMessages") {
                                expect(directChatMessagesObserver.lastValue?.count) == 0
                            }
                            it("tracks send message error") {
                                expect(tracker.trackedEvents.map { $0.actualName }) == ["user-sent-message-error"]
                            }
                        }
                    }
                }
            }

            describe ("check user type") {
                var seller: User!
                context ("User is professional and has a phone number") {
                    beforeEach {
                        var user = MockUser.makeMock()
                        user.type = .pro
                        user.phone = "666-666-666"
                        seller = user
                        userRepository.userResult = UserResult(value: user)
                        buildListingViewModel()
                        sut.active = true
                        expect(sellerObserver.eventValues.map { $0?.objectId }).toEventually(equal([nil, user.objectId]))
                    }
                    it ("isProfessional var is updated") {
                        expect(sellerObserver.lastValue.map { $0!.objectId! }) == seller.objectId
                    }
                    it ("phoneNumber var has a value") {
                        expect(sut.seller.value?.phone).toEventually(equal("666-666-666"))
                    }
                }
                context ("User is professional and doesn't have a phone number") {
                    beforeEach {
                        var user = MockUser.makeMock()
                        user.type = .pro
                        user.phone = nil
                        seller = user
                        userRepository.userResult = UserResult(value: user)
                        buildListingViewModel()
                        sut.active = true
                        expect(sellerObserver.eventValues.map { $0?.objectId }).toEventually(equal([nil, user.objectId]))
                    }
                    it ("isProfessional var is updated") {
                         expect(sellerObserver.lastValue.map { $0!.objectId! }) == seller.objectId
                    }
                    it ("phoneNumber var has no value") {
                        expect(sut.seller.value?.phone).toEventually(beNil())
                    }
                }
                context ("User is not professional") {
                    beforeEach {
                        var user = MockUser.makeMock()
                        user.type = .user
                        seller = user
                        userRepository.userResult = UserResult(value: user)
                        buildListingViewModel()
                        sut.active = true
                        expect(sellerObserver.eventValues.map { $0?.objectId }).toEventually(equal([nil, user.objectId]))
                    }
                    it ("isProfessional var is updated") {
                        expect(sut.seller.value?.isProfessional).toEventually(equal(false))
                    }
                }
            }

            describe ("the right bump up banner appears") {
                context ("AB test are not active") {
                    beforeEach {
                        featureFlags.freeBumpUpEnabled = false
                        featureFlags.pricedBumpUpEnabled = false

                        let myUser = MockMyUser.makeMock()
                        myUserRepository.myUserVar.value = myUser
                        product = MockProduct.makeMock()
                        var userProduct = MockUserListing.makeMock()
                        userProduct.objectId = myUser.objectId
                        product.user = userProduct
                        product.status = .approved

                        purchasesShopper.isBumpUpPending = false

                        buildListingViewModel()
                        sut.active = true

                        expect(sut.bumpUpBannerInfo.value).toEventually(beNil())
                    }
                    it ("banner info is nil") {
                        expect(sut.bumpUpBannerInfo.value).to(beNil())
                    }
                }
                context ("AB tests active") {
                    beforeEach {
                        featureFlags.freeBumpUpEnabled = true
                        featureFlags.pricedBumpUpEnabled = true
                    }
                    context ("product is not mine") {
                        beforeEach {
                            var myUser = MockMyUser.makeMock()
                            myUser.objectId = "user_id"
                            myUserRepository.myUserVar.value = myUser
                            product = MockProduct.makeMock()
                            var userProduct = MockUserListing.makeMock()
                            userProduct.objectId = "product_id"
                            product.user = userProduct
                            product.status = .approved

                            purchasesShopper.isBumpUpPending = false

                            buildListingViewModel()
                            sut.active = true

                            expect(sut.bumpUpBannerInfo.value).toEventually(beNil())
                        }
                        it ("banner info is nil") {
                            expect(sut.bumpUpBannerInfo.value).to(beNil())
                        }
                    }
                    context ("product is mine") {
                        context ("product status makes it not bumpeable") {
                            beforeEach {
                                let myUser = MockMyUser.makeMock()
                                myUserRepository.myUserVar.value = myUser
                                product = MockProduct.makeMock()
                                var userProduct = MockUserListing.makeMock()
                                userProduct.objectId = myUser.objectId
                                product.user = userProduct
                                product.featured = false
                                product.status = .deleted
                                purchasesShopper.isBumpUpPending = false

                                buildListingViewModel()
                                sut.active = true

                                expect(sut.bumpUpBannerInfo.value).toEventually(beNil())
                            }
                            it ("banner info is nil") {
                                expect(sut.bumpUpBannerInfo.value).to(beNil())
                            }
                        }
                        context ("product status is pending, and is already bumped") {
                            beforeEach {

                                self.calledOpenFreeBumpUpView = false
                                let myUser = MockMyUser.makeMock()
                                myUserRepository.myUserVar.value = myUser
                                product = MockProduct.makeMock()
                                var userProduct = MockUserListing.makeMock()
                                userProduct.objectId = myUser.objectId
                                product.user = userProduct
                                product.status = .pending
                                product.featured = true

                                purchasesShopper.isBumpUpPending = false

                                var paymentItem = MockPaymentItem.makeMock()
                                paymentItem.provider = .apple
                                var bumpeableProduct = MockBumpeableListing.makeMock()
                                bumpeableProduct.paymentItems = [paymentItem]
                                monetizationRepository.retrieveResult = BumpeableListingResult(value: bumpeableProduct)

                                buildListingViewModel()
                                sut.active = true

                                expect(sut.bumpUpBannerInfo.value).toEventuallyNot(beNil())
                            }
                            it ("banner info type is priced") {
                                expect(sut.bumpUpBannerInfo.value?.type) == .priced
                            }
                            it ("banner interaction block opens priced bump up view") {
                                sut.bumpUpBannerInfo.value?.bannerInteractionBlock(0)
                                expect(self.calledOpenPricedBumpUpView).toEventually(beTrue())
                            }
                            it ("banner button block tries to bump up the product") {
                                // "tries to" because the result of the bump up feature is tested in another context
                                sut.bumpUpBannerInfo.value?.buttonBlock(0)
                                expect(self.delegateReceivedShowLoading).toEventually(beTrue())
                            }
                        }
                        context ("product status makes it bumpeable") {
                            context ("retrieve products request fails") {
                                beforeEach {

                                    self.calledOpenFreeBumpUpView = false
                                    let myUser = MockMyUser.makeMock()
                                    myUserRepository.myUserVar.value = myUser
                                    product = MockProduct.makeMock()
                                    var userProduct = MockUserListing.makeMock()
                                    userProduct.objectId = myUser.objectId
                                    product.user = userProduct
                                    product.status = .approved

                                    purchasesShopper.isBumpUpPending = false

                                    var paymentItem = MockPaymentItem.makeMock()
                                    paymentItem.provider = .letgo
                                    var bumpeableProduct = MockBumpeableListing.makeMock()
                                    bumpeableProduct.paymentItems = [paymentItem]
                                    monetizationRepository.retrieveResult = BumpeableListingResult(error: .notFound)

                                    buildListingViewModel()
                                    sut.active = true

                                    expect(sut.bumpUpBannerInfo.value).toEventually(beNil())
                                }
                                it ("banner info is nil") {
                                    expect(sut.bumpUpBannerInfo.value).to(beNil())
                                }
                            }
                            context ("retrieve products response 'paymentItems' is empty") {
                                beforeEach {

                                    self.calledOpenFreeBumpUpView = false
                                    let myUser = MockMyUser.makeMock()
                                    myUserRepository.myUserVar.value = myUser
                                    product = MockProduct.makeMock()
                                    var userProduct = MockUserListing.makeMock()
                                    userProduct.objectId = myUser.objectId
                                    product.user = userProduct
                                    product.status = .approved

                                    purchasesShopper.isBumpUpPending = false

                                    var bumpeableProduct = MockBumpeableListing.makeMock()
                                    bumpeableProduct.paymentItems = []
                                    monetizationRepository.retrieveResult = BumpeableListingResult(value: bumpeableProduct)

                                    buildListingViewModel()
                                    sut.active = true

                                    expect(sut.bumpUpBannerInfo.value).toEventually(beNil())
                                }
                                it ("banner info is nil") {
                                    expect(sut.bumpUpBannerInfo.value).to(beNil())
                                }
                            }
                            context ("free bump") {
                                beforeEach {

                                    self.calledOpenFreeBumpUpView = false
                                    let myUser = MockMyUser.makeMock()
                                    myUserRepository.myUserVar.value = myUser
                                    product = MockProduct.makeMock()
                                    var userProduct = MockUserListing.makeMock()
                                    userProduct.objectId = myUser.objectId
                                    product.user = userProduct
                                    product.status = .approved

                                    purchasesShopper.isBumpUpPending = false

                                    var paymentItem = MockPaymentItem.makeMock()
                                    paymentItem.provider = .letgo
                                    var bumpeableProduct = MockBumpeableListing.makeMock()
                                    bumpeableProduct.paymentItems = [paymentItem]
                                    monetizationRepository.retrieveResult = BumpeableListingResult(value: bumpeableProduct)

                                    buildListingViewModel()
                                    sut.active = true

                                    expect(sut.bumpUpBannerInfo.value).toEventuallyNot(beNil())
                                }
                                it ("banner info type is free") {
                                    expect(sut.bumpUpBannerInfo.value?.type) == .free
                                }
                                it ("banner interaction block opens free bump up view") {
                                    sut.bumpUpBannerInfo.value?.bannerInteractionBlock(0)
                                    expect(self.calledOpenFreeBumpUpView).toEventually(beTrue())
                                }
                                it ("banner button block open free bump up view") {
                                    sut.bumpUpBannerInfo.value?.buttonBlock(0)
                                    expect(self.calledOpenFreeBumpUpView).toEventually(beTrue())
                                }
                            }
                            context ("priced bump, new item") {
                                beforeEach {

                                    self.calledOpenFreeBumpUpView = false
                                    let myUser = MockMyUser.makeMock()
                                    myUserRepository.myUserVar.value = myUser
                                    product = MockProduct.makeMock()
                                    var userProduct = MockUserListing.makeMock()
                                    userProduct.objectId = myUser.objectId
                                    product.user = userProduct
                                    product.status = .approved

                                    purchasesShopper.isBumpUpPending = false

                                    var paymentItem = MockPaymentItem.makeMock()
                                    paymentItem.provider = .apple
                                    var bumpeableProduct = MockBumpeableListing.makeMock()
                                    bumpeableProduct.paymentItems = [paymentItem]
                                    monetizationRepository.retrieveResult = BumpeableListingResult(value: bumpeableProduct)

                                    buildListingViewModel()
                                    sut.active = true

                                    expect(sut.bumpUpBannerInfo.value).toEventuallyNot(beNil())
                                }
                                it ("banner info type is priced") {
                                    expect(sut.bumpUpBannerInfo.value?.type) == .priced
                                }
                                it ("banner interaction block opens priced bump up view") {
                                    sut.bumpUpBannerInfo.value?.bannerInteractionBlock(0)
                                    expect(self.calledOpenPricedBumpUpView).toEventually(beTrue())
                                }
                                it ("banner button block tries to bump up the product") {
                                    // "tries to" because the result of the bump up feature is tested in another context
                                    sut.bumpUpBannerInfo.value?.buttonBlock(0)
                                    expect(self.delegateReceivedShowLoading).toEventually(beTrue())
                                }
                            }
                            context ("priced bump, restore item") {
                                beforeEach {

                                    self.calledOpenFreeBumpUpView = false
                                    let myUser = MockMyUser.makeMock()
                                    myUserRepository.myUserVar.value = myUser
                                    product = MockProduct.makeMock()
                                    var userProduct = MockUserListing.makeMock()
                                    userProduct.objectId = myUser.objectId
                                    product.user = userProduct
                                    product.status = .approved

                                    purchasesShopper.isBumpUpPending = true

                                    var paymentItem = MockPaymentItem.makeMock()
                                    paymentItem.provider = .apple
                                    var bumpeableProduct = MockBumpeableListing.makeMock()
                                    bumpeableProduct.paymentItems = [paymentItem]
                                    monetizationRepository.retrieveResult = BumpeableListingResult(value: bumpeableProduct)

                                    buildListingViewModel()
                                    sut.active = true

                                    expect(sut.bumpUpBannerInfo.value).toEventuallyNot(beNil())
                                }
                                it ("banner info type is restore") {
                                    expect(sut.bumpUpBannerInfo.value?.type) == .restore
                                }
                                it ("banner interaction block tres to restore the bump") {
                                    // "tries to" because the result of the bump up feature is tested in another context
                                    sut.bumpUpBannerInfo.value?.bannerInteractionBlock(0)
                                    expect(self.delegateReceivedShowLoading).toEventually(beTrue())
                                }
                                it ("banner button block tries to restore the bump") {
                                    // "tries to" because the result of the bump up feature is tested in another context
                                    sut.bumpUpBannerInfo.value?.buttonBlock(0)
                                    expect(self.delegateReceivedShowLoading).toEventually(beTrue())
                                }
                            }
                        }
                    }
                }
            }

            describe("priced bump up product") {
                beforeEach {
                    featureFlags.pricedBumpUpEnabled = true
                    let myUser = MockMyUser.makeMock()
                    myUserRepository.myUserVar.value = myUser
                    product = MockProduct.makeMock()
                    product.objectId = "product_id"
                    var userProduct = MockUserListing.makeMock()
                    userProduct.objectId = myUser.objectId
                    product.user = userProduct
                    product.status = .approved

                    var paymentItem = MockPaymentItem.makeMock()
                    paymentItem.provider = .apple
                    paymentItem.itemId = "paymentItemId"
                    var bumpeableProduct = MockBumpeableListing.makeMock()
                    bumpeableProduct.paymentItems = [paymentItem]
                    monetizationRepository.retrieveResult = BumpeableListingResult(value: bumpeableProduct)
                }
                context ("appstore payment fails") {
                    beforeEach {
                        purchasesShopper.paymentSucceeds = false

                        buildListingViewModel()
                        sut.active = true

                        expect(sut.bumpUpPurchaseableProduct).toEventuallyNot(beNil())
                        sut.bumpUpProduct(productId: product.objectId!, isBoost: false)
                    }
                    it ("transaction finishes with payment failed") {
                        expect(self.lastLoadingMessageShown).toEventually(equal(R.Strings.bumpUpErrorPaymentFailed))
                    }
                }
                context ("appstore payment succeeds but bump fails") {
                    beforeEach {
                        purchasesShopper.paymentSucceeds = true
                        purchasesShopper.pricedBumpSucceeds = false

                        buildListingViewModel()
                        sut.active = true

                        expect(sut.bumpUpPurchaseableProduct).toEventuallyNot(beNil())
                        sut.bumpUpProduct(productId: product.objectId!, isBoost: false)
                    }
                    it ("transaction finishes with bump failed") {
                        expect(self.lastLoadingMessageShown).toEventually(equal(R.Strings.bumpUpErrorBumpGeneric))
                    }
                }
                context ("appstore payment and bump succeed") {
                    beforeEach {
                        purchasesShopper.paymentSucceeds = true
                        purchasesShopper.pricedBumpSucceeds = true

                        buildListingViewModel()
                        sut.active = true

                        expect(sut.bumpUpPurchaseableProduct).toEventuallyNot(beNil())
                        sut.bumpUpProduct(productId: product.objectId!, isBoost: false)
                    }
                    it ("transaction finishes with bump suceeded") {
                        expect(self.lastLoadingMessageShown).toEventually(equal(R.Strings.bumpUpPaySuccess))
                    }
                }
            }
        }
    }

    override func resetViewModelSpec() {
        super.resetViewModelSpec()
        shownAlertText = nil
        selectBuyersCalled = false
        calledLogin = nil
        
    }

    override func vmShowAlert(_ title: String?, message: String?, cancelLabel: String, actions: [UIAction]) {
        shownAlertText = message
        DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(50)) {
            actions.last?.action()
        }
    }
}

extension ListingViewModelSpec: ListingViewModelDelegate {

    func vmOpenMainSignUp(_ signUpVM: SignUpViewModel, afterLoginAction: @escaping () -> ()) {}

    func vmOpenStickersSelector(_ stickers: [Sticker]) {}

    func vmAskForRating() {}
    func vmShowOnboarding() {}
    func vmShowProductDetailOptions(_ cancelLabel: String, actions: [UIAction]) {}

    func vmShareDidFailedWith(_ error: String) {}
    func vmShareViewControllerAndItem() -> (UIViewController, UIBarButtonItem?) {
        return (UIViewController(), nil)
    }

    var trackingFeedPosition: LetGoGodMode.EventParameterFeedPosition {
        return .none
    }

    var listingOrigin: ListingOrigin {
        return listingViewModelDelegateListingOriginValue
    }
    
    // Bump Up
    func vmResetBumpUpBannerCountdown() {}
}

extension ListingViewModelSpec: ListingDetailNavigator {
    func openVideoPlayer(atIndex index: Int,
                         listingVM: ListingViewModel,
                         source: LetGoGodMode.EventParameterListingVisitSource) {

    }


    func closeProductDetail() {

    }
    func editListing(_ listing: Listing,
                     bumpUpProductData: BumpUpProductData?,
                     listingCanBeBoosted: Bool,
                     timeSinceLastBump: TimeInterval?,
                     maxCountdown: TimeInterval) {

    }
    func openListingChat(_ listing: Listing, source: LetGoGodMode.EventParameterTypePage, interlocutor: User?) {

    }
    func closeListingAfterDelete(_ listing: Listing) {
        
    }
    func openFreeBumpUp(forListing listing: Listing,
                        bumpUpProductData: BumpUpProductData,
                        typePage: LetGoGodMode.EventParameterTypePage?,
                        maxCountdown: TimeInterval) {
        calledOpenFreeBumpUpView = true
    }
    func openPayBumpUp(forListing listing: Listing,
                       bumpUpProductData: BumpUpProductData,
                       typePage: LetGoGodMode.EventParameterTypePage?,
                       maxCountdown: TimeInterval) {
        calledOpenPricedBumpUpView = true
    }
    func openBumpUpBoost(forListing listing: Listing,
                         bumpUpProductData: BumpUpProductData,
                         typePage: LetGoGodMode.EventParameterTypePage?,
                         timeSinceLastBump: TimeInterval,
                         maxCountdown: TimeInterval) {
        calledOpenBumpUpBoostView = true
    }
    func selectBuyerToRate(source: RateUserSource,
                           buyers: [UserListing],
                           listingId: String,
                           sourceRateBuyers: SourceRateBuyers?,
                           trackingInfo: LetGoGodMode.MarkAsSoldTrackingInfo) {
        self.selectBuyersCalled = true
    }
    func showProductFavoriteBubble(with data: BubbleNotificationData) {
        shownFavoriteBubble = true
    }
    func openLoginIfNeededFromProductDetail(from: LetGoGodMode.EventParameterLoginSourceValue, infoMessage: String,
                                            loggedInAction: @escaping (() -> Void)) {
        calledLogin = true
        loggedInAction()
    }
    func showBumpUpNotAvailableAlertWithTitle(title: String,
                                              text: String,
                                              alertType: AlertType,
                                              buttonsLayout: AlertButtonsLayout,
                                              actions: [UIAction]) {

    }

    func showBumpUpBoostSucceededAlert() {

    }

    func openContactUs(forListing listing: Listing, contactUstype: ContactUsType) {

    }

    func openFeaturedInfo() {

    }

    func closeFeaturedInfo() {

    }

    func openAskPhoneFor(listing: Listing, interlocutor: User?) {

    }

    func closeAskPhoneFor(listing: Listing, openChat: Bool, withPhoneNum: String?, source: LetGoGodMode.EventParameterTypePage,
                          interlocutor: User?) {

    }
}
