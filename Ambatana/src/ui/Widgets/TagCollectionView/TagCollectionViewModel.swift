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
    var tags: [String] = [] {
        didSet {
            delegate?.vmDidReloadData(self)
        }
    }
    
    init(cellStyle: TagCollectionViewCellStyle,
         delegate: TagCollectionViewModelDelegate? = nil) {
        self.delegate = delegate
        self.cellStyle = cellStyle
    }
}

extension TagCollectionViewModel: UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return tags.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cellIdentifier = cellStyle.containsCross ? TagCollectionViewWithCloseCell.reusableID : TagCollectionViewCell.reusableID
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellIdentifier, for: indexPath)
        if let configurableCell = cell as? TagCollectionConfigurable {
            configurableCell.setupWith(style: cellStyle)
            configurableCell.configure(with: tags[indexPath.row])
        }
        return cell
    }

}

extension TagCollectionViewModel: UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        selectionDelegate?.vm(self, didSelectTagAtIndex: indexPath.item)
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {
        if cellStyle.containsCross {
            let cellText = tags[indexPath.row]
            return TagCollectionViewWithCloseCell.cellSizeForText(text: cellText, style: cellStyle)
        }
        return (collectionViewLayout as? UICollectionViewFlowLayout)?.itemSize ?? .zero
    }

}
