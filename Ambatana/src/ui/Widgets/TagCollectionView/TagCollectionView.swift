import Foundation
import UIKit
import LGCoreKit

class TagCollectionView: UICollectionView, TagCollectionViewModelDelegate {

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        register(TagCollectionViewCell.self, forCellWithReuseIdentifier: TagCollectionViewCell.reusableID)
    }
    
    init(viewModel: TagCollectionViewModel) {
        let flowLayout = CenterAlignedCollectionViewFlowLayout()
        flowLayout.estimatedItemSize = CGSize(width: 1, height: 1)
        flowLayout.minimumInteritemSpacing = 5
        flowLayout.minimumLineSpacing = 5
        
        super.init(frame: CGRect.zero, collectionViewLayout: flowLayout)
        
        register(TagCollectionViewCell.self, forCellWithReuseIdentifier: TagCollectionViewCell.reusableID)
        dataSource = viewModel
        delegate = viewModel
    }
    
    func defaultSetup() {
        report(AppReport.uikit(error: .breadcrumb), message: "TagCollectionView defaultSetup")
        backgroundColor = .clear
        let flowLayout = CenterAlignedCollectionViewFlowLayout()
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
    
    func vmDidReloadData(_ vm: TagCollectionViewModel) {
        reloadData()
        report(AppReport.uikit(error: .breadcrumb), message: "TagCollectionView vmReloadData invalidateLayout")
        collectionViewLayout.invalidateLayout()
    }
}
