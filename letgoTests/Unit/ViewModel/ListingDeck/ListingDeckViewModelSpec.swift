//
//  ListingDeckViewModelSpec.swift
//  LetGo
//
//  Created by Facundo Menzella on 02/11/2017.
//  Copyright © 2017 Ambatana. All rights reserved.
//

@testable import LetGoGodMode
import RxTest
import RxSwift
import LGCoreKit
import Quick
import Nimble


class ListingDeckViewModelSpec: BaseViewModelSpec {

    override func spec() {
        var sut: ListingDeckViewModel!

        var listingViewModelMaker: MockListingViewModelMaker!
        var listingListRequester: MockListingListRequester!
        var imageDownloader: MockImageDownloader!

        var myUserRepository: MockMyUserRepository!
        var listingRepository: MockListingRepository!
        var chatWrapper: MockChatWrapper!
        var locationManager: MockLocationManager!
        var countryHelper: CountryHelper!
        var product: MockProduct!
        var featureFlags: MockFeatureFlags!
        var purchasesShopper: MockPurchasesShopper!
        var notificationsManager: MockNotificationsManager!
        var monetizationRepository: MockMonetizationRepository!
        var tracker: MockTracker!

        var disposeBag: DisposeBag!
        var scheduler: TestScheduler!

        var cellModelsObserver: TestableObserver<[ListingViewModel]>!
        var navBarButtonsObserver: TestableObserver<[UIAction]>!
        var actionButtonsObserver: TestableObserver<[UIAction]>!
        var quickAnswersObserver: TestableObserver<[[QuickAnswer]]>!
        var quickAnswersAvailableObserver: TestableObserver<Bool>!
        var directChatEnabledObserver: TestableObserver<Bool>!
        var directChatPlaceholderObserver: TestableObserver<String>!
        var directChatMessagesObserver: TestableObserver<[ChatViewMessage]>!
        var bumpUpBannerInfoObserver: TestableObserver<BumpUpInfo?>!

        describe("ListingDeckViewModelSpec") {

            func startObserving() {
                disposeBag = DisposeBag()

                sut.objects.observable.bind(to:cellModelsObserver).disposed(by:disposeBag)
                sut.navBarButtons.asObservable().bind(to:navBarButtonsObserver).disposed(by:disposeBag)
                sut.actionButtons.asObservable().bind(to:actionButtonsObserver).disposed(by:disposeBag)
                sut.quickChatViewModel.quickAnswers.asObservable().bind(to:quickAnswersObserver).disposed(by:disposeBag)

                sut.quickChatViewModel.chatEnabled.asObservable().bind(to:quickAnswersAvailableObserver).disposed(by:disposeBag)
                sut.quickChatViewModel.chatEnabled.asObservable().bind(to:directChatEnabledObserver).disposed(by:disposeBag)
                sut.quickChatViewModel.directChatPlaceholder.asObservable().bind(to:directChatPlaceholderObserver).disposed(by:disposeBag)
                sut.quickChatViewModel.directChatMessages.observable.bind(to:directChatMessagesObserver).disposed(by:disposeBag)
                sut.bumpUpBannerInfo.asObservable().bind(to:bumpUpBannerInfoObserver).disposed(by:disposeBag)
            }

            func buildSut(productListModels: [ListingCellModel]? = nil,
                          initialProduct: Product? = nil,
                          source: EventParameterListingVisitSource = .listingList,
                          actionOnFirstAppear: ProductCarouselActionOnFirstAppear = .nonexistent,
                          trackingIndex: Int? = nil,
                          firstProductSyncRequired: Bool = false) {

                var initialListing: Listing? = nil
                if let initialProduct = initialProduct {
                    initialListing = .product(initialProduct)
                }

                sut = ListingDeckViewModel(productListModels: productListModels,
                                           initialListing: initialListing,
                                           listingListRequester: listingListRequester,
                                           detailNavigator: self,
                                           source: source,
                                           imageDownloader: imageDownloader,
                                           listingViewModelMaker: listingViewModelMaker,
                                           shouldSyncFirstListing: firstProductSyncRequired,
                                           binder: ListingDeckViewModelBinder())

                sut.delegate = self
            }

            beforeEach {
                myUserRepository = MockMyUserRepository.makeMock()
                listingRepository = MockListingRepository.makeMock()
                chatWrapper = MockChatWrapper()
                locationManager = MockLocationManager()
                countryHelper = CountryHelper.mock()
                product = MockProduct.makeMock()
                featureFlags = MockFeatureFlags()
                purchasesShopper = MockPurchasesShopper()
                notificationsManager = MockNotificationsManager()
                monetizationRepository = MockMonetizationRepository.makeMock()
                tracker = MockTracker()

                listingListRequester = MockListingListRequester(canRetrieve: true, offset: 0, pageSize: 20)
                imageDownloader = MockImageDownloader()

                listingViewModelMaker = MockListingViewModelMaker(myUserRepository: myUserRepository,
                                                                  listingRepository: listingRepository,
                                                                  chatWrapper: chatWrapper,
                                                                  locationManager: locationManager,
                                                                  countryHelper: countryHelper,
                                                                  featureFlags: featureFlags,
                                                                  purchasesShopper: purchasesShopper,
                                                                  monetizationRepository: monetizationRepository,
                                                                  tracker: tracker)

                scheduler = TestScheduler(initialClock: 0)
                scheduler.start()
                cellModelsObserver = scheduler.createObserver(Array<ListingViewModel>.self)
                navBarButtonsObserver = scheduler.createObserver(Array<UIAction>.self)
                actionButtonsObserver = scheduler.createObserver(Array<UIAction>.self)
                quickAnswersObserver = scheduler.createObserver(Array<Array<QuickAnswer>>.self)
                quickAnswersAvailableObserver = scheduler.createObserver(Bool.self)
                directChatEnabledObserver = scheduler.createObserver(Bool.self)
                directChatPlaceholderObserver = scheduler.createObserver(String.self)
                directChatMessagesObserver = scheduler.createObserver(Array<ChatViewMessage>.self)
                bumpUpBannerInfoObserver = scheduler.createObserver(Optional<BumpUpInfo>.self)

                self.resetViewModelSpec()
            }
            afterEach {
                scheduler.stop()
                disposeBag = nil
            }
            describe("A user that opens the deck") {
                context("The first product he sees") {
                    beforeEach {
                        let myUser = MockMyUser.makeMock()
                        myUserRepository.myUserVar.value = myUser
                        var productUser = MockUserListing.makeMock()
                        productUser.objectId = myUser.objectId
                        product.user = productUser
                        product.status = .approved
                        buildSut(initialProduct: product)
                        sut.active = true
                        startObserving()
                        it("Is the initial product") {
                            expect(sut.currentListingViewModel?.listing.value.objectId).toEventually(equal(product.objectId))
                        }
                    }
                }
                context("The viewmodel becomes active") {
                    beforeEach {
                        let myUser = MockMyUser.makeMock()
                        myUserRepository.myUserVar.value = myUser
                        var productUser = MockUserListing.makeMock()
                        productUser.objectId = myUser.objectId
                        product.user = productUser
                        product.status = .approved
                        buildSut(initialProduct: product)
                        sut.active = true
                        startObserving()
                        it("the initial product is properly exposed") {
                            let objectId = sut.currentListingViewModel?.listing.value.objectId
                            let viewModelObjectId = sut.viewModelFor(listing: .product(product))?.listing.value.objectId
                            expect(objectId).toEventually(equal(viewModelObjectId))
                        }
                    }
                }
            }
            describe("quick answers") {
                describe("ab test non-dynamic") {
                    beforeEach {
                        featureFlags.dynamicQuickAnswers = .control
                    }
                    context("product is mine and available") {
                        beforeEach {
                            let myUser = MockMyUser.makeMock()
                            myUserRepository.myUserVar.value = myUser
                            var productUser = MockUserListing.makeMock()
                            productUser.objectId = myUser.objectId
                            product.user = productUser
                            product.status = .approved
                            buildSut(initialProduct: product)
                            sut.active = true
                            startObserving()
                        }
                        it("quick answers are not available") {
                            expect(quickAnswersAvailableObserver.eventValues) == [false] //first product
                        }
                        it("quickAnswers are empty") {
                            expect(quickAnswersObserver.eventValues.map { $0.isEmpty }) == [true] //first product
                        }
                    }
                    context("product is not mine and available") {
                        context("non free product") {
                            beforeEach {
                                let myUser = MockMyUser.makeMock()
                                myUserRepository.myUserVar.value = myUser
                                product.status = .approved
                                product.price = .normal(25)
                                buildSut(initialProduct: product)
                                sut.active = true
                                startObserving()
                            }
                            it("quick answers are available") {
                                expect(quickAnswersAvailableObserver.eventValues) == [true] //first product
                            }
                            it("receives 3 groups of quick answers") {
                                expect(quickAnswersObserver.lastValue?.count) == 3
                            }
                            it("matches first group with the right availability quick answers") {
                                expect(quickAnswersObserver.lastValue?[0]) == [.stillAvailable]
                            }
                            it("matches second group with the right negotiable quick answers") {
                                expect(quickAnswersObserver.lastValue?[1]) == [.isNegotiable]
                            }
                            it("matches third group with the right condition quick answers") {
                                expect(quickAnswersObserver.lastValue?[2]) == [.listingCondition]
                            }
                        }
                        context("free product") {
                            beforeEach {
                                let myUser = MockMyUser.makeMock()
                                myUserRepository.myUserVar.value = myUser
                                product.status = .approved
                                product.price = .free
                                featureFlags.freePostingModeAllowed = true
                                buildSut(initialProduct: product)
                                sut.active = true
                                startObserving()
                            }
                            it("quick answers are available") {
                                expect(quickAnswersAvailableObserver.eventValues) == [true] //first product
                            }
                            it("receives 3 groups of quick answers") {
                                expect(quickAnswersObserver.lastValue?.count) == 3
                            }
                            it("matches first group with the right interested quick answers") {
                                expect(quickAnswersObserver.lastValue?[0]) == [.interested]
                            }
                            it("matches second group with the right meet up quick answers") {
                                expect(quickAnswersObserver.lastValue?[1]) == [.meetUp]
                            }
                            it("matches third group with the right condition quick answers") {
                                expect(quickAnswersObserver.lastValue?[2]) == [.listingCondition]
                            }
                        }
                    }
                }

                describe("ab test dynamic") {
                    beforeEach {
                        featureFlags.dynamicQuickAnswers = .dynamicNoKeyboard
                    }
                    context("product is mine and available") {
                        beforeEach {
                            let myUser = MockMyUser.makeMock()
                            myUserRepository.myUserVar.value = myUser
                            var productUser = MockUserListing.makeMock()
                            productUser.objectId = myUser.objectId
                            product.user = productUser
                            product.status = .approved
                            buildSut(initialProduct: product)
                            sut.active = true
                            startObserving()
                        }
                        it("quick answers are not available") {
                            expect(quickAnswersAvailableObserver.eventValues) == [false] //first product
                        }
                        it("quickAnswers are empty") {
                            expect(quickAnswersObserver.eventValues.map { $0.isEmpty }) == [true] //first product
                        }
                    }
                    context("product is not mine and available") {
                        context("non free product") {
                            beforeEach {
                                let myUser = MockMyUser.makeMock()
                                myUserRepository.myUserVar.value = myUser
                                product.status = .approved
                                product.price = .normal(25)
                                buildSut(initialProduct: product)
                                sut.active = true
                                startObserving()
                            }
                            it("quick answers are available") {
                                expect(quickAnswersAvailableObserver.eventValues) == [true] //first product
                            }
                            it("receives 4 groups of quick answers") {
                                expect(quickAnswersObserver.lastValue?.count) == 4
                            }
                            it("matches first group with the right availability quick answers") {
                                expect(quickAnswersObserver.lastValue?[0]) == [.stillAvailable, .stillForSale, .freeStillHave]
                            }
                            it("matches second group with the right meet up quick answers") {
                                expect(quickAnswersObserver.lastValue?[1]) == [.meetUp, .meetUpLocated, .meetUpWhereYouWant]
                            }
                            it("matches third group with the right condition quick answers") {
                                expect(quickAnswersObserver.lastValue?[2]) == [.listingCondition, .listingConditionGood, .listingConditionDescribe]
                            }
                            it("matches fourth group with the right price quick answers") {
                                expect(quickAnswersObserver.lastValue?[3]) == [.isNegotiable, .priceFirm, .priceWillingToNegotiate]
                            }
                        }
                        context("free product") {
                            beforeEach {
                                let myUser = MockMyUser.makeMock()
                                myUserRepository.myUserVar.value = myUser
                                product.status = .approved
                                product.price = .free
                                featureFlags.freePostingModeAllowed = true
                                buildSut(initialProduct: product)
                                sut.active = true
                                startObserving()
                            }
                            it("quick answers are available") {
                                expect(quickAnswersAvailableObserver.eventValues) == [true] //first product
                            }
                            it("receives 3 groups of quick answers") {
                                expect(quickAnswersObserver.lastValue?.count) == 3
                            }
                            it("matches first group with the right availability quick answers") {
                                expect(quickAnswersObserver.lastValue?[0]) == [.stillAvailable, .freeStillHave]
                            }
                            it("matches second group with the right meet up quick answers") {
                                expect(quickAnswersObserver.lastValue?[1]) == [.meetUp, .meetUpLocated, .meetUpWhereYouWant]
                            }
                            it("matches third group with the right condition quick answers") {
                                expect(quickAnswersObserver.lastValue?[2]) == [.listingCondition, .listingConditionGood, .listingConditionDescribe]
                            }
                        }
                    }
                }
            }
            describe("pagination") {
                context("single item") {
                    beforeEach {
                        listingListRequester.generateItems(30)
                        buildSut(initialProduct: product)
                        sut.active = true
                        startObserving()
                    }
                    it("items count automatically becomes 21") {
                        expect(sut.objectCount).toEventually(equal(21))
                    }
                }
                context("multiple items") {
                    context("item before the threshold") {
                        beforeEach {
                            var products = MockProduct.makeMocks(count: 20)
                            products[0] = product
                            let productListModels = products.map { ListingCellModel.listingCell(listing: .product($0)) }
                            listingListRequester.generateItems(30)
                            buildSut(productListModels: productListModels, initialProduct: product)
                            sut.active = true
                            startObserving()
                        }
                        it("doesn't paginate initially") {
                            expect(sut.objectCount).toNot(beGreaterThan(20))
                        }
                        describe("switch to item after threshold") {
                            beforeEach {
                                sut.moveToProductAtIndex(18, movement: .swipeRight)
                            }
                            it("gets one extra page") {
                                expect(sut.objectCount).toEventually(equal(40))
                            }
                        }
                    }
                    context("item after the threshold") {
                        beforeEach {
                            var products = MockProduct.makeMocks(count: 20)
                            products[18] = product
                            let productListModels = products.map { ListingCellModel.listingCell(listing: .product($0)) }
                            listingListRequester.generateItems(30)
                            buildSut(productListModels: productListModels, initialProduct: product)
                            sut.active = true
                            startObserving()
                        }
                        it("paginates initially") {
                            expect(sut.objectCount).toEventually(equal(40))
                        }
                    }
                }
                context("long pagination") {
                    beforeEach {
                        //Simulating that we're on page 8-10
                        var products = MockProduct.makeMocks(count: 180)
                        products[160] = product
                        listingListRequester.generateItems(200)
                        listingListRequester.offset = 180
                        let productListModels = products.map { ListingCellModel.listingCell(listing: .product($0)) }
                        buildSut(productListModels: productListModels, initialProduct: product)
                        sut.active = true
                        startObserving()
                    }
                    describe("move to item before threshold") {
                        beforeEach {
                            sut.moveToProductAtIndex(172, movement: .swipeRight)
                        }
                        it("doesn't paginate") {
                            expect(sut.objectCount).toNot(beGreaterThan(180))
                        }
                    }
                    describe("move to item after threshold") {
                        beforeEach {
                            sut.moveToProductAtIndex(178, movement: .swipeRight)
                        }
                        it("paginates") {
                            expect(sut.objectCount).toEventually(equal(200))
                        }
                    }
                }
            }
            describe("products navigation") {
                describe("image pre-caching") {
                    var products: [MockProduct]!
                    beforeEach {
                        products = MockProduct.makeMocks(count: 20)
                        for i in 0..<products.count {
                            var product = products[i]
                            var image = MockFile.makeMock()
                            image.fileURL = URL.makeRandom()
                            product.images = [image]
                            products[i] = product
                        }
                    }
                    context("first item is 0") {
                        beforeEach {
                            product = products[0]
                            let productListModels = products.map { ListingCellModel.listingCell(listing: .product($0)) }
                            buildSut(productListModels: productListModels, initialProduct: product)
                            sut.active = true
                            startObserving()
                        }
                        it("requests images for items 0-3") {
                            let images = products.prefix(through: 3).flatMap { $0.images.first?.fileURL }
                            expect(imageDownloader.downloadImagesRequested) == images
                        }
                        describe("swipe right") {
                            beforeEach {
                                sut.moveToProductAtIndex(1, movement: .swipeRight)
                            }
                            it("just requests one more image on the right") {
                                let images = [products[4].images.first?.fileURL].flatMap { $0 }
                                expect(imageDownloader.downloadImagesRequested) == images
                            }
                        }
                    }
                    context("first item is in the middle of list") {
                        beforeEach {
                            product = products[10]
                            let productListModels = products.map { ListingCellModel.listingCell(listing: .product($0)) }
                            buildSut(productListModels: productListModels, initialProduct: product)
                            sut.active = true
                            startObserving()
                        }
                        it("requests images for items 9-13") {
                            let images = products[9...13].flatMap { $0.images.first?.fileURL }
                            expect(imageDownloader.downloadImagesRequested) == images
                        }
                        describe("swipe right") {
                            beforeEach {
                                sut.moveToProductAtIndex(11, movement: .swipeRight)
                            }
                            it("just requests one more image on the right") {
                                let images = [products[14].images.first?.fileURL].flatMap { $0 }
                                expect(imageDownloader.downloadImagesRequested) == images
                            }
                        }
                        describe("swipe left") {
                            beforeEach {
                                sut.moveToProductAtIndex(9, movement: .swipeLeft)
                            }
                            it("just requests one more image on the left") {
                                let images = [products[8].images.first?.fileURL].flatMap { $0 }
                                expect(imageDownloader.downloadImagesRequested) == images
                            }
                        }
                    }
                }
                describe("elements update and visit trackings") {
                    var products: [MockProduct]!
                    beforeEach {
                        products = MockProduct.makeMocks(count: 20)
                        let productListModels = products.map { ListingCellModel.listingCell(listing: .product($0)) }
                        buildSut(productListModels: productListModels)
                        sut.active = true
                        startObserving()
                    }
                    context("viewmodel inactive") {
                        beforeEach {
                            sut.active = false
                            sut.moveToProductAtIndex(1, movement: .tap)
                            sut.moveToProductAtIndex(2, movement: .tap)
                        }
                        it("doesn't track any product visit") {
                            expect(tracker.trackedEvents.count) == 0
                        }
                        it("navbarButtons changed twice") {
                            expect(navBarButtonsObserver.eventValues.count) == 3
                        }
                        it("actionButtons changed twice") {
                            expect(actionButtonsObserver.eventValues.count) == 3
                        }
                        it("quickanswersavailable changed twice") {
                            expect(quickAnswersAvailableObserver.eventValues.count) == 3
                        }
                        it("directChagEnabled changed twice") {
                            expect(directChatEnabledObserver.eventValues.count) == 3
                        }
                        describe("view model gets active") {
                            beforeEach {
                                sut.active = true
                            }
                            it("has just one tracking") {
                                expect(tracker.trackedEvents.count) == 1
                            }
                            it("tracks product visit") {
                                expect(tracker.trackedEvents.last?.actualName) == "product-detail-visit"
                            }
                            it("tracks with product Id of product index 2") {
                                let firstEvent = tracker.trackedEvents.last
                                expect(firstEvent?.params?.stringKeyParams["product-id"] as? String) == products[2].objectId
                            }
                        }
                    }
                    context("viewmodel active") {
                        beforeEach {
                            sut.active = true
                            sut.moveToProductAtIndex(1, movement: .tap)
                            sut.moveToProductAtIndex(2, movement: .tap)
                        }
                        it("tracks 3 product visits") {
                            expect(tracker.trackedEvents.map { $0.actualName }) == ["product-detail-visit","product-detail-visit","product-detail-visit"]
                        }
                        it("tracks with product ids of first 3 products") {
                            expect(tracker.trackedEvents.flatMap { $0.params?.stringKeyParams["product-id"] as? String })
                                == products.prefix(through: 2).flatMap { $0.objectId }
                        }
                        it("navbarButtons changed twice") {
                            expect(navBarButtonsObserver.eventValues.count) == 3
                        }
                        it("actionButtons changed twice") {
                            expect(actionButtonsObserver.eventValues.count) == 3
                        }
                        it("quickanswersavailable changed twice") {
                            expect(quickAnswersAvailableObserver.eventValues.count) == 3
                        }
                        it("directChagEnabled changed twice") {
                            expect(directChatEnabledObserver.eventValues.count) == 3
                        }
                    }
                }
            }
            describe("changes after myUser update") {
                var stats: MockListingStats!
                beforeEach {
                    var relation = MockUserListingRelation.makeMock()
                    relation.isFavorited = true
                    relation.isReported = false
                    listingRepository.userProductRelationResult = ListingUserRelationResult(relation)
                    stats = MockListingStats.makeMock()
                    listingRepository.statsResult = ListingStatsResult(stats)
                    product.status = .approved
                }
                context("user not logged in") {
                    beforeEach {
                        buildSut(initialProduct: product)
                        sut.active = true
                        startObserving()
                    }
                    it("there's a share navbar button") {
                        let accesibilityIds: [AccessibilityId] = [.listingCarouselNavBarShareButton]
                        expect(navBarButtonsObserver.lastValue?.flatMap { $0.accessibilityId }) == accesibilityIds
                    }
                    it("directchatenabled is true") {
                        expect(directChatEnabledObserver.eventValues) == [true]
                    }
                    it("action buttons are empty") {
                        expect(actionButtonsObserver.eventValues.map { $0.count }) == [0]
                    }
                    describe("user logs in, product is not mine") {
                        beforeEach {
                            let myUser = MockMyUser.makeMock()
                            myUserRepository.myUserVar.value = myUser
                        }
                        it("action buttons are again empty") {
                            expect(actionButtonsObserver.eventValues.map { $0.count }) == [0, 0]
                        }
                        it("share navbar button remains share") {
                            let accesibilityIds: [AccessibilityId] = [.listingCarouselNavBarShareButton]
                            expect(navBarButtonsObserver.lastValue?.flatMap { $0.accessibilityId }) == accesibilityIds
                        }
                    }
                    describe("user logs in, product is mine") {
                        beforeEach {
                            var myUser = MockMyUser.makeMock()
                            myUser.objectId = product.user.objectId
                            myUserRepository.myUserVar.value = myUser
                        }
                        it("directchatenabled is false") {
                            expect(directChatEnabledObserver.eventValues) == [true, false]
                        }
                        it("action buttons have one item") {
                            expect(actionButtonsObserver.eventValues.map { $0.count }) == [0, 1]
                        }
                        it("action buttons item is to mark as sold") {
                            expect(actionButtonsObserver.lastValue?.first?.text) == LGLocalizedString.productMarkAsSoldButton
                        }
                        it("navbar buttons now have share and edit") {
                            let accesibilityIds: [AccessibilityId] = [.listingCarouselNavBarEditButton, .listingCarouselNavBarActionsButton]
                            expect(navBarButtonsObserver.lastValue?.flatMap { $0.accessibilityId }) == accesibilityIds
                        }
                    }
                }
            }
            describe("overlay elements state") {
                beforeEach {
                    product.name = String.makeRandom()
                    var productUser = MockUserListing.makeMock()
                    productUser.name = String.makeRandom()
                    product.user = productUser

                    // Already selected as winners but not removed
                    featureFlags.freePostingModeAllowed = true
                }
                context("product is mine") {
                    var myUser: MockMyUser!
                    beforeEach {
                        myUser = MockMyUser.makeMock()
                        myUser.objectId = product.user.objectId
                        myUser.name = String.makeRandom()
                        myUserRepository.myUserVar.value = myUser
                        listingRepository.transactionsResult = ListingTransactionsResult(value: [])
                    }
                    context("pending") {
                        context("not featured") {
                            beforeEach {
                                product.status = .pending
                                product.name = String.makeRandom()
                                product.featured = false
                                buildSut(initialProduct: product)
                                sut.active = true
                                startObserving()
                            }
                            it("navbar buttons have edit and options") {
                                let accesibilityIds: [AccessibilityId] = [.listingCarouselNavBarEditButton, .listingCarouselNavBarActionsButton]
                                expect(navBarButtonsObserver.lastValue?.flatMap { $0.accessibilityId }) == accesibilityIds
                            }
                            it("there are no action buttons") {
                                expect(actionButtonsObserver.lastValue?.count) == 0
                            }
                            it("quick answers are disabled") {
                                expect(quickAnswersAvailableObserver.lastValue) == false
                            }
                            it("direct chat is disabled") {
                                expect(directChatEnabledObserver.lastValue) == false
                            }
                        }
                        context("featured") {
                            beforeEach {
                                product.status = .pending
                                product.name = String.makeRandom()
                                product.featured = true
                                buildSut(initialProduct: product)
                                sut.active = true
                                startObserving()
                            }
                            it("navbar buttons have edit and options") {
                                let accesibilityIds: [AccessibilityId] = [.listingCarouselNavBarEditButton, .listingCarouselNavBarActionsButton]
                                expect(navBarButtonsObserver.lastValue?.flatMap { $0.accessibilityId }) == accesibilityIds
                            }
                            it("there are no action buttons") {
                                expect(actionButtonsObserver.lastValue?.count) == 0
                            }
                            it("quick answers are disabled") {
                                expect(quickAnswersAvailableObserver.lastValue) == false
                            }
                            it("direct chat is disabled") {
                                expect(directChatEnabledObserver.lastValue) == false
                            }
                        }
                    }
                    context("approved - normal") {
                        beforeEach {
                            product.status = .approved
                            product.price = .normal(25)
                            product.name = String.makeRandom()
                            buildSut(initialProduct: product)
                            sut.active = true
                            startObserving()
                        }
                        it("navbar buttons have edit and options") {
                            let accesibilityIds: [AccessibilityId] = [.listingCarouselNavBarEditButton, .listingCarouselNavBarActionsButton]
                            expect(navBarButtonsObserver.lastValue?.flatMap { $0.accessibilityId }) == accesibilityIds
                        }
                        it("there is a mark sold action") {
                            expect(actionButtonsObserver.lastValue?.flatMap { $0.text }) == [LGLocalizedString.productMarkAsSoldButton]
                        }
                        it("quick answers are disabled") {
                            expect(quickAnswersAvailableObserver.lastValue) == false
                        }
                        it("direct chat is disabled") {
                            expect(directChatEnabledObserver.lastValue) == false
                        }
                    }
                    context("approved - free") {
                        beforeEach {
                            product.status = .approved
                            product.price = .free
                            product.name = String.makeRandom()
                            buildSut(initialProduct: product)
                            sut.active = true
                            startObserving()
                        }
                        it("navbar buttons have edit and options") {
                            let accesibilityIds: [AccessibilityId] = [.listingCarouselNavBarEditButton, .listingCarouselNavBarActionsButton]
                            expect(navBarButtonsObserver.lastValue?.flatMap { $0.accessibilityId }) == accesibilityIds
                        }
                        it("there is a mark sold action") {
                            expect(actionButtonsObserver.lastValue?.flatMap { $0.text }) == [LGLocalizedString.productMarkAsSoldFreeButton]
                        }
                        it("quick answers are disabled") {
                            expect(quickAnswersAvailableObserver.lastValue) == false
                        }
                        it("direct chat is disabled") {
                            expect(directChatEnabledObserver.lastValue) == false
                        }
                    }
                    context("sold - normal") {
                        beforeEach {
                            product.status = .sold
                            product.price = .normal(25)
                            product.name = String.makeRandom()
                            buildSut(initialProduct: product)
                            sut.active = true
                            startObserving()
                        }
                        it("navbar buttons have just options") {
                            let accesibilityIds: [AccessibilityId] = [.listingCarouselNavBarActionsButton]
                            expect(navBarButtonsObserver.lastValue?.flatMap { $0.accessibilityId }) == accesibilityIds
                        }
                        it("there is a sell again action") {
                            expect(actionButtonsObserver.lastValue?.flatMap { $0.text }) == [LGLocalizedString.productSellAgainButton]
                        }
                        it("quick answers are disabled") {
                            expect(quickAnswersAvailableObserver.lastValue) == false
                        }
                        it("direct chat is disabled") {
                            expect(directChatEnabledObserver.lastValue) == false
                        }
                    }
                    context("sold - free") {
                        beforeEach {
                            product.status = .sold
                            product.price = .free
                            product.name = String.makeRandom()
                            buildSut(initialProduct: product)
                            sut.active = true
                            startObserving()
                        }
                        it("navbar buttons have just options") {
                            let accesibilityIds: [AccessibilityId] = [.listingCarouselNavBarActionsButton]
                            expect(navBarButtonsObserver.lastValue?.flatMap { $0.accessibilityId }) == accesibilityIds
                        }
                        it("there is a sell again action") {
                            expect(actionButtonsObserver.lastValue?.flatMap { $0.text }) == [LGLocalizedString.productSellAgainFreeButton]
                        }
                        it("quick answers are disabled") {
                            expect(quickAnswersAvailableObserver.lastValue) == false
                        }
                        it("direct chat is disabled") {
                            expect(directChatEnabledObserver.lastValue) == false
                        }
                    }
                }
                context("product isn't mine") {
                    context("pending") {
                        beforeEach {
                            product.status = .pending
                            product.name = String.makeRandom()
                            buildSut(initialProduct: product)
                            sut.active = true
                            startObserving()
                        }
                        it("navbar buttons has share button") {
                            let accesibilityIds: [AccessibilityId] = [.listingCarouselNavBarShareButton]
                            expect(navBarButtonsObserver.lastValue?.flatMap { $0.accessibilityId }) == accesibilityIds
                        }
                        it("there are no action buttons") {
                            expect(actionButtonsObserver.lastValue?.count) == 0
                        }
                        it("quick answers are disabled") {
                            expect(quickAnswersAvailableObserver.lastValue) == false
                        }
                        it("direct chat is disabled") {
                            expect(directChatEnabledObserver.lastValue) == false
                        }
                    }
                    context("approved - normal") {
                        beforeEach {
                            product.status = .approved
                            product.price = .normal(25)
                            product.name = String.makeRandom()
                            buildSut(initialProduct: product)
                            sut.active = true
                            startObserving()
                        }
                        it("navbar buttons has share button") {
                            let accesibilityIds: [AccessibilityId] = [.listingCarouselNavBarShareButton]
                            expect(navBarButtonsObserver.lastValue?.flatMap { $0.accessibilityId }) == accesibilityIds
                        }
                        it("there are no action buttons") {
                            expect(actionButtonsObserver.lastValue?.count) == 0
                        }
                        it("quick answers are enabled") {
                            expect(quickAnswersAvailableObserver.lastValue) == true
                        }
                        it("direct chat is enabled") {
                            expect(directChatEnabledObserver.lastValue) == true
                        }
                    }
                    context("approved - free") {
                        beforeEach {
                            product.status = .approved
                            product.price = .free
                            product.name = String.makeRandom()
                            buildSut(initialProduct: product)
                            sut.active = true
                            startObserving()
                        }
                        it("navbar buttons has share button") {
                            let accesibilityIds: [AccessibilityId] = [.listingCarouselNavBarShareButton]
                            expect(navBarButtonsObserver.lastValue?.flatMap { $0.accessibilityId }) == accesibilityIds
                        }
                        it("there are no action buttons") {
                            expect(actionButtonsObserver.lastValue?.count) == 0
                        }
                        it("quick answers are enabled") {
                            expect(quickAnswersAvailableObserver.lastValue) == true
                        }
                        it("direct chat is enabled") {
                            expect(directChatEnabledObserver.lastValue) == true
                        }
                    }
                    context("sold - normal") {
                        beforeEach {
                            product.status = .sold
                            product.price = .normal(25)
                            product.name = String.makeRandom()
                            buildSut(initialProduct: product)
                            sut.active = true
                            startObserving()
                        }
                        it("navbar buttons has share button") {
                            let accesibilityIds: [AccessibilityId] = [.listingCarouselNavBarShareButton]
                            expect(navBarButtonsObserver.lastValue?.flatMap { $0.accessibilityId }) == accesibilityIds
                        }
                        it("there are no action buttons") {
                            expect(actionButtonsObserver.lastValue?.count) == 0
                        }
                        it("quick answers are disabled") {
                            expect(quickAnswersAvailableObserver.lastValue) == false
                        }
                        it("direct chat is disabled") {
                            expect(directChatEnabledObserver.lastValue) == false
                        }
                    }
                    context("sold - free") {
                        beforeEach {
                            product.status = .sold
                            product.price = .free
                            product.name = String.makeRandom()
                            buildSut(initialProduct: product)
                            sut.active = true
                            startObserving()
                        }
                        it("navbar buttons has share button") {
                            let accesibilityIds: [AccessibilityId] = [.listingCarouselNavBarShareButton]
                            expect(navBarButtonsObserver.lastValue?.flatMap { $0.accessibilityId }) == accesibilityIds
                        }
                        it("there are no action buttons") {
                            expect(actionButtonsObserver.lastValue?.count) == 0
                        }
                        it("quick answers are disabled") {
                            expect(quickAnswersAvailableObserver.lastValue) == false
                        }
                        it("direct chat is disabled") {
                            expect(directChatEnabledObserver.lastValue) == false
                        }
                    }
                }
            }
        }
    }

}


