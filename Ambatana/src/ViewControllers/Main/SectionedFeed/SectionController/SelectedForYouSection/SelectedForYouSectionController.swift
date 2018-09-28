import IGListKit
import LGComponents

protocol SelectedForYouDelegate: class {
    func openSelectedForYou()
}

final class SelectedForYouSectionController: ListSectionController {

    weak var selectedForYouDelegate: SelectedForYouDelegate?

    override init() {
        super.init()
        inset = .zero
    }

    override func numberOfItems() -> Int {
        return 1
    }

    override func sizeForItem(at index: Int) -> CGSize {
        guard let width =  collectionContext?.containerSize.width else { return .zero }
        return AspectRatio.w4h3.size(setting: width, in: .width)
    }

    override func cellForItem(at index: Int) -> UICollectionViewCell {
        guard let cell = collectionContext?.dequeueReusableCell(of: CollectionCell.self,
                                                                for: self,
                                                                at: index) as? CollectionCell
            else {
                fatalError("Cannot dequeue CollectionCell in SelectedForYouSectionController")
        }
        cell.configure(with: R.Asset.ProductCellBanners.collectionYou.image,
                       titleText: R.Strings.collectionYouTitle)
        cell.selectedForYouDelegate = selectedForYouDelegate
        return cell
    }

    override func didSelectItem(at index: Int) {
        selectedForYouDelegate?.openSelectedForYou()
    }
}
