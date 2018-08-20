import UIKit
import LGComponents

final class P2PPaymentsOnboardingViewController: BaseViewController {
    override func loadView() {
        let onboardingView = P2PPaymentsOnboardingView()
        onboardingView.configureLayoutGuides()
        view = onboardingView

    }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor.white
    }
}
