import LGCoreKit
import LGComponents

final class PhotoMediaViewerViewDataSource: NSObject, UICollectionViewDataSource {
    private let media: [Media]
    private let imageDownloader: ImageDownloaderType
    private let backgroundColor: UIColor
    private let placeholderImage: UIImage?

    init(media: [Media],
         imageDownloader: ImageDownloaderType,
         backgroundColor: UIColor,
         placeholderImage: UIImage?) {
        self.media = media
        self.imageDownloader = imageDownloader
        self.backgroundColor = backgroundColor
        self.placeholderImage = placeholderImage
    }

    private func mediaAtIndex(index: Int) -> Media? {
        return media[safeAt: index] ?? nil
    }

    private func imageURL(at index: Int) -> URL? {
        return mediaAtIndex(index: index)?.outputs.image ?? nil
    }

    func collectionView(_ collectionView: UICollectionView,
                        cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let media = mediaAtIndex(index: indexPath.row) else { return ListingCarouselImageCell() }
        switch media.type {
        case .image:
            return dequeueFrom(collectionView, imageCellForItem: indexPath)
        case .video:
            return dequeueFrom(collectionView, videoCellForItem: indexPath)
        }
    }

    private func dequeueFrom(_ collectionView: UICollectionView,
                        imageCellForItem indexPath: IndexPath) -> ListingCarouselImageCell {
        guard let cell = collectionView.dequeue(type: ListingCarouselImageCell.self,
                                                for: indexPath) else { return ListingCarouselImageCell() }
        guard let imageURL = imageURL(at: indexPath.row) else { return cell }

        let imageCellTag = (indexPath as NSIndexPath).hash
        cell.tag = imageCellTag
        cell.position = indexPath.row
        cell.backgroundColor = backgroundColor

        if cell.imageURL != imageURL {
            if let placeholder = placeholderImage, indexPath.row == 0 {
                cell.setImage(placeholder)
            }

            imageDownloader.downloadImageWithURL(imageURL) {
                [weak cell] (result, url) in
                guard let cell = cell else { return }
                if let value = result.value, cell.tag == imageCellTag {
                    cell.imageURL = imageURL
                    cell.setImage(value.image)
                }
            }
        }
        return cell
    }

    private func dequeueFrom(_ collectionView: UICollectionView,
                                videoCellForItem indexPath: IndexPath) -> ListingCarouselVideoCell {
        guard let  cell = collectionView.dequeue(type: ListingCarouselVideoCell.self,
                                                 for: indexPath) else { return ListingCarouselVideoCell() }
        guard let videoURL = imageURL(at: indexPath.row) else { return cell }
        cell.setVideo(url: videoURL)
        cell.position = indexPath.item
        return cell
    }


    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return media.count
    }
}
