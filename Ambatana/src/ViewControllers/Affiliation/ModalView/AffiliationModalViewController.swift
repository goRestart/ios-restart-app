import LGComponents
import RxSwift
import RxCocoa

final class AffiliationModalViewController: BaseViewController {
    fileprivate let modalView = AffiliationModalView(frame: UIScreen.main.bounds)
    private let viewModel: AffiliationModalViewModel
    private let disposeBag = DisposeBag()

    @available(*, unavailable)
    required init?(coder aDecoder: NSCoder) { fatalError("Die xibs, die") }

    init(viewModel: AffiliationModalViewModel) {
        self.viewModel = viewModel
        super.init(viewModel: viewModel, nibName: nil)
    }

    override func loadView() {
        self.view = modalView
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .blackTextHighAlpha

        setupRx()
    }

    private func setupRx() {
        let bindings = [
            viewModel.rx.data.bind(to: self.rx.data)
        ]
        bindings.forEach { $0.disposed(by: disposeBag) }
    }
}

extension Reactive where Base: AffiliationModalViewController {
    var data: Binder<AffiliationModalData> {
        return Binder(self.base) { controller, data in
            controller.modalView.populate(with: data)
        }
    }
}
