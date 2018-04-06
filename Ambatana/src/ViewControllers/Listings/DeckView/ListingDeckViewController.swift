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

    fileprivate let listingDeckView = ListingDeckView()
    fileprivate let viewModel: ListingDeckViewModel
    fileprivate let binder = ListingDeckViewControllerBinder()

    fileprivate var transitioner: PhotoViewerTransitionAnimator?
    private var lastPageBeforeDragging: Int = 0

    private let dismissTap = UITapGestureRecognizer()
    private var quickChatView: QuickChatView?
    var quickChatTopToCollectionBotton: NSLayoutConstraint?
    var chatEnabled: Bool = false { didSet { quickChatTopToCollectionBotton?.isActive = chatEnabled } }
    
    lazy var windowTargetFrame: CGRect = {
        let size = listingDeckView.cardSize
        let frame = CGRect(x: 20, y: 0, width: size.width, height: size.height)
        return listingDeckView.collectionView.convertToWindow(frame)
    }()

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

    override func viewDidFirstAppear(_ animated: Bool) {
        super.viewDidFirstAppear(animated)

        self.updateStartIndex()
        listingDeckView.collectionView.layoutIfNeeded()
        guard let current = currentPageCell() else { return }
        populateCell(current)
        let index = viewModel.currentIndex
        let bumpUp = viewModel.bumpUpBannerInfo.value
        UIView.animate(withDuration: 0.5,
                       delay: 0,
                       options: .curveEaseIn,
                       animations: { [weak self] in
                        self?.listingDeckView.collectionView.alpha = 1
        }, completion: { [weak self] _ in
            self?.didMoveToItemAtIndex(index)
            current.delayedOnboardingFlashDetails(withDelay: 0.3, duration: 0.6)
        })
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        dismissTap.addTarget(self, action: #selector(hideFullScreenChat))
        view.backgroundColor = listingDeckView.backgroundColor
        
        setupCollectionView()
        setupQuickChatView(viewModel.quickChatViewModel)
        setupRx()
        reloadData()
    }

    override func viewWillDisappearToBackground(_ toBackground: Bool) {
        super.viewWillDisappearToBackground(toBackground)
        listingDeckView.collectionView.clipsToBounds = true
        if toBackground {
            closeBumpUpBanner(animated: true)
        }
    }

    override func viewWillAppearFromBackground(_ fromBackground: Bool) {
        super.viewWillAppearFromBackground(fromBackground)
        setupNavigationBar()
        listingDeckView.collectionView.clipsToBounds = false
    }

    override func viewWillFirstAppear(_ animated: Bool) {
        super.viewWillFirstAppear(animated)
        listingDeckView.collectionView.alpha = 0
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
            guard let model = viewModel.snapshotModelAt(index: indexPath.row) else { return cell }
            cell.tag = indexPath.row
            binder.bind(cell: cell)
            cell.populateWith(model, imageDownloader: viewModel.imageDownloader)
            cell.delegate = self

            return cell
        }
        return UICollectionViewCell()
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
        UIView.animate(withDuration: 0.3, animations: { [weak self] in
            self?.quickChatView?.resignFirstResponder()
        }) { [weak self] (completion) in
            self?.viewModel.close()
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
    var rxDidBeginEditing: ControlEvent<()>? { return quickChatView?.rxDidBeginEditing }
    var rxDidEndEditing: ControlEvent<()>? { return quickChatView?.rxDidEndEditing }

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
        cell.isUserInteractionEnabled = indexPath.row == viewModel.currentIndex
        guard let card = cell as? ListingCardView else { return }
        card.updateVerticalContentInset(animated: false)
    }

    func willBeginDragging() {
        lastPageBeforeDragging = listingDeckView.currentPage
        listingDeckView.bumpUpBanner.alphaAnimated(0)
    }

    func didMoveToItemAtIndex(_ index: Int) {
        viewModel.didMoveToListing()
        if let left = listingDeckView.cardAtIndex(index - 1) {
            left.updateVerticalContentInset(animated: true)
            left.isUserInteractionEnabled = false
        }
        if let right = listingDeckView.cardAtIndex(index + 1) {
            right.updateVerticalContentInset(animated: true)
            right.isUserInteractionEnabled = false
        }
    }
    
    func didEndDecelerating() {
        guard let cell = listingDeckView.cardAtIndex(viewModel.currentIndex) else { return }
        populateCell(cell)
    }

    private func populateCell(_ card: ListingCardView) {
        card.isUserInteractionEnabled = true

        guard let listing = viewModel.listingCellModelAt(index: viewModel.currentIndex) else { return }
        card.populateWith(cellModel: listing, imageDownloader: viewModel.imageDownloader)
    }
    
    func cardViewDidShowMoreInfo(_ cardView: ListingCardView) {
        guard cardView.tag == viewModel.currentIndex else { return }
        guard isCardVisible(cardView) else { return }
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
        let height = view.bounds.height - keyboardChange.origin
        quickChatView?.updateWith(bottomInset: height,
                                  animationTime: TimeInterval(keyboardChange.animationTime),
                                  animationOptions: keyboardChange.animationOptions)
        if keyboardChange.visible {
            showFullScreenChat()
        } else {
            hideFullScreenChat()
        }
    }
    
    func updateViewWith(alpha: CGFloat, chatEnabled: Bool, isMine: Bool, actionsEnabled: Bool) {
        self.chatEnabled = chatEnabled
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
        updateChatWith(alpha: chatAlpha)
    }
    

    func didTapShare() {
        viewModel.currentListingViewModel?.shareProduct()
    }

    func didTapCardAction() {
        viewModel.didTapCardAction()
    }

    func updateWithBumpUpInfo(_ bumpInfo: BumpUpInfo?) {
        guard let bumpUp = bumpInfo else {
            closeBumpUpBanner(animated: true)
            return
        }

        listingDeckView.bumpUpBanner.alphaAnimated(1)
        guard !listingDeckView.isBumpUpVisible else {
            // banner is already visible, but info changes
            listingDeckView.updateBumpUp(withInfo: bumpUp)
            return
        }

        viewModel.bumpUpBannerShown(type: bumpUp.type)
        listingDeckView.updateBumpUp(withInfo: bumpUp)
        listingDeckView.bumpUpBanner.layoutIfNeeded()
        UIView.animate(withDuration: 0.3,
                       delay: 0,
                       options: .curveEaseIn,
                       animations: { [weak self] in
                        self?.listingDeckView.showBumpUp()
                        self?.listingDeckView.layoutIfNeeded()
            }, completion: nil)
    }

    private func isCardVisible(_ cardView: ListingCardView) -> Bool {
        let filtered = listingDeckView.collectionView
            .visibleCells
            .filter { cell in return cell.tag == cardView.tag }
        return !filtered.isEmpty
    }
}

