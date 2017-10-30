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

    let overlayView = UIView()
    let directChatTable = CustomTouchesTableView()
    var directAnswersView = DirectAnswersHorizontalView(answers: [], sideMargin: CarouselUI.itemsMargin)
    let chatTextView = ChatTextView()
    var chatTextViewBottom: NSLayoutConstraint? = nil

    let collectionView: UICollectionView
    var collectionViewTop: NSLayoutConstraint? = nil
    let layout = ListingDeckCollectionViewLayout()

    let itemActionsView = ListingDeckActionView()

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
        }

        collectionView.showsHorizontalScrollIndicator = false
        collectionView.decelerationRate = 0
        collectionView.backgroundColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
    }

    private func setupPrivateActionsView() {
        addSubview(itemActionsView)
        itemActionsView.translatesAutoresizingMaskIntoConstraints = false
        itemActionsView.layout(with: self).trailing().bottom().leading()
        itemActionsView.layout(with: collectionView).below()
        itemActionsView.setContentCompressionResistancePriority(UILayoutPriorityRequired, for: .vertical)
        itemActionsView.alpha = 0
        itemActionsView.backgroundColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
    }

    private func setupDirectChatView() {
        addSubview(overlayView)
        overlayView.translatesAutoresizingMaskIntoConstraints = false
        overlayView.layout(with: self).fill()
        overlayView.alpha = 0
        overlayView.backgroundColor = UIColor.black.withAlphaComponent(0.6)

        chatTextView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(chatTextView)
        chatTextView.layout(with: self)
            .fillHorizontal(by: CarouselUI.itemsMargin)
            .bottomMargin(by: -16.0) { [weak self] constraint in self?.chatTextViewBottom = constraint }
        chatTextView.backgroundColor = .white

        directAnswersView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(directAnswersView)
        directAnswersView.layout(with: self).leftMargin().rightMargin()
        directAnswersView.layout(with: chatTextView).above(by: -8.0)
        directAnswersView.backgroundColor = .clear
        directAnswersView.style = .light

        addSubview(directChatTable)
        directChatTable.translatesAutoresizingMaskIntoConstraints = false
        directChatTable.layout(with: self).topMargin().leftMargin().rightMargin()
        directChatTable.layout(with: directAnswersView).above(by: -8.0)
        directChatTable.alpha = 0
        directChatTable.backgroundColor = .clear
    }

    func updateChatWith(alpha: CGFloat) {
        chatTextView.alpha = alpha
        directAnswersView.alpha = alpha
    }

    func updatePrivateActionsWith(alpha: CGFloat) {
        itemActionsView.alpha = alpha
    }

    func updateBottom(wintInset inset: CGFloat) {
        self.chatTextViewBottom?.constant = -(inset + 16.0)
    }

    func showFullScreenChat() {
        overlayView.alpha = 1
    }

    func hideFullScreenChat() {
        chatTextView.resignFirstResponder()
        overlayView.alpha = 0
    }

    func showBumpUp() {  }

    func hideBumpUp() { print("hideBumpUp") }

    func showActions() {
        self.itemActionsView.alpha = 1
    }

    func hideActions() {
        self.itemActionsView.alpha = 0
    }

    func showChat() {
        self.directAnswersView.alpha = 1
        self.chatTextView.alpha = 1
    }

    func hideChat() {
        self.directAnswersView.alpha = 0
        self.chatTextView.alpha = 0
    }
    
}
