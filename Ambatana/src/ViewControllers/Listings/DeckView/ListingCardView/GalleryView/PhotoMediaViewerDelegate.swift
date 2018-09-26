final class PhotoMediaViewerDelegate: NSObject, UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView,
                        willDisplay cell: UICollectionViewCell,
                        forItemAt indexPath: IndexPath) {
        if let imageCell = cell as? ListingCarouselImageCell {
            imageCell.resetZoom()
        } else if let videoCell = cell as? ListingCarouselVideoCell {
            videoCell.play()
        }
    }

    func collectionView(_ collectionView: UICollectionView,
                        didEndDisplaying cell: UICollectionViewCell,
                        forItemAt indexPath: IndexPath) {
        guard let videoCell = cell as? ListingCarouselVideoCell else { return }
        videoCell.pause()
    }
}
