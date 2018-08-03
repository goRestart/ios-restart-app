
import UIKit

extension UICollectionView {
    
    func scrollToSupplementaryView(ofKind kind: String,
                                   atIndexPath indexPath: IndexPath,
                                   atScrollPosition scrollPosition: UICollectionViewScrollPosition,
                                   verticalOffset: CGFloat,
                                   animated: Bool) {
        self.layoutIfNeeded()
        if let layoutAttributes =  self.layoutAttributesForSupplementaryElement(ofKind: kind, at: indexPath) {
            let viewOrigin = CGPoint(x: layoutAttributes.frame.origin.x, y: layoutAttributes.frame.origin.y)
            var resultOffset : CGPoint = self.contentOffset
            
            switch(scrollPosition) {
            case UICollectionViewScrollPosition.top:
                resultOffset.y = viewOrigin.y - (self.contentInset.top+verticalOffset)
                
            case UICollectionViewScrollPosition.left:
                resultOffset.x = viewOrigin.x - self.contentInset.left
                
            case UICollectionViewScrollPosition.right:
                resultOffset.x = (viewOrigin.x - self.contentInset.left) - (self.frame.size.width - layoutAttributes.frame.size.width)
                
            case UICollectionViewScrollPosition.bottom:
                resultOffset.y = (viewOrigin.y - self.contentInset.top) - (self.frame.size.height - layoutAttributes.frame.size.height)
                
            case UICollectionViewScrollPosition.centeredVertically:
                resultOffset.y = (viewOrigin.y - self.contentInset.top) - (self.frame.size.height / 2 - layoutAttributes.frame.size.height / 2)
                
            case UICollectionViewScrollPosition.centeredHorizontally:
                resultOffset.x = (viewOrigin.x - self.contentInset.left) - (self.frame.size.width / 2 - layoutAttributes.frame.size.width / 2)
            default:
                break
            }
            self.scrollRectToVisible(CGRect(origin: resultOffset, size: self.frame.size), animated: animated)
        }
    }
}
