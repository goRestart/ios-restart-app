import LGCoreKit
import LGComponents
import RxSwift

protocol ListingCarouselCellDelegate: class {
    func didTapOnCarouselCell(_ cell: UICollectionViewCell, tapSide: ListingCarouselTapSide?)
    func isZooming(_ zooming: Bool)
    func didScrollToPage(_ page: Int)
    func didPullFromCellWith(_ offset: CGFloat, bottomLimit: CGFloat)
    func canScrollToNextPage() -> Bool
    func didEndDraggingCell()
}

enum ListingCarouselTapSide {
    case left
    case right
}

final class ListingCarouselCell: UICollectionViewCell {

    static let identifier = "ListingCarouselCell"
    var collectionView: UICollectionView
    
    fileprivate var productImages = [Media]()
    fileprivate var productBackgroundColor: UIColor?
    weak var delegate: ListingCarouselCellDelegate?
    var placeholderImage: UIImage?
    fileprivate var currentPage = 0
    fileprivate var imageScrollDirection: UICollectionViewScrollDirection = .vertical
    fileprivate var verticalScrollCounter: CGFloat = 0.0
    fileprivate var numberOfImages: Int {
        return productImages.count
    }

    var imageDownloader: ImageDownloaderType =  ImageDownloader.sharedInstance

    private var disposeBag = DisposeBag()
    
    override init(frame: CGRect) {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        layout.itemSize = frame.size
        layout.minimumLineSpacing = 0
        layout.minimumInteritemSpacing = 0
        collectionView = UICollectionView(frame: frame, collectionViewLayout: layout)
        if #available(iOS 11.0, *) {
            // TODO: This was introduced to work with safe areas and IphoneXes
            // we will tackle this later 💥
            collectionView.contentInsetAdjustmentBehavior = .never
        }
        super.init(frame: frame)
        setupUI()
        setAccessibilityIds()
    }
    
    required init?(coder aDecoder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    func setupUI() {
        addSubview(collectionView)
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        let constraints = [
            collectionView.topAnchor.constraint(equalTo: contentView.topAnchor),
            collectionView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            collectionView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
            collectionView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor)
        ]
        NSLayoutConstraint.activate(constraints)

        collectionView.keyboardDismissMode = .onDrag
        collectionView.backgroundColor = .clear
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.isPagingEnabled = true
        collectionView.alwaysBounceVertical = true
        collectionView.showsVerticalScrollIndicator = false
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.allowsSelection = false
        collectionView.isDirectionalLockEnabled = true
        collectionView.register(ListingCarouselImageCell.self,
                                forCellWithReuseIdentifier: ListingCarouselImageCell.reusableID)
        
        let singleTap = UITapGestureRecognizer(target: self, action: #selector(doSingleTapAction))
        collectionView.addGestureRecognizer(singleTap)
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        disposeBag = DisposeBag()
        delegate = nil
        collectionView.setContentOffset(CGPoint.zero, animated: false)
    }
    
    @objc func doSingleTapAction(_ gestureRecognizer: UITapGestureRecognizer) {
        guard imageScrollDirection == .horizontal else {
            delegate?.didTapOnCarouselCell(self, tapSide: nil)
            return
        }

        let tapLocation = gestureRecognizer.location(in: gestureRecognizer.view)
        let pageSize = collectionView.frame.size.width
        guard pageSize > 0, numberOfImages > 0 else { return }
        let tapLocationPage = tapLocation.x - CGFloat(currentPage)*pageSize
        if tapLocationPage < pageSize/4 {
            let collectionContentOffset = collectionView.contentOffset.x - self.width
            if collectionContentOffset < 0 {
                delegate?.didTapOnCarouselCell(self, tapSide: .left)
            } else {
                collectionView.setContentOffset(CGPoint(x: collectionContentOffset, y: 0.0), animated: true)
            }
        } else {
            let collectionContentOffset = collectionView.contentOffset.x + self.width
            if collectionContentOffset >= self.width * CGFloat(numberOfImages) {
                delegate?.didTapOnCarouselCell(self, tapSide: .right)
            } else {
                collectionView.setContentOffset(CGPoint(x: collectionContentOffset, y: 0.0), animated: true)
            }
        }
    }

    func configureCellWith(cellModel: ListingCarouselCellModel, placeholderImage: UIImage?, indexPath: IndexPath,
                           imageDownloader: ImageDownloaderType, imageScrollDirection: UICollectionViewScrollDirection) {
        self.tag = (indexPath as NSIndexPath).hash
        self.productImages = cellModel.media
        self.productBackgroundColor = cellModel.backgroundColor
        self.imageDownloader = imageDownloader
        self.placeholderImage = placeholderImage
        self.imageScrollDirection = imageScrollDirection

        if let layout = collectionView.collectionViewLayout as? UICollectionViewFlowLayout {
            layout.scrollDirection = imageScrollDirection
        }

        if let media = productImages.first,
            let placeholderURL = media.outputs.imageThumbnail,
            placeholderImage == nil {
            self.placeholderImage = imageDownloader.cachedImageForUrl(placeholderURL)
        }
        
        collectionView.isScrollEnabled = (imageScrollDirection != .horizontal)
        collectionView.reloadData()
    }
    
    func returnToFirstImage() {
        guard productImages.count > 1 else { return }
        let scrollPosition = imageScrollDirection == .horizontal ? UICollectionViewScrollPosition.left : UICollectionViewScrollPosition.top
        collectionView.scrollToItem(at: IndexPath(item: 0, section: 0), at: scrollPosition, animated: false)
    }
        
    fileprivate func imageAtIndex(_ index: Int) -> URL? {
        guard 0..<productImages.count ~= index else { return nil }
        return productImages[index].outputs.image
    }
}

