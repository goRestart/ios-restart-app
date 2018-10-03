import UIKit
import LGComponents
import RxSwift
import RxCocoa

final class P2PPaymentsPayoutRequestView: UIView {
    var bankAccountPayoutParams: P2PPaymentsPayoutViewModel.BankAccountPayoutParams {
        return bankAccountView.bankAccountParams
    }

    var cardPayoutParams: P2PPaymentsPayoutViewModel.CardPayoutParams {
        return debitCardView.cardPayoutParams
    }

    private let typeSelectorView = P2PPaymentsPayoutTypeSelectorView()
    fileprivate let bankAccountView = P2PPaymentsPayoutBankAccountView()
    fileprivate let debitCardView = P2PPaymentsPayoutCardView()
    private let disposeBag = DisposeBag()

    init() {
        super.init(frame: .zero)
        setup()
    }

    @available(*, unavailable)
    required init?(coder aDecoder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    private func setup() {
        debitCardView.isHidden = true
        addSubviewsForAutoLayout([typeSelectorView, bankAccountView, debitCardView])
        setupConstraints()
        typeSelectorView.rx.optionSelected.drive(onNext: { [weak self] optionSelected in
            switch optionSelected {
            case .bankAccount:
                self?.bankAccountView.isHidden = false
                self?.debitCardView.isHidden = true
            case .debitCard:
                self?.bankAccountView.isHidden = true
                self?.debitCardView.isHidden = false
            }
        }).disposed(by: disposeBag)
    }

    private func setupConstraints() {
        NSLayoutConstraint.activate([
            typeSelectorView.topAnchor.constraint(equalTo: safeTopAnchor),
            typeSelectorView.leadingAnchor.constraint(equalTo: leadingAnchor),
            typeSelectorView.trailingAnchor.constraint(equalTo: trailingAnchor),

            bankAccountView.topAnchor.constraint(equalTo: typeSelectorView.bottomAnchor),
            bankAccountView.leadingAnchor.constraint(equalTo: leadingAnchor),
            bankAccountView.trailingAnchor.constraint(equalTo: trailingAnchor),
            bankAccountView.bottomAnchor.constraint(equalTo: safeBottomAnchor),

            debitCardView.topAnchor.constraint(equalTo: typeSelectorView.bottomAnchor),
            debitCardView.leadingAnchor.constraint(equalTo: leadingAnchor),
            debitCardView.trailingAnchor.constraint(equalTo: trailingAnchor),
            debitCardView.bottomAnchor.constraint(equalTo: safeBottomAnchor),
        ])
    }
}

// MARK: - Rx

extension Reactive where Base: P2PPaymentsPayoutRequestView {
    var bankAccountPayoutButtonTap: ControlEvent<Void> {
        return base.bankAccountView.rx.payoutButtonTap
    }

    var cardPayoutButtonTap: ControlEvent<Void> {
        return base.debitCardView.rx.payoutButtonTap
    }

    var instantPaymentFeeText: Binder<String?> {
        return base.debitCardView.rx.instantPaymentFeeText
    }

    var instantFundsAvailableText: Binder<String?> {
        return base.debitCardView.rx.instantFundsAvailableText
    }

    var cardStandardFundsAvailableText: Binder<String?> {
        return base.debitCardView.rx.standardFundsAvailableText
    }

    var bankAccountStandardFundsAvailableText: Binder<String?> {
        return base.bankAccountView.rx.standardFundsAvailableText
    }
}
