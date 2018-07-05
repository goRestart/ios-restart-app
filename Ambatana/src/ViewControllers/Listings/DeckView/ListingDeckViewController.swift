import Foundation
import UIKit
import LGCoreKit
import RxCocoa
import RxSwift
import LGComponents
import GoogleMobileAds

typealias DeckMovement = CarouselMovement

final class ListingDeckViewController: BaseViewController, UICollectionViewDataSource, UICollectionViewDelegate {
    private struct Layout {
        struct Insets {
            static let chat: CGFloat = 75
            static let bump: CGFloat = 80
        }
    }
    override var preferredStatusBarStyle: UIStatusBarStyle { return .default }

    fileprivate let listingDeckView = ListingDeckView()
    fileprivate let viewModel: ListingDeckViewModel
    fileprivate let binder = ListingDeckViewControllerBinder()

    fileprivate var transitioner: PhotoViewerTransitionAnimator?
    private var lastPageBeforeDragging: Int = 0

    private var interstitial: GADInterstitial?
    private var firstAdShowed = false
    private var lastIndexAd = -1
    
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

        updateStartIndex()
        listingDeckView.collectionView.layoutIfNeeded()
        guard let current = currentPageCell() else { return }
        populateCell(current)
        let index = viewModel.currentIndex
        UIView.animate(withDuration: 0.5,
                       delay: 0,
                       options: .curveEaseIn,
                       animations: { [weak self] in
                        self?.listingDeckView.collectionView.alpha = 1
        }, completion: { [weak self] _ in
            self?.didMoveToItemAtIndex(index)
        })
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = listingDeckView.backgroundColor
        
        setupCollectionView()
        setupRx()
        reloadData()
        setupInterstitial()
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
    
    private func setupInterstitial() {
        interstitial = viewModel.createAndLoadInterstitial()
        if let interstitial = interstitial {
            interstitial.delegate = self
        }
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

        self.navigationItem.leftBarButtonItem  = UIBarButtonItem(image: R.Asset.CongratsScreenImages.icCloseRed.image,
                                                                 style: .plain,
                                                                 target: self,
                                                                 action: #selector(didTapClose))

        self.navigationItem.rightBarButtonItem  = UIBarButtonItem(image: R.Asset.IconsButtons.icMoreOptions.image,
                                                                  style: .plain,
                                                                  target: self,
                                                                  action: #selector(didTapMoreActions))
    }

    // Actions

    @objc private func didTapMoreActions() {
        var toShowActions = viewModel.navBarButtons
        let title = R.Strings.productOnboardingShowAgainButtonTitle
        toShowActions.append(UIAction(interface: .text(title), action: { [weak viewModel] in
            viewModel?.showOnBoarding()
        }))
        showActionSheet(R.Strings.commonCancel, actions: toShowActions, barButtonItem: nil)
    }

    @objc private func didTapClose() {
        closeBumpUpBanner(animated: false)
        viewModel.close()
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

    func willDisplayCell(_ cell: UICollectionViewCell, atIndexPath indexPath: IndexPath) {
        cell.isUserInteractionEnabled = indexPath.row == viewModel.currentIndex
    }

    func willBeginDragging() {
        lastPageBeforeDragging = listingDeckView.currentPage
        listingDeckView.bumpUpBanner.animateTo(alpha: 0)
        animatePlayButton(withAlpha: 0)
    }

    func didMoveToItemAtIndex(_ index: Int) {
        viewModel.didMoveToListing()
        listingDeckView.cardAtIndex(index - 1)?.isUserInteractionEnabled = false
        listingDeckView.cardAtIndex(index + 1)?.isUserInteractionEnabled = false
        animatePlayButton(withAlpha: viewModel.isPlayable ? 1 : 0)
    }
    
    func didEndDecelerating() {
        guard let cell = listingDeckView.cardAtIndex(viewModel.currentIndex) else { return }
        populateCell(cell)
        animatePlayButton(withAlpha: viewModel.isPlayable ? 1 : 0)
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

    func updateViewWithActions(_ actionButtons: [UIAction]) {
        guard let actionButton = actionButtons.first else { return }
        listingDeckView.configureActionWith(actionButton)
    }
    
    func updateViewWith(alpha: CGFloat, chatEnabled: Bool, actionsEnabled: Bool) {

        let clippedAlpha = min(1.0, alpha)

        let actionsAlpha = actionsEnabled ? clippedAlpha : 0
        let bumpBannerAlpha: CGFloat = (actionsEnabled || !chatEnabled) ? 1.0 : 0

        listingDeckView.updatePrivateActionsWith(actionsAlpha: actionsAlpha, bumpBannerAlpha: bumpBannerAlpha)
        updateChatWith(alpha: (chatEnabled && !actionsEnabled) ? clippedAlpha : 0)
    }

    func updateChatWith(alpha: CGFloat) {
        // TODO: Handle interested button
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

        listingDeckView.bumpUpBanner.animateTo(alpha: 1)
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
    
    func presentInterstitialAtIndex(_ index: Int) {
        viewModel.presentInterstitial(self.interstitial, index: index, fromViewController: self)
    }

    private func isCardVisible(_ cardView: ListingCardView) -> Bool {
        let filtered = listingDeckView.collectionView
            .visibleCells
            .filter { cell in return cell.tag == cardView.tag }
        return !filtered.isEmpty
    }

    private func animatePlayButton(withAlpha alpha: CGFloat) {
        guard viewModel.isPlayable else {
            listingDeckView.updatePlayButtonWith(alpha: 0)
            return
        }
        UIView.animate(withDuration: 0.3) {
            self.listingDeckView.updatePlayButtonWith(alpha: alpha)
        }
    }
}

// TODO: Refactor ABIOS-3814
extension ListingDeckViewController {
    private func processActionOnFirstAppear() {
        switch viewModel.actionOnFirstAppear {
        case .showKeyboard:
            break // we no longer support this one
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

extension ListingDeckViewController: DeckMapViewDelegate {
    func deckMapViewDidTapOnView(_ vc: DeckMapViewController) {
        dismiss(animated: true, completion: nil)
    }
}

extension ListingDeckViewController: ListingCardDetailsViewDelegate, ListingCardViewDelegate, ListingDeckCollectionViewLayoutDelegate {
    func viewControllerToShowShareOptions() -> UIViewController { return self }
    
    func targetPage(forProposedPage proposedPage: Int, withScrollingDirection direction: ScrollingDirection) -> Int {
        guard direction != .none else {
            return proposedPage
        }
        return min(max(0, lastPageBeforeDragging + direction.delta), viewModel.objectCount - 1)
    }

    func cardViewDidTapOnStatusView(_ cardView: ListingCardView) {
        guard cardView.tag == viewModel.currentIndex else { return }
        viewModel.didTapStatusView()
    }

    func cardViewDidTapOnReputationTooltip(_ cardView: ListingCardView) {
        viewModel.didTapReputationTooltip()
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

// MARK: - GADIntertitialDelegate

extension ListingDeckViewController: GADInterstitialDelegate {
    
    /// Tells the delegate the interstitial had been animated off the screen.
    func interstitialDidDismissScreen(_ ad: GADInterstitial) {
        setupInterstitial()
    }
    
    func interstitialWillPresentScreen(_ ad: GADInterstitial) {
        viewModel.interstitialAdShown(typePage: EventParameterTypePage.nextItem)
    }
    
    func interstitialWillLeaveApplication(_ ad: GADInterstitial) {
        viewModel.interstitialAdTapped(typePage: EventParameterTypePage.nextItem)
    }
    
}
