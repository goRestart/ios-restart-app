import Foundation
import UIKit

class TagCollectionView: UICollectionView, TagCollectionViewModelDelegate {
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        backgroundColor = .clear
    }
    
    func defaultSetup() {
        let flowLayout = LeftAlignedCollectionViewFlowLayout()
        flowLayout.estimatedItemSize = CGSize(width: 1, height: 1)
        flowLayout.minimumInteritemSpacing = 5
        flowLayout.minimumLineSpacing = 5
        collectionViewLayout = flowLayout
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        adjustHeightConstraintToFitContent()
    }
    
    private func adjustHeightConstraintToFitContent() {
        firstHeightConstraint()?.constant = collectionViewLayout.collectionViewContentSize.height
    }
    
    func vmReloadData(_ vm: TagCollectionViewModel) {
        reloadData()
        collectionViewLayout.invalidateLayout()
    }
    
    private func firstHeightConstraint() -> NSLayoutConstraint? {
        guard let heightConstraint = constraints.filter({
            $0.firstItem as? NSObject == self && $0.firstAttribute == .height
        }).first else {
            return nil
        }
        return heightConstraint
    }
}
