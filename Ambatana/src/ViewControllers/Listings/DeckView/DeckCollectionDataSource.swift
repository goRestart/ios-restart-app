import Foundation
import LGComponents

protocol DeckCollectionViewModel: class {
    var objectCount: Int { get }
    func snapshotModelAt(index: Int) -> ListingDeckSnapshotType?
}

final class DeckCollectionDataSource: NSObject, UICollectionViewDataSource {
    private weak var viewModel: DeckCollectionViewModel?
    private let imageDownloader: ImageDownloaderType
    weak var delegate: ListingCardViewDelegate?

    init(withViewModel vm: DeckCollectionViewModel, imageDownloader: ImageDownloaderType) {
        self.viewModel = vm
        self.imageDownloader = imageDownloader
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return viewModel?.objectCount ?? 0
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeue(type: ListingCardView.self,
                                                for: indexPath) else { return UICollectionViewCell() }
        guard let model = viewModel?.snapshotModelAt(index: indexPath.row) else { return cell }

        cell.tag = indexPath.row
        cell.populateWith(model, imageDownloader: imageDownloader)
        cell.delegate = self.delegate

        return cell
    }
}
