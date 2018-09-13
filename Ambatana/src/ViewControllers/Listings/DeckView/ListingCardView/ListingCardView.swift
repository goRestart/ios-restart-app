import Foundation
import UIKit
import RxSwift
import LGCoreKit
import LGComponents

protocol ListingCardViewDelegate: class {
    func cardViewDidTapOnMoreInfo(_ cardView: ListingCardView)
}

private enum Layout {
    enum Height {
        static let full: CGFloat = 58
        static let simple: CGFloat = 30
    }
}

final class ListingCardView: UICollectionViewCell, ReusableCell {
    weak var delegate: ListingCardViewDelegate?
    private let cardTapGesture = UITapGestureRecognizer()

    private let pageControl = ListingCardPageControl()
    private var carousel: ListingCardMediaCarousel?

    private let videoPreview = VideoPreview(frame: .zero)
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

    private let moreInfoView: MoreInfoViewType
    private let setupMoreInfo: (MoreInfoViewType, UIView) -> ()

    private var imageDownloader: ImageDownloaderType?

    override init(frame: CGRect) {
        self.moreInfoView = FeatureFlags.sharedInstance.deckItemPage.moreInfoView
        if FeatureFlags.sharedInstance.deckItemPage.fullMoreInfo {
            setupMoreInfo = FeatureFlags.sharedInstance.deckItemPage.constraintFull
        } else {
            setupMoreInfo = FeatureFlags.sharedInstance.deckItemPage.constraintSimple
        }
        super.init(frame: frame)
        setupUI()
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        previewImageView.image = nil
        carousel = nil
        videoPreview.pause()
    }

    func populateWith(_ model: ListingCardModel, imageDownloader: ImageDownloaderType) {
        self.imageDownloader = imageDownloader
        populateWith(media: model.media)
        populateWith(title: model.title ?? "", price: model.price)
    }

    required init?(coder aDecoder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    func populateWith(media: [Media]) {
        updateWith(carousel: ListingCardMediaCarousel(media: media, current: 0))
    }

    private func populateWith(title: String, price: String) {
        moreInfoView.setupWith(title: title, price: price)
    }

    private func updateWith(carousel: ListingCardMediaCarousel) {
        pageControl.isHidden = carousel.media.count <= 1
        pageControl.setPages(carousel.media.count)
        pageControl.turnOnAt(carousel.current)
        populateWith(media: carousel.media[safeAt: carousel.current])
        self.carousel = carousel
    }

    private func populateWith(media: Media?) {
        if let video = media?.outputs.video {
            videoPreview.isHidden = false
            previewImageView.isHidden = true
            videoPreview.url = video
            videoPreview.play()
        } else  if let previewURL = media?.outputs.image {
            videoPreview.isHidden = true
            previewImageView.isHidden = false
            previewImageView.lg_setImageWithURL(previewURL)
        }
    }

    private func setupUI() {
        contentView.addSubviewsForAutoLayout([previewImageView, videoPreview, pageControl])
        [
            previewImageView.topAnchor.constraint(equalTo: contentView.topAnchor),
            previewImageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            previewImageView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            previewImageView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),

            videoPreview.topAnchor.constraint(equalTo: contentView.topAnchor),
            videoPreview.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            videoPreview.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            videoPreview.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),

            pageControl.topAnchor.constraint(equalTo: contentView.topAnchor, constant: Metrics.margin),
            pageControl.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: Metrics.margin),
            pageControl.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -Metrics.margin)
        ].activate()
        setupMoreInfoView()
        setupTapGesture()

        backgroundColor = .clear
        contentView.clipsToBounds = true
        contentView.backgroundColor = .white
    }

    private func setupMoreInfoView() {
        moreInfoView.isUserInteractionEnabled = false
        setupMoreInfo(moreInfoView, contentView)
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

private extension NewItemPageV3 {
    var moreInfoView: MoreInfoViewType {
        guard fullMoreInfo else { return MoreInfoLabel(axis: .vertical) }
        return ListingCardInfoView(frame: .zero)
    }

    var fullMoreInfo: Bool { return self == .infoWithLaterals || self == .infoWithoutLaterals }
    var simpleMoreInfo: Bool { return self == .buttonWithLaterals || self == .buttonWithoutLaterals }

    func constraintFull(moreInfo: MoreInfoViewType, into view: UIView) {
        view.addSubviewForAutoLayout(moreInfo)
        [
            moreInfo.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -Metrics.margin),
            moreInfo.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: Metrics.margin),
            moreInfo.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -Metrics.margin),
            moreInfo.heightAnchor.constraint(equalToConstant: Layout.Height.full)
        ].activate()
    }

    func constraintSimple(moreInfo: MoreInfoViewType, into view: UIView) {
        view.addSubviewForAutoLayout(moreInfo)
        [
            moreInfo.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            moreInfo.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -Metrics.margin),
            moreInfo.heightAnchor.constraint(equalToConstant: Layout.Height.simple)
        ].activate()
    }
}
