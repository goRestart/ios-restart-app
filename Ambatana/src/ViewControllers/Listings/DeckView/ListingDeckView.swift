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

protocol ListingDeckViewDelegate {

}

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
        setupCollectionView()
        setupBottomView()
        bringSubview(toFront: collectionView)

        collectionView.backgroundColor = #colorLiteral(red: 0.721568644, green: 0.8862745166, blue: 0.5921568871, alpha: 1)
    }

    private func setupCollectionView() {
        addSubview(collectionView)
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.delegate = self
        collectionView.layout(with: self).top().leading().trailing()
    }

    private func setupBottomView() {
        addSubview(bottomView)
        bottomView.translatesAutoresizingMaskIntoConstraints = false
        bottomView.layout(with: collectionView).below()
        bottomView.layout(with: self).trailing().bottom().leading()
        bottomView.setContentCompressionResistancePriority(UILayoutPriorityRequired, for: .vertical)
    }
    

    // MARK : UIScrollViewDelegate

    func scrollViewWillEndDragging(_ scrollView: UIScrollView,
                                   withVelocity velocity: CGPoint,
                                   targetContentOffset: UnsafeMutablePointer<CGPoint>) {
        let anchor: CGFloat = 325.0 
        guard self.collectionView == scrollView else { return }
        var targetOffset = collectionView.contentOffset.x
        targetOffset = round(targetOffset / anchor) * anchor
        targetContentOffset.pointee.x = targetOffset
    }
}
