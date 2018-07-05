import Foundation
import UIKit
import LGCoreKit
import RxSwift
import RxCocoa
import LGComponents

final class ListingDeckView: UIView, UICollectionViewDelegate, ListingDeckViewType {
    struct Layout {
        // to center the play button with the page symbols
        static let playButtonEdges = UIEdgeInsets(top: 11,
                                                  left: 0,
                                                  bottom: 0,
                                                  right: 30)
        static let playButtonHeight: CGFloat = 30
		struct Height {
            static let previewFactor: CGFloat = 0.7
            static let actions: CGFloat = 100
        }
        static let collectionVerticalInset: CGFloat = 18
    }
    static let actionsViewBackgroundColor: UIColor = UIColor.white.withAlphaComponent(0.8)

    var cardSize: CGSize { return collectionLayout.cardSize }
    var cellHeight: CGFloat { return collectionLayout.cellHeight }

    lazy var collectionView: UICollectionView = UICollectionView(frame: .zero, collectionViewLayout: collectionLayout)
    lazy var rxCollectionView: Reactive<UICollectionView> = collectionView.rx
    private let collectionLayout = ListingDeckCollectionViewLayout()

    let itemActionsView = ListingDeckActionView()

    private let startPlayingButton: UIButton = {
        let button = UIButton(type: .custom)
        button.setImage(R.Asset.IconsButtons.VideoPosting.icVideopostingPlay.image, for: .normal)
        return button
    }()

    var rxStartPlayingButton: Reactive<UIButton> { return startPlayingButton.rx }
    var rxActionButton: Reactive<LetgoButton> { return itemActionsView.actionButton.rx }

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
        addSubviewsForAutoLayout([collectionView, itemActionsView, startPlayingButton])
        NSLayoutConstraint.activate([
            collectionView.topAnchor.constraint(equalTo: topAnchor, constant: Layout.collectionVerticalInset),
            collectionView.leadingAnchor.constraint(equalTo: leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: trailingAnchor),

            itemActionsView.leadingAnchor.constraint(equalTo: leadingAnchor),
            itemActionsView.trailingAnchor.constraint(equalTo: trailingAnchor),
            itemActionsView.topAnchor.constraint(equalTo: collectionView.bottomAnchor),
            itemActionsView.bottomAnchor.constraint(equalTo: bottomAnchor),
            itemActionsView.heightAnchor.constraint(equalToConstant: Layout.Height.actions),

            startPlayingButton.rightAnchor.constraint(equalTo: collectionView.rightAnchor,
                                                      constant: -Layout.playButtonEdges.right),
            startPlayingButton.topAnchor.constraint(equalTo: collectionView.topAnchor,
                                                    constant: Layout.playButtonEdges.top),
            startPlayingButton.widthAnchor.constraint(equalToConstant: Layout.playButtonHeight),
            startPlayingButton.heightAnchor.constraint(equalTo: startPlayingButton.widthAnchor)
        ])

        setupCollectionView()
        setupPrivateActionsView()

        if #available(iOS 10.0, *) { collectionView.isPrefetchingEnabled = true }
    }

    private func setupCollectionView() {
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.decelerationRate = 0
        collectionView.contentInset = .zero
        collectionView.bounces = true
        collectionView.alwaysBounceVertical = false
        collectionView.backgroundColor = UIColor.white

        setupPlayableButton()
    }

    private func setupPlayableButton() {
        startPlayingButton.alpha = 0
        startPlayingButton.addTarget(self, action: #selector(bouncePlayingButton), for: .touchUpInside)
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

    func updatePlayButtonWith(alpha: CGFloat) {
        startPlayingButton.alpha = alpha
    }

    func updatePrivateActionsWith(actionsAlpha: CGFloat, bumpBannerAlpha: CGFloat) {
        itemActionsView.alpha = max(actionsAlpha, bumpBannerAlpha)
        itemActionsView.backgroundColor = actionsAlpha > 0 ? ListingDeckView.actionsViewBackgroundColor : .clear
        itemActionsView.updatePrivateActionsWith(actionsAlpha: actionsAlpha, bumpBannerAlpha: bumpBannerAlpha)
    }

    // MARK: ItemActionsView

    func configureActionWith(_ action: UIAction) {
        itemActionsView.actionButton.configureWith(uiAction: action)
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

    @objc private func bouncePlayingButton() {
        startPlayingButton.bounce()
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
