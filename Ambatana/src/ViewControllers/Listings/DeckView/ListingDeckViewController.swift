//
//  ListingDeckViewController.swift
//  LetGo
//
//  Created by Facundo Menzella on 23/10/2017.
//  Copyright © 2017 Ambatana. All rights reserved.
//

import Foundation
import UIKit
import LGCoreKit
import RxCocoa
import RxSwift

typealias DeckMovement = CarouselMovement

final class ListingDeckViewController: KeyboardViewController, UICollectionViewDataSource, UICollectionViewDelegate {
    override var preferredStatusBarStyle: UIStatusBarStyle { return .default }

    private var finishedTransition: Bool = false
    fileprivate let listingDeckView = ListingDeckView()
    fileprivate let viewModel: ListingDeckViewModel
    fileprivate let binder = ListingDeckViewControllerBinder()

    fileprivate var transitioner: PhotoViewerTransitionAnimator?
    private var lastPageBeforeDragging: Int = 0

    init(viewModel: ListingDeckViewModel) {
        self.viewModel = viewModel
        super.init(viewModel: viewModel, nibName: nil)
    }

    required init?(coder aDecoder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    override func loadView() {
        super.loadView()
        view.addSubviewForAutoLayout(listingDeckView)
        constraintViewToSafeRootView(listingDeckView)
    }

    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        listingDeckView.resignFirstResponder()
    }

    override func viewDidFirstAppear(_ animated: Bool) {
        super.viewDidFirstAppear(animated)
        setupPageCurrentCell()
        listingDeckView.currentPageCell()?.delayedOnboardingFlashDetails(withDelay: 0.6, duration: 0.6)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = listingDeckView.backgroundColor
 
        listingDeckView.setQuickChatViewModel(viewModel.quickChatViewModel)
        setupCollectionView()
        setupRx()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setupNavigationBar()
        listingDeckView.collectionView.clipsToBounds = false
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(true)
        listingDeckView.collectionView.clipsToBounds = true
    }

    override func viewWillAppearFromBackground(_ fromBackground: Bool) {
        super.viewWillAppearFromBackground(fromBackground)
        setupNavigationBar()
    }

    func updateStartIndex() {
        let startIndexPath = IndexPath(item: viewModel.startIndex, section: 0)
        listingDeckView.scrollToIndex(startIndexPath)
    }

    // MARK: Rx

    private func setupRx() {
        binder.listingDeckViewController = self
        binder.bind(withViewModel: viewModel, listingDeckView: listingDeckView)
    }

    // MARK: CollectionView

    private func setupCollectionView() {
        automaticallyAdjustsScrollViewInsets = false
        listingDeckView.collectionView.dataSource = self
        listingDeckView.setCollectionLayoutDelegate(self)
        listingDeckView.collectionView.register(ListingCardView.self,
                                                forCellWithReuseIdentifier: ListingCardView.reusableID)
    }

    func reloadData() {
        listingDeckView.collectionView.reloadData()
    }

