//
//  LeftAlignedHorizontalScrollColectionViewFlowLayout.swift
//  LetGo
//
//  Created by Raúl de Oñate Blanco on 05/02/2018.
//  Copyright © 2018 Ambatana. All rights reserved.
//

import Foundation

class LeftAlignedHorizontalScrollCollectionViewFlowLayout: LeftAlignedCollectionViewFlowLayout {
    override func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
        scrollDirection = .horizontal
        let elementsAttributes = super.layoutAttributesForElements(in: rect)
        return elementsAttributes
    }
}
