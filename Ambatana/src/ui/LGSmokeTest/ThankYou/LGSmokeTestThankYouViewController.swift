import LGComponents

final class LGSmokeTestThankYouViewController: BaseViewController {
    
    private let viewModel: LGSmokeTestThankYouViewModel
    
    // MARK: - Subviews
    
    private let container: UIView = {
        let view = UIView()
        view.backgroundColor = .white
        view.cornerRadius = 21
        return view
    }()
    
    private let rootStackView: UIStackView = {
        let stackView = UIStackView.vertical([])
        stackView.spacing = Metrics.veryBigMargin
        stackView.alignment = .center
        stackView.distribution = .equalSpacing
        stackView.spacing = Metrics.bigMargin
        return stackView
    }()
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: Layout.titleFontSize,
                                 weight: UIFont.Weight.bold)
        label.textColor = .lgBlack
        label.textAlignment = .center
        label.text = R.Strings.smoketestThankYouTitle
        label.minimumScaleFactor = 0.6
        label.adjustsFontSizeToFitWidth = true
        return label
    }()
    
    private let subtitleLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        label.textAlignment = .center
        label.textColor = .grayDark
        return label
    }()
    
    private let icon: UIImageView = {
        let icon = UIImageView()
        icon.contentMode = .center
        icon.cornerRadius = Layout.iconSize/2
        icon.tintColor = .white
        icon.backgroundColor = .clickToTalk
        return icon
    }()
    
    private let bodyLabel: UILabel = {
        let label = UILabel()
        label.font = .systemMediumFont(size: Layout.bodyFontSize)
        label.textAlignment = .center
        label.text = R.Strings.smoketestThankYouRegisterInterest
        return label
    }()
    
    // MARK: - Lifecycle
    
    init(viewModel: LGSmokeTestThankYouViewModel) {
        self.viewModel = viewModel
        super.init(viewModel: viewModel, nibName: nil)
        modalPresentationStyle = .overFullScreen
        modalTransitionStyle = .crossDissolve
        setupUI()
        setupGestures()
        populate(viewModel)
    }
    
    @available (*, unavailable)
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
    
    //  MARK: - Private
    
    private func setupGestures() {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissThankYou))
        view.addGestureRecognizer(tapGesture)
    }
    
    private func setupUI() {
        view.backgroundColor = UIColor.lgBlack.withAlphaComponent(0.5)
        addSubViews()
        addConstraints()
    }
    
    private func addSubViews() {
        container.addSubviewsForAutoLayout([rootStackView])
        view.addSubviewsForAutoLayout([container])
        rootStackView.addArrangedSubviews([icon, titleLabel, subtitleLabel, bodyLabel])
    }
    
    private func addConstraints() {
        let constraints = [
            container.leadingAnchor.constraint(equalTo: safeLeadingAnchor, constant: Metrics.bigMargin),
            container.trailingAnchor.constraint(equalTo: safeTrailingAnchor, constant: -Metrics.bigMargin),
            container.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            
            rootStackView.leadingAnchor.constraint(equalTo: container.leadingAnchor, constant: Layout.margin),
            rootStackView.trailingAnchor.constraint(equalTo: container.trailingAnchor, constant: -Layout.margin),
            rootStackView.bottomAnchor.constraint(equalTo: container.bottomAnchor, constant: -Layout.margin),
            rootStackView.topAnchor.constraint(equalTo: container.topAnchor, constant: Layout.margin),
        ]
        constraints.activate()
    }
    
    //  MARK: - Actions
    
    @objc private func dismissThankYou() {
        dismiss(animated: true)
    }
    
}

extension LGSmokeTestThankYouViewController {
    func populate(_ viewModel: LGSmokeTestThankYouViewModel) {
        icon.image = viewModel.image
        subtitleLabel.text = viewModel.subtitle
        bodyLabel.textColor = viewModel.color
    }
}

private enum Layout {
    static let cornerRadius: CGFloat = 21
    static let margin: CGFloat = 28
    static let iconSize: CGFloat = 83
    static let titleFontSize: CGFloat = 24
    static let subtitleFontSize = 16
    static let bodyFontSize = 15
}
