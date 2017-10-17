//
//  SellCoordinator.swift
//  LetGo
//
//  Created by Albert Hernández López on 20/06/16.
//  Copyright © 2016 Ambatana. All rights reserved.
//

import LGCoreKit
import RxSwift



protocol SellCoordinatorDelegate: class {
    func sellCoordinatorDidCancel(_ coordinator: SellCoordinator)
    func sellCoordinator(_ coordinator: SellCoordinator, didFinishWithListing listing: Listing)
}

final class SellCoordinator: Coordinator {
    var child: Coordinator?
    weak var coordinatorDelegate: CoordinatorDelegate?
    var viewController: UIViewController
    let navigationController: SellNavigationController
    weak var presentedAlertController: UIAlertController?
    let bubbleNotificationManager: BubbleNotificationManager
    let sessionManager: SessionManager
    
    fileprivate var parentViewController: UIViewController?

    fileprivate let listingRepository: ListingRepository
    fileprivate let keyValueStorage: KeyValueStorage
    fileprivate let tracker: Tracker
    fileprivate let featureFlags: FeatureFlaggeable
    fileprivate let postingSource: PostingSource
    fileprivate let postCategory: PostCategory?
    fileprivate var postingDetailStep: PostingDetailStep?
    weak var delegate: SellCoordinatorDelegate?

    fileprivate let disposeBag = DisposeBag()


    // MARK: - Lifecycle

    convenience init(source: PostingSource,
                     postCategory: PostCategory?,
                     forcedInitialTab: PostListingViewController.Tab?) {
        self.init(source: source,
                  postCategory: postCategory,
                  forcedInitialTab: forcedInitialTab,
                  listingRepository: Core.listingRepository,
                  bubbleNotificationManager: LGBubbleNotificationManager.sharedInstance,
                  keyValueStorage: KeyValueStorage.sharedInstance,
                  tracker: TrackerProxy.sharedInstance,
                  featureFlags: FeatureFlags.sharedInstance,
                  sessionManager: Core.sessionManager)
    }

    init(source: PostingSource,
         postCategory: PostCategory?,
         forcedInitialTab: PostListingViewController.Tab?,
         listingRepository: ListingRepository,
         bubbleNotificationManager: BubbleNotificationManager,
         keyValueStorage: KeyValueStorage,
         tracker: Tracker,
         featureFlags: FeatureFlags,
         sessionManager: SessionManager) {
        self.listingRepository = listingRepository
        self.bubbleNotificationManager = bubbleNotificationManager
        self.keyValueStorage = keyValueStorage
        self.tracker = tracker
        self.postingSource = source
        self.postCategory = postCategory
        self.featureFlags = featureFlags
        self.sessionManager = sessionManager
        let postListingVM = PostListingViewModel(source: source, postCategory: postCategory)
        let postListingVC = PostListingViewController(viewModel: postListingVM,
                                                      forcedInitialTab: forcedInitialTab)
        
        navigationController = SellNavigationController(rootViewController: postListingVC)
        navigationController.modalPresentationStyle = .overCurrentContext
        self.viewController = navigationController
        postListingVM.navigator = self
    }

    func presentViewController(parent: UIViewController, animated: Bool, completion: (() -> Void)?) {
        guard let postListingVC = viewController as? UINavigationController else { return }
        guard postListingVC.parent == nil else { return }

        parentViewController = parent
        parent.present(postListingVC, animated: animated, completion: completion)
    }

    func dismissViewController(animated: Bool, completion: (() -> Void)?) {
        viewController.dismissWithPresented(animated: animated, completion: completion)
    }
}


// MARK: - PostListingNavigator

extension SellCoordinator: PostListingNavigator {
    func cancelPostListing() {
        closeCoordinator(animated: true) { [weak self] in
            guard let strongSelf = self else { return }
            strongSelf.delegate?.sellCoordinatorDidCancel(strongSelf)
        }
    }

    func closePostProductAndPostInBackground(params: ListingCreationParams,
                                             trackingInfo: PostListingTrackingInfo) {
        dismissViewController(animated: true) { [weak self] in

            self?.listingRepository.create(listingParams: params) { result in
                if let listing = result.value {
                    self?.trackPost(withListing: listing, trackingInfo: trackingInfo)
                    self?.keyValueStorage.userPostProductPostedPreviously = true
                    self?.showConfirmation(listingResult: ListingResult(value: listing),
                                           trackingInfo: trackingInfo)
                } else if let error = result.error {
                    self?.trackListingPostedInBackground(withError: error)
                    self?.showConfirmation(listingResult: ListingResult(error: error),
                                           trackingInfo: trackingInfo)
                }
            }
        }
    }
    
    func startDetails(postListingState: PostListingState) {
        let viewModel = BasePostingDetailsViewModel(step: .propertyType)
        viewModel.navigator = self
        let vc = BasePostingDetailsViewController(viewModel: viewModel)
        postingDetailStep = .propertyType
        navigationController.updating(state: postListingState)
        navigationController.shouldModifyProgress = true
        navigationController.pushViewController(vc, animated: false)
    }
    
