import Foundation
import UIKit
import LGCoreKit

class TagCollectionView: UICollectionView, TagCollectionViewModelDelegate {

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

    
    // MARK: - Lifecycle
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        register(TagCollectionViewCell.self, forCellWithReuseIdentifier: TagCollectionViewCell.reusableID)
    }
    
    init(viewModel: TagCollectionViewModel, flowLayout: UICollectionViewFlowLayout) {
        //let flowLayout = CenterAlignedCollectionViewFlowLayout()

//        let flowLayout = UICollectionViewFlowLayout()
//flowLayout.estimatedItemSize = CGSize(width: 1, height: 1)
////flowLayout.sectionInset = UIEdgeInsets(top: 10, left: 5, bottom: 10, right: 5)
////flowLayout.minimumInteritemSpacing = FilterTagsView.minimumInteritemSpacing
//flowLayout.minimumInteritemSpacing = 5
//flowLayout.minimumLineSpacing = 0
//flowLayout.scrollDirection = .horizontal
        super.init(frame: CGRect.zero, collectionViewLayout: flowLayout)

        register(TagCollectionViewCell.self, forCellWithReuseIdentifier: TagCollectionViewCell.reusableID)
        dataSource = viewModel
        delegate = viewModel
    }
    
    func defaultSetup() {
        report(AppReport.uikit(error: .breadcrumb), message: "TagCollectionView defaultSetup")
        backgroundColor = .clear
        let flowLayout = LeftAlignedCollectionViewFlowLayout()
        flowLayout.estimatedItemSize = CGSize(width: 1, height: 1)
        flowLayout.minimumInteritemSpacing = 5
        flowLayout.minimumLineSpacing = 0
        flowLayout.scrollDirection = .horizontal
        collectionViewLayout = flowLayout
        report(AppReport.uikit(error: .breadcrumb), message: "TagCollectionView defaultSetup end")
//        report(AppReport.uikit(error: .breadcrumb), message: "TagCollectionView defaultSetup")
//        backgroundColor = .clear
//        let flowLayout = LeftAlignedCollectionViewFlowLayout()
//        flowLayout.estimatedItemSize = CGSize(width: 1, height: 1)
//        flowLayout.minimumInteritemSpacing = 5
//        flowLayout.minimumLineSpacing = 5
//        collectionViewLayout = flowLayout
//        report(AppReport.uikit(error: .breadcrumb), message: "TagCollectionView defaultSetup end")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        invalidateIntrinsicContentSize()
        report(AppReport.uikit(error: .breadcrumb), message: "invalidateIntrinsicContentSize")
    }
    
    func updateFlowLayout() {
        let flowLayout = UICollectionViewFlowLayout()
        flowLayout.estimatedItemSize = CGSize(width: 1, height: 1)
        //flowLayout.sectionInset = UIEdgeInsets(top: 10, left: 5, bottom: 10, right: 5)
        //flowLayout.minimumInteritemSpacing = FilterTagsView.minimumInteritemSpacing
        flowLayout.minimumInteritemSpacing = 5
        flowLayout.minimumLineSpacing = 0
        flowLayout.scrollDirection = .horizontal
        collectionViewLayout = flowLayout
    }
    
    
    // MARK: - TagCollectionViewModelDelegate
    
    func vmDidReloadData(_ vm: TagCollectionViewModel) {
        reloadData()
        report(AppReport.uikit(error: .breadcrumb), message: "TagCollectionView vmReloadData invalidateLayout")
        collectionViewLayout.invalidateLayout()
    }
}
