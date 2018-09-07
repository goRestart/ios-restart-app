import UIKit
import LGComponents

// MARK: - State

struct P2PPaymentsOfferStatusStepViewState {
    let title: String
    let description: String
    let extraDescription: ExtraDescription?
    let buttonState: ButtonState?
}

extension P2PPaymentsOfferStatusStepViewState {
    typealias ButtonTapHandler = () -> Void

    enum Style {
        case positive, negative

        var color: UIColor {
            switch self {
            case .positive: return .p2pPaymentsPositive
            case .negative: return .primaryColor
            }
        }
    }

    struct ExtraDescription {
        let text: String
        let style: Style
    }

    struct ButtonState {
        let title: String
        let tapHandler: ButtonTapHandler?
    }
}

// MARK: - View

final class P2PPaymentsOfferStatusStepView: UIView {
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemBoldFont(size: 20)
        label.textColor = UIColor.lgBlack
        return label
    }()

    private let descriptionLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(size: 16)
        label.textColor = UIColor.grayDark
        label.numberOfLines = 0
        label.setContentHuggingPriority(.defaultHigh, for: .vertical)
        return label
    }()

    private let extraDescriptionLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemBoldFont(size: 16)
        label.textColor = UIColor.primaryColor
        return label
    }()

    private lazy var actionButton: LetgoButton = {
        let button = LetgoButton(withStyle: .secondary(fontSize: ButtonFontSize.medium, withBorder: true))
        button.addTarget(self, action: #selector(actionButtonTapped), for: .touchUpInside)
        return button
    }()

    private lazy var stackView: UIStackView = {
        let stackView = UIStackView.vertical([extraDescriptionLabel, actionButton])
        stackView.spacing = 16
        stackView.distribution = .equalSpacing
        stackView.alignment = .leading
        return stackView
    }()

    private let state: P2PPaymentsOfferStatusStepViewState

    init(state: P2PPaymentsOfferStatusStepViewState) {
        self.state = state
        super.init(frame: .zero)
        setup()
    }

    @available(*, unavailable)
    required init?(coder aDecoder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    private func setup() {
        addSubviewsForAutoLayout([titleLabel, descriptionLabel, extraDescriptionLabel, actionButton])
        setupConstraints()
        configureForCurrentState()
    }

    private func setupConstraints() {
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: topAnchor),
            titleLabel.leadingAnchor.constraint(equalTo: leadingAnchor),
            titleLabel.trailingAnchor.constraint(equalTo: trailingAnchor),

            descriptionLabel.topAnchor.constraint(equalTo: descriptionLabel.bottomAnchor, constant: 4),
            descriptionLabel.leadingAnchor.constraint(equalTo: leadingAnchor),
            descriptionLabel.trailingAnchor.constraint(equalTo: trailingAnchor),

            stackView.topAnchor.constraint(equalTo: stackView.bottomAnchor, constant: 4),
            stackView.bottomAnchor.constraint(equalTo: bottomAnchor),
            stackView.leadingAnchor.constraint(equalTo: leadingAnchor),
            stackView.trailingAnchor.constraint(equalTo: trailingAnchor),
        ])
    }

    private func configureForCurrentState() {
        titleLabel.text = state.title
        descriptionLabel.text = state.description
        if let extraDescription = state.extraDescription {
            extraDescriptionLabel.text = extraDescription.text
            extraDescriptionLabel.textColor = extraDescription.style.color
        }
        if let buttonState = state.buttonState {
            actionButton.setTitle(buttonState.title, for: .normal)
        }
    }

    @objc private func actionButtonTapped() {
        state.buttonState?.tapHandler?()
    }
}
