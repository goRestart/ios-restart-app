import Foundation
import UIKit
import LGCoreKit

class TagCollectionView: UICollectionView, TagCollectionViewModelDelegate {
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    func defaultSetup() {
        report(AppReport.uikit(error: .breadcrumb), message: "TagCollectionView defaultSetup")
        backgroundColor = .clear
        let flowLayout = LeftAlignedCollectionViewFlowLayout()
        flowLayout.estimatedItemSize = CGSize(width: 1, height: 1)
        flowLayout.minimumInteritemSpacing = 5
        flowLayout.minimumLineSpacing = 5
        collectionViewLayout = flowLayout
        report(AppReport.uikit(error: .breadcrumb), message: "TagCollectionView defaultSetup end")
    }

    override var intrinsicContentSize: CGSize {
        report(AppReport.uikit(error: .breadcrumb), message: "TagCollectionView intrinsicContentSize")
        if collectionViewLayout.collectionViewContentSize == .zero {
            // we need to return something different than zero or the datasource `cellForItemAt` method won't get called.
            return CGSize(width: 1, height: 1)
        }
        let height = collectionViewLayout.collectionViewContentSize.height
        let width = collectionViewLayout.collectionViewContentSize.width

        let msg = "TagCollectionView intrinsicContentSize \(height), \(width)"
        report(AppReport.uikit(error: .breadcrumb), message: msg)

        return collectionViewLayout.collectionViewContentSize
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        invalidateIntrinsicContentSize()
        report(AppReport.uikit(error: .breadcrumb), message: "invalidateIntrinsicContentSize")
    }
    
    func vmReloadData(_ vm: TagCollectionViewModel) {
        reloadData()
        report(AppReport.uikit(error: .breadcrumb), message: "TagCollectionView vmReloadData invalidateLayout")
        collectionViewLayout.invalidateLayout()
    }
}
