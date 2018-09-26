import LGComponents

final class LGFeaturesView: UIView {
    
    private let rootStackView: UIStackView = {
        let stackView = UIStackView.vertical([])
        stackView.spacing = Layout.verticalSpacing
        stackView.alignment = .leading
        stackView.distribution = .fillEqually
        return stackView
    }()
    
    var features: [String] = [] {
        didSet {
            setNeedsLayout()
        }
    }
    
    // MARK: - Lifecycle
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    @available (*, unavailable)
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        rootStackView.addArrangedSubviews(featuresSubViews)
    }
    
    // MARK: - Private
    
    private func setupUI() {
        addSubviewsForAutoLayout([rootStackView])
        addConstraints()
    }
    
    private func addConstraints() {
        let constraints = [rootStackView.leadingAnchor.constraint(equalTo: leadingAnchor),
                           rootStackView.trailingAnchor.constraint(equalTo: trailingAnchor),
                           rootStackView.topAnchor.constraint(equalTo: topAnchor),
                           rootStackView.bottomAnchor.constraint(equalTo: bottomAnchor)
        ]
        constraints.activate()
    }

    private lazy var featuresSubViews: [UIView] = {
        return features.map { FeatureView(feature: $0) }
    }()
    
    enum Layout {
        static let verticalSpacing: CGFloat = 6
    }
    
}

//  MARK: - FeatureView

private final class FeatureView: UIView {
    
    private let feature: String
    
    // MARK: - Lifecycle
    
    init(feature: String) {
        self.feature = feature
        super.init(frame: .zero)
        setupUI()
        populate(feature)
    }
    
    @available (*, unavailable)
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
    
    override var intrinsicContentSize: CGSize {
        return CGSize(width: icon.width + featureLabel.width + Layout.horizontalSpacing,
                      height: max(icon.height, featureLabel.height))
    }
    
    // MARK: - Subviews
    
    private let featureLabel: UILabel = {
        let label = UILabel()
        label.font = .systemRegularFont(size: Layout.featureFontSize)
        label.textColor = .lgBlack
        label.minimumScaleFactor = 0.8
        return label
    }()
    
    private let icon: UIImageView = {
        let icon = UIImageView(image: R.Asset.IconsButtons.checkboxSelectedRoundGray.image)
        icon.tintColor = .terciaryColor
        icon.contentMode = .center
        return icon
    }()
    
    
    //  MARK: - Private
    
    private func populate(_ feature: String) {
        self.featureLabel.text = feature
    }
    
    private func setupUI() {
        addSubViews()
        addConstraints()
    }
    
    private func addSubViews() {
        addSubviewsForAutoLayout([icon, featureLabel])
    }
    
    private func addConstraints() {

        let constraints = [icon.leadingAnchor.constraint(equalTo: leadingAnchor),
                           icon.topAnchor.constraint(equalTo: topAnchor),
                           
                           featureLabel.leadingAnchor.constraint(equalTo: icon.trailingAnchor,
                                                                 constant: Layout.horizontalSpacing),
                           featureLabel.trailingAnchor.constraint(equalTo: trailingAnchor,
                                                                  constant: -Metrics.veryShortMargin),
                           featureLabel.centerYAnchor.constraint(equalTo: icon.centerYAnchor)]
        constraints.activate()
        
    }
    
    enum Layout {
        static let featureFontSize = 14
        static let horizontalSpacing: CGFloat = 8
    }

}
