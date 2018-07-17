import LGComponents

final class SettingsTableViewHeader: UIView {
    
    struct Layout {
        static let totalHeight: CGFloat = 40
        static let horizontalMargin: CGFloat = 12
        static let labelHeight: CGFloat = 15
    }
    
    let label: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemRegularFont(size: 13)
        label.textColor = UIColor.gray
        return label
    }()
    
    let topSeparator: UIView = {
        let separator = UIView()
        separator.backgroundColor = UIColor.grayLight
        return separator
    }()

    
    // MARK: - Lifecycle
    
    init() {
        super.init(frame: .zero)
        setupConstraints()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    // MARK: - UI
    
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
        label.text = title.localizedUppercase
    }
}
