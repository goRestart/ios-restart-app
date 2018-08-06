import Foundation
import LGCoreKit
import LGComponents

final class ListingCoordinator {
    private let navigationController: UINavigationController
    weak var listingDetailNavigator: ListingDetailNavigator?
    
    private let myUserRepository: MyUserRepository

    weak var tabNavigator: TabNavigator?

    private let userCoordinator: UserCoordinator
    private let listingRepository: ListingRepository

    private let simpleListingAssembly: SimpleListingsAssembly

    private let tracker: Tracker
    private let featureFlags: FeatureFlaggeable
    var deckAnimator: DeckAnimator?

    convenience init(navigationController: UINavigationController, userCoordinator: UserCoordinator) {
        self.init(navigationController: navigationController,
                  listingRepository: Core.listingRepository,
                  myUserRepository: Core.myUserRepository,
                  tracker: TrackerProxy.sharedInstance,
                  featureFlags: FeatureFlags.sharedInstance,
                  userCoordinator: userCoordinator,
                  simpleListingAssembly: LGSimpleListingsBuilder.standard(nav: navigationController))
    }

    private init(navigationController: UINavigationController,
                 listingRepository: ListingRepository,
                 myUserRepository: MyUserRepository,
                 tracker: Tracker,
                 featureFlags: FeatureFlaggeable,
                 userCoordinator: UserCoordinator,
                 simpleListingAssembly: SimpleListingsAssembly) {
        self.navigationController = navigationController
        self.listingRepository = listingRepository
        self.myUserRepository = myUserRepository
        self.userCoordinator = userCoordinator
        self.simpleListingAssembly = simpleListingAssembly
        self.tracker = tracker
        self.featureFlags = featureFlags
    }

    func openListing(_ data: ListingDetailData,
                     source: EventParameterListingVisitSource,
                     actionOnFirstAppear: ProductCarouselActionOnFirstAppear) {
        switch data {
        case let .id(listingId):
            openListing(listingId: listingId, source: source, actionOnFirstAppear: actionOnFirstAppear)
        case let .listingAPI(listing, thumbnailImage, originFrame):
            openListing(listing: listing, thumbnailImage: thumbnailImage, originFrame: originFrame, source: source,
                        index: 0, discover: false, actionOnFirstAppear: actionOnFirstAppear)
        case let .listingList(listing, cellModels, requester, thumbnailImage, originFrame, showRelated, index):
            openListing(listing, cellModels: cellModels, requester: requester, thumbnailImage: thumbnailImage,
                        originFrame: originFrame, showRelated: showRelated, source: source,
                        index: index)
        case let .listingChat(chatConversation):
            openListing(chatConversation: chatConversation, source: source)
        }
    }

    private func openListing(listingId: String,
                             source: EventParameterListingVisitSource,
                             actionOnFirstAppear: ProductCarouselActionOnFirstAppear) {
        navigationController.showLoadingMessageAlert()
        listingRepository.retrieve(listingId) { [weak self] result in
            if let listing = result.value {
                self?.navigationController.dismissLoadingMessageAlert {
                    self?.openListing(listing: listing, source: source, index: 0, discover: false,
                                      actionOnFirstAppear: actionOnFirstAppear)
                }
            } else if let error = result.error {
                switch error {
                case .network:
                    self?.navigationController.dismissLoadingMessageAlert {
                        self?.navigationController.showAutoFadingOutMessageAlert(message: R.Strings.commonErrorConnectionFailed)
                    }
                case .internalError, .unauthorized, .tooManyRequests, .userNotVerified, .serverError,
                     .wsChatError, .searchAlertError:
                    self?.navigationController.dismissLoadingMessageAlert {
                        self?.navigationController.showAutoFadingOutMessageAlert(message: R.Strings.commonProductNotAvailable)
                    }
                case .notFound, .forbidden:
                    let relatedRequester = RelatedListingListRequester(listingId: listingId,
                                                                       itemsPerPage: SharedConstants.numListingsPerPageDefault)
                    relatedRequester.retrieveFirstPage { result in
                        self?.navigationController.dismissLoadingMessageAlert {
                            if let relatedListings = result.listingsResult.value, !relatedListings.isEmpty {
                                self?.openRelatedListingsForNonExistentListing(listingId: listingId,
                                                                               source: source,
                                                                               requester: relatedRequester,
                                                                               relatedListings: relatedListings)
                            }
                            self?.navigationController.showAutoFadingOutMessageAlert(message: R.Strings.commonProductNotAvailable)
                        }
                    }
                }
                self?.trackProductNotAvailable(source: source, repositoryError: error)
            }
        }
    }