    // MARK: UICollectionViewDataSource

    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return viewModel.objectCount
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if let cell = collectionView.dequeueReusableCell(withReuseIdentifier: ListingCardView.reusableID,
                                                         for: indexPath) as? ListingCardView {
            guard finishedTransition || isTransitionIndexPath(indexPath) else { return cell }
            guard let model = viewModel.snapshotModelAt(index: indexPath.row) else { return cell }
            cell.isUserInteractionEnabled = indexPath.row == listingDeckView.currentPage
            cell.populateWith(model, imageDownloader: viewModel.imageDownloader)
            cell.delegate = self
            cell.alpha = finishedTransition || indexPath.row == viewModel.currentIndex ? 1 : 0

            return cell
        }
        return UICollectionViewCell()
    }

    private func updateCellContentInset(_ cell: ListingCardView, animated: Bool) {
        let inset = listingDeckView.cellHeight * 0.8
        cell.setVerticalContentInset(inset, animated: animated)
    }

    // MARK: NavBar

    private func setupNavigationBar() {
        setNavBarBackgroundStyle(.transparent(substyle: .light))
        self.navigationController?.navigationBar.isTranslucent = true
        self.navigationController?.view.backgroundColor = .clear

        self.navigationItem.leftBarButtonItem  = UIBarButtonItem(image: #imageLiteral(resourceName: "ic_close_red"),
                                                                 style: .plain,
                                                                 target: self,
                                                                 action: #selector(didTapClose))

        self.navigationItem.rightBarButtonItem  = UIBarButtonItem(image: #imageLiteral(resourceName: "ic_more_options"),
                                                                  style: .plain,
                                                                  target: self,
                                                                  action: #selector(didTapMoreActions))
    }

    // Actions

    @objc private func didTapMoreActions() {
        var toShowActions = viewModel.navBarButtons
        let title = LGLocalizedString.productOnboardingShowAgainButtonTitle
        toShowActions.append(UIAction(interface: .text(title), action: { [weak viewModel] in
            viewModel?.showOnBoarding()
        }))
        showActionSheet(LGLocalizedString.commonCancel, actions: toShowActions, barButtonItem: nil)
    }

    @objc private func didTapClose() {
        closeBumpUpBanner(animated: false)
        UIView.animate(withDuration: 0.3, animations: {
            self.listingDeckView.resignFirstResponder()
        }) { (completion) in
            self.viewModel.close()
        }
    }

    private func closeBumpUpBanner(animated: Bool) {
        guard listingDeckView.isBumpUpVisible else { return }
        listingDeckView.hideBumpUp()
        if animated {
            UIView.animate(withDuration: 0.2,
                           delay: 0,
                           options: .curveEaseIn,
                           animations: { [weak self] in
                            self?.listingDeckView.itemActionsView.layoutIfNeeded()
                }, completion: nil)
        } else {
            listingDeckView.itemActionsView.layoutIfNeeded()
        }
    }
}

extension ListingDeckViewController: ListingDeckViewControllerBinderType {
    var rxContentOffset: Observable<CGPoint> { return listingDeckView.rxCollectionView.contentOffset.share() }

    func turnNavigationBar(_ on: Bool) {
        if on {
            navigationItem.hidesBackButton = false
            setupNavigationBar()
        } else {
            navigationItem.hidesBackButton = true
            navigationItem.leftBarButtonItem = UIBarButtonItem()
            navigationItem.rightBarButtonItem = UIBarButtonItem()
        }
    }

    func willDisplayCell(_ cell: UICollectionViewCell, atIndexPath indexPath: IndexPath) {
        guard finishedTransition || isTransitionIndexPath(indexPath) else { return }
        guard let card = cell as? ListingCardView else { return }
        updateCellContentInset(card, animated: false)
    }

    func willBeginDragging() {
        lastPageBeforeDragging = listingDeckView.currentPage
    }
    
    func didEndDecelerating() {
        listingDeckView.blockSideInteractions()
        listingDeckView.collectionView.visibleCells.flatMap { $0 as? ListingCardView }.forEach { cell in
            guard cell != listingDeckView.currentPageCell() else { return }
            updateCellContentInset(cell, animated: true)
        }
        setupPageCurrentCell()
    }

    private func setupPageCurrentCell() {
        guard let cell = listingDeckView.currentPageCell() else { return }
        binder.bind(cell: cell)
        cell.isUserInteractionEnabled = true

        let currentPage = listingDeckView.currentPage
        guard let listing = viewModel.listingCellModelAt(index: currentPage) else { return }
        cell.populateWith(cellModel: listing, imageDownloader: viewModel.imageDownloader)
        viewModel.didMoveToListing()
    }

    func didShowMoreInfo() {
        viewModel.didShowMoreInfo()
    }

    func didTapOnUserIcon() {
        viewModel.showUser()
    }

    func updateViewWithActions(_ actionButtons: [UIAction]) {
        guard let actionButton = actionButtons.first else {
            return
        }
        listingDeckView.configureActionWith(actionButton)
    }

    func updateWith(keyboardChange: KeyboardChange) {
        let height = listingDeckView.bounds.height - keyboardChange.origin
        listingDeckView.updateWith(bottomInset: height,
                                   animationTime: TimeInterval(keyboardChange.animationTime),
                                   animationOptions: keyboardChange.animationOptions,
                                   completion: nil)
        if keyboardChange.visible {
            listingDeckView.showFullScreenChat()
        } else {
            listingDeckView.hideFullScreenChat()
        }
    }
    
    func updateViewWith(alpha: CGFloat, chatEnabled: Bool, isMine: Bool, actionsEnabled: Bool) {
        listingDeckView.chatEnabled = chatEnabled
        let chatAlpha: CGFloat
        let actionsAlpha: CGFloat
        if isMine && actionsEnabled {
            actionsAlpha = min(1.0, alpha)
            chatAlpha = 0
        } else if !chatEnabled {
            actionsAlpha = 0
            chatAlpha = 0
        } else {
            chatAlpha = min(1.0, alpha)
            actionsAlpha = 0
        }

        listingDeckView.updatePrivateActionsWith(alpha: actionsAlpha)
        listingDeckView.updateChatWith(alpha: chatAlpha)
    }
    

    func didTapShare() {
        viewModel.currentListingViewModel?.shareProduct()
    }

    func didTapCardAction() {
        viewModel.didTapCardAction()
    }

    func showBumpUpBanner(bumpInfo: BumpUpInfo) {
        guard !listingDeckView.isBumpUpVisible else {
            // banner is already visible, but info changes
            listingDeckView.updateBumpUp(withInfo: bumpInfo)
            return
        }

        viewModel.bumpUpBannerShown(type: bumpInfo.type)
        delay(1.0) { [weak self] in
            self?.listingDeckView.updateBumpUp(withInfo: bumpInfo)
            self?.listingDeckView.showBumpUp()
            UIView.animate(withDuration: 0.3,
                           delay: 0,
                           options: .curveEaseIn,
                           animations: { [weak self] in
                self?.listingDeckView.layoutIfNeeded()
            }, completion: nil)
        }
    }

    func closeBumpUpBanner() {
        closeBumpUpBanner(animated: true)
    }
}

extension ListingDeckViewController: ListingDeckViewModelDelegate {

    func vmShareViewControllerAndItem() -> (UIViewController, UIBarButtonItem?) {
        return (self, navigationItem.rightBarButtonItems?.first)
    }

    func vmResetBumpUpBannerCountdown() {
        listingDeckView.resetBumpUpCountdown()
    }
}

extension ListingDeckViewController: ListingCardDetailsViewDelegate, ListingCardViewDelegate, ListingCardDetailMapViewDelegate, ListingDeckCollectionViewLayoutDelegate {
    func viewControllerToShowShareOptions() -> UIViewController { return self }

    func didTapOnMapSnapshot(_ snapshot: UIView) {
        guard let cell = listingDeckView.currentPageCell() else { return }
        listingDeckView.collectionView.isScrollEnabled = false
        cell.showFullMap(fromRect: snapshot.frame)
    }

    func didTapOnPreview() {
        displayPhotoViewer()
    }

    func displayPhotoViewer() {
        viewModel.openPhotoViewer()
    }
    
    func targetPage(forProposedPage proposedPage: Int, withScrollingDirection direction: ScrollingDirection) -> Int {
        guard direction != .none else {
            return proposedPage
        }
        return min(max(0, lastPageBeforeDragging + direction.delta), viewModel.objectCount - 1)
    }

    func didTapMapView() {
        guard let cell = listingDeckView.currentPageCell()  else { return }
        listingDeckView.collectionView.isScrollEnabled = true
        cell.hideFullMap()
    }

    func didTapOnStatusView() {
        viewModel.didTapStatusView()
    }
}

extension ListingDeckViewController {
    func transitionCell() -> ListingCardView? {
        let indexPath = IndexPath(row: viewModel.startIndex, section: 0)
        guard let card = collectionView(listingDeckView.collectionView, cellForItemAt: indexPath) as? ListingCardView else { return nil }
        updateCellContentInset(card, animated: false)
        return card
    }
    var windowTargetFrame: CGRect {
        let size = listingDeckView.cardSize
        let frame = CGRect(x: 20, y: 0, width: size.width, height: size.height)
        return listingDeckView.collectionView.convertToWindow(frame)
    }
    func isTransitionIndexPath(_ indexPath: IndexPath) -> Bool {
        return indexPath.row >= viewModel.startIndex - 1 && indexPath.row <= viewModel.startIndex + 1
    }
    var animationController: UIViewControllerAnimatedTransitioning? {
        if transitioner == nil {
            guard let cell = listingDeckView.currentPageCell()  else { return nil }
            let frame = cell.convert(cell.previewImageViewFrame, to: listingDeckView)
            
            guard let url = viewModel.urlAtIndex(0),
                let cached = viewModel.imageDownloader.cachedImageForUrl(url) else { return nil }
            transitioner = PhotoViewerTransitionAnimator(image: cached, initialFrame: frame)
        }
        guard let url = viewModel.urlAtIndex(0),
            let cached = viewModel.imageDownloader.cachedImageForUrl(url) else { return nil }
        transitioner?.setImage(cached)
        return transitioner
    }

    func endTransitionAnimation() {
        finishedTransition = true
        UIView.animate(withDuration: 0.3) { [weak self] in
            self?.updateSideCellsWithAlpha(1)
        }
    }

    func updateSideCellsWithAlpha(_ alpha: CGFloat) {
        let current = viewModel.startIndex
        listingDeckView.cardAtIndex(current - 1)?.alpha = alpha
        listingDeckView.cardAtIndex(current + 1)?.alpha = alpha
    }
}
