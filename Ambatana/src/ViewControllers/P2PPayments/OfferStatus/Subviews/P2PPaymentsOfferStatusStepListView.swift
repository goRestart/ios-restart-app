import UIKit
import LGComponents
import RxSwift
import RxCocoa

// MARK: - State

struct P2PPaymentsOfferStatusStepListState {
    typealias Step = P2PPaymentsOfferStatusStepViewState

    enum CurrentStep {
        case completed(Int)
        case failed(Int)
    }

    let steps: [Step]
    let currentStep: CurrentStep

    static let empty = P2PPaymentsOfferStatusStepListState(steps: [], currentStep: .completed(0))
}

// MARK: - View

final class P2PPaymentsOfferStatusStepListView: UIView {
    var state: P2PPaymentsOfferStatusStepListState = .empty {
        didSet { configureForCurrentState() }
    }

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
            stepsStackView.widthAnchor.constraint(equalTo: widthAnchor, constant: -48),
            stepsStackView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            stepsStackView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            stepsStackView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor, constant: 24),
            stepsStackView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor, constant: -24),
        ])
    }

    private func configureForCurrentState() {
        let stepViews = state.steps.map { P2PPaymentsOfferStatusStepView(state: $0) }
        stepsStackView.arrangedSubviews.forEach { $0.removeFromSuperview() }
        stepsStackView.addArrangedSubviews(stepViews)
    }
}

extension Reactive where Base: P2PPaymentsOfferStatusStepListView {
    var state: Binder<P2PPaymentsOfferStatusStepListState> {
        return Binder(self.base) { base, state in
            base.state = state
        }
    }
}
