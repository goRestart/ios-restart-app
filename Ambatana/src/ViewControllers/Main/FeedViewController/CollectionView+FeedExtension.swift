//
//  CollectionView+FeedExtension.swift
//  LetGo
//
//  Created by Haiyan Ma on 24/04/2018.
//  Copyright © 2018 Ambatana. All rights reserved.
//

import UIKit

extension UICollectionView {
    
    func registerFeedHeaders(_ headerTypes: [FeedPresenter.Type]) {
        headerTypes.forEach { registerFeedHeader($0) }
    }
    
    func registerFeedFooters(_ footerTypes: [FeedPresenter.Type]) {
        footerTypes.forEach { registerFeedFooter($0) }
    }
    
    func registerFeedCells(_ cellTypes: [FeedPresenter.Type]) {
        cellTypes.forEach { registerFeedCell($0) }
    }
    
    func dequeueReusableCell(withFeedPresenter feedPresenter: FeedPresenter,
                             forIndexPath indexPath: IndexPath) -> UICollectionViewCell? {
        return dequeueReusableCell(withReuseIdentifier: type(of: feedPresenter).reuseIdentifier, for: indexPath)
    }
    
    func dequeueReusableHeaderView(withFeedPresenter feedPresenter: FeedPresenter,
                                   for indexPath: IndexPath) -> UICollectionReusableView? {
        return dequeueReusableSupplementaryView(ofKind: UICollectionElementKindSectionHeader,
                                                withReuseIdentifier: type(of: feedPresenter).reuseIdentifier,
                                                for: indexPath)
    }
    
    func dequeueReusableFooterView(withFeedPresenter feedPresenter: FeedPresenter,
                                   for indexPath: IndexPath) -> UICollectionReusableView? {
        return dequeueReusableSupplementaryView(ofKind: UICollectionElementKindSectionFooter,
                                                withReuseIdentifier: type(of: feedPresenter).reuseIdentifier,
                                                for: indexPath)
    }
    
    
    // MARK:- Private Methods
    
    private func registerFeedHeader(_ headerType: FeedPresenter.Type) {
        register(headerType.feedClass,
                 forSupplementaryViewOfKind: UICollectionElementKindSectionHeader,
                 withReuseIdentifier: headerType.reuseIdentifier)
    }
    
    private func registerFeedFooter(_ footerType: FeedPresenter.Type) {
        register(footerType.feedClass,
                 forSupplementaryViewOfKind: UICollectionElementKindSectionFooter,
                 withReuseIdentifier: footerType.reuseIdentifier)
    }
    
    private func registerFeedCell(_ cellType: FeedPresenter.Type) {
        register(cellType.feedClass,
                 forCellWithReuseIdentifier: cellType.reuseIdentifier)
    }
}
