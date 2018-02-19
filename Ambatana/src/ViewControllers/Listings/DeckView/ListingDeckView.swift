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
    struct Layout { struct Height { static let previewFactor: CGFloat = 0.7 } }

    let collectionView: UICollectionView
    let rxCollectionView: Reactive<UICollectionView>

    private var quickChatView: QuickChatView?
    private var dismissTap: UITapGestureRecognizer?
    
    private var collectionViewTop: NSLayoutConstraint? = nil
    private let itemActionsView = ListingDeckActionView()
    private let collectionLayout = ListingDeckCollectionViewLayout()

    var rxActionButton: Reactive<UIButton> { return itemActionsView.actionButton.rx }
    var rxChatTextView: Reactive<ChatTextView>? { return quickChatView?.rxChatTextView }
    var currentPage: Int { return collectionLayout.page }
    var bumpUpBanner: BumpUpBanner { return itemActionsView.bumpUpBanner }
    var isBumpUpVisible: Bool { return itemActionsView.isBumpUpVisisble }

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
        collectionView.layout(with: self).leading().trailing().top() { [weak self] constraint in
            self?.collectionViewTop = constraint
        }.proportionalHeight(multiplier: Layout.Height.previewFactor)

        collectionView.showsHorizontalScrollIndicator = false
        collectionView.decelerationRate = 0
        collectionView.backgroundColor = UIColor.viewControllerBackground
    }

    private func setupPrivateActionsView() {
        addSubview(itemActionsView)
        itemActionsView.translatesAutoresizingMaskIntoConstraints = false

        let layoutGuide = UILayoutGuide()
        itemActionsView.addLayoutGuide(layoutGuide)

        layoutGuide.topAnchor.constraint(equalTo: collectionView.bottomAnchor).isActive = true
        layoutGuide.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true

        itemActionsView.layout(with: self).fillHorizontal().bottom(relatedBy: .lessThanOrEqual)
        itemActionsView.layout(with: collectionView).below(relatedBy: .greaterThanOrEqual)

        itemActionsView.centerYAnchor.constraint(equalTo: layoutGuide.centerYAnchor).isActive = true

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

    func showActions() {
        itemActionsView.alpha = 1
    }

    func hideActions() {
        itemActionsView.alpha = 0
    }

    // MARK: Chat

    func updateChatWith(alpha: CGFloat) {
        quickChatView?.alpha = alpha
    }
    
    func showFullScreenChat() {
        guard let chatView = quickChatView else { return }
        focusOnChat()
        chatView.becomeFirstResponder()
    }

    @objc func hideFullScreenChat() {
        quickChatView?.resignFirstResponder()
        focusOnCollectionView()
    }

    func showChat() {
        quickChatView?.alpha = 1
        focusOnCollectionView()
    }

    private func focusOnChat() {
        guard let chat = quickChatView else { return }
        if dismissTap == nil {
            let tapGesture = UITapGestureRecognizer(target: self, action: #selector(hideFullScreenChat))
            chat.addDismissGestureRecognizer(tapGesture)
            dismissTap = tapGesture
        }
        bringSubview(toFront: chat)
    }

    private func focusOnCollectionView() {
        bringSubview(toFront: collectionView)
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
