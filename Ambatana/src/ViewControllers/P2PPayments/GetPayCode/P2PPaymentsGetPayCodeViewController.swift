import UIKit
import LGComponents
import RxSwift
import RxCocoa

final class P2PPaymentsGetPayCodeViewController: BaseViewController {
    private let viewModel: P2PPaymentsGetPayCodeViewModel

    init(viewModel: P2PPaymentsGetPayCodeViewModel) {
        self.viewModel = viewModel
        super.init(viewModel: viewModel, nibName: nil)
    }

    @available(*, unavailable)
    required init?(coder aDecoder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    override func viewDidLoad() {
        super.viewDidLoad()
        setup()
    }

    private func setup() {
    }
}
