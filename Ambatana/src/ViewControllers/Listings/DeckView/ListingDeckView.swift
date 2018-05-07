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
        // to center the play button with the page symbols
        static let playButtonEdges = UIEdgeInsets(top: 11,
                                                  left: 0,
                                                  bottom: 0,
                                                  right: 30)
        struct Height {
            static let previewFactor: CGFloat = 0.7
        }
        static let collectionVerticalInset: CGFloat = 18
    }
    var cardSize: CGSize { return collectionLayout.cardSize }
    var cellHeight: CGFloat { return collectionLayout.cellHeight }

    let collectionView: UICollectionView
    private let collectionLayout = ListingDeckCollectionViewLayout()
    let rxCollectionView: Reactive<UICollectionView>

    let itemActionsView = ListingDeckActionView()
    private let startPlayingButton: UIButton = {
        let button = UIButton(type: .custom)
        button.setImage(#imageLiteral(resourceName: "ic_videoposting_play"), for: .normal)
        return button
    }()

    var rxStartPlayingButton: Reactive<UIButton> { return startPlayingButton.rx }
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

    required init?(coder aDecoder: NSCoder) { fatalError("Die xibs die") }

    func scrollToIndex(_ index: IndexPath) {
        collectionView.scrollToItem(at: index, at: .centeredHorizontally, animated: false)
    }

    private func setupUI() {
        backgroundColor = UIColor.white
        setupCollectionView()
        setupPrivateActionsView()
        if #available(iOS 10.0, *) { collectionView.isPrefetchingEnabled = true }
    }

    private func setupCollectionView() {
        addSubviewForAutoLayout(collectionView)
        NSLayoutConstraint.activate([
            collectionView.topAnchor.constraint(equalTo: topAnchor, constant: Layout.collectionVerticalInset),
            collectionView.leadingAnchor.constraint(equalTo: leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: trailingAnchor),
            collectionView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -Layout.collectionVerticalInset)
        ])

        collectionView.showsHorizontalScrollIndicator = false
        collectionView.decelerationRate = 0
        collectionView.contentInset = .zero
        collectionView.bounces = true
        collectionView.alwaysBounceVertical = false
        collectionView.backgroundColor = UIColor.white

        setupPlayableButton()
    }

    private func setupPlayableButton() {
        addSubviewForAutoLayout(startPlayingButton)
        startPlayingButton.alpha = 0
        NSLayoutConstraint.activate([
            startPlayingButton.rightAnchor.constraint(equalTo: collectionView.rightAnchor,
                                                      constant: -Layout.playButtonEdges.right),
            startPlayingButton.topAnchor.constraint(equalTo: collectionView.topAnchor,
                                                    constant: Layout.playButtonEdges.top),
            startPlayingButton.widthAnchor.constraint(equalToConstant: 30),
            startPlayingButton.heightAnchor.constraint(equalTo: startPlayingButton.widthAnchor)
        ])
        startPlayingButton.addTarget(self, action: #selector(bouncePlayingButton), for: .touchUpInside)
    }

    private func setupPrivateActionsView() {
        addSubview(itemActionsView)
        itemActionsView.translatesAutoresizingMaskIntoConstraints = false

        itemActionsView.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true
        itemActionsView.layout(with: self).fillHorizontal()

        itemActionsView.setContentCompressionResistancePriority(.required, for: .vertical)
        itemActionsView.setContentHuggingPriority(.required, for: .vertical)
        itemActionsView.alpha = 0
        itemActionsView.backgroundColor = UIColor.white.withAlphaComponent(0.8)
    }

    func normalizedPageOffset(givenOffset: CGFloat) -> CGFloat {
        return collectionLayout.normalizedPageOffset(givenOffset: givenOffset)
    }

    func updatePlayButtonWith(alpha: CGFloat) {
        startPlayingButton.alpha = alpha
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
