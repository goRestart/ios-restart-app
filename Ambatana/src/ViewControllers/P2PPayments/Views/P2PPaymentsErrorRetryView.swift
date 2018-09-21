import UIKit
import LGComponents
import RxSwift
import RxCocoa

final class P2PPaymentsErrorRetryView: UIView {
    private enum Layout {
        static let contentHorizontalMargin: CGFloat = 24
        static let buttonTopMargin: CGFloat = 12
    }

    private let errorLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(size: 16)
        label.textColor = UIColor.grayDark
        label.numberOfLines = 0
        label.setContentHuggingPriority(.defaultHigh, for: .vertical)
        label.text = R.Strings.paymentsLoadingGenericError
        return label
    }()

    fileprivate let retryButton: LetgoButton = {
        let button = LetgoButton(withStyle: .secondary(fontSize: ButtonFontSize.medium, withBorder: true))
        button.setTitle(R.Strings.paymentsErrorRetry, for: .normal)
        return button
    }()

    init() {
        super.init(frame: .zero)
        setup()
    }

    @available(*, unavailable)
    required init?(coder aDecoder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    private func setup() {
        addSubviewsForAutoLayout([errorLabel, retryButton])
        setupConstraints()
    }

    private func setupConstraints() {
        NSLayoutConstraint.activate([
            errorLabel.centerYAnchor.constraint(equalTo: centerYAnchor),
            errorLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: Layout.contentHorizontalMargin),
            errorLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: -Layout.contentHorizontalMargin),

            retryButton.centerXAnchor.constraint(equalTo: errorLabel.centerXAnchor),
            retryButton.topAnchor.constraint(equalTo: errorLabel.bottomAnchor, constant: Layout.buttonTopMargin),
        ])
    }
}

extension Reactive where Base: P2PPaymentsErrorRetryView {
    var retryTap: ControlEvent<Void> {
        return base.retryButton.rx.tap
    }
}
