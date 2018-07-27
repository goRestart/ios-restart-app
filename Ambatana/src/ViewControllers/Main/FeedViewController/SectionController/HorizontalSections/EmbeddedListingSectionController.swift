import IGListKit

/// This class renders horizontally scrolling listing cells
/// It should be able to render large, medium, or small listing cells
final class EmbeddedListingSectionController: ListSectionController {

    override init() {
        super.init()
        inset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 10)
    }

    override func sizeForItem(at index: Int) -> CGSize {
        let height = collectionContext?.containerSize.height ?? 0
        return CGSize(width: height, height: height)
    }

    override func cellForItem(at index: Int) -> UICollectionViewCell {
        guard let cell = collectionContext?.dequeueReusableCell(of: SimpleImageListingCell.self,
                                                                for: self,
                                                                at: index) as? SimpleImageListingCell else {
            fatalError()
        }
        cell.backgroundColor = .blue
        return cell
    }
}
