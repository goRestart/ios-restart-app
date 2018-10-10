import LGComponents
import RxCocoa
import RxSwift

final class LGSingleSelectionList: UIView {
    
    private let disposeBag = DisposeBag()
    
    private let rootStackView: UIStackView = {
        let stackView = UIStackView.vertical([])
        stackView.alignment = .leading
        stackView.distribution = .fillEqually
        return stackView
    }()
    private var featuresSubViews: [SelectableItem]
    
    fileprivate var selectedFeedback = BehaviorRelay<Feedback?>(value: nil)
    
    // MARK: - Lifecycle
    
    init(feedbacks: [Feedback] = []) {
        self.featuresSubViews = feedbacks.map { SelectableItem(feedback: $0) }
        super.init(frame: .zero)
        setupUI()
        addTargets()
    }
    
    @available (*, unavailable)
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
    
    // MARK: - Private
    
    private func setupUI() {
        addSubviewsForAutoLayout([rootStackView])
        rootStackView.addArrangedSubviews(featuresSubViews)
        addConstraints()
    }
    
    private func addConstraints() {
        let constraints = [rootStackView.leadingAnchor.constraint(equalTo: leadingAnchor),
                           rootStackView.trailingAnchor.constraint(equalTo: trailingAnchor),
                           rootStackView.topAnchor.constraint(equalTo: topAnchor, constant: Metrics.margin),
                           rootStackView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -Metrics.margin)
        ]
        constraints.activate()
    }

    private func addTargets() {
        featuresSubViews.enumerated().forEach { index, button in
            button.tag = index
            button.addTarget(self, action: #selector(tapped(_:)), for: .touchUpInside)
        }
    }
    
    @objc private func tapped(_ sender: UIControl) {
        featuresSubViews.forEach { $0.isSelected = ($0.tag == sender.tag) }
        guard let feedback = featuresSubViews.first(where: { $0.isSelected })?.feedback else { return }
        selectedFeedback.accept(feedback)
    }
    
    enum Layout {
        static let verticalSpacing = CGFloat(6)
    }
    
}

extension Reactive where Base == LGSingleSelectionList {
    var selectedFeedback: Observable<Feedback?> { return base.selectedFeedback.asObservable() }
    var selected: Observable<Bool> { return base.selectedFeedback.asObservable().map { return $0 != nil } }
}

//  MARK: - ListItem

private final class SelectableItem: UIControl {
    
    let feedback: Feedback
    private let disposeBag = DisposeBag()
    
    override var isSelected: Bool {
        didSet {
            guard isSelected != oldValue else { return }
            setNeedsLayout()
        }
    }
    
    // MARK: - Lifecycle
    
    init(feedback: Feedback) {
        self.feedback = feedback
        super.init(frame: .zero)
        setupUI()
        populate(feedback.title)
    }
    
    @available (*, unavailable)
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
    
    override var intrinsicContentSize: CGSize {
        return CGSize(width: selectionIcon.width + titleLabel.width + Layout.horizontalSpacing,
                      height: Layout.itemHeight)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        updateSelectionIcon()
    }
    
    // MARK: - Subviews
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: Layout.titleFontSize,
                                 weight: UIFont.Weight.bold)
        label.textColor = .lgBlack
        label.minimumScaleFactor = 0.8
        return label
    }()
    
    private let selectionIcon: UIView = {
        let view = UIView()
        view.contentMode = .center
        view.cornerRadius = Layout.selectionIconSize/2
        view.isUserInteractionEnabled = false
        return view
    }()
    
    
    //  MARK: - Private
    
    private func populate(_ title: String) {
        self.titleLabel.text = title
    }
    
    private func setupUI() {
        addSubViews()
        addConstraints()
    }
    
    private func addSubViews() {
        addSubviewsForAutoLayout([selectionIcon, titleLabel])
    }
    
    private func addConstraints() {
        
        let constraints = [selectionIcon.leadingAnchor.constraint(equalTo: leadingAnchor),
                           selectionIcon.topAnchor.constraint(equalTo: topAnchor),
                           selectionIcon.widthAnchor.constraint(equalToConstant: Layout.selectionIconSize),
                           selectionIcon.heightAnchor.constraint(equalToConstant: Layout.selectionIconSize),
                           
                           titleLabel.leadingAnchor.constraint(equalTo: selectionIcon.trailingAnchor,
                                                                 constant: Layout.horizontalSpacing),
                           titleLabel.trailingAnchor.constraint(equalTo: trailingAnchor,
                                                                  constant: -Metrics.veryBigMargin),
                           titleLabel.centerYAnchor.constraint(equalTo: selectionIcon.centerYAnchor)]
        constraints.activate()
        
    }

    private func updateSelectionIcon() {
        
        let fromColor: UIColor = isSelected ? .grayRegular : .primaryColor
        let toColor: UIColor  = isSelected ? .primaryColor : .grayRegular
        let fromWidth: CGFloat = isSelected ? 2 : 8
        let toWidth: CGFloat  = isSelected ? 8 : 2
        
        let colorAnimation = CABasicAnimation(keyPath: #keyPath(CALayer.borderColor))
        colorAnimation.fromValue = fromColor.cgColor
        colorAnimation.toValue = toColor.cgColor
        selectionIcon.layer.borderColor = toColor.cgColor
        
        let widthAnimation = CABasicAnimation(keyPath: #keyPath(CALayer.borderWidth))
        widthAnimation.fromValue = fromWidth
        widthAnimation.toValue = toWidth
        widthAnimation.duration = 0.3
        selectionIcon.layer.borderWidth = toWidth
        
        let bothAnimations = CAAnimationGroup()
        bothAnimations.duration = 0.3
        bothAnimations.animations = [colorAnimation, widthAnimation]
        bothAnimations.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseInEaseOut)
        
        selectionIcon.layer.add(bothAnimations, forKey: "colorAndWidth")

    }
    
    enum Layout {
        static let itemHeight = CGFloat(48)
        static let titleFontSize = CGFloat(20)
        static let selectionIconSize = CGFloat(24)
        static let horizontalSpacing = CGFloat(8)
    }
    
}

