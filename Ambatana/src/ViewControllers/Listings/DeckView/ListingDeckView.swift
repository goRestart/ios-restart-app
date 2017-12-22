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
    let directChatTable = CustomTouchesTableView()
    let collectionView: UICollectionView

    private let overlayView = UIView()
    private var chatTextViewBottom: NSLayoutConstraint? = nil
    private var collectionViewTop: NSLayoutConstraint? = nil
    private let directAnswersView = DirectAnswersHorizontalView(answers: [], sideMargin: Metrics.margin)
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

    private func setupUI() {
        backgroundColor = UIColor.viewControllerBackground
        setupCollectionView()
        setupPrivateActionsView()

        bringSubview(toFront: collectionView)
        setupDirectChatView()
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

    private func setupDirectChatView() {
        addSubview(overlayView)
        overlayView.translatesAutoresizingMaskIntoConstraints = false
        overlayView.layout(with: self).fill()
        overlayView.alpha = 0
        overlayView.backgroundColor = UIColor.black.withAlphaComponent(0.6)

        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(hideFullScreenChat))
        overlayView.addGestureRecognizer(tapGesture)

        chatTextView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(chatTextView)
        chatTextView.layout(with: self)
            .fillHorizontal(by: CarouselUI.itemsMargin)
            .bottomMargin(by: -Metrics.margin) { [weak self] constraint in self?.chatTextViewBottom = constraint }
        chatTextView.backgroundColor = .clear

        directAnswersView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(directAnswersView)
        directAnswersView.layout(with: self).fillHorizontal()
        directAnswersView.layout(with: chatTextView).above(by: -Metrics.shortMargin)

        directAnswersView.backgroundColor = .clear
        directAnswersView.style = .light

        addSubview(directChatTable)
        directChatTable.translatesAutoresizingMaskIntoConstraints = false
        directChatTable.layout(with: self).topMargin().fillHorizontal()
        directChatTable.layout(with: directAnswersView).above(by: -Metrics.shortMargin)
        directChatTable.alpha = 0
        directChatTable.backgroundColor = .clear
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
        chatTextViewBottom?.constant = -(inset + Metrics.margin)
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

    @discardableResult
    override func resignFirstResponder() -> Bool {
        return chatTextView.resignFirstResponder()
    }

    func setDirectAnswersHorizontalViewDelegate(_ delegate: DirectAnswersHorizontalViewDelegate) {
        directAnswersView.delegate = delegate
    }

    func updateDirectChatWith(answers: [[QuickAnswer]], isDynamic: Bool) {
        directAnswersView.update(answers: answers, isDynamic: isDynamic)
    }

    func updateChatWith(alpha: CGFloat) {
        chatTextView.alpha = alpha
        directAnswersView.alpha = alpha
    }

    func setChatText(_ text: String) {
        chatTextView.setText(text)
    }

    func setChatInitialText(_ text: String) {
        chatTextView.setInitialText(text)
    }

    func showFullScreenChat() {
        overlayView.alpha = 1
    }

    @objc func hideFullScreenChat() {
        chatTextView.resignFirstResponder()
        overlayView.alpha = 0
    }

    func showChat() {
        directAnswersView.alpha = 1
        chatTextView.alpha = 1
    }

    func hideChat() {
        directAnswersView.alpha = 0
        chatTextView.alpha = 0
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
