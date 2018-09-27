import UIKit
import LGComponents
import RxSwift
import RxCocoa
import LGCoreKit

private enum ViewLayout {
    static let stackViewSpacing: CGFloat = 8
    static let stackViewInsets = UIEdgeInsets(top: 9, left: 10, bottom: -9, right: -10)
    static let actionButtonHeight: CGFloat = 32
}

final class ChatPaymentBannerView: UIView {
    private let stackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.alignment = .center
        stackView.spacing = ViewLayout.stackViewSpacing
        return stackView
    }()
    
    fileprivate let titleLabel: UILabel = {
        let label = UILabel()
        label.font = .systemMediumFont(size: 16)
        label.textColor = .blackText
        label.numberOfLines = 0
        label.setContentHuggingPriority(.defaultLow, for: .horizontal)
        return label
    }()
    
    fileprivate let actionButton: LetgoButton = {
        let button = LetgoButton(withStyle: .primary(fontSize: .medium))
        button.setContentHuggingPriority(.defaultHigh, for: .horizontal)
        return button
    }()
    
    private let viewModel = ChatPaymentBannerViewModel()
    private let viewBinder = ChatPaymentBannerViewBinder()
    
    fileprivate let buttonActionRelay = PublishRelay<ButtonActionEvent>()
    var actionButtonEvent: Driver<ButtonActionEvent> {
        return buttonActionRelay.asDriver(onErrorJustReturn: .none)
    }
    
    private let bag = DisposeBag()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
        setupBindings()
    }
    
    required init?(coder aDecoder: NSCoder) { fatalError() }
    
    private func setupUI() {
        backgroundColor = .grayBackground

        stackView.addArrangedSubviews([titleLabel, actionButton])
        addSubviewForAutoLayout(stackView)
        setupConstraints()
        applyDefaultShadow()
    }
    
    func configure(with params: P2PPaymentStateParams) {
        viewModel.configure(with: params)
    }
    
    private func setupBindings() {
        viewBinder.bind(self, viewModel: viewModel, bag: bag)
    }
    
    private func setupConstraints() {
        actionButton.heightAnchor.constraint(equalToConstant: ViewLayout.actionButtonHeight).isActive = true
        
        let stackViewConstraints = [
            stackView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: ViewLayout.stackViewInsets.left),
            stackView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: ViewLayout.stackViewInsets.right),
            stackView.topAnchor.constraint(equalTo: topAnchor, constant: ViewLayout.stackViewInsets.top),
            stackView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: ViewLayout.stackViewInsets.bottom)
        ]
        stackViewConstraints.activate()
    }
}

// MARK: - View bindings

extension Reactive where Base: ChatPaymentBannerView {
    var buttonActionEvent: Binder<ButtonActionEvent> {
        return Binder(base) { base, event in
            base.buttonActionRelay.accept(event)
        }
    }
    
    var offerState: Binder<P2PPaymentState> {
        return Binder(base) { base, state in
            base.titleLabel.text = state.title
            base.actionButton.setTitle(state.actionTitle, for: .normal)
        }
    }
    
    var isHidden: Binder<Bool> {
        return Binder(base) { base, isHidden in
            base.isHidden = isHidden
        }
    }
    
    var actionButtonWasTapped: Observable<Void> {
        return base.actionButton.rx
            .controlEvent(.touchUpInside)
            .debounce(0.1, scheduler: MainScheduler.instance)
    }
}
