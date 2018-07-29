import UIKit
import LGCoreKit
import RxCocoa
import RxSwift
import LGComponents

private struct LGMapDetailViewMetrics {
    static let height: CGFloat = 180
    static let titleLabelFont = UIFont.systemMediumFont(size: 19)
    static let priceLabelFont = UIFont.systemBoldFont(size: 23)
    static let imageCornerRadius: CGFloat = 6
    static let imageWidth: CGFloat = 129
    static let imageHeight: CGFloat = 150
}

protocol LGMapDetailViewDelegate: class {
    func mapDetailTapped(_ listing: Listing, originImageView: UIImageView?)
}

final class LGMapDetailView: UIView {
    
    private let disposeBag = DisposeBag()

    private var imageDownloader: ImageDownloaderType?
    
    private let listingVariable: Variable<Listing?> = Variable(nil)
    private let tagsVariable: Variable<[String]> = Variable([])
    
    weak var delegate: LGMapDetailViewDelegate?
    
    
    // MARK: - Lifecycle
    
    init(imageDownloader: ImageDownloaderType) {
        super.init(frame: .zero)
        self.imageDownloader = imageDownloader
        setupUI()
        setupRx()
    }
    
    required init?(coder aDecoder: NSCoder) { fatalError("init(coder:) has not been implemented") }
    
    // MARK: - Subviews
    
    private let ribbonView: LGRibbonView = {
        let ribbonView = LGRibbonView()
        ribbonView.title = R.Strings.bumpUpProductCellFeaturedStripe
        return ribbonView
    }()
    
    private let imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.cornerRadius = LGMapDetailViewMetrics.imageCornerRadius
        imageView.clipsToBounds = true
        return imageView
    }()
    
    private let detailStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.alignment = .top
        stackView.layoutMargins = .zero
        stackView.spacing = Metrics.shortMargin
        stackView.clipsToBounds = true
        return stackView
    }()
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 2
        label.font = LGMapDetailViewMetrics.titleLabelFont
        label.textAlignment = .left
        label.textColor = .lgBlack
        return label
    }()
    
    private let priceLabel: UILabel = {
        let label = UILabel()
        label.font = LGMapDetailViewMetrics.priceLabelFont
        label.textAlignment = .left
        label.textColor = .lgBlack
        return label
    }()
    
    private var tagCollectionViewModel = TagCollectionViewModel(cellStyle: .grayBorder)
    private var tagCollectionView: TagCollectionView?
    
    //  MARK: - Private
    
    private func setupUI() {
        backgroundColor = .white
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(detailTapped(_:)))
        addGestureRecognizer(tapGesture)
        
        tagCollectionView = TagCollectionView(viewModel: tagCollectionViewModel, flowLayout: .leftAligned)
        
        detailStackView.addArrangedSubview(titleLabel)
        detailStackView.addArrangedSubview(priceLabel)
        
        imageView.addSubviewForAutoLayout(ribbonView)
        addSubviewsForAutoLayout([imageView, detailStackView])
        
        if let tagCollectionView = tagCollectionView {
            addSubviewForAutoLayout(tagCollectionView)
        }
        
        ribbonView.layout(with: imageView).fill()
        imageView.layout(with: self)
            .top(by: Metrics.margin)
            .leading(by: Metrics.margin)
        imageView.layout()
            .width(LGMapDetailViewMetrics.imageWidth)
            .height(LGMapDetailViewMetrics.imageHeight)
        
        detailStackView.layout(with: self)
            .top(by: Metrics.margin)
            .trailing(by: -Metrics.margin)
        detailStackView.layout(with: imageView).toLeft(by: Metrics.margin)
        
        tagCollectionView?.layout(with: detailStackView)
            .below(by: Metrics.shortMargin)
        tagCollectionView?.layout(with: self)
            .trailing(by: -Metrics.margin)
        tagCollectionView?.layout(with: imageView)
            .lastBaseline()
            .toLeft(by: Metrics.margin)
    }
    
    private func setupRx() {
        listingVariable
            .asDriver()
            .drive(onNext: {[weak self] listing in
                guard let listing = listing else { return }
                self?.configure(with: listing)
            }).disposed(by: disposeBag)
        tagsVariable
            .asDriver()
            .drive(onNext: { [weak self] tags in
                self?.tagCollectionViewModel.tags = tags
                self?.tagCollectionView?.reloadData()
            }).disposed(by: disposeBag)
    }
    
    private func configure(with listing: Listing) {
        imageView.image = nil
        imageView.backgroundColor = UIColor.placeholderBackgroundColor(listing.objectId)
        titleLabel.text = listing.name
        priceLabel.text = listing.priceString(freeModeAllowed: false)
        ribbonView.isHidden = !(listing.featured ?? false)
        guard let imageUrl = listing.thumbnail?.fileURL else { return }
        _ = imageDownloader?.downloadImageWithURL(imageUrl) { [weak self] (result, url) in
            guard url == imageUrl else { return }
            self?.imageView.image = result.value?.image
        }
    }
    
    //  MARK: - Public
    
    public func update(with listing: Listing, tags: [String]) {
        listingVariable.value = listing
        tagsVariable.value = tags
    }
    
    @objc private func detailTapped(_ tapGesture: UITapGestureRecognizer) {
        guard let listing = listingVariable.value else { return }
        delegate?.mapDetailTapped(listing, originImageView: imageView)
    }
    
    override var intrinsicContentSize: CGSize {
        return CGSize(width: UIViewNoIntrinsicMetric, height: LGMapDetailViewMetrics.height)
    }
    
}
