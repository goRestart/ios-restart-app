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
        static let buttonHeight: CGFloat = 50
    }
    override var preferredStatusBarStyle: UIStatusBarStyle { return .default }

    fileprivate lazy var quickChatVC = QuickChatViewController(listingViewModel: viewModel.currentListingViewModel)
    fileprivate lazy var bumpUpVC = BumpUpContainerViewController()

    fileprivate let actionButton: LetgoButton = {
        let button = LetgoButton(withStyle: .terciary)
        button.setTitle(R.Strings.productMarkAsSoldButton, for: .normal)
        button.alpha = 0
        return button
    }()

    fileprivate let listingDeckView = ListingDeckView()
    private let collectionDataSource: DeckCollectionDataSource
    private let collectionDelegate: DeckViewCollectionDelegate

    fileprivate let viewModel: ListingDeckViewModel
    fileprivate let binder = ListingDeckViewControllerBinder()
    fileprivate let disposeBag = DisposeBag()
    private lazy var cardOnBoarding = ListingCardOnBoardingView()

    fileprivate lazy var shareButton: UIButton = {
        let button = UIButton(type: .custom)
        button.setImage(R.Asset.IconsButtons.NewItemPage.nitShare.image.withRenderingMode(.alwaysTemplate),
                        for: .normal)
        button.tintColor = .grayRegular
        button.addTarget(viewModel, action: #selector(ListingDeckViewModel.share), for: .touchUpInside)
        return button
    }()
    fileprivate lazy var moreButton: UIButton = {
        let button = UIButton(type: .custom)
        button.setImage(R.Asset.IconsButtons.NewItemPage.nitMore.image.withRenderingMode(.alwaysTemplate),
                        for: .normal)
        button.tintColor = .grayRegular
        button.addTarget(self, action: #selector(ListingDeckViewController.didTapMoreActions), for: .touchUpInside)
        return button
    }()
    fileprivate lazy var favoriteButton: UIButton = {
        let button = UIButton(type: .custom)
        button.tintColor = .grayRegular
        button.setImage(R.Asset.IconsButtons.NewItemPage.nitFavourite.image.withRenderingMode(.alwaysTemplate),
                        for: .normal)
        button.addTarget(viewModel, action: #selector(ListingDeckViewModel.switchFavorite), for: .touchUpInside)
        return button
    }()
    fileprivate lazy var editButton: UIButton = {
        let button = UIButton(type: .custom)
        button.tintColor = .grayRegular
        button.setImage(R.Asset.IconsButtons.icPen.image.withRenderingMode(.alwaysTemplate),
                        for: .normal)
        button.addTarget(viewModel, action: #selector(ListingDeckViewModel.edit), for: .touchUpInside)
        return button
    }()
    fileprivate var navBarButtons: [UIButton] { return [favoriteButton, moreButton, shareButton] }

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

    private func addBumpUp() {
        addChildViewController(bumpUpVC)
        listingDeckView.addSubviewsForAutoLayout([bumpUpVC.view, actionButton])

        NSLayoutConstraint.activate([
            actionButton.bottomAnchor.constraint(equalTo: bumpUpVC.view.topAnchor, constant: -Metrics.shortMargin),
            actionButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: Metrics.margin),
            actionButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -Metrics.margin),
            actionButton.heightAnchor.constraint(equalToConstant: Layout.buttonHeight),

            bumpUpVC.view.leadingAnchor.constraint(equalTo: listingDeckView.leadingAnchor),
            bumpUpVC.view.trailingAnchor.constraint(equalTo: listingDeckView.trailingAnchor),
            bumpUpVC.view.bottomAnchor.constraint(equalTo: view.bottomAnchor)
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

        view.backgroundColor = listingDeckView.backgroundColor
        
        setupCollectionView()
        setupRx()
        reloadData()
        setupInterstitial()

        setNavigationBarRightButtons([favoriteButton, shareButton, moreButton], animated: false)
        if viewModel.currentListingViewModel.isMine {
            addBumpUp()
        } else {
            addQuickChat()
        }
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
        let bindings = [
            viewModel.rx.listingStatus.drive(rx.status),
            viewModel.rx.listingAction.drive(rx.listingAction)
        ]
        bindings.forEach { $0.disposed(by: disposeBag) }
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

        let image = R.Asset.IconsButtons.icPostClose.image.withRenderingMode(.alwaysTemplate)
        let button = UIBarButtonItem(image: image,
                                     style: .plain,
                                     target: self,
                                     action: #selector(didTapClose))
        button.tintColor = .grayRegular
        self.navigationItem.leftBarButtonItem  = button
    }

    // Actions

    @objc private func didTapMoreActions() {
        var toShowActions = viewModel.navBarButtons
        toShowActions.append(UIAction(interface: .text(R.Strings.productOnboardingShowAgainButtonTitle),
                                      action: { [weak viewModel] in
            viewModel?.showOnBoarding()
        }))
        let moreInfo = R.Strings.productMoreInfoOpenButton.lowercased().capitalizedFirstLetterOnly
        toShowActions.append(UIAction(interface: .text(moreInfo),
                                      action: { [weak viewModel] in
            viewModel?.showListingDetail()
        }))
        showActionSheet(R.Strings.commonCancel, actions: toShowActions, barButtonItem: nil)
    }

    @objc private func didTapClose() {
        viewModel.close()
    }
}

extension ListingDeckViewController {

    func willDisplayCell(_ cell: UICollectionViewCell, atIndexPath indexPath: IndexPath) {
        cell.isUserInteractionEnabled = indexPath.row == viewModel.currentIndex
    }

    func willBeginDragging() {
        collectionDelegate.lastPageBeforeDragging = listingDeckView.currentPage
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
        bumpUpVC.resetBumpUpCountdown()
    }
}

// MARK: Rx

extension Reactive where Base: ListingDeckViewController {
    var contentOffset: Observable<CGPoint> {
        return base.listingDeckView.rx.collectionView.contentOffset.asObservable()
    }

    var actionButton: Reactive<LetgoButton> { return base.actionButton.rx }

    var bumpUp: Binder<BumpUpInfo?> { return base.bumpUpVC.rx.bumpInfo }
    
    var action: Binder<UIAction?> {
        return Binder(self.base) { controller, actionable in
            if let actionable = actionable {
                controller.actionButton.configureWith(uiAction: actionable)
            }

            guard let actionable = actionable else { return }
            controller.actionButton.rx
                .tap
                .takeUntil(controller.viewModel.rx.actionButton)
                .bind {
                actionable.action()
            }.disposed(by: controller.disposeBag)
        }
    }

    var actionsAlpha: Binder<CGFloat> {
        return Binder(self.base) { controller, alpha in
            let clippedAlpha = min(1.0, alpha)
            controller.listingDeckView.statusView.alpha = clippedAlpha
            controller.actionButton.alpha = clippedAlpha
        }
    }

    var navBarAlpha: Binder<CGFloat> {
        return Binder(self.base) { controller, alpha in
            controller.navBarButtons.forEach { $0.alpha = max(alpha, 0.1) }
        }
    }

    var listingAction: Binder<ListingAction> {
        return Binder(self.base) { controller, action in
            let buttons: [UIButton]
            if action.isFavoritable {
                if action.isFavorite {
                    controller.favoriteButton.setImage(R.Asset.IconsButtons.NewItemPage.nitFavouriteOn.image, for: .normal)
                } else {
                    let image = R.Asset.IconsButtons.NewItemPage.nitFavourite.image.withRenderingMode(.alwaysTemplate)
                    controller.favoriteButton.setImage(image, for: .normal)
                }
                buttons = [controller.favoriteButton, controller.shareButton, controller.moreButton]
            } else if action.isEditable {
                buttons = [controller.editButton, controller.shareButton, controller.moreButton]
            } else {
                buttons = [controller.shareButton, controller.moreButton]
            }
            controller.setNavigationBarRightButtons(buttons, animated: false)
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
