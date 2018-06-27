import UIKit
import LGComponents

final class TourBlurBackgroundViewController: BaseViewController {

    init() {
        super.init(viewModel: nil, nibName: "TourBlurBackgroundViewController",
                   statusBarStyle: .lightContent)
        setupForModalWithNonOpaqueBackground()
        modalTransitionStyle = .crossDissolve
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .clear

        // Do any additional setup after loading the view.
    }
}
