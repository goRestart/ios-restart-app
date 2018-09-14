import Foundation
import UIKit
import LGCoreKit
import RxSwift
import RxCocoa
import LGComponents

final class ListingDeckView: UIView, UICollectionViewDelegate {
    struct Layout {
		struct Height {
            static let previewFactor: CGFloat = 0.7
            static let actions: CGFloat = 120
        }
        static let collectionVerticalInset: CGFloat = 18
    }
    static let actionsViewBackgroundColor: UIColor = UIColor.white.withAlphaComponent(0.8)

    var cardSize: CGSize { return collectionLayout.cardSize }
    var cellHeight: CGFloat { return collectionLayout.cellHeight }

    let statusView: ListingStatusView = {
        let view = ListingStatusView()
        view.applyDefaultShadow()
        view.alpha = 0
        return view
    }()
    let statusTap = UITapGestureRecognizer()

    lazy var collectionView: UICollectionView = UICollectionView(frame: .zero, collectionViewLayout: collectionLayout)
    private let collectionLayout = ListingDeckCollectionViewLayout()

    let itemActionsView = ListingDeckActionView()

    var currentPage: Int { return collectionLayout.page }
    var bumpUpBanner: BumpUpBanner { return itemActionsView.bumpUpBanner }
    var isBumpUpVisible: Bool { return itemActionsView.isBumpUpVisible }

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }

    required init?(coder aDecoder: NSCoder) { fatalError("Die xibs die") }

    func scrollToIndex(_ index: IndexPath) {
        collectionView.scrollToItem(at: index, at: .centeredHorizontally, animated: false)
    }

    private func setupUI() {
        backgroundColor = UIColor.white
        addSubviewsForAutoLayout([collectionView, statusView, itemActionsView])
        NSLayoutConstraint.activate([
            collectionView.topAnchor.constraint(equalTo: topAnchor, constant: Layout.collectionVerticalInset),
            collectionView.leadingAnchor.constraint(equalTo: leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: trailingAnchor),
            collectionView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -Layout.Height.actions),

            statusView.topAnchor.constraint(equalTo: collectionView.topAnchor, constant: Metrics.veryBigMargin),
            statusView.centerXAnchor.constraint(equalTo: centerXAnchor),

            itemActionsView.leadingAnchor.constraint(equalTo: leadingAnchor),
            itemActionsView.trailingAnchor.constraint(equalTo: trailingAnchor),
            itemActionsView.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])

        setupCollectionView()
        setupPrivateActionsView()
        statusView.addGestureRecognizer(statusTap)

        if #available(iOS 10.0, *) { collectionView.isPrefetchingEnabled = true }
    }

    private func setupCollectionView() {
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.decelerationRate = 0
        collectionView.contentInset = .zero
        collectionView.bounces = true
        collectionView.alwaysBounceVertical = false
        collectionView.backgroundColor = UIColor.white
    }

    private func setupPrivateActionsView() {
        itemActionsView.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true
        itemActionsView.layout(with: self).fillHorizontal()

        itemActionsView.setContentCompressionResistancePriority(.required, for: .vertical)
        itemActionsView.setContentHuggingPriority(.required, for: .vertical)
        itemActionsView.alpha = 0
        itemActionsView.backgroundColor = ListingDeckView.actionsViewBackgroundColor
    }

    func normalizedPageOffset(givenOffset: CGFloat) -> CGFloat {
        return collectionLayout.normalizedPageOffset(givenOffset: givenOffset)
    }

    func updatePrivateActionsWith(actionsAlpha: CGFloat) {
        itemActionsView.alpha = actionsAlpha
        itemActionsView.backgroundColor = actionsAlpha > 0 ? ListingDeckView.actionsViewBackgroundColor : .clear
        itemActionsView.updatePrivateActionsWith(actionsAlpha: actionsAlpha)
    }

    // MARK: ItemActionsView

    func configureActionWith(_ action: UIAction?) {
        if let action = action {
            itemActionsView.actionButton.configureWith(uiAction: action)
        } else {
            itemActionsView.actionButton.alpha = 0
        }
    }

    // MARK: BumpUp

    func updateBumpUp(withInfo info: BumpUpInfo) {
        itemActionsView.updateBumpUp(withInfo: info)
    }

    func showBumpUp() {
        itemActionsView.showBumpUp()
    }

    func hideBumpUp() {
        itemActionsView.hideBumpUp()
    }

    func resetBumpUpCountdown() {
        bumpUpBanner.resetCountdown()
    }

    func handleCollectionChange<T>(_ change: CollectionChange<T>, completion: ((Bool) -> Void)? = nil) {
        collectionView.handleCollectionChange(change, completion: completion)
    }

    func setCollectionLayoutDelegate(_ delegate: ListingDeckCollectionViewLayoutDelegate) {
        collectionLayout.delegate = delegate
    }
}

extension ListingDeckView {
    func cardAtIndex(_ index: Int) -> ListingCardView? {
        return collectionView.cellForItem(at: IndexPath(item: index, section: 0)) as? ListingCardView
    }

    func endTransitionAnimation(current: Int) {
        cardAtIndex(current - 1)?.alpha = 1
        cardAtIndex(current + 1)?.alpha = 1
    }
}

extension Reactive where Base: ListingDeckView {
    var collectionView: Reactive<UICollectionView> { return base.collectionView.rx }
    var actionButton: Reactive<LetgoButton> { return base.itemActionsView.actionButton.rx }
    var statusControlEvent: ControlEvent<UITapGestureRecognizer> { return base.statusTap.rx.event }
}


