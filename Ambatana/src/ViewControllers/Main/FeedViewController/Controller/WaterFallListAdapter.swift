import IGListKit

final class WaterFallListAdapter: ListAdapter {

    private let numberOfColumnsInLastSection: Int
    weak var scrollDelegate: WaterFallScrollable?
    
    init(updater: ListUpdatingDelegate,
         viewController: UIViewController?,
         workingRangeSize: Int,
         numberOfColumnsInLastSection: Int) {
        self.numberOfColumnsInLastSection = numberOfColumnsInLastSection
        super.init(updater: updater,
                   viewController: viewController,
                   workingRangeSize: workingRangeSize)
    }
}

extension WaterFallListAdapter: WaterFallLayoutDelegate {

    func collectionView (_ collectionView: UICollectionView,
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
        let isLastSection = section == collectionView.numberOfSections - 1
        return isLastSection ? numberOfColumnsInLastSection : 1
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        headerStickynessForSectionAt section: Int) -> HeaderStickyType {
        let isLastSection = section == collectionView.numberOfSections - 1
        return isLastSection ? .sticky : .nonSticky
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        insetForSectionAt section: Int) -> UIEdgeInsets {
        return sectionController(forSection: section)?.inset ?? .zero
    }
}

extension WaterFallListAdapter {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        scrollDelegate?.didScroll(scrollView)
    }
}

