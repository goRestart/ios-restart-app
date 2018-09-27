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
    private var carousel = ListingCardMediaCarousel(media: [], currentIndex: 0)

    private let mediaView: PhotoMediaViewerView
    private var mediaViewModel: PhotoMediaViewerViewModel?

    var previewVisibleFrame: CGRect {
        let size = CGSize(width: contentView.width, height: contentView.height)
        return CGRect(origin: frame.origin, size: size)
    }

    private let moreInfoView: MoreInfoViewType
    private let setupMoreInfo: (MoreInfoViewType, UIView) -> ()

    override init(frame: CGRect) {
        self.moreInfoView = FeatureFlags.sharedInstance.deckItemPage.moreInfoView
        if FeatureFlags.sharedInstance.deckItemPage.fullMoreInfo {
            setupMoreInfo = FeatureFlags.sharedInstance.deckItemPage.constraintFull
        } else {
            setupMoreInfo = FeatureFlags.sharedInstance.deckItemPage.constraintSimple
        }
        self.mediaView = PhotoMediaViewerView(frame: frame)
        super.init(frame: frame)
        setupUI()
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        carousel = ListingCardMediaCarousel(media: [], currentIndex: 0)
        mediaView.reset()
    }

    func populateWith(_ model: ListingCardModel, imageDownloader: ImageDownloaderType) {
        populateWith(title: model.title ?? "", price: model.price)
        populateWith(media: model.media, imageDownloader: imageDownloader)
    }

    @available(*, unavailable)
    required init?(coder aDecoder: NSCoder) { fatalError("Die xibs, die") }

    func populateWith(media: [Media], imageDownloader: ImageDownloaderType) {
        let vm = PhotoMediaViewerViewModel(tag: 0,
                                           media: media,
                                           backgroundColor: .white,
                                           placeholderImage: nil,
                                           imageDownloader: imageDownloader)
        mediaViewModel = vm
        mediaView.set(viewModel: vm)
        updateWith(carousel: ListingCardMediaCarousel(media: media, currentIndex: 0))
        mediaView.reloadData()
    }

    private func populateWith(title: String, price: String) {
        moreInfoView.setupWith(title: title, price: price)
    }

    private func updateWith(carousel: ListingCardMediaCarousel) {
        pageControl.isHidden = carousel.media.count <= 1
        pageControl.setPages(carousel.media.count)
        pageControl.turnOnAt(carousel.currentIndex)
        mediaViewModel?.setIndex(carousel.currentIndex)
        self.carousel = carousel
    }

    private func setupUI() {
        contentView.addSubviewsForAutoLayout([mediaView, pageControl])
        [
            mediaView.topAnchor.constraint(equalTo: contentView.topAnchor),
            mediaView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            mediaView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
            mediaView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),

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
        } else if isLeft {
            updateWith(carousel: carousel.makePrevious())
        } else {
            updateWith(carousel: carousel.makeNext())
        }
    }

    override func apply(_ layoutAttributes: UICollectionViewLayoutAttributes) {
        super.apply(layoutAttributes)
        contentView.layer.cornerRadius = Metrics.margin
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
