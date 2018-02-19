//
//  ListingDeckViewController.swift
//  LetGo
//
//  Created by Facundo Menzella on 23/10/2017.
//  Copyright © 2017 Ambatana. All rights reserved.
//

import Foundation
import UIKit
import RxCocoa
import RxSwift

final class ListingDeckViewController: KeyboardViewController, UICollectionViewDataSource, UICollectionViewDelegate {
    override var preferredStatusBarStyle: UIStatusBarStyle { return .default }

    var cardInsets: UIEdgeInsets { return listingDeckView.cardsInsets }

    fileprivate let listingDeckView = ListingDeckView()
    fileprivate let viewModel: ListingDeckViewModel
    fileprivate let binder = ListingDeckViewControllerBinder()

    fileprivate var transitioner: PhotoViewerTransitionAnimator?

    init(viewModel: ListingDeckViewModel) {
        self.viewModel = viewModel
        super.init(viewModel: viewModel, nibName: nil)
    }

    required init?(coder aDecoder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    override func loadView() {
        self.view = listingDeckView
    }

    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        listingDeckView.updateTop(wintInset: topBarHeight)
    }

    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        listingDeckView.resignFirstResponder()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        onboardingFlashDetails()
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        listingDeckView.setQuickChatViewModel(viewModel.quickChatViewModel)
        setupRx()

        setupCollectionView()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setupNavigationBar()
    }

    func cardSystemLayoutSizeFittingSize(_ target: CGSize) -> CGSize {
        return listingDeckView.cardSystemLayoutSizeFittingSize(target)
    }

    // MARK: Rx

    private func setupRx() {
        binder.listingDeckViewController = self
        binder.bind(withViewModel: viewModel, listingDeckView: listingDeckView)
    }

    // MARK: CollectionView

    private func setupCollectionView() {
        listingDeckView.collectionView.dataSource = self
        listingDeckView.collectionView.register(ListingCardView.self, forCellWithReuseIdentifier: ListingCardView.reusableID)

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
        if let cell = collectionView.dequeueReusableCell(withReuseIdentifier: ListingCardView.reusableID, for: indexPath) as? ListingCardView {
            guard let listing = viewModel.listingCellModelAt(index: indexPath.row) else {
                return cell
            }
            cell.populateWith(listingViewModel: listing, imageDownloader: viewModel.imageDownloader)
            binder.bind(cell: cell)
            cell.delegate = self
            cell.isUserInteractionEnabled = (indexPath.row == listingDeckView.currentPage)
            return cell
        }
        return UICollectionViewCell()
    }

    // MARK: NavBar

    private func setupNavigationBar() {
        setNavBarBackgroundStyle(.transparent(substyle: .light))
        self.navigationController?.navigationBar.isTranslucent = true
        self.navigationController?.view.backgroundColor = .clear

        let leftButton = UIBarButtonItem(image: #imageLiteral(resourceName: "ic_close_red"), style: .plain, target: self, action: #selector(didTapClose))
        self.navigationItem.leftBarButtonItem  = leftButton
    }

    // Actions

    @objc private func didTapClose() {
        closeBumpUpBanner()
        UIView.animate(withDuration: 0.3, animations: {
            self.listingDeckView.resignFirstResponder()
        }) { (completion) in
            self.viewModel.close()
        }
    }

    func closeBumpUpBanner() {
        listingDeckView.hideBumpUp()
        UIView.animate(withDuration: 0.3,
                       delay: 0,
                       usingSpringWithDamping: 6.0,
                       initialSpringVelocity: 3.0,
                       options: .layoutSubviews, animations: {
                        self.listingDeckView.layoutIfNeeded()
        }, completion: nil)
    }
}

extension ListingDeckViewController {
    private func onboardingFlashDetails() {
        guard let current = listingDeckView.collectionView.cellForItem(at: IndexPath(row: 0, section: 0)) else { return }
        guard let cell = current as? ListingCardView else { return }
        cell.onboardingFlashDetails()
    }
}

extension ListingDeckViewController: ListingDeckViewControllerBinderType {
    func didTapOnUserIcon() {
        viewModel.showUser()
    }

