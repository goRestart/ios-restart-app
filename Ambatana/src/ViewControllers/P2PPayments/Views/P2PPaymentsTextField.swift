import UIKit
import LGComponents
import RxSwift
import RxCocoa

final class P2PPaymentsTextField: UITextField {
    weak var nextResponderTextField: UIResponder?

    private let lineView = P2PPaymentsLineSeparatorView()

    init() {
        super.init(frame: .zero)
        setup()
    }

    @available(*, unavailable)
    required init?(coder aDecoder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    private func setup() {
        font = UIFont.boldSystemFont(ofSize: 20)
        textColor = UIColor.lgBlack
        tintColor = UIColor.primaryColor
        addTarget(self, action: #selector(nextButtonTapped), for: .editingDidEndOnExit)
        addSubviewForAutoLayout(lineView)
        setupConstraints()
    }

    private func setupConstraints() {
        NSLayoutConstraint.activate([
            lineView.bottomAnchor.constraint(equalTo: bottomAnchor),
            lineView.leadingAnchor.constraint(equalTo: leadingAnchor),
            lineView.trailingAnchor.constraint(equalTo: trailingAnchor),
        ])
    }

    @objc private func nextButtonTapped() {
        guard let responder = nextResponderTextField else {
            resignFirstResponder()
            return
        }
        responder.becomeFirstResponder()
    }

    override var intrinsicContentSize: CGSize {
        return CGSize(width: super.intrinsicContentSize.width, height: 48)
    }

    // MARK: - Public meyhods

    func setPlaceholderText(_ text: String) {
        attributedPlaceholder = NSAttributedString(string: text,
                                                   attributes: [.foregroundColor: UIColor.grayRegular,
                                                                .font: UIFont.boldSystemFont(ofSize: 20)])
    }
}

extension Reactive where Base: P2PPaymentsTextField {
    var isEmpty: Driver<Bool> {
        return text.asDriver().map { $0?.isEmpty ?? true }
    }
}