    func openListing(listing: Listing, thumbnailImage: UIImage? = nil, originFrame: CGRect? = nil,
                     source: EventParameterListingVisitSource, requester: ListingListRequester? = nil, index: Int,
                     discover: Bool, actionOnFirstAppear: ProductCarouselActionOnFirstAppear) {
        guard let listingId = listing.objectId else { return }
        var requestersArray: [ListingListRequester] = []
        let listingListRequester: ListingListRequester?
        if discover {
            listingListRequester = DiscoverListingListRequester(listingId: listingId,
                                                                itemsPerPage: SharedConstants.numListingsPerPageDefault)
        } else {
            listingListRequester = RelatedListingListRequester(listing: listing,
                                                               itemsPerPage: SharedConstants.numListingsPerPageDefault)
        }
        guard let relatedRequester = listingListRequester else { return }
        requestersArray.append(relatedRequester)

        // Adding product list after related
        let listOffset = index + 1 // we need the product AFTER the current one
        if let requester = requester {
            let requesterCopy = requester.duplicate()
            requesterCopy.updateInitialOffset(listOffset)
            requestersArray.append(requesterCopy)
        } else {
            let filteredRequester = FilteredListingListRequester(itemsPerPage: SharedConstants.numListingsPerPageDefault, offset: listOffset)
            requestersArray.append(filteredRequester)
        }

        let requester = ListingListMultiRequester(requesters: requestersArray)
        if featureFlags.deckItemPage.isActive {
            openListingNewItemPage(listing,
                                   thumbnailImage: thumbnailImage,
                                   cellModels: nil,
                                   originFrame: nil,
                                   requester: requester,
                                   source: source,
                                   actionOnFirstAppear: actionOnFirstAppear,
                                   trackingIndex: nil)
        } else {
            let vm = ListingCarouselViewModel(listing: listing, thumbnailImage: thumbnailImage,
                                              listingListRequester: requester, source: source,
                                              actionOnFirstAppear: actionOnFirstAppear, trackingIndex: index)
            vm.navigator = listingDetailNavigator
            openListing(vm, thumbnailImage: thumbnailImage, originFrame: originFrame, listingId: listingId)
        }

    }

    func openListing(_ listing: Listing, cellModels: [ListingCellModel], requester: ListingListRequester,
                     thumbnailImage: UIImage?, originFrame: CGRect?, showRelated: Bool,
                     source: EventParameterListingVisitSource, index: Int) {
        if showRelated {
            //Same as single product opening
            openListing(listing: listing,
                        thumbnailImage: thumbnailImage,
                        originFrame: originFrame,
                        source: source,
                        requester: requester,
                        index: index,
                        discover: false,
                        actionOnFirstAppear: .nonexistent)
        } else if featureFlags.deckItemPage.isActive {
            openListingNewItemPage(listing,
                                   thumbnailImage: thumbnailImage,
                                   cellModels: cellModels,
                                   originFrame: originFrame,
                                   requester: requester,
                                   source: source,
                                   actionOnFirstAppear: .nonexistent,
                                   trackingIndex: index)
        } else {
            let vm = ListingCarouselViewModel(productListModels: cellModels, initialListing: listing,
                                              thumbnailImage: thumbnailImage, listingListRequester: requester, source: source,
                                              actionOnFirstAppear: .nonexistent, trackingIndex: index,
                                              firstProductSyncRequired: false)
            vm.navigator = listingDetailNavigator
            openListing(vm, thumbnailImage: thumbnailImage, originFrame: originFrame, listingId: listing.objectId)
        }
    }

    func openListing(chatConversation: ChatConversation, source: EventParameterListingVisitSource) {
        guard let localProduct = LocalProduct(chatConversation: chatConversation, myUser: myUserRepository.myUser),
            let listingId = localProduct.objectId else { return }
        let relatedRequester = RelatedListingListRequester(listingId: listingId,
                                                           itemsPerPage: SharedConstants.numListingsPerPageDefault)
        let filteredRequester = FilteredListingListRequester( itemsPerPage: SharedConstants.numListingsPerPageDefault, offset: 0)
        let requester = ListingListMultiRequester(requesters: [relatedRequester, filteredRequester])

        if featureFlags.deckItemPage.isActive {
            openListingNewItemPage(listing: .product(localProduct),
                                   listingListRequester: requester,
                                   source: source)
        } else {
            let vm = ListingCarouselViewModel(listing: .product(localProduct), listingListRequester: requester,
                                              source: source, actionOnFirstAppear: .nonexistent, trackingIndex: nil)
            vm.navigator = listingDetailNavigator
            openListing(vm, thumbnailImage: nil, originFrame: nil, listingId: listingId)
        }
    }

