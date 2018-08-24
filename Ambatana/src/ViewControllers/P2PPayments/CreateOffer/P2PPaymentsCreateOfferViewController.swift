import UIKit
import LGComponents
import RxSwift
import RxCocoa

final class P2PPaymentsCreateOfferViewController: BaseViewController {
    var viewModel: P2PPaymentsCreateOfferViewModel
    private let disposeBag = DisposeBag()

    init(viewModel: P2PPaymentsCreateOfferViewModel) {
        self.viewModel = viewModel
        super.init(viewModel: viewModel, nibName: nil)
    }

    @available(*, unavailable)
    required init?(coder aDecoder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    override func loadView() {
        let createOfferView = P2PPaymentsCreateOfferView()
        view = createOfferView
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor.white
    }
}
