//
//  ListingDeckView.swift
//  LetGo
//
//  Created by Facundo Menzella on 23/10/2017.
//  Copyright © 2017 Ambatana. All rights reserved.
//

import Foundation
import UIKit
import LGCoreKit
import RxSwift
import RxCocoa

final class ListingDeckView: UIView, UICollectionViewDelegate, ListingDeckViewType {
    struct Layout {
        struct Height {
            static let previewFactor: CGFloat = 0.7
        }
    }
    var cardSize: CGSize { return collectionLayout.cardSize }
    var cellHeight: CGFloat { return collectionLayout.cellHeight }

    private let topInsetView = UIView()
    let collectionView: UICollectionView
    private let collectionLayout = ListingDeckCollectionViewLayout()
    let rxCollectionView: Reactive<UICollectionView>
    
    private let bottomInsetView = UIView()

    let itemActionsView = ListingDeckActionView()

    var rxActionButton: Reactive<LetgoButton> { return itemActionsView.actionButton.rx }

    var currentPage: Int { return collectionLayout.page }
    var bumpUpBanner: BumpUpBanner { return itemActionsView.bumpUpBanner }
    var isBumpUpVisible: Bool { return itemActionsView.isBumpUpVisible }

    override init(frame: CGRect) {
        collectionView = UICollectionView(frame: .zero, collectionViewLayout: collectionLayout)
        rxCollectionView = collectionView.rx
        
        super.init(frame: frame)
        setupUI()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func scrollToIndex(_ index: IndexPath) {
        collectionView.scrollToItem(at: index, at: .centeredHorizontally, animated: false)
    }

    func constraintCollectionBottomTo(_ anchor: NSLayoutYAxisAnchor, constant: CGFloat) -> NSLayoutConstraint {
        return bottomInsetView.bottomAnchor.constraint(equalTo: anchor, constant: constant)
    }

    private func setupUI() {
        backgroundColor = UIColor.white
        setupCollectionView()
        setupPrivateActionsView()
        if #available(iOS 10.0, *) { collectionView.isPrefetchingEnabled = true }
    }

    private func setupCollectionView() {
        addSubviewsForAutoLayout([topInsetView, bottomInsetView, collectionView])
        let topInsetConstraint = topInsetView.topAnchor.constraint(equalTo: topAnchor)
        NSLayoutConstraint.activate([
            topInsetConstraint,
            topInsetView.leadingAnchor.constraint(equalTo: leadingAnchor),
            topInsetView.trailingAnchor.constraint(equalTo: trailingAnchor),
            topInsetView.heightAnchor.constraint(equalToConstant: 18),

            collectionView.topAnchor.constraint(equalTo: topInsetView.bottomAnchor),
            collectionView.leadingAnchor.constraint(equalTo: leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: trailingAnchor),

            bottomInsetView.topAnchor.constraint(equalTo: collectionView.bottomAnchor),
            bottomInsetView.leadingAnchor.constraint(equalTo: leadingAnchor),
            bottomInsetView.trailingAnchor.constraint(equalTo: trailingAnchor),
            bottomInsetView.heightAnchor.constraint(equalTo: topInsetView.heightAnchor),
        ])

        topInsetView.isUserInteractionEnabled = false
        topInsetView.alpha = 0
        bottomInsetView.isUserInteractionEnabled = false
        bottomInsetView.alpha = 0

        collectionView.showsHorizontalScrollIndicator = false
        collectionView.decelerationRate = 0
        collectionView.contentInset = .zero
        collectionView.bounces = true
        collectionView.alwaysBounceVertical = false
        collectionView.backgroundColor = UIColor.white
    }

    private func setupPrivateActionsView() {
        addSubview(itemActionsView)
        itemActionsView.translatesAutoresizingMaskIntoConstraints = false

        let collectionBottom = itemActionsView.topAnchor.constraint(equalTo: bottomInsetView.bottomAnchor)
        collectionBottom.priority = .required - 1
        collectionBottom.isActive = true
        itemActionsView.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true
        itemActionsView.layout(with: self).fillHorizontal()

        itemActionsView.setContentCompressionResistancePriority(.required, for: .vertical)
        itemActionsView.setContentHuggingPriority(.required, for: .vertical)
        itemActionsView.alpha = 0
        itemActionsView.backgroundColor = .white
    }

    func normalizedPageOffset(givenOffset: CGFloat) -> CGFloat {
        return collectionLayout.normalizedPageOffset(givenOffset: givenOffset)
    }

    func updatePrivateActionsWith(alpha: CGFloat) {
        itemActionsView.alpha = alpha
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
