import LGComponents
import LGCoreKit
import UIKit

final class AffiliationChallengeView: UIView {
    enum Style {
        case progress
        case steps(count: Int)
    }

    private enum Layout {
        static let padding: CGFloat = 24
        static let contentPadding: CGFloat = 16
        static let verticalSpacing: CGFloat = 8
        static let lineTopSpacing: CGFloat = 4
        static let lineBottomSpacing: CGFloat = 8
        static let lineHeight: CGFloat = 1
        static let buttonHeight: CGFloat = 50
        static let containerCornerRadius: CGFloat = 16
    }

    private let container: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.white
        return view
    }()

    private let pointsView = AffiliationPointsView()

    private let faqButton: UIButton = {
        let button = UIButton(type: .custom)
        button.setImage(R.Asset.Affiliation.question24.image,
                        for: .normal)
        return button
    }()

    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemMediumFont(size: 14)
        label.textColor = .grayDark
        label.numberOfLines = 1
        return label
    }()

    private let subtitleLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemBoldFont(size: 28)
        label.textColor = .lgBlack
        label.numberOfLines = 2
        return label
    }()

    private let descriptionLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(size: 16)
        label.textColor = .grayDark
        label.numberOfLines = 0
        return label
    }()

    private let progressView = AffiliationProgressView()
    private var stepViews: [AffiliationChallengeStepView] = []
    private let separatorView: UIView = {
        let view = UIView()
        view.backgroundColor = .white
        return view
    }()
    private let separatorLine: UIView = {
        let view = UIView()
        view.backgroundColor = .veryLightGray
        return view
    }()

    private let button: LetgoButton = {
        let button = LetgoButton()
        button.setStyle(.primary(fontSize: .big))
        return button
    }()

    private let stackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.spacing = Layout.verticalSpacing
        return stackView
    }()

    private let style: Style
    var faqButtonPressedCallback: (() -> ())?
    var buttonPressedCallback: (() -> ())?


    // MARK: - Lifecycle

    init(style: Style) {
        self.style = style
        super.init(frame: CGRect.zero)
        setupUI()
    }

    @available(*, unavailable)
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        applyShadow(withOpacity: 0.15,
                    radius: Layout.padding/4)
        layer.shadowPath = UIBezierPath(roundedRect: bounds,
                                        cornerRadius: Layout.containerCornerRadius).cgPath
    }
    
    private func setupUI() {
        setupContainer()
        setupPoints()
        setupFAQButton()
        setupStackView()
    }

    private func setupContainer() {
        addSubviewForAutoLayout(container)
        let constraints = [container.leadingAnchor.constraint(equalTo: leadingAnchor,
                                                              constant: Layout.padding),
                           container.trailingAnchor.constraint(equalTo: trailingAnchor,
                                                               constant: -Layout.padding),
                           container.topAnchor.constraint(equalTo: topAnchor,
                                                          constant: Layout.padding/2),
                           container.bottomAnchor.constraint(equalTo: bottomAnchor,
                                                             constant: -Layout.padding/2)]
        constraints.activate()

        container.clipsToBounds = true
        container.backgroundColor = .white
        container.layer.borderColor = UIColor.grayLight.cgColor
        container.layer.borderWidth = 1
        container.layer.cornerRadius = 16
        container.applyDefaultShadow()
    }

    private func setupPoints() {
        container.addSubviewForAutoLayout(pointsView)

        let constraints = [pointsView.leadingAnchor.constraint(equalTo: container.leadingAnchor,
                                                               constant: Layout.contentPadding),
                           pointsView.topAnchor.constraint(equalTo: container.topAnchor,
                                                           constant: Layout.contentPadding)]
        constraints.activate()
    }

    private func setupFAQButton() {
        container.addSubviewForAutoLayout(faqButton)
        let constraints = [faqButton.topAnchor.constraint(equalTo: container.topAnchor,
                                                          constant: Layout.contentPadding),
                           faqButton.trailingAnchor.constraint(equalTo: container.trailingAnchor,
                                                               constant: -Layout.contentPadding)]
        constraints.activate()

        faqButton.addTarget(self,
                            action: #selector(faqButtonPressed),
                            for: .touchUpInside)
    }

    @objc private func faqButtonPressed() {
        faqButtonPressedCallback?()
    }

    private func setupStackView() {
        container.addSubviewForAutoLayout(stackView)
        stackView.addArrangedSubview(titleLabel)
        stackView.addArrangedSubview(subtitleLabel)
        stackView.addArrangedSubview(descriptionLabel)

        switch style {
        case .progress:
            stackView.addArrangedSubview(progressView)
        case let .steps(count):
            for _ in 0..<count {
                let stepView = AffiliationChallengeStepView()
                stackView.addArrangedSubview(stepView)
                stepViews.append(stepView)
            }
        }

        separatorView.addSubviewForAutoLayout(separatorLine)
        let lineConstraints = [separatorLine.leadingAnchor.constraint(equalTo: separatorView.leadingAnchor),
                               separatorLine.trailingAnchor.constraint(equalTo: separatorView.trailingAnchor),
                               separatorLine.topAnchor.constraint(equalTo: separatorView.topAnchor,
                                                                  constant: Layout.lineTopSpacing),
                               separatorLine.bottomAnchor.constraint(equalTo: separatorView.bottomAnchor,
                                                                     constant: -Layout.lineBottomSpacing),
                               separatorLine.heightAnchor.constraint(equalToConstant: Layout.lineHeight)]
        lineConstraints.activate()

        stackView.addArrangedSubview(separatorView)
        let separatorConstraints = [separatorView.leadingAnchor.constraint(equalTo: stackView.leadingAnchor),
                                    separatorView.trailingAnchor.constraint(equalTo: stackView.trailingAnchor)]
        separatorConstraints.activate()
        stackView.addArrangedSubview(button)

        let constraints = [stackView.leadingAnchor.constraint(equalTo: container.leadingAnchor,
                                                              constant: Layout.contentPadding),
                           stackView.trailingAnchor.constraint(equalTo: container.trailingAnchor,
                                                               constant: -Layout.contentPadding),
                           stackView.topAnchor.constraint(equalTo: pointsView.bottomAnchor,
                                                          constant: Layout.contentPadding),
                           stackView.bottomAnchor.constraint(equalTo: container.bottomAnchor,
                                                             constant: -Layout.contentPadding),
                           button.heightAnchor.constraint(equalToConstant: Layout.buttonHeight)]
        constraints.activate()

        _ = addTopBorderWithWidth(LGUIKitConstants.onePixelSize, color: UIColor.gray)
        button.addTarget(self,
                         action: #selector(buttonPressed),
                         for: .touchUpInside)
    }

    @objc private func buttonPressed() {
        buttonPressedCallback?()
    }

    func setup(inviteFriendsData: ChallengeInviteFriendsData) {
        let points = inviteFriendsData.calculateTotalPointsReward()
        pointsView.set(points: points)
        progressView.setup(data: inviteFriendsData)
        setup(status: inviteFriendsData.status)
    }

    func setup(joinLetgoData: ChallengeJoinLetgoData) {
        pointsView.set(points: joinLetgoData.pointsReward)

        let isPhoneConfirmed = joinLetgoData.stepsCompleted.contains(.phoneVerification)
        let isListingPosted = joinLetgoData.stepsCompleted.contains(.listingPosted)

        for (index, stepView) in stepViews.enumerated() {
            let stepNumber = index + 1
            stepView.set(stepNumber: stepNumber)

            switch index {
            case ChallengeJoinLetgoData.Step.phoneVerification.index:
                stepView.set(title: R.Strings.affiliationChallengesJoinLetgoStepPhoneLabel)
                let status: AffiliationChallengeStepView.Status = isPhoneConfirmed ? .completed : .todo(isHighlighted: true)
                stepView.set(status: status)
                button.setTitle(R.Strings.affiliationChallengesJoinLetgoStepPhoneButton,
                                for: .normal)
            case ChallengeJoinLetgoData.Step.listingPosted.index:
                stepView.set(title: R.Strings.affiliationChallengesJoinLetgoStepPostLabel)
                let status: AffiliationChallengeStepView.Status
                if isListingPosted {
                    status = .completed
                } else {
                    status = joinLetgoData.status == .completed ? .completed : .todo(isHighlighted: isPhoneConfirmed)
                }
                stepView.set(status: status)
                button.setTitle(R.Strings.affiliationChallengesJoinLetgoStepPostButton,
                                for: .normal)
            default:
                break
            }
        }
        setup(status: joinLetgoData.status)
    }

    private func setup(status: ChallengeStatus) {
        switch status {
        case .ongoing:
            addToStackView(view: separatorView)
            addToStackView(view: button)
        case .completed, .pending:
            removeFromStackView(view: separatorView)
            removeFromStackView(view: button)
        case .processing:
            break // TODO
        }
    }

    private func addToStackView(view: UIView) {
        guard view.superview == nil else { return }
        stackView.addArrangedSubview(view)
        view.isHidden = false
    }

    private func removeFromStackView(view: UIView) {
        guard view.superview != nil else { return }
        stackView.removeArrangedSubview(view)
        view.isHidden = true
    }


    // MARK: - Setup

    func set(title: String) {
        titleLabel.text = title
    }

    func set(subtitle: String) {
        subtitleLabel.text = subtitle
    }

    func set(description: String) {
        descriptionLabel.text = description
    }

    func set(buttonTitle: String) {
        button.setTitle(buttonTitle,
                        for: .normal)
    }
}

private extension ChallengeJoinLetgoData.Step {
    var index: Int {
        switch self {
        case .phoneVerification:
            return 0
        case .listingPosted, .listingApproved:
            return 1
        }
    }
}
