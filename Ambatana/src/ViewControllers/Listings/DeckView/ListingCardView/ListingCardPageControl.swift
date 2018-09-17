import Foundation

final class ListingCardPageControl: UIView {
    private enum Default {
        static let maxPages = 10 // TODO: Totally arbitrary for now
    }
    private enum Colors {
        static let on: UIColor = .white
        static let off = UIColor.white.withAlphaComponent(0.7)
    }
    private enum Layout {
        static let pillHeight: CGFloat = 4
        static let spacing: CGFloat = 4
        static let intrinsicHeight: CGFloat = 12
    }

    private let pills: [UIView] = {
        var pills = (1...Default.maxPages).map { _ in ListingCardPageControl.makePill() }
        return pills
    }()

    private lazy var stackView: UIStackView = {
        let sv = UIStackView.horizontal(pills)
        sv.alignment = .fill
        sv.distribution = .fillEqually
        sv.spacing = Layout.spacing
        return sv
    }()

    override var intrinsicContentSize: CGSize {
        return CGSize(width: UIViewNoIntrinsicMetric, height: Layout.intrinsicHeight) }

    convenience init() {
        self.init(frame: .zero)
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }

    required init?(coder aDecoder: NSCoder) { fatalError("Die xibs, die") }

    private func setupUI() {
        addSubviewForAutoLayout(stackView)
        NSLayoutConstraint.activate([
            stackView.heightAnchor.constraint(equalToConstant: Layout.pillHeight),
            stackView.leadingAnchor.constraint(equalTo: leadingAnchor),
            stackView.trailingAnchor.constraint(equalTo: trailingAnchor),
            stackView.centerYAnchor.constraint(equalTo: centerYAnchor)
        ])
    }
}

extension ListingCardPageControl {
    func turnOnAt(_ index: Int) {
        stackView.arrangedSubviews.enumerated().forEach { (offset, view) in
            view.backgroundColor = index == offset ? Colors.on : Colors.off
        }
    }

    func setPages(_ number: Int) {
        stackView.arrangedSubviews.enumerated().forEach { (offset, view) in
            view.isHidden = offset >= number
        }
    }
}

extension ListingCardPageControl {
    static func makePill() -> UIView {
        let view = UIView()
        view.backgroundColor = Colors.off
        view.cornerRadius = Layout.pillHeight / 2
        return view
    }
}
