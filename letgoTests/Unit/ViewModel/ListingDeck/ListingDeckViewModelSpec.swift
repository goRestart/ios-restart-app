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
import LGComponents

final class ListingDeckViewModelSpec: BaseViewModelSpec {

    override func spec() {
        var sut: ListingDeckViewModel!

        var listingViewModelMaker: MockListingViewModelMaker!
        var listingListRequester: MockListingListRequester!
        var imageDownloader: MockImageDownloader!

        var myUserRepository: MockMyUserRepository!
        var mockUserRepository: MockUserRepository!
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

        var cellModelsObserver: TestableObserver<[ListingCellModel]>!
        var actionButtonsObserver: TestableObserver<[UIAction]>!
        var quickAnswersObserver: TestableObserver<[QuickAnswer]>!
        var quickAnswersAvailableObserver: TestableObserver<Bool>!
        var directChatEnabledObserver: TestableObserver<Bool>!
        var directChatPlaceholderObserver: TestableObserver<String>!
        var directChatMessagesObserver: TestableObserver<[ChatViewMessage]>!
        var bumpUpBannerInfoObserver: TestableObserver<BumpUpInfo?>!

        var prefetching = Prefetching(previousCount: 3, nextCount: 3)

        describe("ListingDeckViewModelSpec") {

            func startObserving() {
                disposeBag = DisposeBag()
                sut.objects.observable.bind(to: cellModelsObserver).disposed(by: disposeBag)
                sut.actionButtons.asObservable().bind(to:actionButtonsObserver).disposed(by:disposeBag)
                sut.quickChatViewModel.quickAnswers.asObservable().bind(to:quickAnswersObserver).disposed(by:disposeBag)

                sut.quickChatViewModel.chatEnabled.asObservable().bind(to:quickAnswersAvailableObserver).disposed(by:disposeBag)
                sut.quickChatViewModel.chatEnabled.asObservable().bind(to:directChatEnabledObserver).disposed(by:disposeBag)
                sut.quickChatViewModel.directChatPlaceholder.asObservable().bind(to:directChatPlaceholderObserver).disposed(by:disposeBag)
                sut.quickChatViewModel.directChatMessages.observable.bind(to:directChatMessagesObserver).disposed(by:disposeBag)
                sut.bumpUpBannerInfo.asObservable().bind(to:bumpUpBannerInfoObserver).disposed(by:disposeBag)
            }

            func buildSut(productListModels: [ListingCellModel] = [],
                          initialProduct: Product? = nil,
                          source: LetGoGodMode.EventParameterListingVisitSource = .listingList,
                          actionOnFirstAppear: ProductCarouselActionOnFirstAppear = .nonexistent,
                          trackingIndex: Int? = nil,
                          firstProductSyncRequired: Bool = false) {

                var initialListing: Listing? = nil
                if let initialProduct = initialProduct {
                    initialListing = .product(initialProduct)
                }
                sut = ListingDeckViewModel(listModels: productListModels,
                                           initialListing: initialListing,
                                           listingListRequester: listingListRequester,
                                           detailNavigator: self,
                                           source: source,
                                           imageDownloader: imageDownloader,
                                           listingViewModelMaker: listingViewModelMaker,
                                           myUserRepository: myUserRepository,
                                           pagination: Pagination.makePagination(first: 0, next: 1, isLast: false),
                                           prefetching: prefetching,
                                           shouldSyncFirstListing: firstProductSyncRequired,
                                           binder: ListingDeckViewModelBinder(),
                                           tracker: tracker,
                                           actionOnFirstAppear: actionOnFirstAppear,
                                           trackingIndex: nil,
                                           keyValueStorage: MockKeyValueStorage(),
                                           featureFlags: MockFeatureFlags(),
                                           adsRequester: AdsRequester())

                sut.delegate = self
            }

            beforeEach {
                mockUserRepository = MockUserRepository.makeMock()
                myUserRepository = MockMyUserRepository.makeMock()
                listingRepository = MockListingRepository.makeMock()
                chatWrapper = MockChatWrapper()
                locationManager = MockLocationManager()
                countryHelper = CountryHelper.mock()
                product = MockProduct.makeProductMocks(1, allowDiscarded: false).first!
                featureFlags = MockFeatureFlags()
                purchasesShopper = MockPurchasesShopper()
                notificationsManager = MockNotificationsManager()
                monetizationRepository = MockMonetizationRepository.makeMock()
                tracker = MockTracker()

                listingListRequester = MockListingListRequester(canRetrieve: true, offset: 0, pageSize: 20)
                imageDownloader = MockImageDownloader()

                listingViewModelMaker = MockListingViewModelMaker(myUserRepository: myUserRepository,
                                                                  userRepository: mockUserRepository,
                                                                  listingRepository: listingRepository,
                                                                  chatWrapper: chatWrapper,
                                                                  locationManager: locationManager,
                                                                  countryHelper: countryHelper,
                                                                  featureFlags: featureFlags,
                                                                  purchasesShopper: purchasesShopper,
                                                                  monetizationRepository: monetizationRepository,
                                                                  tracker: tracker,
                                                                  keyValueStorage: MockKeyValueStorage())

                scheduler = TestScheduler(initialClock: 0)
                scheduler.start()
                cellModelsObserver = scheduler.createObserver(Array<ListingCellModel>.self)
                actionButtonsObserver = scheduler.createObserver(Array<UIAction>.self)
                quickAnswersObserver = scheduler.createObserver(Array<QuickAnswer>.self)
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
                                expect(quickAnswersObserver.lastValue?[0]) == .stillAvailable
                            }
                            it("matches second group with the right negotiable quick answers") {
                                expect(quickAnswersObserver.lastValue?[1]) == .isNegotiable
                            }
                            it("matches third group with the right condition quick answers") {
                                expect(quickAnswersObserver.lastValue?[2]) == .listingCondition
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
                                expect(quickAnswersObserver.lastValue?[0]) == .interested
                            }
                            it("matches second group with the right meet up quick answers") {
                                expect(quickAnswersObserver.lastValue?[1]) == .meetUp
                            }
                            it("matches third group with the right condition quick answers") {
                                expect(quickAnswersObserver.lastValue?[2]) == .listingCondition
                            }
                        }
                    }
                }
            }
            describe("pagination") {
                context("single item") {
                    beforeEach {
                        listingListRequester.generateItems(30, allowDiscarded: false)
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
                            var products = MockProduct.makeProductMocks(20, allowDiscarded: false)
                            products[0] = product
                            let productListModels = products.map { ListingCellModel.listingCell(listing: .product($0)) }
                            listingListRequester.generateItems(30, allowDiscarded: false)
                            buildSut(productListModels: productListModels, initialProduct: product)
                            sut.active = true
                            startObserving()
                        }
                        it("doesn't paginate initially") {
                            expect(sut.objectCount).toNot(beGreaterThan(20))
                        }
                        describe("switch to item after threshold") {
                            beforeEach {
                                sut.moveToListingAtIndex(18, movement: .swipeRight)
                            }
                            it("gets one extra page") {
                                expect(sut.objectCount).toEventually(equal(40))
                            }
                        }
                    }
                    context("item after the threshold") {
                        beforeEach {
                            var products = MockProduct.makeProductMocks(20, allowDiscarded: false)
                            products[18] = product
                            let productListModels = products.map { ListingCellModel.listingCell(listing: .product($0)) }
                            listingListRequester.generateItems(30, allowDiscarded: false)
                            buildSut(productListModels: productListModels, initialProduct: product)
                            sut.active = true
                            startObserving()
                        }
                        it("paginates initially") {
                            expect(sut.objectCount).toEventually(equal(40))
                        }
                    }

                    context("discarded item after the threshold") {
                        var index: Int!
                        beforeEach {
                            index = Int.random(15, 19)

                            var products = MockProduct.makeProductMocks(20, allowDiscarded: false)
                            product.status = ListingStatus.discarded(reason: nil)
                            products[index] = product
                            let productListModels = products.map { ListingCellModel.listingCell(listing: .product($0)) }
                            listingListRequester.generateItems(30, allowDiscarded: false)
                            buildSut(productListModels: productListModels, initialProduct: product)
                            sut.active = true
                            startObserving()
                        }
                        it("filters the product") {
                            expect(sut.objects.value.map { $0.listing?.objectId }
                                                    .filter { $0 == product.objectId }).to(beEmpty())
                        }
                        it("does not paginate") {
                            expect(sut.objectCount).toEventually(equal(19))
                        }
                    }
                }
                context("long pagination") {
                    beforeEach {
                        //Simulating that we're on page 8-10
                        var products = MockProduct.makeProductMocks(180, allowDiscarded: false)
                        products[160] = product
                        listingListRequester.generateItems(200, allowDiscarded: false)
                        listingListRequester.offset = 180
                        let productListModels = products.map { ListingCellModel.listingCell(listing: .product($0)) }
                        buildSut(productListModels: productListModels, initialProduct: product)
                        sut.active = true
                        startObserving()
                    }
                    describe("move to item before threshold") {
                        beforeEach {
                            sut.moveToListingAtIndex(172, movement: .swipeRight)
                        }
                        it("doesn't paginate") {
                            expect(sut.objectCount).toNot(beGreaterThan(180))
                        }
                    }
                    describe("move to item after threshold") {
                        beforeEach {
                            sut.moveToListingAtIndex(178, movement: .swipeRight)
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
                        products = MockProduct.makeProductMocks(20, allowDiscarded: false)
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
                            let images = products.prefix(through: 3).compactMap { $0.images.first?.fileURL }
                            expect(imageDownloader.downloadImagesRequested) == images
                        }
                        describe("swipe right") {
                            beforeEach {
                                sut.moveToListingAtIndex(1, movement: .swipeRight)
                            }
                            it("just requests one more image on the right") {
                                let images = [products[4].images.first?.fileURL].compactMap { $0 }
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
                        it("requests images for items 7-13") {
                            let initial = 10 - prefetching.previousCount
                            let end = 10 + prefetching.nextCount
                            let images = products[initial...end].compactMap { $0.images.first?.fileURL }
                            expect(imageDownloader.downloadImagesRequested) == images
                        }
                        describe("swipe right") {
                            beforeEach {
                                sut.moveToListingAtIndex(11, movement: .swipeRight)
                            }
                            it("just requests one more image on the right") {
                                let images = [products[14].images.first?.fileURL].compactMap { $0 }
                                expect(imageDownloader.downloadImagesRequested) == images
                            }
                        }
                        describe("swipe left") {
                            beforeEach {
                                sut.moveToListingAtIndex(9, movement: .swipeLeft)
                            }
                            it("just requests one more image on the left") {
                                let images = [products[6].images.first?.fileURL].compactMap { $0 }
                                expect(imageDownloader.downloadImagesRequested) == images
                            }
                        }
                    }
                }
                describe("elements update and visit trackings") {
                    var products: [MockProduct]!
                    beforeEach {
                        products = MockProduct.makeProductMocks(20, allowDiscarded: false)
                        let productListModels = products.map { ListingCellModel.listingCell(listing: .product($0)) }
                        buildSut(productListModels: productListModels)
                        startObserving()
                    }
                    context("viewmodel inactive") {
                        beforeEach {
                            sut.active = false
                            sut.moveToListingAtIndex(1, movement: .tap)
                            sut.moveToListingAtIndex(2, movement: .tap)
                        }
                        it("doesn't track any product visit") {
                            expect(tracker.trackedEvents.count) == 0
                        }
                        it("actionButtons changed just for the initial binding") {
                            expect(actionButtonsObserver.eventValues.count) == 1
                        }
                        it("quickanswersavailable changed just for the initial binding") {
                            expect(quickAnswersAvailableObserver.eventValues.count) == 1
                        }
                        it("directChagEnabled changed just for the initial binding") {
                            expect(directChatEnabledObserver.eventValues.count) == 1
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
                            it("tracks with product Id of product index 0") {
                                let firstEvent = tracker.trackedEvents.last
                                expect(firstEvent?.params?.stringKeyParams["product-id"] as? String) == products[0].objectId
                            }
                        }
                    }
                    context("viewmodel active") {
                        beforeEach {
                            sut.active = true
                            sut.moveToListingAtIndex(1, movement: .tap)
                            sut.moveToListingAtIndex(2, movement: .tap)
                        }
                        it("tracks 3 product visits") {
                            expect(tracker.trackedEvents.map { $0.actualName }) == ["product-detail-visit",
                                                                                    "product-detail-visit",
                                                                                    "product-detail-visit"]
                        }
                        it("tracks with product ids of first 3 products") {
                            expect(tracker.trackedEvents.compactMap { $0.params?.stringKeyParams["product-id"] as? String })
                                == products.prefix(through: 2).compactMap { $0.objectId }
                        }
                        // We have 4 = movements + activation ()
                        it("actionButtons changed 4 times") {
                            expect(actionButtonsObserver.eventValues.count) == 4
                        }
                        it("quickanswersavailable changed 4 times") {
                            expect(quickAnswersAvailableObserver.eventValues.count) == 4
                        }
                        it("directChagEnabled changed 4 times") {
                            expect(directChatEnabledObserver.eventValues.count) == 4
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
                            expect(actionButtonsObserver.lastValue?.first?.text) == R.Strings.productMarkAsSoldButton
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
                        it("there is a mark sold action") {
                            expect(actionButtonsObserver.lastValue?.compactMap { $0.text }) == [R.Strings.productMarkAsSoldButton]
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
                        it("there is a mark sold action") {
                            expect(actionButtonsObserver.lastValue?.compactMap { $0.text }) == [R.Strings.productMarkAsSoldFreeButton]
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
                        it("there is a sell again action") {
                            expect(actionButtonsObserver.lastValue?.compactMap { $0.text }) == [R.Strings.productSellAgainButton]
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
                        it("there is a sell again action") {
                            expect(actionButtonsObserver.lastValue?.compactMap { $0.text }) == [R.Strings.productSellAgainFreeButton]
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
    func openVideoPlayer(atIndex index: Int,
                         listingVM: ListingViewModel,
                         source: LetGoGodMode.EventParameterListingVisitSource) { }

    func openListingChat(_ listing: Listing, source: LetGoGodMode.EventParameterTypePage, interlocutor: User?) { }
    func openAskPhoneFor(listing: Listing, interlocutor: User?) { }
    func closeAskPhoneFor(listing: Listing,
                          openChat: Bool,
                          withPhoneNum: String?,
                          source: LetGoGodMode.EventParameterTypePage,
                          interlocutor: User?) { }
    func editListing(_ listing: Listing,
                     bumpUpProductData: BumpUpProductData?,
                     listingCanBeBoosted: Bool,
                     timeSinceLastBump: TimeInterval?,
                     maxCountdown: TimeInterval) { }
    func openFreeBumpUp(forListing listing: Listing,
                        bumpUpProductData: BumpUpProductData,
                        typePage: LetGoGodMode.EventParameterTypePage?,
                        maxCountdown: TimeInterval) {}
    func openPayBumpUp(forListing listing: Listing,
                       bumpUpProductData: BumpUpProductData,
                       typePage: LetGoGodMode.EventParameterTypePage?,
                       maxCountdown: TimeInterval) {}
    func openBumpUpBoost(forListing listing: Listing,
                         bumpUpProductData: BumpUpProductData,
                         typePage: LetGoGodMode.EventParameterTypePage?,
                         timeSinceLastBump: TimeInterval,
                         maxCountdown: TimeInterval) {}
    func closeProductDetail() {}
    func openListingChat(_ listing: Listing, source: LetGoGodMode.EventParameterTypePage) {}
    func closeListingAfterDelete(_ listing: Listing) {}
    func selectBuyerToRate(source: RateUserSource,
                           buyers: [UserListing],
                           listingId: String,
                           sourceRateBuyers: SourceRateBuyers?,
                           trackingInfo: LetGoGodMode.MarkAsSoldTrackingInfo) {}
    func showProductFavoriteBubble(with data: BubbleNotificationData) {}
    func openLoginIfNeededFromProductDetail(from: LetGoGodMode.EventParameterLoginSourceValue, infoMessage: String,
                                            loggedInAction: @escaping (() -> Void)) {}
    func showBumpUpNotAvailableAlertWithTitle(title: String,
                                              text: String,
                                              alertType: AlertType,
                                              buttonsLayout: AlertButtonsLayout,
                                              actions: [UIAction]) {}
    func showBumpUpBoostSucceededAlert() {}
    func openContactUs(forListing listing: Listing, contactUstype: ContactUsType) {}
    func openFeaturedInfo() {}
    func openListingAttributeTable(withViewModel viewModel: ListingAttributeTableViewModel) {}
    func closeListingAttributeTable() {}
}
