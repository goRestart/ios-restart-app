import Foundation

protocol TagCollectionViewModelDelegate: class {
    
    func vmReloadData(_ vm: TagCollectionViewModel)
}

class TagCollectionViewModel: NSObject {
    weak var delegate: TagCollectionViewModelDelegate?
    var tags: [String] {
        didSet {
            delegate?.vmReloadData(self)
        }
    }
    
    init(tags: [String], delegate: TagCollectionViewModelDelegate? = nil) {
        self.delegate = delegate
        self.tags = tags
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
        cell.configure(with: tags[indexPath.row])
        return cell
    }
}
