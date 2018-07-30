import Foundation
import LGComponents
import RxSwift
import RxCocoa

protocol LPMessageView: class {
    var dismissControl: UIControl? { get }
    var closeControl: UIControl? { get }
    var actionControl: UIControl? { get }

    var headline: String { get set }
    var subHeadline: String { get set }
    var action: String { get set }
    var image: UIImage? { get set }
}

private extension Reactive where Base: LPMessageViewController {
    var headlineString: Binder<String> {
        return Binder(self.base) { (vc: LPMessageViewController, headline: String) in
            vc.lpView.headline = headline
        }
    }

    var subHeadlineString: Binder<String> {
        return Binder(self.base) { (vc: LPMessageViewController, subHeadline: String) in
            vc.lpView.subHeadline = subHeadline
        }
    }

    var actionString: Binder<String> {
        return Binder(self.base) { (vc: LPMessageViewController, action: String) in
            vc.lpView.action = action
        }
    }

    var image: Binder<UIImage> {
        return Binder(self.base) { (vc: LPMessageViewController, image: UIImage) in
            vc.lpView.image = image
        }
    }
}

private extension LPMessageType {
    var view: LPMessageView & UIView {
        switch self {
        case .centerPopup: return LPCenterPopupView()
        case .interstitial: return LPInterstitialView()
        }
    }
}

final class LPMessageViewController: BaseViewController {

    private let viewModel: LPMessageViewModel
    fileprivate let lpView: LPMessageView & UIView

    private let disposeBag = DisposeBag()

    required init?(coder aDecoder: NSCoder) { fatalError("Die xibs, die") }

    init(vm: LPMessageViewModel) {
        self.viewModel = vm
        self.lpView = vm.type.view

        super.init(viewModel: nil, nibName: nil)

        modalTransitionStyle = .crossDissolve
        modalPresentationStyle = .overCurrentContext
    }

    override func loadView() {
        guard viewModel.type == .interstitial else {
            self.view = lpView
            return
        }
        super.loadView()
        view.addSubviewForAutoLayout(lpView)
        NSLayoutConstraint.activate([
            lpView.topAnchor.constraint(equalTo: safeTopAnchor),
            lpView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            lpView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            lpView.bottomAnchor.constraint(equalTo: safeBottomAnchor)
        ])
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setupRx()

        if viewModel.shouldDismissTappingBackground {
            view.backgroundColor = UIColor.black.withAlphaComponent(0.5)
            view.addGestureRecognizer(UITapGestureRecognizer(target: viewModel,
                                                             action: #selector(LPMessageViewModel.close)))
        } else {
            view.backgroundColor = lpView.backgroundColor // BaseViewController overrides background color
        }
    }

    private func setupRx() {
        lpView.actionControl?.rx.controlEvent(.touchUpInside)
            .bind(onNext: { [weak self] _ in
                self?.viewModel.action.action()
        }).disposed(by: disposeBag)

        lpView.closeControl?.rx.controlEvent(.touchUpInside)
            .bind(onNext: { [weak self] _ in
                self?.viewModel.close()
        }).disposed(by: disposeBag)

        lpView.dismissControl?.rx.controlEvent(.touchUpInside)
            .bind(onNext: { [weak self] _ in
                self?.viewModel.close()
        }).disposed(by: disposeBag)

        let bindings = [
            viewModel.headline.asDriver().drive(rx.headlineString),
            viewModel.subHeadline.asDriver().drive(rx.subHeadlineString),
            viewModel.image.asDriver().drive(rx.image),
            viewModel.actionString.asDriver().drive(rx.actionString)
        ]
        bindings.forEach { $0.disposed(by: disposeBag) }
    }

}
