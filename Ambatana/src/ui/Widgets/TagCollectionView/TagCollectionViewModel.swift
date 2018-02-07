import Foundation

protocol TagCollectionViewModelDelegate: class {
    func vmDidReloadData(_ vm: TagCollectionViewModel)
}

protocol TagCollectionViewModelSelectionDelegate: class {
    func vm(_ vm: TagCollectionViewModel, didSelectTagAtIndex index: Int)
}

class TagCollectionViewModel: NSObject {
    let cellStyle: TagCollectionViewCellStyle
    weak var delegate: TagCollectionViewModelDelegate?
    weak var selectionDelegate: TagCollectionViewModelSelectionDelegate?
    var tags: [String] {
        didSet {
            delegate?.vmDidReloadData(self)
        }
    }
    
    init(tags: [String],
         cellStyle: TagCollectionViewCellStyle,
         delegate: TagCollectionViewModelDelegate? = nil) {
        self.delegate = delegate
        self.tags = tags
        self.cellStyle = cellStyle
    }
}

extension TagCollectionViewModel: UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return tags.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: TagCollectionViewCell.reusableID,
                                                            for: indexPath) as? TagCollectionViewCell
            else {
                return UICollectionViewCell()
        }
        cell.setupWith(style: cellStyle)
        cell.configure(with: tags[indexPath.row])
        return cell
    }
}

extension TagCollectionViewModel: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        selectionDelegate?.vm(self, didSelectTagAtIndex: indexPath.item)
    }
}
