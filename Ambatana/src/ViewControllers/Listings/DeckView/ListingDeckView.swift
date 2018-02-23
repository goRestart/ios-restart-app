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

final class ListingDeckView: UIView, UICollectionViewDelegate, ListingDeckViewType {
    struct Layout {
        struct Height { static let previewFactor: CGFloat = 0.7 }
    }

    let collectionView: UICollectionView
    let rxCollectionView: Reactive<UICollectionView>
    var chatEnabled: Bool = false {
        didSet {
            quickChatTopToCollectionBotton?.isActive = chatEnabled
        }
    }
    private var quickChatView: QuickChatView?
    private var quickChatTopToCollectionBotton: NSLayoutConstraint?
    private var dismissTap: UITapGestureRecognizer?
    
    private var collectionViewTop: NSLayoutConstraint? = nil
    let itemActionsView = ListingDeckActionView()
    private let collectionLayout = ListingDeckCollectionViewLayout()

    var rxActionButton: Reactive<UIButton> { return itemActionsView.actionButton.rx }
    var rxChatTextView: Reactive<ChatTextView>? { return quickChatView?.rxChatTextView }
    var currentPage: Int { return collectionLayout.page }
    var bumpUpBanner: BumpUpBanner { return itemActionsView.bumpUpBanner }
    var isBumpUpVisible: Bool { return itemActionsView.isBumpUpVisisble }
    var cardsInsets: UIEdgeInsets { return collectionLayout.cardInsets }

    override init(frame: CGRect) {
        collectionView = UICollectionView(frame: .zero, collectionViewLayout: collectionLayout)
        rxCollectionView = collectionView.rx
        
        super.init(frame: frame)
        setupUI()
    }

    required init?(coder aDecoder: NSCoder) {
        collectionView = UICollectionView(frame: .zero, collectionViewLayout: collectionLayout)
        rxCollectionView = collectionView.rx
        super.init(coder: aDecoder)
        setupUI()
    }

    func cardSystemLayoutSizeFittingSize(_ target: CGSize) -> CGSize {
        return collectionLayout.cardSystemLayoutSizeFittingSize(target)
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
        collectionView.cellForItem(at: IndexPath(row: current, section: 0))?.isUserInteractionEnabled = true
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
    }

    private func setupCollectionView() {
        addSubview(collectionView)
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.layout(with: self).leading().trailing()
        collectionViewTop = collectionView.topAnchor.constraint(equalTo: topAnchor)
        collectionViewTop?.isActive = true

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

        let collectionBottom = itemActionsView.topAnchor.constraint(equalTo: collectionView.bottomAnchor)
        collectionBottom.priority = .required - 1
        collectionBottom.isActive = true
        itemActionsView.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true

        itemActionsView.layout(with: self).fillHorizontal().bottom(relatedBy: .lessThanOrEqual)
        itemActionsView.layout(with: collectionView).below(relatedBy: .equal)

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
        quickChatTopToCollectionBotton = collectionView.bottomAnchor.constraint(equalTo: directTop,
                                                                                constant: -Metrics.margin)

        focusOnCollectionView()
    }

    func pageOffset(givenOffset: CGFloat) -> CGFloat {
        return collectionLayout.pageOffset(givenOffset: givenOffset)
    }

    func updatePrivateActionsWith(alpha: CGFloat) {
        itemActionsView.alpha = alpha
    }

    func updateBumpUp(withInfo info: BumpUpInfo) {
        itemActionsView.updateBumpUp(withInfo: info)
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

    func showBumpUp() {
        itemActionsView.showBumpUp()
    }

    func hideBumpUp() {
        itemActionsView.hideBumpUp()
    }

    func resetBumpUpCountdown() {
        bumpUpBanner.resetCountdown()
    }

}
