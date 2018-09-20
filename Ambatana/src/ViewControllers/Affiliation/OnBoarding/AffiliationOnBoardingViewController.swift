import RxSwift
import RxCocoa
import LGCoreKit
import LGComponents

final class AffiliationOnBoardingViewController: BaseViewController {

    fileprivate let onboardingView = AffiliationOnBoardingView()
    private let viewModel: AffiliationOnBoardingViewModel
    private let disposeBag = DisposeBag()

    init(viewModel: AffiliationOnBoardingViewModel) {
        self.viewModel = viewModel
        super.init(viewModel: viewModel, nibName: nil)
    }

    @available(*, unavailable)
    required init?(coder aDecoder: NSCoder) { fatalError("Die xibs, die") }

    override func loadView() {
        self.view = onboardingView
    }

    @objc private func close() {
        viewModel.close()
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        viewModel.onboardingData
            .asObservable()
            .asDriver(onErrorJustReturn: nil)
            .drive(rx.data)
            .disposed(by: disposeBag)

        let tap = UITapGestureRecognizer(target: self, action: #selector(close))
        onboardingView.addGestureRecognizer(tap)
    }

    fileprivate func update(with data: AffiliationOnBoardingVM) {
        onboardingView.set(avatar: data.inviterURL,
                           userName: data.inviterName,
                           userId: data.inviterID,
                           message: data.message)
    }
}

extension Reactive where Base: AffiliationOnBoardingViewController {
    var data: Binder<AffiliationOnBoardingVM?> {
        return Binder(self.base) { controller, data in
            guard let data = data else { return }
            controller.update(with: data)
        }
    }
}