    func openListing(_ viewModel: ListingCarouselViewModel, thumbnailImage: UIImage?, originFrame: CGRect?,
                     listingId: String?) {
        let color = UIColor.placeholderBackgroundColor(listingId)
        let animator = ListingCarouselPushAnimator(originFrame: originFrame, originThumbnail: thumbnailImage,
                                                   backgroundColor: color)
        let vc = ListingCarouselViewController(viewModel: viewModel, pushAnimator: animator)
        navigationController.pushViewController(vc, animated: true)
    }

    func openListingNewItemPage(listing: Listing,
                                listingListRequester: ListingListRequester,
                                source: EventParameterListingVisitSource) {
        openListingNewItemPage(listing,
                               thumbnailImage: nil,
                               cellModels: nil,
                               originFrame: nil,
                               requester: listingListRequester,
                               source: source,
                               actionOnFirstAppear: .nonexistent,
                               trackingIndex: nil)
    }

    func openListingNewItemPage(_ listing: Listing,
                                thumbnailImage: UIImage?,
                                cellModels: [ListingCellModel]?,
                                originFrame: CGRect?,
                                requester: ListingListRequester,
                                source: EventParameterListingVisitSource,
                                actionOnFirstAppear: DeckActionOnFirstAppear,
                                trackingIndex: Int?) {
        if deckAnimator == nil {
            let coordinator = DeckCoordinator(withNavigationController: navigationController)
            deckAnimator = coordinator
        }

        let viewModel = ListingDeckViewModel(listModels: cellModels ?? [],
                                             listing: listing,
                                             listingListRequester: requester,
                                             source: source,
                                             detailNavigator: listingDetailNavigator,
                                             actionOnFirstAppear: actionOnFirstAppear,
                                             trackingIndex: trackingIndex)

        let deckViewController = ListingDeckViewController(viewModel: viewModel)
        viewModel.delegate = deckViewController

        deckAnimator?.setupWith(viewModel: viewModel)
        navigationController.pushViewController(deckViewController, animated: true)
    }

    func openUser(userId: String, source: UserSource) {
        userCoordinator.openUser(userId: userId, source: source)
    }
}

private extension ListingCoordinator {
    func openRelatedListingsForNonExistentListing(listingId: String,
                                                  source: EventParameterListingVisitSource,
                                                  requester: ListingListRequester,
                                                  relatedListings: [Listing]) {
        let vc = simpleListingAssembly.buildSimpleListingViewController(listingId: listingId,
                                                                        source: source,
                                                                        requester: requester,
                                                                        relatedListings: relatedListings,
                                                                        detailNavigator: listingDetailNavigator)
        navigationController.pushViewController(vc, animated: true)
        trackRelatedListings(listingId: listingId, source: .notFound)
    }
}

// MARK: Tracking
private extension ListingCoordinator {
    func trackProductNotAvailable(source: EventParameterListingVisitSource, repositoryError: RepositoryError) {
        var reason: EventParameterNotAvailableReason
        switch repositoryError {
        case .internalError, .wsChatError, .searchAlertError:
            reason = .internalError
        case .notFound:
            reason = .notFound
        case .unauthorized:
            reason = .unauthorized
        case .forbidden:
            reason = .forbidden
        case .tooManyRequests:
            reason = .tooManyRequests
        case .userNotVerified:
            reason = .userNotVerified
        case .serverError:
            reason = .serverError
        case .network:
            reason = .network
        }
        let productNotAvailableEvent = TrackerEvent.listingNotAvailable( source, reason: reason)
        tracker.trackEvent(productNotAvailableEvent)
    }

    func trackRelatedListings(listingId: String,
                              source: EventParameterRelatedListingsVisitSource) {
        let relatedListings = TrackerEvent.relatedListings(listingId: listingId,
                                                           source: source)
        tracker.trackEvent(relatedListings)
    }
}

