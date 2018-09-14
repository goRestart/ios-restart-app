import Foundation
import UIKit
import LGCoreKit
import RxCocoa
import RxSwift
import LGComponents
import GoogleMobileAds

typealias DeckMovement = CarouselMovement

final class ListingDeckViewController: KeyboardViewController, UICollectionViewDelegate {
    private enum Layout {
        enum Insets {
            static let chat: CGFloat = 75
            static let bump: CGFloat = 80
        }
    }
    override var preferredStatusBarStyle: UIStatusBarStyle { return .default }

    fileprivate let quickChatVC: QuickChatViewController
    fileprivate let listingDeckView = ListingDeckView()
    private let collectionDataSource: DeckCollectionDataSource
    private let collectionDelegate: DeckViewCollectionDelegate

    fileprivate let viewModel: ListingDeckViewModel
    fileprivate let binder = ListingDeckViewControllerBinder()
    fileprivate let disposeBag = DisposeBag()
    private lazy var cardOnBoarding = ListingCardOnBoardingView()

    private let shouldShowCardsOnBoarding: Bool

    private var interstitial: GADInterstitial?
    private var firstAdShowed = false
    private var lastIndexAd = -1

    init(viewModel: ListingDeckViewModel) {
        self.viewModel = viewModel
        self.shouldShowCardsOnBoarding = viewModel.shouldShowCardGesturesOnBoarding
        self.collectionDataSource =  DeckCollectionDataSource(withViewModel: viewModel,
                                                              imageDownloader: viewModel.imageDownloader)
        self.collectionDelegate = DeckViewCollectionDelegate(viewModel: viewModel, listingDeckView: listingDeckView)

        self.quickChatVC = QuickChatViewController(listingViewModel: viewModel.currentListingViewModel)
        super.init(viewModel: viewModel, nibName: nil)
        self.hidesBottomBarWhenPushed = true
        self.collectionDataSource.delegate = collectionDelegate
    }

    @available(*, unavailable)
    required init?(coder aDecoder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    override func loadView() {
        super.loadView()
        view.addSubviewForAutoLayout(listingDeckView)
        constraintViewToSafeRootView(listingDeckView)
    }

    private func addQuickChat() {
        addChildViewController(quickChatVC)
        listingDeckView.addSubviewForAutoLayout(quickChatVC.view)

        NSLayoutConstraint.activate([
            quickChatVC.view.topAnchor.constraint(equalTo: safeTopAnchor),
            quickChatVC.view.leadingAnchor.constraint(equalTo: listingDeckView.leadingAnchor),
            quickChatVC.view.trailingAnchor.constraint(equalTo: listingDeckView.trailingAnchor),
            quickChatVC.view.bottomAnchor.constraint(equalTo: safeBottomAnchor)
        ])
    }

    override func viewDidFirstAppear(_ animated: Bool) {
        super.viewDidFirstAppear(animated)
        updateStartIndex()
        listingDeckView.collectionView.layoutIfNeeded()
        guard let current = currentPageCell() else { return }
        current.isUserInteractionEnabled = true
        UIView.animate(withDuration: 0.5,
                       delay: 0,
                       options: .curveEaseIn,
                       animations: { [weak self] in
                        self?.listingDeckView.collectionView.alpha = 1
        }, completion: { [weak self] _ in
            self?.didAnimateCollectionViewAppearence(withCurrentCell: current)
        })
    }

    private func didAnimateCollectionViewAppearence(withCurrentCell current: ListingCardView) {
        didMoveToItemAtIndex(viewModel.currentIndex)
        guard shouldShowCardsOnBoarding else { return }
        viewModel.didShowCardsGesturesOnBoarding()
        showCardGestureNavigation(withCurrentCell: current)
    }

    private func showCardGestureNavigation(withCurrentCell current: ListingCardView) {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(removeOnBoarding))
        cardOnBoarding.addGestureRecognizer(tapGesture)

        cardOnBoarding.alpha = 0
        current.contentView.addSubviewForAutoLayout(cardOnBoarding)
        cardOnBoarding.layout(with: current.contentView).fill()
        cardOnBoarding.animateTo(alpha: 1)
    }

