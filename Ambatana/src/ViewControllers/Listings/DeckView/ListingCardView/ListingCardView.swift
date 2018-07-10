import Foundation
import UIKit
import RxSwift
import LGCoreKit
import LGComponents

enum CardViewTapLocation {
    case right, left, bottom
}

protocol ListingCardViewDelegate: class {
    func cardViewDidTapOnStatusView(_ cardView: ListingCardView)
    func cardViewDidTapOn(_ cardView: ListingCardView, location: CardViewTapLocation)
}

final class ListingCardView: UICollectionViewCell, ReusableCell {
    weak var delegate: ListingCardViewDelegate?
    private let cardTapGesture = UITapGestureRecognizer()

    private let binder = ListingCardViewBinder()

    private let statusView = ProductStatusView()
    private let statusTapGesture = UITapGestureRecognizer()

    private let previewImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.clipsToBounds = true
        imageView.backgroundColor = .gray
        imageView.contentMode = .scaleAspectFill
        return imageView
    }()

    var previewVisibleFrame: CGRect {
        let size = CGSize(width: contentView.width, height: previewImageView.height)
        return CGRect(origin: frame.origin, size: size)
    }

    private var imageDownloader: ImageDownloaderType?
    private(set) var pageCount: Int = 0

    override init(frame: CGRect) {
        super.init(frame: frame)
        binder.cardView = self
        setupUI()
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        previewImageView.image = nil
    }

    func populateWith(cellModel listingViewModel: ListingCardViewCellModel, imageDownloader: ImageDownloaderType) {
        self.imageDownloader = imageDownloader
        binder.bind(withViewModel: listingViewModel)
    }

    func populateWith(_ listingSnapshot: ListingDeckSnapshotType, imageDownloader: ImageDownloaderType) {
        self.imageDownloader = imageDownloader
        populateWith(preview: listingSnapshot.preview, imageCount: listingSnapshot.imageCount)
    }

    func populateWith(preview: URL?, imageCount: Int) {
        update(pageCount: imageCount)
        guard let previewURL = preview else { return }
        _ = imageDownloader?.downloadImageWithURL(previewURL) { [weak self] (result, url) in
            if let value = result.value {
                let higherThanWider = value.image.size.height >= value.image.size.width
                DispatchQueue.main.async {
                    self?.previewImageView.contentMode = higherThanWider ? .scaleAspectFill : .scaleAspectFit
                    self?.previewImageView.image = value.image
                }
            }
        }
    }

    func populateWith(status: ListingViewModelStatus?, featured: Bool) {
        guard let listingStatus = status else {
            statusView.isHidden = true
            return
        }
        statusTapGesture.isEnabled = featured
        let statusVisible = featured || listingStatus.shouldShowStatus
        statusView.isHidden = !statusVisible
        statusView.setFeaturedStatus(listingStatus, featured: featured)
    }

    required init?(coder aDecoder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    func update(pageCount: Int) {
        self.pageCount = pageCount
        // TODO: Update page progress bar
    }

    private func setupUI() {
        contentView.addSubviewsForAutoLayout([previewImageView, statusView])

        NSLayoutConstraint.activate([
            previewImageView.topAnchor.constraint(equalTo: contentView.topAnchor),
            previewImageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            previewImageView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            previewImageView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),

            statusView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: Metrics.margin),
            statusView.centerXAnchor.constraint(equalTo: contentView.centerXAnchor)
        ])
        setupStatusView()
        setupTapGesture()

        backgroundColor = .clear
        contentView.clipsToBounds = true
        contentView.backgroundColor = .white
    }

    private func setupTapGesture() {
        contentView.addGestureRecognizer(cardTapGesture)
        cardTapGesture.addTarget(self, action: #selector(didTapCard))
    }

    @objc private func didTapCard(_ gesture: UITapGestureRecognizer) {
        let location = gesture.location(in: contentView)
        let isLeft = location.x / contentView.width < 0.5

        delegate?.cardViewDidTapOn(self, location: isLeft ? .left : .right)

        // TODO: Check more info when we have it implemented
    }

    private func setupStatusView() {
        statusTapGesture.addTarget(self, action: #selector(touchUpStatusView))
        statusView.addGestureRecognizer(statusTapGesture)
        statusView.isHidden = true
    }

    @objc private func touchUpStatusView() {
        statusView.bounce { [weak self] in
            guard let strongSelf = self else { return }
            strongSelf.delegate?.cardViewDidTapOnStatusView(strongSelf)
        }
    }

    override func apply(_ layoutAttributes: UICollectionViewLayoutAttributes) {
        super.apply(layoutAttributes)
        contentView.layer.cornerRadius = Metrics.margin
        previewImageView.layer.cornerRadius = Metrics.margin
    }
}
