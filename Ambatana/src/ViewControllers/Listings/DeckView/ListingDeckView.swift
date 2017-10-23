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

    let collectionView = UICollectionView(frame: .zero, collectionViewLayout: ListingDeckCollectionViewLayout())
    let bottomView = UIView()

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setupUI()
    }

    private func setupUI() {
        setupCollectionView()
        setupBottomView()

        collectionView.backgroundColor = #colorLiteral(red: 0.721568644, green: 0.8862745166, blue: 0.5921568871, alpha: 1)
        bottomView.backgroundColor = #colorLiteral(red: 0.9764705896, green: 0.850980401, blue: 0.5490196347, alpha: 1)
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
        bottomView.layout(with: collectionView).below(by: 8)
        bottomView.layout(with: self).proportionalHeight(multiplier: 0.2).trailing().bottom().leading()
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
