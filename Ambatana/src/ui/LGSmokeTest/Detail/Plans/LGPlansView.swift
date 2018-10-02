import LGComponents
import RxCocoa
import RxSwift

final class LGPlansView: UIView {
    
    fileprivate let plansSubviews: [PlanView]
    fileprivate var selectedPlan = Variable<SmokeTestSubscriptionPlan?>(nil)
    
    // MARK: - Subviews
    
    private let rootStackView: UIStackView = {
        let stackView = UIStackView.vertical([])
        stackView.spacing = Metrics.bigMargin
        return stackView
    }()
    
    // MARK: - Lifecycle
    
    init(plans: [SmokeTestSubscriptionPlan]?) {
        self.plansSubviews = plans?.map { PlanView(plan: $0) } ?? []
        super.init(frame: .zero)
        setupUI()
        addTargets()
    }
    
    @available (*, unavailable)
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
    
    // MARK: - Private
    
    private func setupUI() {
        addSubviewsForAutoLayout([rootStackView])
        rootStackView.addArrangedSubviews(plansSubviews)
        addConstraints()
    }
    
    private func addConstraints() {
        let constraints = [rootStackView.leadingAnchor.constraint(equalTo: leadingAnchor),
                           rootStackView.trailingAnchor.constraint(equalTo: trailingAnchor),
                           rootStackView.bottomAnchor.constraint(equalTo: bottomAnchor),
                           rootStackView.topAnchor.constraint(equalTo: topAnchor)]
        constraints.activate()
    }
    
    private func addTargets() {
        plansSubviews.enumerated().forEach { index, button in
            button.tag = index
            let tapGesture = UITapGestureRecognizer(target: self, action: #selector(tapped(_:)))
            button.addGestureRecognizer(tapGesture)
        }
    }
    
    @objc private func tapped(_ gesture: UITapGestureRecognizer) {
        let plan = plansSubviews.first { $0.tag == gesture.view?.tag }?.plan
        selectedPlan.value = plan
    }
    
}

extension Reactive where Base == LGPlansView {
    var selectedPlan: Observable<SmokeTestSubscriptionPlan?> { return base.selectedPlan.asObservable() }
}

private final class PlanView: UIView {
    
    let plan: SmokeTestSubscriptionPlan
    
    private lazy var recommendedHeight: NSLayoutConstraint = {
        return recommendedLabel.heightAnchor.constraint(equalToConstant: Layout.recommendedHeight)
    }()
    
    private lazy var titleTopConstraint: NSLayoutConstraint = {
        return titleLabel.topAnchor.constraint(equalTo: topAnchor, constant: Metrics.shortMargin)
    }()
    
    // MARK: - Lifecycle
    
    init(plan: SmokeTestSubscriptionPlan) {
        self.plan = plan
        super.init(frame: .zero)
        setupUI()
        populate(plan)
    }
    
    @available (*, unavailable)
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
    
    // MARK: - Subviews
    
    private let mainBubble: UIView = {
        let stackView = UIView()
        stackView.cornerRadius = Layout.cornerRadius
        stackView.backgroundColor = .primaryColor
        return stackView
    }()
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: Layout.titleFontSize,
                                 weight: UIFont.Weight.bold)
        label.textAlignment = .center
        label.textColor = .white
        return label
    }()
    
    private let subtitleLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: Layout.subtitleFontSize,
                                 weight: UIFont.Weight.bold)
        label.textAlignment = .center
        label.textColor = .white
        return label
    }()
    
    private let recommendedLabel: UILabel = {
        let label = UIRoundedLabelWithPadding()
        label.font = UIFont.systemFont(ofSize: Layout.recommendedFontSize,
                                       weight: UIFont.Weight.bold)
        label.backgroundColor = .terciaryColor
        label.cornerRadius = Layout.recommendedCornerRadius
        label.text = R.Strings.smoketestRecommended
        label.textColor = .white
        label.padding = UIEdgeInsets(top: 5, left: 12, bottom: 5, right: 12)
        return label
    }()
    
    
    //  MARK: - Private
    
    private func populate(_ plan: SmokeTestSubscriptionPlan) {
        titleLabel.text = plan.title
        subtitleLabel.text = plan.subtitle
        recommendedHeight.constant = plan.isRecomended ? Layout.recommendedHeight : 0 
        titleTopConstraint.constant = plan.isRecomended ? Metrics.margin : Metrics.shortMargin
    }
    
    private func setupUI() {
        backgroundColor = .white
        addSubViews()
        addConstraints()
    }
    
    private func addSubViews() {
        mainBubble.addSubviewsForAutoLayout([titleLabel, subtitleLabel])
        addSubviewsForAutoLayout([mainBubble, recommendedLabel])
    }
    
    private func addConstraints() {
        
        let constraints = [
            recommendedLabel.centerYAnchor.constraint(equalTo: mainBubble.topAnchor),
            recommendedLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: Metrics.veryShortMargin),
            recommendedHeight,
            
            titleTopConstraint,
            titleLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: Metrics.shortMargin),
            titleLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -Metrics.shortMargin),
            
            subtitleLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: Metrics.shortMargin),
            subtitleLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: Metrics.shortMargin),
            subtitleLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -Metrics.shortMargin),
            subtitleLabel.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -Metrics.shortMargin),
            
            mainBubble.leadingAnchor.constraint(equalTo: leadingAnchor),
            mainBubble.trailingAnchor.constraint(equalTo: trailingAnchor),
            mainBubble.bottomAnchor.constraint(equalTo: bottomAnchor),
            mainBubble.topAnchor.constraint(equalTo: topAnchor)]
        
        constraints.activate()
        
    }
    
    private enum Layout {
        static let cornerRadius: CGFloat = 10
        static let titleFontSize: CGFloat = 18
        static let subtitleFontSize: CGFloat = 12
        static let recommendedHeight: CGFloat = 22
        static let recommendedFontSize: CGFloat = 12
        static let recommendedCornerRadius: CGFloat = 12
        static let recommendedPadding = UIEdgeInsets(top: 5, left: 12, bottom: 5, right: 12)
    }
}

