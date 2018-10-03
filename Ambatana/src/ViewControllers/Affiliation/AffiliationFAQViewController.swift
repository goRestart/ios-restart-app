import LGComponents
import WebKit

final class AffiliationFAQViewController: BaseViewController {
    private let viewModel: AffiliationFAQViewModel
    private let webView = WKWebView()

    // MARK: Lifecycle

    init(viewModel: AffiliationFAQViewModel) {
        self.viewModel = viewModel
        super.init(viewModel: viewModel,
                   nibName: nil)
        setupUI()
        setupConstraints()
        setAccessibilityIds()
    }

    @available(*, unavailable)
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupUI() {
        title = R.Strings.affiliationFaqTitle
        if let url = viewModel.url {
            let request = URLRequest(url: url)
            webView.load(request)
        }
    }

    private func setupConstraints() {
        automaticallyAdjustsScrollViewInsets = false
        webView.addToViewController(self, inView: self.view)
    }

    private func setAccessibilityIds() {
    }
}
