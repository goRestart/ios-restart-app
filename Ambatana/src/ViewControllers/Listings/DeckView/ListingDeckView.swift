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

final class ListingDeckView: UIView, UICollectionViewDelegate {
    struct Layout { struct Height { static let previewFactor: CGFloat = 0.7 } }

    let collectionView: UICollectionView

    private var quickChatView: QuickChatView?
    private var collectionViewTop: NSLayoutConstraint? = nil
    private let itemActionsView = ListingDeckActionView()
    private let collectionLayout = ListingDeckCollectionViewLayout()
    private let chatTextView = ChatTextView()

    var rx_actionButton: Reactive<UIButton> { return itemActionsView.actionButton.rx }
    var rx_chatTextView: Reactive<ChatTextView> { return chatTextView.rx }
    var currentPage: Int { return collectionLayout.page }
    var bumpUpBanner: BumpUpBanner { return itemActionsView.bumpUpBanner }
    var isBumpUpVisible: Bool { return itemActionsView.isBumpUpVisisble }

    override init(frame: CGRect) {
        collectionView = UICollectionView(frame: .zero, collectionViewLayout: collectionLayout)
        super.init(frame: frame)
        setupUI()
    }

    required init?(coder aDecoder: NSCoder) {
        collectionView = UICollectionView(frame: .zero, collectionViewLayout: collectionLayout)
        super.init(coder: aDecoder)
        setupUI()
    }

    @discardableResult
    override func resignFirstResponder() -> Bool {
        return quickChatView?.resignFirstResponder() ?? true
    }
    
    func setQuickChatViewModel(_ viewModel: QuickChatViewModel) {
        let quickChatView = QuickChatView(chatViewModel: viewModel)
        setupDirectChatView(quickChatView: quickChatView)
        self.quickChatView = quickChatView
    }

    private func setupUI() {
        backgroundColor = UIColor.viewControllerBackground
        setupCollectionView()
        setupPrivateActionsView()

        bringSubview(toFront: collectionView)
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

    func enableScrollForItemAtPage(_ page: Int) {
        collectionView.cellForItem(at: IndexPath(item: page - 1,
                                                 section: 0))?.contentView.isUserInteractionEnabled = false
        collectionView.cellForItem(at: IndexPath(item: page + 1,
                                                 section: 0))?.contentView.isUserInteractionEnabled = false

        collectionView.cellForItem(at: IndexPath(item: page, section: 0))?.contentView.isUserInteractionEnabled = true
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
    func updateBottom(wintInset inset: CGFloat) {
        quickChatView?.updateWith(bottomInset: inset, animationTime: TimeInterval(0.3), animationOptions: [])
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

    func setChatText(_ text: String) {
        chatTextView.setText(text)
    }

    func setChatInitialText(_ text: String) {
        chatTextView.setInitialText(text)
    }

    func showFullScreenChat() {
        guard let chatView = quickChatView else { return }
        chatView.becomeFirstResponder()
        focusOnChat()
    }

    @objc func hideFullScreenChat() {
        chatTextView.resignFirstResponder()
        focusOnCollectionView()
    }

    func showChat() {
        quickChatView?.alpha = 1
        focusOnCollectionView()
    }

    private func focusOnChat() {
        bringSubview(toFront: collectionView)
    }

    private func focusOnCollectionView() {
        bringSubview(toFront: collectionView)
    }

    func hideChat() {
        quickChatView?.alpha = 0
        bringSubview(toFront: collectionView)
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
