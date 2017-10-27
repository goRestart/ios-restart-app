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

final class ListingDeckView: UIView, UICollectionViewDelegate {

    let directChatTable = CustomTouchesTableView()
    let chatTextView = ChatTextView()

    let collectionView: UICollectionView
    let layout = ListingDeckCollectionViewLayout()

    let bottomView = UIView()
    let itemActionsView = ListingDeckActionView()
    var directAnswersView = DirectAnswersHorizontalView(answers: [], sideMargin: CarouselUI.itemsMargin)

    override init(frame: CGRect) {
        collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        super.init(frame: frame)
        setupUI()
    }

    required init?(coder aDecoder: NSCoder) {
        collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        super.init(coder: aDecoder)
        setupUI()
    }

    private func setupUI() {
        backgroundColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
        setupDirectChatView()
        setupCollectionView()
        setupBottomView()
        bringSubview(toFront: collectionView)
    }

    private func setupCollectionView() {
        addSubview(collectionView)
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.layout(with: self).top().leading().trailing()

        collectionView.showsHorizontalScrollIndicator = false
        collectionView.decelerationRate = 0
        collectionView.backgroundColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
    }

    private func setupBottomView() {
        addSubview(bottomView)
        bottomView.translatesAutoresizingMaskIntoConstraints = false
        bottomView.layout(with: collectionView).below()
        bottomView.layout(with: self).trailing().bottom().leading()
        bottomView.setContentCompressionResistancePriority(UILayoutPriorityRequired, for: .vertical)

        setupPrivateActionsView()
    }

    private func setupPrivateActionsView() {
        bottomView.addSubview(itemActionsView)
        itemActionsView.translatesAutoresizingMaskIntoConstraints = false
        itemActionsView.layout(with: bottomView).fill()
        itemActionsView.alpha = 0
    }

    private func setupDirectChatView() {
        directAnswersView.style = .light
        directAnswersView.translatesAutoresizingMaskIntoConstraints = false
        bottomView.addSubview(directAnswersView)
        directAnswersView.layout(with: bottomView).leading().trailing().top()

        chatTextView.translatesAutoresizingMaskIntoConstraints = false
        bottomView.addSubview(chatTextView)
        chatTextView.layout(with: bottomView)
            .leading(by: CarouselUI.itemsMargin).trailing(by: -CarouselUI.itemsMargin)
        chatTextView.layout(with: directAnswersView).top(to: .bottom, by: CarouselUI.itemsMargin)
//                                                         constraintBlock: { [weak self] in self?.directAnswersBottom = $0 })

        addSubview(directChatTable)
        directChatTable.translatesAutoresizingMaskIntoConstraints = false
        directChatTable.layout(with: self).topMargin().leftMargin().rightMargin()
        directChatTable.layout(with: directAnswersView).above()
        directChatTable.alpha = 0
    }

    func showBumpUp() {  }

    func hideBumpUp() { print("hideBumpUp") }

    func showActions() {
        UIView.animate(withDuration: 0.2) {
            self.itemActionsView.alpha = 1
            self.directAnswersView.alpha = 0
            self.chatTextView.alpha = 0
            self.directChatTable.alpha = 0
        }
    }

    func hideActions() {
        UIView.animate(withDuration: 0.2) {
            self.itemActionsView.alpha = 0
            self.directAnswersView.alpha = 1
            self.chatTextView.alpha = 1
            self.directChatTable.alpha = 1
        }
    }

    func showChat() { hideActions() }

    func hideChat() { showActions() }

}
