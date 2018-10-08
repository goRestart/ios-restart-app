import Foundation
import UIKit
import LGCoreKit
import LGComponents

enum TagCollectionViewFlowLayout {
    case leftAligned
    case centerAligned
    case singleRowWithScroll
    
    var collectionFlowLayout: UICollectionViewFlowLayout {
        switch self {
        case .leftAligned:
            let flowLayout = LeftAlignedCollectionViewFlowLayout()
            flowLayout.estimatedItemSize = CGSize(width: 1, height: 1)
            flowLayout.minimumInteritemSpacing = 5
            flowLayout.minimumLineSpacing = 5
            return flowLayout
        case .centerAligned:
            let flowLayout = CollectionViewCenteredFlowLayout()
            flowLayout.estimatedItemSize = CGSize(width: 1, height: 1)
            flowLayout.minimumInteritemSpacing = 10
            flowLayout.minimumLineSpacing = 10
            return flowLayout
        case .singleRowWithScroll:
            let flowLayout = UICollectionViewFlowLayout()
            flowLayout.estimatedItemSize = CGSize(width: 1, height: 1)
            flowLayout.minimumInteritemSpacing = 10
            flowLayout.minimumLineSpacing = 10
            flowLayout.scrollDirection = .horizontal
            return flowLayout
        }
    }
}

class TagCollectionView: UICollectionView, TagCollectionViewModelDelegate {

    override var intrinsicContentSize: CGSize {
        report(AppReport.uikit(error: .breadcrumb), message: "TagCollectionView-intrinsicContentSize-start")
        if collectionViewLayout.collectionViewContentSize == .zero {
            report(AppReport.uikit(error: .breadcrumb), message: "TagCollectionView-intrinsicContentSize-ZeroLayoutSize")
            // we need to return something different than zero or the datasource `cellForItemAt` method won't get called.
            return CGSize(width: 1, height: 1)
        }
        let height = collectionViewLayout.collectionViewContentSize.height
        let width = collectionViewLayout.collectionViewContentSize.width
        let msg = "TagCollectionView intrinsicContentSize \(height), \(width)"
        report(AppReport.uikit(error: .breadcrumb), message: "TagCollectionView-intrinsicContentSize-end-\(msg)")

        return collectionViewLayout.collectionViewContentSize
    }

    
    // MARK: - Lifecycle
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        register(TagCollectionViewCell.self, forCellWithReuseIdentifier: TagCollectionViewCell.reusableID)
        register(TagCollectionViewWithCloseCell.self, forCellWithReuseIdentifier: TagCollectionViewWithCloseCell.reusableID)
    }
    
    init(viewModel: TagCollectionViewModel, flowLayout: TagCollectionViewFlowLayout) {
        super.init(frame: CGRect.zero, collectionViewLayout: flowLayout.collectionFlowLayout)
        register(TagCollectionViewCell.self, forCellWithReuseIdentifier: TagCollectionViewCell.reusableID)
        register(TagCollectionViewWithCloseCell.self, forCellWithReuseIdentifier: TagCollectionViewWithCloseCell.reusableID)
        dataSource = viewModel
        delegate = viewModel
        setupUI()
    }
    
    func defaultSetup() {
        collectionViewLayout = TagCollectionViewFlowLayout.leftAligned.collectionFlowLayout
        setupUI()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        invalidateIntrinsicContentSize()
    }
    
    
    // MARK: - UI
    
    private func setupUI() {
        translatesAutoresizingMaskIntoConstraints = false
        backgroundColor = .clear
        showsHorizontalScrollIndicator = false
    }
    
    
    // MARK: - TagCollectionViewModelDelegate
    
    func vmDidReloadData(_ vm: TagCollectionViewModel) {
        reloadData()
        collectionViewLayout.invalidateLayout()
    }
}
