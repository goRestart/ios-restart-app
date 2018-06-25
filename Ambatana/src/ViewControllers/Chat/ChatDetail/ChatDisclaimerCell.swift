import UIKit
import RxSwift
import LGComponents

class ChatDisclaimerCell: UITableViewCell, ReusableCell {
    
    let backgroundCellView: UIView = {
        let bgView = UIView()
        bgView.cornerRadius = LGUIKitConstants.mediumCornerRadius
        bgView.backgroundColor = .disclaimerColor
        return bgView
    }()

    let messageLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        label.font = .bigBodyFont
        label.textColor = .darkGrayText
        label.textAlignment = .center
        return label
    }()

    private struct Layout {
        static let textVerticalMargin: CGFloat = 15
        static let textHorizontalMargin: CGFloat = 20
    }

    private var tapAction: (() -> Void)?
    private let disposeBag = DisposeBag()


    // MARK: - Lifecycle

    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUI()
        setupConstraints()
        setAccessibilityIds()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupUI() {
        backgroundColor = .clear
        selectionStyle = .none
        layer.shouldRasterize = true
        layer.rasterizationScale = UIScreen.main.scale
        contentView.addSubviewsForAutoLayout([backgroundCellView, messageLabel])

        let tap = UITapGestureRecognizer(target: self, action: #selector(tapped))
        addGestureRecognizer(tap)
    }

    private func setupConstraints() {
        let constraints = [
            backgroundCellView.leadingAnchor.constraint(equalTo: contentView.layoutMarginsGuide.leadingAnchor),
            backgroundCellView.trailingAnchor.constraint(equalTo: contentView.layoutMarginsGuide.trailingAnchor),
            backgroundCellView.topAnchor.constraint(equalTo: contentView.layoutMarginsGuide.topAnchor),
            backgroundCellView.bottomAnchor.constraint(equalTo: contentView.layoutMarginsGuide.bottomAnchor),
            messageLabel.leadingAnchor.constraint(equalTo: backgroundCellView.leadingAnchor, constant: Layout.textHorizontalMargin),
            messageLabel.trailingAnchor.constraint(equalTo: backgroundCellView.trailingAnchor, constant: -Layout.textHorizontalMargin),
            messageLabel.topAnchor.constraint(equalTo: backgroundCellView.topAnchor, constant: Layout.textVerticalMargin),
            messageLabel.bottomAnchor.constraint(equalTo: backgroundCellView.bottomAnchor, constant: -Layout.textVerticalMargin)
        ]

        NSLayoutConstraint.activate(constraints)
    }

}

// MARK: - Public methods

extension ChatDisclaimerCell {

    func setMessage(_ message: NSAttributedString) {
        messageLabel.attributedText = message
    }

    func setTap(action: (() -> Void)?) {
        tapAction = action
    }
}


// MARK: - Private methods

extension ChatDisclaimerCell {

    @objc private func tapped() {
        tapAction?()
    }
}

extension ChatDisclaimerCell {
    func setAccessibilityIds() {
        set(accessibilityId: .chatDisclaimerCellContainer)
        messageLabel.set(accessibilityId: .chatDisclaimerCellMessageLabel)
    }
}
