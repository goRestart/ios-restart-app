import Foundation
import UIKit

class LeftAlignedCollectionViewFlowLayout: UICollectionViewFlowLayout {
    
    override func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
        var xPosition: CGFloat = 0
        let elementsAttributes = super.layoutAttributesForElements(in: rect)
        elementsAttributes?.forEach { attributes in
            if attributes.frame.origin.x == sectionInset.left {
                xPosition = sectionInset.left
            } else {
                attributes.frame.origin.x = xPosition
            }
            xPosition += attributes.frame.size.width + minimumInteritemSpacing
        }
        return elementsAttributes
    }
}