    @objc private func removeOnBoarding() {
        cardOnBoarding.animateTo(alpha: 0, duration: 0.3) { [weak self] (completion) in
            self?.cardOnBoarding.removeFromSuperview()
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        addQuickChat()

        view.backgroundColor = listingDeckView.backgroundColor
        
        setupCollectionView()
        setupRx()
        reloadData()
        setupInterstitial()

        let bindings = [
            viewModel.rx.listingStatus.drive(rx.status)
        ]
        bindings.forEach { $0.disposed(by: disposeBag) }
    }

    override func viewWillDisappearToBackground(_ toBackground: Bool) {
        super.viewWillDisappearToBackground(toBackground)
        listingDeckView.collectionView.clipsToBounds = true
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
        listingDeckView.collectionView.dataSource = self.collectionDataSource
        listingDeckView.setCollectionLayoutDelegate(collectionDelegate)
        listingDeckView.collectionView.register(ListingCardView.self,
                                                forCellWithReuseIdentifier: ListingCardView.reusableID)
    }

    func reloadData() {
        listingDeckView.collectionView.reloadData()
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

extension ListingDeckViewController {

    func willDisplayCell(_ cell: UICollectionViewCell, atIndexPath indexPath: IndexPath) {
        cell.isUserInteractionEnabled = indexPath.row == viewModel.currentIndex
    }

    func willBeginDragging() {
        collectionDelegate.lastPageBeforeDragging = listingDeckView.currentPage
        listingDeckView.bumpUpBanner.animateTo(alpha: 0)
    }

    func didMoveToItemAtIndex(_ index: Int) {
        listingDeckView.cardAtIndex(index - 1)?.isUserInteractionEnabled = false
        listingDeckView.cardAtIndex(index)?.isUserInteractionEnabled = true
        listingDeckView.cardAtIndex(index + 1)?.isUserInteractionEnabled = false
    }

    func didTapStatus() {
        viewModel.didTapStatusView()
    }
    
    func didEndDecelerating() {
        guard let cell = listingDeckView.cardAtIndex(viewModel.currentIndex) else { return }
        cell.isUserInteractionEnabled = true
        collectionDelegate.lastPageBeforeDragging = listingDeckView.currentPage
    }

    func didTapShare() {
        viewModel.currentListingViewModel.shareProduct()
    }
    
    func presentInterstitialAtIndex(_ index: Int) {
        viewModel.presentInterstitial(self.interstitial, index: index, fromViewController: self)
    }
}

extension ListingDeckViewController {
    private func currentPageCell() -> ListingCardView? {
        return listingDeckView.cardAtIndex(viewModel.currentIndex)
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

// MARK: Rx

extension Reactive where Base: ListingDeckViewController {
    var contentOffset: Observable<CGPoint> {
        return base.listingDeckView.rx.collectionView.contentOffset.asObservable()
    }

    var action: Binder<UIAction?> {
        return Binder(self.base) { controller, actionable in
            controller.listingDeckView.configureActionWith(actionable)

            guard let actionable = actionable else { return }
            controller.listingDeckView.rx.actionButton
                .tap
                .takeUntil(controller.viewModel.rx.actionButtons)
                .bind {
                actionable.action()
            }.disposed(by: controller.disposeBag)
        }
    }

    var actionsAlpha: Binder<CGFloat> {
        return Binder(self.base) { controller, alpha in
            let clippedAlpha = min(1.0, alpha)
            controller.listingDeckView.statusView.alpha = clippedAlpha
            controller.listingDeckView.updatePrivateActionsWith(actionsAlpha: clippedAlpha)
        }
    }

    var chatAlpha: Binder<CGFloat> {
        return Binder(self.base) { controller, alpha in
            controller.quickChatVC.view.alpha = alpha
        }
    }

    var status: Binder<ListingDeckStatus?> {
        return Binder(self.base) { controller, status in
            guard let status = status else { return }
            let statusVisible = status.isFeatured || status.status.shouldShowStatus
            controller.listingDeckView.statusView.isHidden = !statusVisible
            controller.listingDeckView.statusView.setFeaturedStatus(status.status, featured: status.isFeatured)
        }
    }

    var bumpUp: Binder<BumpUpInfo?> {
        return Binder(self.base) { controller, bumpUpData in
            controller.updateWithBumpUpInfo(bumpUpData)
        }
    }
}

extension ListingDeckViewController {
    func updateWithBumpUpInfo(_ bumpInfo: BumpUpInfo?) {
        guard let bumpUp = bumpInfo else {
            closeBumpUpBanner(animated: true)
            return
        }

        listingDeckView.updateBumpUp(withInfo: bumpUp)

        guard !listingDeckView.isBumpUpVisible else { return }
        viewModel.bumpUpBannerShown(bumpInfo: bumpUp)

        listingDeckView.showBumpUp()
        UIView.animate(withDuration: 0.3,
                       delay: 0,
                       options: .curveEaseIn,
                       animations: { [weak self] in
                        self?.listingDeckView.itemActionsView.layoutIfNeeded()
            }, completion: nil)
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
