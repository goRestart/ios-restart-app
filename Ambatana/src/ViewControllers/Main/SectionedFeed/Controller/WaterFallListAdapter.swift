import IGListKit
import LGComponents

final class WaterFallListAdapter: ListAdapter {

    private let waterfallColumnCount: Int
    weak var scrollDelegate: WaterFallScrollable?
    
    init(updater: ListUpdatingDelegate,
         viewController: UIViewController?,
         workingRangeSize: Int,
         waterfallColumnCount: Int) {
        self.waterfallColumnCount = waterfallColumnCount
        super.init(updater: updater,
                   viewController: viewController,
                   workingRangeSize: workingRangeSize)
    }
}

extension WaterFallListAdapter: LGWaterFallLayoutDelegate {
    
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        heightForHeaderForSectionAt section: Int) -> CGFloat {
        return sizeForSupplementaryView(ofKind: UICollectionElementKindSectionHeader,
                                        at: IndexPath(item: 0, section: section)).height
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        heightForFooterInSection section: Int) -> CGFloat {
        return sizeForSupplementaryView(ofKind: UICollectionElementKindSectionFooter,
                                        at: IndexPath(item: 0, section: section)).height
    }

    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAtIndexPath indexPath: IndexPath) -> CGSize {
        return sizeForItem(at: indexPath)
    }

    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        columnCountForSectionAt section: Int) -> Int {
        let sc = sectionController(forSection: section)
        if sc is ProductListingSectionController
            || sc is AdsSectionController
            || sc is SelectedForYouSectionController {
            return waterfallColumnCount
        } else { return 1 }
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        headerStickynessForSectionAt section: Int) -> HeaderStickyType {
        return .nonSticky
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        insetForSectionAt section: Int) -> UIEdgeInsets {
        return sectionController(forSection: section)?.inset ?? .zero
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return Metrics.shortMargin
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        willDisplay cell: UICollectionViewCell,
                        forItemAt indexPath: IndexPath) {
        scrollDelegate?.willScroll(toSection: indexPath.section)
    }
}

extension WaterFallListAdapter {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        scrollDelegate?.didScroll(scrollView)
    }
}