    func nextPostingDetailStep(step: PostingDetailStep) {
        let viewModel = BasePostingDetailsViewModel(step: step)
        viewModel.navigator = self
        let vc = BasePostingDetailsViewController(viewModel: viewModel)
        navigationController.pushViewController(vc, animated: true)
    }
    
    
    fileprivate func trackListingPostedInBackground(withError error: RepositoryError) {
        let sellError: EventParameterPostListingError
        switch error {
        case .network:
            sellError = .network
        case let .forbidden(cause: cause):
            sellError = .forbidden(cause: cause)
        case .serverError, .notFound, .unauthorized, .tooManyRequests, .userNotVerified:
           sellError = .serverError(code: error.errorCode)
        case .internalError, .wsChatError:
            sellError = .internalError
        }
        let sellErrorDataEvent = TrackerEvent.listingSellErrorData(sellError)
        TrackerProxy.sharedInstance.trackEvent(sellErrorDataEvent)
    }

    fileprivate func showConfirmation(listingResult: ListingResult, trackingInfo: PostListingTrackingInfo) {
        guard let parentVC = parentViewController else { return }
        
        let listingPostedVM = ListingPostedViewModel(listingResult: listingResult, trackingInfo: trackingInfo)
        listingPostedVM.navigator = self
        let listingPostedVC = ListingPostedViewController(viewModel: listingPostedVM)
        viewController = listingPostedVC
        parentVC.present(listingPostedVC, animated: true, completion: nil)
    }

    func closePostProductAndPostLater(params: ListingCreationParams, images: [UIImage],
                                      trackingInfo: PostListingTrackingInfo) {
        guard let parentVC = parentViewController else { return }

        dismissViewController(animated: true) { [weak self] in
            let listingPostedVM = ListingPostedViewModel(postParams: params, listingImages: images,
                                                         trackingInfo: trackingInfo)
            listingPostedVM.navigator = self
            let listingPostedVC = ListingPostedViewController(viewModel: listingPostedVM)
            self?.viewController = listingPostedVC
            parentVC.present(listingPostedVC, animated: true, completion: nil)
        }
    }

    func openLoginIfNeededFromListingPosted(from: EventParameterLoginSourceValue, loggedInAction: @escaping (() -> Void), cancelAction: (() -> Void)?) {
        openLoginIfNeeded(from: from, style: .popup(LGLocalizedString.productPostLoginMessage), loggedInAction: loggedInAction, cancelAction: cancelAction)
    }
}


// MARK: - ListingPostedNavigator

extension SellCoordinator: ListingPostedNavigator {
    func cancelListingPosted() {
        closeCoordinator(animated: true) { [weak self] in
            guard let strongSelf = self, let delegate = strongSelf.delegate else { return }

            delegate.sellCoordinatorDidCancel(strongSelf)
        }
    }

    func closeListingPosted(_ listing: Listing) {
        closeCoordinator(animated: true) { [weak self] in
            guard let strongSelf = self, let delegate = strongSelf.delegate else { return }

            delegate.sellCoordinator(strongSelf, didFinishWithListing: listing)
        }
    }

    func closeListingPostedAndOpenEdit(_ listing: Listing) {
        dismissViewController(animated: true) { [weak self] in
            guard let parentVC = self?.parentViewController else { return }

            // Open a coordinator @ ABIOS-2719
            let editVM = EditListingViewModel(listing: listing)
            editVM.closeCompletion = { editedListing in
                self?.closeCoordinator(animated: false) {
                    guard let strongSelf = self else { return }
                    strongSelf.delegate?.sellCoordinator(strongSelf, didFinishWithListing: editedListing ?? listing)
                }
            }
            let editVC = EditListingViewController(viewModel: editVM)
            let navCtl = UINavigationController(rootViewController: editVC)
            parentVC.present(navCtl, animated: true, completion: nil)
        }
    }

    func closeProductPostedAndOpenPost() {
        dismissViewController(animated: true) { [weak self] in
            guard let strongSelf = self, let parentVC = strongSelf.parentViewController else { return }
            let postListingVM = PostListingViewModel(source: strongSelf.postingSource, postCategory: nil)
            let postListingVC = PostListingViewController(viewModel: postListingVM,
                                                          forcedInitialTab: nil)
            strongSelf.viewController = postListingVC
            postListingVM.navigator = self

            strongSelf.presentViewController(parent: parentVC, animated: true, completion: nil)
        }
    }
}


// MARK: - Tracking

fileprivate extension SellCoordinator {
    func trackPost(withListing listing: Listing, trackingInfo: PostListingTrackingInfo) {
        let event = TrackerEvent.listingSellComplete(listing, buttonName: trackingInfo.buttonName, sellButtonPosition: trackingInfo.sellButtonPosition,
                                                     negotiable: trackingInfo.negotiablePrice, pictureSource: trackingInfo.imageSource,
                                                     freePostingModeAllowed: featureFlags.freePostingModeAllowed)

        tracker.trackEvent(event)

        // Track product was sold in the first 24h (and not tracked before)
        if let firstOpenDate = keyValueStorage[.firstRunDate], Date().timeIntervalSince(firstOpenDate) <= 86400 &&
                !keyValueStorage.userTrackingProductSellComplete24hTracked {
            keyValueStorage.userTrackingProductSellComplete24hTracked = true

            let event = TrackerEvent.listingSellComplete24h(listing)
            tracker.trackEvent(event)
        }
    }
}