// TODO: Refactor ABIOS-3814
extension ListingDeckViewController {
    private func processActionOnFirstAppear() {
        switch viewModel.actionOnFirstAppear {
        case .showKeyboard:
            quickChatView?.becomeFirstResponder()
        case .showShareSheet:
            viewModel.didTapCardAction()
        case .triggerBumpUp(_,_,_,_):
            viewModel.showBumpUpView(viewModel.actionOnFirstAppear)
        case .triggerMarkAsSold:
            viewModel.currentListingViewModel?.markAsSold()
        case .edit:
            viewModel.currentListingViewModel?.editListing()
        case .nonexistent:
            break
        }
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
        guard let cell = currentPageCell() else { return }
        listingDeckView.collectionView.isScrollEnabled = false
        cell.showFullMap(fromRect: snapshot.frame)
    }

    func cardViewDidTapOnPreview(_ cardView: ListingCardView) {
        guard cardView.tag == viewModel.currentIndex else { return }
        viewModel.openPhotoViewer()
    }
    
    func targetPage(forProposedPage proposedPage: Int, withScrollingDirection direction: ScrollingDirection) -> Int {
        guard direction != .none else {
            return proposedPage
        }
        return min(max(0, lastPageBeforeDragging + direction.delta), viewModel.objectCount - 1)
    }

    func didTapMapView() {
        guard let cell = currentPageCell()  else { return }
        listingDeckView.collectionView.isScrollEnabled = true
        cell.hideFullMap()
    }

    func cardViewDidTapOnStatusView(_ cardView: ListingCardView) {
        guard cardView.tag == viewModel.currentIndex else { return }
        viewModel.didTapStatusView()
    }

    // MARK: Chat
    override func resignFirstResponder() -> Bool {
        return quickChatView?.resignFirstResponder() ?? true
    }

    func updateChatWith(alpha: CGFloat) {
        quickChatView?.alpha = alpha
    }

    private func setupQuickChatView(_ viewModel: QuickChatViewModel) {
        let quickChatView = QuickChatView(chatViewModel: viewModel)
        quickChatView.addDismissGestureRecognizer(dismissTap)
        quickChatView.isRemovedWhenResigningFirstResponder = false
        setupDirectChatView(quickChatView: quickChatView)
        self.quickChatView = quickChatView
        
        focusOnCollectionView()

        mainResponder = quickChatView.textView
    }

    private func setupDirectChatView(quickChatView: QuickChatView) {
        quickChatView.isRemovedWhenResigningFirstResponder = false
        view.addSubviewForAutoLayout(quickChatView)
        quickChatView.layout(with: view).fillHorizontal().top().bottom(by: -Metrics.shortMargin)
        quickChatTopToCollectionBotton = listingDeckView.constraintCollectionBottomTo(quickChatView.directAnswersViewTopAnchor,
                                                                                      constant: -Metrics.margin)

        quickChatTopToCollectionBotton?.isActive = true
        focusOnCollectionView()
    }

    func showFullScreenChat() {
        guard let chatView = quickChatView else { return }
        quickChatTopToCollectionBotton?.isActive = false

        focusOnChat()
        chatView.becomeFirstResponder()
    }

    @objc func hideFullScreenChat() {
        quickChatView?.resignFirstResponder()
        quickChatTopToCollectionBotton?.isActive = chatEnabled
        focusOnCollectionView()
    }

    private func focusOnChat() {
        quickChatView?.isTableInteractionEnabled = true
    }

    func hideChat() {
        quickChatView?.alpha = 0
        focusOnCollectionView()
    }

    private func focusOnCollectionView() {
        quickChatView?.isTableInteractionEnabled = false
    }

    private func currentPageCell() -> ListingCardView? {
        return listingDeckView.cardAtIndex(viewModel.currentIndex)
    }
}

extension ListingDeckViewController {
    var photoViewerTransitionFrame: CGRect {
        guard let current = currentPageCell() else { return windowTargetFrame }
        let size = current.previewVisibleFrame.size
        let corrected = CGRect(x: current.frame.minX, y: current.frame.minY, width: size.width, height: size.height)
        return listingDeckView.collectionView.convertToWindow(corrected)
    }

    var animationController: UIViewControllerAnimatedTransitioning? {
        guard let cached = viewModel.cachedImageAtIndex(0) else { return nil }
        if transitioner == nil {
            transitioner = PhotoViewerTransitionAnimator(image: cached, initialFrame: photoViewerTransitionFrame)
        } else {
            transitioner?.setImage(cached)
        }
        return transitioner
    }
}