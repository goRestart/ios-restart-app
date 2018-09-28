final class PhotoMediaViewerDelegate: NSObject, UICollectionViewDelegateFlowLayout {
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

    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {
        return collectionView.bounds.size
    }
}
