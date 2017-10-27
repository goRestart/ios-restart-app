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

    let collectionView: UICollectionView
    let layout = ListingDeckCollectionViewLayout()

    let bottomView = ListingDeckActionView()

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
        setupBottomView()
        bringSubview(toFront: collectionView)

        collectionView.backgroundColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
    }

    private func setupCollectionView() {
        addSubview(collectionView)
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.layout(with: self).top().leading().trailing()

        collectionView.showsHorizontalScrollIndicator = false
        collectionView.decelerationRate = 0
    }

    private func setupBottomView() {
        addSubview(bottomView)
        bottomView.translatesAutoresizingMaskIntoConstraints = false
        bottomView.layout(with: collectionView).below()
        bottomView.layout(with: self).trailing().bottom().leading()
        bottomView.setContentCompressionResistancePriority(UILayoutPriorityRequired, for: .vertical)
    }

}
