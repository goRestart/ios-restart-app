import UIKit
import LGComponents

class EmbeddedLoginViewController: UIViewController {
    private let viewModel: EmbeddedLoginViewModel


    // MARK: - Lifecycle

    init(viewModel: EmbeddedLoginViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Embedded Login"
        setupUI()
    }

    private func setupUI() {
        view.backgroundColor = UIColor.white
    }
}
