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

        var index: Int {
            switch self {
            case .completed(let index): return index
            case .failed(let index): return index
            }
        }
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

    private var numberViews = [P2PPaymentsNumberView]()
    private var lineViews = [P2PPaymentsStepLineView]()

    init() {
        super.init(frame: .zero)
        setup()
    }

    @available(*, unavailable)
    required init?(coder aDecoder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    private func setup() {
        addSubviewForAutoLayout(stepsStackView)
        setupConstraints()
    }

    private func setupConstraints() {
        NSLayoutConstraint.activate([
            stepsStackView.topAnchor.constraint(equalTo: topAnchor),
            stepsStackView.bottomAnchor.constraint(equalTo: bottomAnchor),
            stepsStackView.trailingAnchor.constraint(equalTo: trailingAnchor),
        ])
    }

    private func configureForCurrentState() {
        removeOldViews()
        let stepViews = state.steps.map { P2PPaymentsOfferStatusStepView(state: $0) }
        stepsStackView.addArrangedSubviews(stepViews)
        createNumberViews(stepViews: stepViews)
        createLineViews()
    }

    private func removeOldViews() {
        stepsStackView.arrangedSubviews.forEach { $0.removeFromSuperview() }
        numberViews.forEach { $0.removeFromSuperview() }
        lineViews.forEach { $0.removeFromSuperview() }
        numberViews.removeAll()
        lineViews.removeAll()
    }

    private func createNumberViews(stepViews: [P2PPaymentsOfferStatusStepView]) {
        for i in 0..<state.steps.count {
            let numberState: P2PPaymentsNumberView.State = {
                if i < state.currentStep.index {
                    return .success
                }
                if i > state.currentStep.index {
                    return .number(i + 1)
                }
                switch state.currentStep {
                case .completed: return .success
                case .failed: return .fail
                }
            }()
            let numberView = P2PPaymentsNumberView(state: numberState)
            numberViews.append(numberView)
        }
        addSubviewsForAutoLayout(numberViews)
        if let firstNumberView = numberViews.first {
            firstNumberView.setContentCompressionResistancePriority(.required, for: .horizontal)
            NSLayoutConstraint.activate([
                firstNumberView.leadingAnchor.constraint(equalTo: self.leadingAnchor),
                firstNumberView.trailingAnchor.constraint(equalTo: stepsStackView.leadingAnchor, constant: -24),
            ])
            numberViews.dropFirst().forEach { view in
                NSLayoutConstraint.activate([
                    view.centerXAnchor.constraint(equalTo: firstNumberView.centerXAnchor)
                ])
            }
        }
        zip(numberViews, stepViews).forEach { numberAndStep in
            let (numberView, stepView) = numberAndStep
            NSLayoutConstraint.activate([
                numberView.topAnchor.constraint(equalTo: stepView.topAnchor),
            ])
        }
    }

    private func createLineViews() {
        zip(numberViews.dropLast(), numberViews.dropFirst()).enumerated().forEach { index, firstAndSecond in
            let (firstNumber, secondNumber) = firstAndSecond
            let line = P2PPaymentsStepLineView()
            let currentStepIndex = state.currentStep.index
            switch (index, state.currentStep) {
            case let (i, _) where i < currentStepIndex: line.completePercentage = 1
            case let (i, .completed(currentIndex)) where i == currentIndex: line.completePercentage = 0.75
            default: line.completePercentage = 0
            }
            lineViews.append(line)
            addSubviewForAutoLayout(line)
            NSLayoutConstraint.activate([
                line.centerXAnchor.constraint(equalTo: firstNumber.centerXAnchor),
                line.topAnchor.constraint(equalTo: firstNumber.bottomAnchor, constant: 4),
                line.bottomAnchor.constraint(equalTo: secondNumber.topAnchor, constant: -4),
            ])
        }
    }
}

extension Reactive where Base: P2PPaymentsOfferStatusStepListView {
    var state: Binder<P2PPaymentsOfferStatusStepListState> {
        return Binder(self.base) { base, state in
            base.state = state
        }
    }
}
