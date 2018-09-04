import UIKit

protocol LGWaterFallLayoutDelegate: UICollectionViewDelegate {

    func collectionView(_ collectionView: UICollectionView,
                         layout collectionViewLayout: UICollectionViewLayout,
                         sizeForItemAtIndexPath indexPath: IndexPath) -> CGSize

    func collectionView(_ collectionView: UICollectionView,
                         layout collectionViewLayout: UICollectionViewLayout,
                         columnCountForSectionAt section: Int) -> Int

    func collectionView(_ collectionView: UICollectionView,
                         layout collectionViewLayout: UICollectionViewLayout,
                         heightForHeaderForSectionAt section: Int) -> CGFloat

    func collectionView(_ collectionView: UICollectionView,
                         layout collectionViewLayout: UICollectionViewLayout,
                         heightForFooterInSection section: Int) -> CGFloat

    func collectionView(_ collectionView: UICollectionView,
                         layout collectionViewLayout: UICollectionViewLayout,
                         insetForSectionAt section: Int) -> UIEdgeInsets

    func collectionView(_ collectionView: UICollectionView,
                         layout collectionViewLayout: UICollectionViewLayout,
                         minimumLineSpacingForSectionAt section: Int) -> CGFloat

    func collectionView(_ collectionView: UICollectionView,
                        headerStickynessForSectionAt section: Int) -> HeaderStickyType
    
    func collectionView(_ collectionView: UICollectionView,
                        willDisplay cell: UICollectionViewCell,
                        forItemAt indexPath: IndexPath)
}

extension LGWaterFallLayoutDelegate {
    func collectionView(_ collectionView: UICollectionView,
                        headerStickynessForSectionAt section: Int) -> HeaderStickyType {
        return .nonSticky
    }
}

