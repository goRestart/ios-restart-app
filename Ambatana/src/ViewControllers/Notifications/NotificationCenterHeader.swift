import LGComponents

final class NotificationCenterHeader: UIView {
    
    struct Layout {
        static let totalHeight: CGFloat = 50
        static let horizontalMargin: CGFloat = 12
        static let labelHeight: CGFloat = 40
    }
    
    private let label: UILabel = {
        let label = UILabel()
        label.font = .systemBoldFont(size: 24)
        label.textColor = .lgBlack
        return label
    }()
    
    
    // MARK: - Lifecycle
    
    init() {
        super.init(frame: .zero)
        setupUI()
        setupConstraints()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    // MARK: - UI
    
    private func setupUI() {
        backgroundColor = .white
    }
    
    private func setupConstraints() {
        addSubviewForAutoLayout(label)
        let constraints = [
            label.leadingAnchor.constraint(equalTo: leadingAnchor, constant: Layout.horizontalMargin),
            label.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -Layout.horizontalMargin),
            label.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -Metrics.veryShortMargin),
            label.heightAnchor.constraint(equalToConstant: Layout.labelHeight),
            ]
        NSLayoutConstraint.activate(constraints)
    }
    
    func setup(withTitle title: String) {
        label.text = title
    }
}
