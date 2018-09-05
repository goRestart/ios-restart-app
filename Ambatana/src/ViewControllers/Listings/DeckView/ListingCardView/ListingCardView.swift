import Foundation
import UIKit
import RxSwift
import LGCoreKit
import LGComponents

protocol ListingCardViewDelegate: class {
    func cardViewDidTapOnMoreInfo(_ cardView: ListingCardView)
}

final class ListingCardView: UICollectionViewCell, ReusableCell {
    weak var delegate: ListingCardViewDelegate?
    private let cardTapGesture = UITapGestureRecognizer()

    private let pageControl = ListingCardPageControl()
    private var carousel: ListingCardMediaCarousel?

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

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        previewImageView.image = nil
        carousel = nil
    }

    func populateWith(_ model: ListingCardModel, imageDownloader: ImageDownloaderType) {
        self.imageDownloader = imageDownloader
        populateWith(media: model.media)
    }

    required init?(coder aDecoder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    func populateWith(media: [Media]) {
        updateWith(carousel: ListingCardMediaCarousel(media: media, current: 0))
    }

    private func updateWith(carousel: ListingCardMediaCarousel) {
        pageControl.isHidden = carousel.media.count <= 1
        pageControl.setPages(carousel.media.count)
        pageControl.turnOnAt(carousel.current)
        populateWith(media: carousel.media[safeAt: carousel.current])
        self.carousel = carousel
    }

    private func populateWith(media: Media?) {
        if let previewURL = media?.outputs.image {
            previewImageView.lg_setImageWithURL(previewURL)
        } else if let video = media?.outputs.video {
            // TODO: handle videos
        }
    }

    private func setupUI() {
        contentView.addSubviewsForAutoLayout([previewImageView, pageControl])

        NSLayoutConstraint.activate([
            previewImageView.topAnchor.constraint(equalTo: contentView.topAnchor),
            previewImageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            previewImageView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            previewImageView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),

            pageControl.topAnchor.constraint(equalTo: contentView.topAnchor, constant: Metrics.margin),
            pageControl.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: Metrics.margin),
            pageControl.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -Metrics.margin)
        ])
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
        let isBottom = location.y / contentView.height > 0.7
        if isBottom {
            delegate?.cardViewDidTapOnMoreInfo(self)
        } else if isLeft, let carousel = self.carousel?.makePrevious() {
            updateWith(carousel: carousel)
        } else if let carousel = self.carousel?.makeNext() {
            updateWith(carousel: carousel)
        }
    }

    override func apply(_ layoutAttributes: UICollectionViewLayoutAttributes) {
        super.apply(layoutAttributes)
        contentView.layer.cornerRadius = Metrics.margin
        previewImageView.layer.cornerRadius = Metrics.margin
        applyShadow(withOpacity: 0.15, radius: Metrics.margin)
        layer.shadowPath = UIBezierPath(roundedRect: bounds, cornerRadius: Metrics.margin).cgPath
    }
}
