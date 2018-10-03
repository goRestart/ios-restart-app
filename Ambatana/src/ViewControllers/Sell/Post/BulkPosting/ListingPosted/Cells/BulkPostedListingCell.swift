import LGCoreKit
import LGComponents
import RxSwift
import RxCocoa

class BulkPostedListingCell: UICollectionViewCell, ReusableCell {

    private let imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.cornerRadius = 10
        imageView.contentMode = .scaleAspectFill
        return imageView
    }()
    private let priceLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.bigBodyFont
        label.textColor = UIColor.lgBlack
        label.textAlignment = .center
        return label
    }()
    fileprivate let editButton: UIButton = {
        let style = ButtonStyle.secondary(fontSize: ButtonFontSize.verySmallBold, withBorder: false)
        let button = LetgoButton(withStyle: style)
        button.setTitle(R.Strings.bulkPostingCongratsEditButton, for: .normal)
        button.titleLabel?.font = UIFont.systemBoldFont(size: 13)
        return button
    }()

    private(set) var disposeBag = DisposeBag()

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func setupUI() {
        addSubviewsForAutoLayout([imageView, priceLabel, editButton])
        NSLayoutConstraint.activate([
            topAnchor.constraint(equalTo: imageView.topAnchor),
            leadingAnchor.constraint(equalTo: imageView.leadingAnchor),
            trailingAnchor.constraint(equalTo: imageView.trailingAnchor),
            imageView.heightAnchor.constraint(equalToConstant: 86),

            priceLabel.topAnchor.constraint(equalTo: imageView.bottomAnchor, constant: Metrics.veryShortMargin),
            priceLabel.leadingAnchor.constraint(equalTo: leadingAnchor),
            priceLabel.trailingAnchor.constraint(equalTo: trailingAnchor),

            editButton.topAnchor.constraint(equalTo: priceLabel.bottomAnchor),
            editButton.leadingAnchor.constraint(equalTo: leadingAnchor),
            editButton.trailingAnchor.constraint(equalTo: trailingAnchor),
            editButton.heightAnchor.constraint(equalToConstant: 32)
        ])
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        disposeBag = DisposeBag()
    }

    func setupWith(price: String, imageURL: URL?) {
        priceLabel.text = price
        if let url = imageURL {
            imageView.lg_setImageWithURL(url)
        }
    }
}

extension Reactive where Base: BulkPostedListingCell {
    var editButtonTapped: ControlEvent<Void> {
        return base.editButton.rx.controlEvent(.touchUpInside)
    }
}
