import UIKit
import LGComponents
import RxSwift
import RxCocoa

final class P2PPaymentsOnboardingViewController: BaseViewController {
    var viewModel: P2PPaymentsOnboardingViewModel
    private let disposeBag = DisposeBag()

    init(viewModel: P2PPaymentsOnboardingViewModel) {
        self.viewModel = viewModel
        super.init(viewModel: viewModel, nibName: nil)
    }

    @available(*, unavailable)
    required init?(coder aDecoder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    override func loadView() {
        let onboardingView = P2PPaymentsOnboardingView()
        onboardingView.rx
            .closeButtonTap
            .subscribe(onNext: { [viewModel] () in
                viewModel.closeButtonPressed()
            })
            .disposed(by: disposeBag)
        onboardingView.rx
            .makeAnOfferButtonTap
            .subscribe(onNext: { [viewModel] () in
                viewModel.makeAnOfferButtonPressed()
            })
            .disposed(by: disposeBag)
        view = onboardingView
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor.white
    }
}