extension ListingDeckViewModelSpec: ListingDeckViewModelDelegate {
    func vmRemoveMoreInfoTooltip() { }
    func vmShowOnboarding() { }
    
    // Forward from ListingViewModelDelegate
    func vmAskForRating() {}
    func vmShowCarouselOptions(_ cancelLabel: String, actions: [UIAction]) {}
    func vmShareViewControllerAndItem() -> (UIViewController, UIBarButtonItem?) {
        return (UIViewController(), nil)
    }
    func vmResetBumpUpBannerCountdown() {}
}

extension ListingDeckViewModelSpec: ListingDetailNavigator {
    func closeProductDetail() {}
    func editListing(_ listing: Listing) {}
    func openListingChat(_ listing: Listing, source: EventParameterTypePage) {}
    func closeListingAfterDelete(_ listing: Listing) {}
    func openFreeBumpUp(forListing listing: Listing, socialMessage: SocialMessage, paymentItemId: String) {}
    func openPayBumpUp(forListing listing: Listing,
                       purchaseableProduct: PurchaseableProduct,
                       paymentItemId: String) {}
    func selectBuyerToRate(source: RateUserSource,
                           buyers: [UserListing],
                           listingId: String,
                           sourceRateBuyers: SourceRateBuyers?,
                           trackingInfo: MarkAsSoldTrackingInfo) {}
    func showProductFavoriteBubble(with data: BubbleNotificationData) {}
    func openLoginIfNeededFromProductDetail(from: EventParameterLoginSourceValue, infoMessage: String,
                                            loggedInAction: @escaping (() -> Void)) {}
    func showBumpUpNotAvailableAlertWithTitle(title: String,
                                              text: String,
                                              alertType: AlertType,
                                              buttonsLayout: AlertButtonsLayout,
                                              actions: [UIAction]) {}
    func openContactUs(forListing listing: Listing, contactUstype: ContactUsType) {}
    func openFeaturedInfo() {}
    func closeFeaturedInfo() {}
}
