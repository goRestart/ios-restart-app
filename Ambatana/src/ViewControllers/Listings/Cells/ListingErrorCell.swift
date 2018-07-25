import UIKit
import LGComponents

struct ErrorViewCellStyle {
    let backgroundColor: UIColor?
    let borderColor: UIColor?
    let containerColor: UIColor?
}

final class ListingErrorCell: UICollectionViewCell, ReusableCell {
    
    //  MARK: - Subviews
    
    private let containerView = UIView()
    
    private let imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.clipsToBounds = true
        imageView.set(accessibilityId:  .listingListErrorImageView)
        return imageView
    }()
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = .systemRegularFont(size: 17)
        label.textColor = .black
        label.textAlignment = .center
        label.minimumScaleFactor = 0.7
        label.numberOfLines = 2
        label.set(accessibilityId: .listingListErrorTitleLabel)
        return label
    }()
    
    private let bodyLabel: UILabel = {
        let label = UILabel()
        label.font = .systemRegularFont(size: 17)
        label.textColor = .grayDark
        label.textAlignment = .center
        label.minimumScaleFactor = 0.7
        label.numberOfLines = 3
        label.setContentCompressionResistancePriority(.defaultHigh, for: .vertical)
        label.set(accessibilityId: .listingListErrorBodyLabel)
        return label
    }()
    
    private lazy var retryButton: LetgoButton = {
       let button = LetgoButton(withStyle: .primary(fontSize: .medium))
        button.set(accessibilityId: .listingListErrorButton)
        button.addTarget(self, action: #selector(retryButtonPressed), for: .touchUpInside)
        return button
    }()
    
    
    //  MARK: - Constraints
    
    private var buttonHeightConstraint: NSLayoutConstraint?
    private var imageHeightConstraint: NSLayoutConstraint?
    
    private var actionButton: (() -> ())?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        set(accessibilityId: .listingListViewErrorView)
        setupUI()
    }
    
    required init?(coder aDecoder: NSCoder) { fatalError("init(coder:) has not been implemented") }
    
    func setup(_ emptyViewModel: LGEmptyViewModel) {
        self.actionButton = emptyViewModel.action
        
        imageView.image = emptyViewModel.icon
        titleLabel.text = emptyViewModel.title
        bodyLabel.text = emptyViewModel.body
        retryButton.setTitle(emptyViewModel.buttonTitle, for: .normal)
        
        imageHeightConstraint?.constant = emptyViewModel.iconHeight
        buttonHeightConstraint?.constant = emptyViewModel.action != nil ? Layout.retryButtonHeight : 0
    }
    
    func setup(withStyle style: ErrorViewCellStyle) {
        contentView.backgroundColor = style.backgroundColor
        containerView.backgroundColor = style.containerColor
        containerView.layer.borderColor = style.borderColor?.cgColor
        containerView.layer.borderWidth = style.borderColor != nil ? 0.5 : 0
        containerView.cornerRadius = 4
    }
    
    //  MARK: - Private
    
    private func setupUI() {
        backgroundColor = .clear
        addSubviews()
        addConstraints()
    }
    
    private func addSubviews() {
        contentView.addSubviewForAutoLayout(containerView)
        containerView.addSubviewsForAutoLayout([imageView, titleLabel, bodyLabel, retryButton])
    }
    
    private func addConstraints() {
        let imageHeightConstraint = imageView.heightAnchor.constraint(equalToConstant: 0)
        let buttonHeightConstraint = retryButton.heightAnchor.constraint(equalToConstant: Layout.actionHeight)
        let buttomBottomConstraint = retryButton.bottomAnchor.constraint(equalTo: containerView.bottomAnchor, constant: -Metrics.veryBigMargin)
        buttomBottomConstraint.priority = .defaultLow
        NSLayoutConstraint.activate([
            containerView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: Metrics.veryBigMargin),
            containerView.leftAnchor.constraint(equalTo: contentView.leftAnchor, constant: Metrics.veryBigMargin),
            containerView.rightAnchor.constraint(equalTo: contentView.rightAnchor, constant: -Metrics.veryBigMargin),
            containerView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -Metrics.veryBigMargin),
            
            imageView.topAnchor.constraint(equalTo: containerView.topAnchor, constant: Metrics.veryBigMargin),
            imageView.centerXAnchor.constraint(equalTo: containerView.centerXAnchor),
            imageView.widthAnchor.constraint(equalTo: containerView.widthAnchor, constant: -2*Metrics.veryBigMargin),
            imageHeightConstraint,
            
            titleLabel.topAnchor.constraint(equalTo: imageView.bottomAnchor, constant: Metrics.margin),
            titleLabel.widthAnchor.constraint(equalTo: containerView.widthAnchor, constant: -2*Metrics.veryBigMargin),
            titleLabel.centerXAnchor.constraint(equalTo: containerView.centerXAnchor),
            
            bodyLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: Metrics.shortMargin),
            bodyLabel.widthAnchor.constraint(equalTo: containerView.widthAnchor, constant: -2*Metrics.veryBigMargin),
            bodyLabel.centerXAnchor.constraint(equalTo: containerView.centerXAnchor),
            
            retryButton.topAnchor.constraint(equalTo: bodyLabel.bottomAnchor, constant: Metrics.bigMargin),
            retryButton.widthAnchor.constraint(equalTo: containerView.widthAnchor, constant: -2*Metrics.veryBigMargin),
            retryButton.centerXAnchor.constraint(equalTo: containerView.centerXAnchor),
            buttomBottomConstraint,
            buttonHeightConstraint
            ])
        self.imageHeightConstraint = imageHeightConstraint
        self.buttonHeightConstraint = buttonHeightConstraint
    }
    
    //  MARK: - Actions
    @objc private func retryButtonPressed() {
        actionButton?()
    }
}


private enum Layout {
    static let actionHeight: CGFloat = 50
    static let imageViewHeight: CGFloat = 50
    static let retryButtonHeight: CGFloat = 50
    static let retryButtonTop: CGFloat = 64
}