    func blockSideInteractions() {
        listingDeckView.blockSideInteractions()
    }

    var rxContentOffset: Observable<CGPoint> { return listingDeckView.rxCollectionView.contentOffset.share() }

    func setLetGoRightButtonWith(_ action: UIAction, buttonTintColor: UIColor?, tapBlock: (ControlEvent<Void>) -> Void) {
        super.setLetGoRightButtonWith(action, buttonTintColor: buttonTintColor, tapBlock: tapBlock)
    }

    func updateViewWithActions(_ actionButtons: [UIAction]) {
        guard let actionButton = actionButtons.first else {
            listingDeckView.hideActions()
            return
        }
        listingDeckView.configureActionWith(actionButton)
        UIView.animate(withDuration: 0.2, animations: { [weak self] in
            self?.listingDeckView.showActions()
        })
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
    
    func updateViewWith(alpha: CGFloat, chatEnabled: Bool) {
        guard chatEnabled else {
            listingDeckView.updatePrivateActionsWith(alpha: 0)
            listingDeckView.updateChatWith(alpha: 0)
            return
        }
        let clippedAlpha = min(1.0, alpha)
        let chatAlpha = chatEnabled ? clippedAlpha : 0
        let actionsAlpha = chatEnabled ? 0 : clippedAlpha

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
            self?.listingDeckView.bumpUpBanner.setNeedsLayout()
            self?.listingDeckView.bumpUpBanner.layoutIfNeeded()

            UIView.animate(withDuration: 0.3,
                           delay: 0,
                           usingSpringWithDamping: 6.0,
                           initialSpringVelocity: 3.0,
                           options: .layoutSubviews, animations: {
                            self?.listingDeckView.showBumpUp()
                            self?.listingDeckView.layoutIfNeeded()
            }, completion: nil)
        }
    }
}

extension ListingDeckViewController: ListingDeckViewModelDelegate {
    func vmShowOptions(_ cancelLabel: String, actions: [UIAction]) {
        showActionSheet(cancelLabel, actions: actions, barButtonItem: nil)
    }

    func vmShowProductDetailOptions(_ cancelLabel: String, actions: [UIAction]) {
        showActionSheet(cancelLabel, actions: actions, barButtonItem: navigationItem.rightBarButtonItems?.first)
    }

    func vmShareViewControllerAndItem() -> (UIViewController, UIBarButtonItem?) {
        return (self, navigationItem.rightBarButtonItems?.first)
    }

    func vmResetBumpUpBannerCountdown() {
        listingDeckView.resetBumpUpCountdown()
    }
}

extension ListingDeckViewController: ListingCardDetailsViewDelegate, ListingCardViewDelegate, ListingCardDetailMapViewDelegate {
    func viewControllerToShowShareOptions() -> UIViewController { return self }

    func didTapOnMapSnapshot(_ snapshot: UIView) {
        let page = listingDeckView.currentPage
        guard let cell = listingDeckView.collectionView.cellForItem(at: IndexPath(row: page, section: 0))
            as? ListingCardView else { return }

        listingDeckView.collectionView.isScrollEnabled = false
        cell.showFullMap(fromRect: snapshot.frame)
    }

    func didTapOnPreview() {
        displayPhotoViewer()
    }

    func displayPhotoViewer() {
        viewModel.openPhotoViewer()
    }

    func didTapMapView() {
        let page = listingDeckView.currentPage
        guard let cell = listingDeckView.collectionView.cellForItem(at: IndexPath(row: page, section: 0))
            as? ListingCardView else { return }
        listingDeckView.collectionView.isScrollEnabled = true
        cell.hideFullMap()
    }

    func didTapOnStatusView() {
        viewModel.didTapStatusView()
    }
}

extension ListingDeckViewController {

    var animationController: UIViewControllerAnimatedTransitioning? {
            if transitioner == nil {
                let current = listingDeckView.currentPage
                let cell = listingDeckView.collectionView.cellForItem(at: IndexPath(row: current, section: 0)) as! ListingCardView
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
}
