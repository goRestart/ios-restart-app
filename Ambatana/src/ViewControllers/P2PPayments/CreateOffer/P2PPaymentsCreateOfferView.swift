import UIKit
import LGComponents
import RxSwift
import RxCocoa

// TODO: @juolgon Localize all texts

final class P2PPaymentsCreateOfferView: UIView {
    private enum Layout {
    }

    init() {
        super.init(frame: .zero)
        setup()
    }

    @available(*, unavailable)
    required init?(coder aDecoder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    private func setup() {
        setupConstraints()
    }

    private func setupConstraints() {
    }
}

// MARK: - P2PPaymentsOnboardingView + Rx

extension Reactive where Base: P2PPaymentsCreateOfferView {}
