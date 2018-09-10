import UIKit
import LGComponents

// MARK: - State

struct P2PPaymentsOfferStatusStepListState {
    typealias Step = P2PPaymentsOfferStatusStepViewState

    enum CurrentStep {
        case pending(Int)
        case completed(Int)
        case failed(Int)
    }

    let steps: [Step]
    let currentStep: CurrentStep

    static let empty = P2PPaymentsOfferStatusStepListState(steps: [], currentStep: .pending(0))
}

// MARK: - View

final class P2PPaymentsOfferStatusStepListView: UIView {
    var state: P2PPaymentsOfferStatusStepListState = .empty

    private let stepsStackView: UIStackView = {
        let stackView = UIStackView.vertical()
        stackView.spacing = 20
        return stackView
    }()

    private let scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.showsVerticalScrollIndicator = false
        scrollView.alwaysBounceVertical = true
        return scrollView
    }()

    init() {
        super.init(frame: .zero)
        setup()
    }

    @available(*, unavailable)
    required init?(coder aDecoder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    private func setup() {
        addSubviewForAutoLayout(scrollView)
        scrollView.addSubviewForAutoLayout(stepsStackView)
        setupConstraints()
    }

    private func setupConstraints() {
        scrollView.constraintToEdges(in: self)
        NSLayoutConstraint.activate([
            stepsStackView.widthAnchor.constraint(equalTo: widthAnchor),
            stepsStackView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            stepsStackView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            stepsStackView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            stepsStackView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
        ])
    }
}
