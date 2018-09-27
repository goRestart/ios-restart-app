import LGComponents
import RxSwift
import RxCocoa

final class LGSmokeTestDetailViewController: BaseViewController {
    
    private let disposeBag = DisposeBag()
    private let viewModel: LGSmokeTestDetailViewModel
    
    // MARK: - Subviews
    
    private let closeButton: UIButton = {
        let button = UIButton(type: .custom)
        button.setImage(R.Asset.IconsButtons.icCloseGray.image, for: .normal)
        return button
    }()
    
    private let rootScrollView: UIScrollView = {
        let scrollView = UIScrollView(frame: .zero)
        scrollView.showsVerticalScrollIndicator = false
        return scrollView
    }()
    
    private let rootStackView: UIStackView = {
        let stackView = UIStackView.vertical([])
        stackView.spacing = Metrics.veryBigMargin
        stackView.alignment = .center
        stackView.distribution = .equalSpacing
        stackView.backgroundColor = .white
        return stackView
    }()
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: Layout.titleFontSize,
                                 weight: UIFont.Weight.bold)
        label.numberOfLines = 0
        label.textColor = .lgBlack
        label.textAlignment = .center
        return label
    }()
    
    private let subtitleLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        label.textAlignment = .center
        return label
    }()
    
    private let imageViewContainer: UIView = {
        let view = UIView()
        view.applyShadow(withOpacity: 0.3,
                         radius: 2,
                         color: UIColor.black.cgColor,
                         offset: CGSize(width: 0, height: 2))
        view.layer.cornerRadius = Layout.avatarSize/2
        view.backgroundColor = .white
        return view
    }()
    
    private let avatarImage: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.cornerRadius = Layout.avatarSize/2
        imageView.layer.borderWidth = 6
        imageView.layer.borderColor = UIColor.white.cgColor
        return imageView
    }()
    
    private let icon: UIImageView = {
        let icon = UIImageView()
        icon.image = R.Asset.IconsButtons.icPhone.image
        icon.contentMode = .center
        icon.cornerRadius = Layout.iconSize/2
        icon.tintColor = .white
        icon.backgroundColor = .clickToTalk
        return icon
    }()
    
    private let plansView: LGPlansView
    private let featuresView = LGFeaturesView(frame: .zero)
    
    // MARK: - Lifecycle
    
    init(viewModel: LGSmokeTestDetailViewModel) {
        self.viewModel = viewModel
        self.plansView = LGPlansView(plans: viewModel.plans)
        super.init(viewModel: viewModel,
                   nibName: nil)
        setupUI()
        setupRx()
        populate(viewModel)
    }
    
    @available (*, unavailable)
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
    
    //  MARK: - Private
    
    private func setupCloseButton() {
        closeButton.addTarget(self, action: #selector(closeDetail), for: .touchUpInside)
    }
    
    private func setupUI() {
        view.backgroundColor = .white
        setupCloseButton()
        addSubViews()
        addConstraints()
    }
    
    private func addSubViews() {
        imageViewContainer.addSubviewsForAutoLayout([avatarImage, icon])
        rootScrollView.addSubviewsForAutoLayout([rootStackView])
        view.addSubviewsForAutoLayout([rootScrollView, closeButton])
        rootStackView.addArrangedSubviews([titleLabel, subtitleLabel, imageViewContainer, plansView, featuresView])
    }
    
    private func addConstraints() {
        let constraints = [
            closeButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: Metrics.shortMargin),
            closeButton.topAnchor.constraint(equalTo: safeTopAnchor, constant: Metrics.shortMargin),
            
            rootScrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: Metrics.margin),
            rootScrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -Metrics.margin),
            rootScrollView.topAnchor.constraint(equalTo: closeButton.bottomAnchor, constant: Metrics.margin),
            rootScrollView.bottomAnchor.constraint(equalTo: safeBottomAnchor),
            
            rootStackView.leadingAnchor.constraint(equalTo: rootScrollView.leadingAnchor),
            rootStackView.topAnchor.constraint(equalTo: rootScrollView.topAnchor),
            rootStackView.bottomAnchor.constraint(equalTo: rootScrollView.bottomAnchor, constant: -Metrics.bigMargin),
            rootStackView.widthAnchor.constraint(equalTo: rootScrollView.widthAnchor),
            
            plansView.widthAnchor.constraint(equalTo: rootStackView.widthAnchor),
            
            imageViewContainer.widthAnchor.constraint(equalToConstant: Layout.avatarSize),
            imageViewContainer.heightAnchor.constraint(equalToConstant: Layout.avatarSize),
            imageViewContainer.centerYAnchor.constraint(equalTo: avatarImage.centerYAnchor),
            imageViewContainer.centerXAnchor.constraint(equalTo: avatarImage.centerXAnchor),
            avatarImage.widthAnchor.constraint(equalTo: imageViewContainer.widthAnchor),
            avatarImage.heightAnchor.constraint(equalTo: imageViewContainer.heightAnchor),
            icon.widthAnchor.constraint(equalToConstant: Layout.iconSize),
            icon.heightAnchor.constraint(equalToConstant: Layout.iconSize),
            icon.centerYAnchor.constraint(equalTo: avatarImage.bottomAnchor, constant: -Metrics.margin),
            icon.centerXAnchor.constraint(equalTo: avatarImage.trailingAnchor, constant: -Metrics.margin)
        ]
        constraints.activate()
    }
    
    private func setupRx() {
        plansView.rx.selectedPlan.ignoreNil().subscribeNext { [weak self] plan in
            self?.viewModel.sendFeedBack(feedback: plan.title)
        }.disposed(by: disposeBag)
    }
    
    //  MARK: - Actions
    
    @objc private func closeDetail() {
        viewModel.didTapCloseDetail()
    }
}

extension LGSmokeTestDetailViewController {
    func populate(_ viewModel: LGSmokeTestDetailViewModel) {
        titleLabel.text = viewModel.title
        subtitleLabel.attributedText = subtitleAttributedText
        featuresView.features = viewModel.features
        avatarImage.image = viewModel.avatarPlaceholder
        if let avatarUrl = viewModel.avatarUrl {
            avatarImage.lg_setImageWithURL(avatarUrl, placeholderImage: viewModel.avatarPlaceholder)
        }
    }
    
    private var subtitleAttributedText: NSAttributedString {
        let highlightedText = R.Strings.smoketestDetailNoCharge
        return viewModel.subtitle.bifontAttributedText(highlightedText: highlightedText,
                                                       mainFont: .systemMediumFont(size: Layout.subtitleFontSize),
                                                       mainColour: .grayRegular,
                                                       otherFont: .systemFont(ofSize: CGFloat(Layout.subtitleFontSize),
                                                                              weight: UIFont.Weight.bold),
                                                       otherColour: .lgBlack)
    }
}

private enum Layout {
    static let cornerRadius: CGFloat = 6
    static let iconSize: CGFloat = 30
    static let avatarSize: CGFloat = 84
    static let titleFontSize: CGFloat = 36
    static let subtitleFontSize = 17
    static let termsFontSize = 12
}
