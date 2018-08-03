import LGComponents

final class ErrorView: UIView {
    private struct Layout {
        static let sideMargin: CGFloat = 24
        static let actionHeight: CGFloat = 50
        static let imageViewHeight: CGFloat = 50
        static let imageViewBottom: CGFloat = 16
        static let titleBottom: CGFloat = Metrics.shortMargin
    }
    
    let containerView: UIView = {
        let container = UIView()
        container.backgroundColor = .clear
        container.isUserInteractionEnabled = true
        container.setContentCompressionResistancePriority(.required, for: .vertical)
        container.setContentHuggingPriority(.defaultLow, for: .horizontal)
        return container
    }()
    
    private let imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.clipsToBounds = true
        imageView.setContentHuggingPriority(.required, for: .vertical)
        imageView.setContentHuggingPriority(.defaultLow, for: .horizontal)
        return imageView
    }()
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemRegularFont(size: 17)
        label.textColor = .black
        label.textAlignment = .center
        label.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
        label.setContentHuggingPriority(.defaultLow, for: .horizontal)
        label.numberOfLines = 2
        return label
    }()
    
    private let bodyLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemRegularFont(size: 17)
        label.textColor = .grayDark
        label.textAlignment = .center
        label.numberOfLines = 0
        label.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
        label.setContentHuggingPriority(.defaultLow, for: .horizontal)
        label.setContentHuggingPriority(.required, for: .vertical)
        return label
    }()
    
    let actionButton = LetgoButton(withStyle: .primary(fontSize: .medium))
    
    var actionHeight: NSLayoutConstraint?
    var imageHeight: NSLayoutConstraint?
    
    private var leadingInset: NSLayoutConstraint?
    private var topInset: NSLayoutConstraint?
    private var trailingInset: NSLayoutConstraint?
    private var bottomInset: NSLayoutConstraint?
    
    convenience init() {
        self.init(frame: .zero)
        setupUI()
    }
    
    func updateWithInsets(_ edgeInsets: UIEdgeInsets) {
        leadingInset?.constant = edgeInsets.left
        topInset?.constant = edgeInsets.top
        trailingInset?.constant = -edgeInsets.right
        bottomInset?.constant = -edgeInsets.bottom
        setNeedsLayout()
    }
    
    func setImage(_ image: UIImage?) {
        imageView.image = image
    }
    
    func setBody(_ body: String?) {
        bodyLabel.text = body
    }
    
    func setTitle(_ title: String?) {
        titleLabel.text = title
    }
    
    private func setupUI() {
        backgroundColor = .clear
        setContentHuggingPriority(.defaultLow, for: .horizontal)
        setupConstraints()
        setupAccessibilityIds()
    }
    
    private func setupAccessibilityIds() {
        set(accessibilityId: .listingListViewErrorView)
        imageView.set(accessibilityId:  .listingListErrorImageView)
        titleLabel.set(accessibilityId: .listingListErrorTitleLabel)
        bodyLabel.set(accessibilityId: .listingListErrorBodyLabel)
        actionButton.set(accessibilityId: .listingListErrorButton)
    }
    
    private func setupConstraints() {
        addSubviewsForAutoLayout([containerView])
        containerView.addSubviewsForAutoLayout([imageView, titleLabel, bodyLabel, actionButton])
        let imageViewHeight = imageView.heightAnchor.constraint(equalToConstant: 0)
        let actionHeight = actionButton.heightAnchor.constraint(equalToConstant: Layout.actionHeight)
        
        let topInset = containerView.topAnchor.constraint(equalTo: topAnchor, constant: Layout.sideMargin)
        let leadingInset = containerView.leftAnchor.constraint(equalTo: leftAnchor, constant: Layout.sideMargin)
        let trailingInset = containerView.rightAnchor.constraint(equalTo: rightAnchor, constant: -Layout.sideMargin)
        let bottomInset = containerView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -Layout.sideMargin)
        NSLayoutConstraint.activate([
            trailingInset, topInset, leadingInset, bottomInset,
            imageView.topAnchor.constraint(equalTo: containerView.topAnchor, constant: Layout.imageViewHeight),
            imageView.centerXAnchor.constraint(equalTo: containerView.centerXAnchor),
            imageView.widthAnchor.constraint(equalTo: containerView.widthAnchor, constant: -2*Layout.sideMargin),
            imageViewHeight,
            
            titleLabel.topAnchor.constraint(equalTo: imageView.bottomAnchor, constant: Layout.imageViewBottom),
            titleLabel.widthAnchor.constraint(equalTo: containerView.widthAnchor, constant: -2*Layout.sideMargin),
            titleLabel.centerXAnchor.constraint(equalTo: containerView.centerXAnchor),
            
            bodyLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: Layout.titleBottom),
            bodyLabel.widthAnchor.constraint(equalTo: containerView.widthAnchor, constant: -2*Layout.sideMargin),
            bodyLabel.centerXAnchor.constraint(equalTo: containerView.centerXAnchor),
            
            actionButton.topAnchor.constraint(equalTo: bodyLabel.bottomAnchor, constant: Layout.sideMargin),
            actionButton.widthAnchor.constraint(equalTo: containerView.widthAnchor, constant: -2*Layout.sideMargin),
            actionButton.centerXAnchor.constraint(equalTo: containerView.centerXAnchor),
            actionButton.bottomAnchor.constraint(equalTo: containerView.bottomAnchor, constant: -Layout.sideMargin),
            actionHeight
            ])
        self.imageHeight = imageViewHeight
        self.actionHeight = actionHeight
        self.topInset = topInset
        self.leadingInset = leadingInset
        self.trailingInset = trailingInset
        self.bottomInset = bottomInset
    }
}
