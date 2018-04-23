//
//  UICollectionViewLayoutAttributes+Builder.swift
//  LetGo
//
//  Created by Haiyan Ma on 19/04/2018.
//  Copyright © 2018 Ambatana. All rights reserved.
//

import UIKit

extension UICollectionViewLayoutAttributes {
    
    static func buildForHeader(inSection section: Int) -> UICollectionViewLayoutAttributes {
        return UICollectionViewLayoutAttributes(forSupplementaryViewOfKind: UICollectionElementKindSectionHeader,
                                                with: IndexPath(item: 0, section: section))
    }
    
    static func buildForFooter(inSection section: Int) -> UICollectionViewLayoutAttributes {
        return UICollectionViewLayoutAttributes(forSupplementaryViewOfKind: UICollectionElementKindSectionFooter,
                                                with: IndexPath(item: 0, section: section))
    }
    
    static func buildForCell(atIndexPath indexPath: IndexPath) -> UICollectionViewLayoutAttributes {
        return UICollectionViewLayoutAttributes(forCellWith: indexPath)
    }
}
