import Foundation
import UIKit

class TagCollectionView: UICollectionView, TagCollectionViewModelDelegate {
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    func defaultSetup() {
        backgroundColor = .clear
        let flowLayout = LeftAlignedCollectionViewFlowLayout()
        flowLayout.estimatedItemSize = CGSize(width: 1, height: 1)
        flowLayout.minimumInteritemSpacing = 5
        flowLayout.minimumLineSpacing = 5
        collectionViewLayout = flowLayout
    }

    override var intrinsicContentSize: CGSize {
        if collectionViewLayout.collectionViewContentSize == .zero {
            // we need to return something different than zero or the datasource `cellForItemAt` method won't get called.
            return CGSize(width: 1, height: 1)
        }
        return collectionViewLayout.collectionViewContentSize
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        invalidateIntrinsicContentSize()
    }
    
    func vmReloadData(_ vm: TagCollectionViewModel) {
        reloadData()
        collectionViewLayout.invalidateLayout()
    }
}
