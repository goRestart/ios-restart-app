//
//  WaterFallLayoutDelegates.swift
//  LetGo
//
//  Created by Haiyan Ma on 09/04/2018.
//  Copyright © 2018 Haiyan Ma. All rights reserved.
//

import UIKit

protocol WaterFallLayoutDelegate: UICollectionViewDelegate {
    
    /// Required to implement the size of item at each indexPath
    func collectionView (_ collectionView: UICollectionView,
                         layout collectionViewLayout: UICollectionViewLayout,
                         sizeForItemAtIndexPath indexPath: IndexPath) -> CGSize
    
    func collectionView (_ collectionView: UICollectionView,
                         layout collectionViewLayout: UICollectionViewLayout,
                         columnCountForSectionAt section: Int) -> Int

    func collectionView (_ collectionView: UICollectionView,
                         layout collectionViewLayout: UICollectionViewLayout,
                         insetForSectionAt section: Int) -> UIEdgeInsets

    func collectionView (_ collectionView: UICollectionView,
                         layout collectionViewLayout: UICollectionViewLayout,
                         minimumLineSpacingForSectionAt section: Int) -> CGFloat
    
    func collectionView (_ collectionView: UICollectionView,
                         layout collectionViewLayout: UICollectionViewLayout,
                         heightForHeaderForSectionAt section: Int) -> CGFloat
    
    func collectionView (_ collectionView: UICollectionView,
                         layout collectionViewLayout: UICollectionViewLayout,
                         heightForFooterInSection section: Int) -> CGFloat

    func collectionView(_ collectionView: UICollectionView,
                        stickynessForHeaderAtIndexPath indexPath:IndexPath) -> HeaderStickyType
}

extension WaterFallLayoutDelegate {

    func collectionView(_ collectionView: UICollectionView,
                        stickynessForHeaderAtIndexPath indexPath:IndexPath) -> HeaderStickyType {
        return .nonSticky
    }
    
    func collectionView (_ collectionView: UICollectionView,
                         layout collectionViewLayout: UICollectionViewLayout,
                         heightForHeaderForSectionAt section: Int) -> CGFloat {
        return WaterFallLayoutSettings.headerHeight
    }
    
    func collectionView (_ collectionView: UICollectionView,
                         layout collectionViewLayout: UICollectionViewLayout,
                         heightForFooterInSection section: Int) -> CGFloat {
        return WaterFallLayoutSettings.footerHeight
    }
    
    func collectionView (_ collectionView: UICollectionView,
                         layout collectionViewLayout: UICollectionViewLayout,
                         minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return WaterFallLayoutSettings.minimumLineSpacing
    }
    
    func collectionView (_ collectionView: UICollectionView,
                         layout collectionViewLayout: UICollectionViewLayout,
                         columnCountForSectionAt section: Int) -> Int {
        return WaterFallLayoutSettings.columnCount
    }
    
    func collectionView (_ collectionView: UICollectionView,
                         layout collectionViewLayout: UICollectionViewLayout,
                         insetForSectionAt section: Int) -> UIEdgeInsets {
        return WaterFallLayoutSettings.sectionInset
    }
}
