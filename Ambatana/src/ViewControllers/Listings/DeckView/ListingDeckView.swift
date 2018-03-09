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

    private var collectionViewTop: NSLayoutConstraint? = nil
    private let topInsetView = UIView()
    let collectionView: UICollectionView
    private let collectionLayout = ListingDeckCollectionViewLayout()
    let rxCollectionView: Reactive<UICollectionView>
    
    private let bottomInsetView = UIView()

    var chatEnabled: Bool = false {
        didSet {
            quickChatTopToCollectionBotton?.isActive = chatEnabled
        }
    }
    private var quickChatView: QuickChatView?
    private var quickChatTopToCollectionBotton: NSLayoutConstraint?
    private var dismissTap: UITapGestureRecognizer?
    
    let itemActionsView = ListingDeckActionView()

    var rxActionButton: Reactive<UIButton> { return itemActionsView.actionButton.rx }
    var rxDidBeginEditing: ControlEvent<()>? { return quickChatView?.rxDidBeginEditing }
    var rxDidEndEditing: ControlEvent<()>? { return quickChatView?.rxDidEndEditing }

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

    @discardableResult
    override func resignFirstResponder() -> Bool {
        return quickChatView?.resignFirstResponder() ?? true
    }

    func blockSideInteractions() {
        let current = collectionLayout.page
        collectionView.cellForItem(at: IndexPath(row: current - 1, section: 0))?.isUserInteractionEnabled = false
        currentPageCell()?.isUserInteractionEnabled = true
        collectionView.cellForItem(at: IndexPath(row: current + 1, section: 0))?.isUserInteractionEnabled = false
    }
    
    func setQuickChatViewModel(_ viewModel: QuickChatViewModel) {
        let quickChatView = QuickChatView(chatViewModel: viewModel)
        quickChatView.isRemovedWhenResigningFirstResponder = false
        setupDirectChatView(quickChatView: quickChatView)
        self.quickChatView = quickChatView
        focusOnCollectionView()
    }

    private func setupUI() {
        backgroundColor = UIColor.viewControllerBackground
        setupCollectionView()
        setupPrivateActionsView()
        focusOnCollectionView()
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
        collectionViewTop = topInsetConstraint

        topInsetView.isUserInteractionEnabled = false
        topInsetView.alpha = 0
        bottomInsetView.isUserInteractionEnabled = false
        bottomInsetView.alpha = 0

        collectionView.showsHorizontalScrollIndicator = false
        collectionView.decelerationRate = 0
        collectionView.contentInset = .zero
        collectionView.bounces = true
        collectionView.alwaysBounceVertical = false
        collectionView.backgroundColor = UIColor.viewControllerBackground
    }

    private func setupPrivateActionsView() {
        addSubview(itemActionsView)
        itemActionsView.translatesAutoresizingMaskIntoConstraints = false

        let collectionBottom = itemActionsView.topAnchor.constraint(equalTo: bottomInsetView.bottomAnchor)
        collectionBottom.priority = .required - 1
        collectionBottom.isActive = true
        itemActionsView.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true
        itemActionsView.layout(with: self).fillHorizontal().bottom(relatedBy: .equal)

        itemActionsView.setContentCompressionResistancePriority(.required, for: .vertical)
        itemActionsView.setContentHuggingPriority(.required, for: .vertical)
        itemActionsView.alpha = 0
        itemActionsView.backgroundColor = UIColor.viewControllerBackground
    }

    private func setupDirectChatView(quickChatView: QuickChatView) {
        quickChatView.isRemovedWhenResigningFirstResponder = false
        addSubview(quickChatView)
        quickChatView.translatesAutoresizingMaskIntoConstraints = false
        quickChatView.layout(with: self).fill()

        let directTop = quickChatView.directAnswersViewTopAnchor
        quickChatTopToCollectionBotton = bottomInsetView.bottomAnchor.constraint(equalTo: directTop,
                                                                                 constant: -Metrics.margin)
        quickChatTopToCollectionBotton?.isActive = true
        focusOnCollectionView()
    }

    func normalizedPageOffset(givenOffset: CGFloat) -> CGFloat {
        return collectionLayout.normalizedPageOffset(givenOffset: givenOffset)
    }

    func updatePrivateActionsWith(alpha: CGFloat) {
        itemActionsView.alpha = alpha
    }

    func updateTop(wintInset inset: CGFloat) {
        collectionViewTop?.constant = inset
    }

    func updateWith(bottomInset: CGFloat, animationTime: TimeInterval,
                    animationOptions: UIViewAnimationOptions, completion: ((Bool) -> Void)? = nil) {
        quickChatView?.updateWith(bottomInset: bottomInset,
                                  animationTime: animationTime,
                                  animationOptions: animationOptions,
                                  completion: completion)
    }

    // MARK: ItemActionsView

    func configureActionWith(_ action: UIAction) {
        itemActionsView.actionButton.configureWith(uiAction: action)
    }

    // MARK: Chat

    func updateChatWith(alpha: CGFloat) {
        quickChatView?.alpha = alpha
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

        guard let chat = quickChatView else { return }
        if dismissTap == nil {
            let tapGesture = UITapGestureRecognizer(target: self, action: #selector(hideFullScreenChat))
            chat.addDismissGestureRecognizer(tapGesture)
            dismissTap = tapGesture
        }
    }

    private func focusOnCollectionView() {
        quickChatView?.isTableInteractionEnabled = false
    }

    func hideChat() {
        quickChatView?.alpha = 0
        focusOnCollectionView()
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
    func currentPageCell() -> ListingCardView? {
        return cardAtIndex(collectionLayout.page)
    }

    func cardAtIndex(_ index: Int) -> ListingCardView? {
        return collectionView.cellForItem(at: IndexPath(item: index, section: 0)) as? ListingCardView
    }

    func endTransitionAnimation(current: Int) {
        cardAtIndex(current - 1)?.alpha = 1
        cardAtIndex(current + 1)?.alpha = 1
    }
}
