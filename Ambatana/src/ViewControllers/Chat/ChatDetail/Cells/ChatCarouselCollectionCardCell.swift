import UIKit
import LGComponents
import LGCoreKit

struct ChatCarouselCollectionCardCellActionData {
    let deeplinkURL: URL?
    let key: String?
}

final class ChatCarouselCollectionCardCell: UICollectionViewCell, ReusableCell {
    
    static let cellSize = CGSize(width: 210, height: 280)
    
    private enum Layout {
        static let imageHeight: CGFloat = 150
        static let buttomHeight: CGFloat = 32
    }
    
    private var card: ChatCarouselCard?
    var buttonAction: ((ChatCarouselCollectionCardCellActionData) -> Void)?
    var cardAction: ((ChatCarouselCollectionCardCellActionData) -> Void)?
    
    private let ribbonView: LGRibbonView = {
        let view = LGRibbonView()
        view.isHidden = true
        view.setupRibbon(configuration: LGRibbonConfiguration(title: R.Strings.productFreePrice,
                                                              icon: R.Asset.IconsButtons.icHeart.image,
                                                              titleColor: .primaryColor))
        return view
    }()
    private let imageView: UIImageView = {
        let iw = UIImageView()
        iw.contentMode = .scaleAspectFill
        iw.backgroundColor = UIColor.placeholderBackgroundColor()
        iw.clipsToBounds = true
        return iw
    }()
    private let labelsContainer = UIView()
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 2
        label.font = UIFont.boldSystemFont(ofSize: 18)
        return label
    }()
    private let priceLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 1
        label.font = UIFont.mediumBodyFont
        label.textColor = UIColor.darkGrayText
        return label
    }()
    private let textLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 2
        label.font = UIFont.mediumBodyFont
        label.textColor = UIColor.darkGrayText
        return label
    }()
    private let button = LetgoButton(withStyle: .primary(fontSize: .medium))
    
    // MARK: Lifecycle
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
        setupSubviews()
        setupConstraints()
    }
    
    @available(*, unavailable)
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        imageView.image = nil
        ribbonView.isHidden = true
        titleLabel.text = nil
        priceLabel.text = nil
        textLabel.text = nil
        button.setTitle(nil, for: .normal)
        button.removeTarget(self, action: #selector(buttonPressed), for: .touchUpInside)
        contentView.removeAllGestureRecognizers()
    }

    // MARK: UI
    
    private func setupUI() {
        contentView.backgroundColor = UIColor.white
        contentView.cornerRadius = ChatBubbleLayout.cornerRadius
        applyShadow(withOpacity: 0.2, radius: ChatCarouselCollectionCell.topBottomInsetForShadows)
    }
    
    private func setupSubviews() {
        contentView.addSubviewsForAutoLayout([imageView, labelsContainer, button, ribbonView])
        labelsContainer.addSubviewsForAutoLayout([titleLabel, priceLabel, textLabel])
    }
    
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            imageView.leftAnchor.constraint(equalTo: contentView.leftAnchor),
            imageView.rightAnchor.constraint(equalTo: contentView.rightAnchor),
            imageView.topAnchor.constraint(equalTo: contentView.topAnchor),
            imageView.heightAnchor.constraint(equalToConstant: Layout.imageHeight),
            imageView.bottomAnchor.constraint(equalTo: labelsContainer.topAnchor, constant: -Metrics.shortMargin),
            ribbonView.topAnchor.constraint(equalTo: imageView.topAnchor),
            ribbonView.rightAnchor.constraint(equalTo: imageView.rightAnchor),
            ribbonView.heightAnchor.constraint(equalToConstant: Layout.imageHeight/2),
            ribbonView.heightAnchor.constraint(equalTo: ribbonView.widthAnchor),
            labelsContainer.bottomAnchor.constraint(lessThanOrEqualTo: button.topAnchor, constant: -Metrics.shortMargin),
            labelsContainer.leftAnchor.constraint(equalTo: contentView.leftAnchor, constant: Metrics.shortMargin),
            labelsContainer.rightAnchor.constraint(equalTo: contentView.rightAnchor, constant: -Metrics.shortMargin),
            button.leftAnchor.constraint(equalTo: contentView.leftAnchor, constant: Metrics.shortMargin),
            button.rightAnchor.constraint(equalTo: contentView.rightAnchor, constant: -Metrics.shortMargin),
            button.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -Metrics.shortMargin),
            button.heightAnchor.constraint(equalToConstant: Layout.buttomHeight)
            ])
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: labelsContainer.topAnchor),
            titleLabel.rightAnchor.constraint(equalTo: labelsContainer.rightAnchor),
            titleLabel.leftAnchor.constraint(equalTo: labelsContainer.leftAnchor),
            titleLabel.bottomAnchor.constraint(equalTo: priceLabel.topAnchor, constant: -Metrics.veryShortMargin),
            priceLabel.rightAnchor.constraint(equalTo: labelsContainer.rightAnchor),
            priceLabel.leftAnchor.constraint(equalTo: labelsContainer.leftAnchor),
            priceLabel.bottomAnchor.constraint(equalTo: textLabel.topAnchor, constant: -Metrics.veryShortMargin),
            textLabel.rightAnchor.constraint(equalTo: labelsContainer.rightAnchor),
            textLabel.leftAnchor.constraint(equalTo: labelsContainer.leftAnchor),
            textLabel.bottomAnchor.constraint(equalTo: labelsContainer.bottomAnchor)
            ])
    }
    
    // MARK: Setup
    
    func set(card: ChatCarouselCard) {
        self.card = card
        if let imageURL = card.imageURL {
            imageView.af_setImage(withURL: imageURL)
        }
        ribbonView.isHidden = card.product?.price.isFree ?? true
        titleLabel.text = card.title
        if let price = card.product?.price, !price.isFree,
            let currency = card.product?.currency {
            priceLabel.text = price.stringValue(currency: currency, isFreeEnabled: true)
        }
        textLabel.text = card.text
        if let buttonTitle = card.actions.first?.content.text {
            button.setTitle(buttonTitle, for: .normal)
            button.addTarget(self, action: #selector(buttonPressed), for: .touchUpInside)
        }
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(cardPresed))
        contentView.addGestureRecognizer(tapGesture)
    }
    
    // MARK: Actions
    
    @objc private func buttonPressed() {
        buttonAction?(ChatCarouselCollectionCardCellActionData(deeplinkURL: card?.actions.first?.content.deeplinkURL,
                                                               key: card?.actions.first?.key))
    }
    
    @objc private func cardPresed() {
        cardAction?(ChatCarouselCollectionCardCellActionData(deeplinkURL: card?.deeplinkURL,
                                                             key: card?.trackingKey))
    }
}