// MARK: - UICollectionViewDataSource & UICollectionViewDelegate 

extension ListingCarouselCell: UICollectionViewDelegate, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return numberOfImages
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath)
        -> UICollectionViewCell {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: ListingCarouselImageCell.reusableID,
                                                          for: indexPath)
            guard let imageCell = cell as? ListingCarouselImageCell else { return ListingCarouselImageCell() }
            guard let imageURL = imageAtIndex(indexPath.row) else { return imageCell }

            //Required to avoid missmatching when downloading images
            let imageCellTag = (indexPath as NSIndexPath).hash
            let productCarouselTag = self.tag
            imageCell.tag = imageCellTag
            imageCell.position = indexPath.row
            imageCell.backgroundColor = productBackgroundColor
            imageCell.delegate = self

            if imageCell.imageURL != imageURL { //Avoid reloading same image in the cell
                if let placeholder = placeholderImage, indexPath.row == 0 {
                    imageCell.setImage(placeholder)
                } else {
                    imageCell.imageView.image = nil
                }

                imageDownloader.downloadImageWithURL(imageURL) { [weak self, weak imageCell] (result, url) in
                    if let value = result.value, self?.tag == productCarouselTag && cell.tag == imageCellTag {
                        imageCell?.imageURL = imageURL
                        imageCell?.setImage(value.image)
                    }
                }
            }
            return imageCell
    }

    func collectionView(_ collectionView: UICollectionView,
                        willDisplay cell: UICollectionViewCell,
                        forItemAt indexPath: IndexPath) {
        guard let imageCell = cell as? ListingCarouselImageCell else { return }
        imageCell.resetZoom()
    }

    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let pageSize = imageScrollDirection == .horizontal ? collectionView.frame.size.width : collectionView.frame.size.height
        guard pageSize > 0, numberOfImages > 0 else { return }
        let collectionContentOffset: CGFloat

        if imageScrollDirection == .horizontal {
            verticalScrollCounter = verticalScrollCounter + scrollView.contentOffset.y
            collectionContentOffset = scrollView.contentOffset.x
            // in horizontal image scrolling, collection should not be able to move upwards.
            if verticalScrollCounter > 0 {
                scrollView.setContentOffset(CGPoint(x: scrollView.contentOffset.x, y: 0.0), animated: false)
            }
        } else {
            collectionContentOffset = scrollView.contentOffset.y
        }
        
        let page = Int(round(collectionContentOffset / pageSize)) % numberOfImages
        if page != currentPage {
            currentPage = page
            delegate?.isZooming(false)
            delegate?.didScrollToPage(page)
        }

        if let delegate = delegate {
            // tells the delegate how much to move the carousel elements "more info", chat textfield & buttons.
            delegate.didPullFromCellWith(scrollView.contentOffset.y, bottomLimit: bottomScrollLimit)

            if !delegate.canScrollToNextPage() {
                // Setting the contentOffset.y = 0 prevents the collection of going down when scrolling for the "more info"
                if imageScrollDirection == .horizontal {
                    // Stay in the current picture
                    scrollView.contentOffset = CGPoint(x: scrollView.contentOffset.x, y: 0)
                } else {
                    scrollView.contentOffset = CGPoint(x: 0, y: 0)
                }
            }
        }
    }
    
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        verticalScrollCounter = 0.0
        delegate?.didEndDraggingCell()
    }

    var bottomScrollLimit: CGFloat {
        return max(0, collectionView.contentSize.height - collectionView.height + collectionView.contentInset.bottom)
    }
}


// MARK: - ListingCarouselImageCellDelegate

extension ListingCarouselCell: ListingCarouselImageCellDelegate {
    func isZooming(_ zooming: Bool, pageAtIndex index: Int) {
        guard index == currentPage else { return }
        delegate?.isZooming(zooming)
    }
}


// MARK: - Private methods
// MARK: > Accessibility

fileprivate extension ListingCarouselCell {
    func setAccessibilityIds() {
        self.set(accessibilityId: .listingCarouselCell)
        collectionView.set(accessibilityId: .listingCarouselCellCollectionView)
        placeholderImage?.set(accessibilityId: .listingCarouselCellPlaceholderImage)
    }
}
