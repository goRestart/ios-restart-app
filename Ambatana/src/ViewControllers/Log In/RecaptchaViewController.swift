import WebKit
import LGComponents

final class RecaptchaViewController: BaseViewController {
    var webView: WKWebView { return recaptchaView.webView }
    var activityIndicator: UIActivityIndicatorView { return recaptchaView.activityIndicator }
    var closeButton: UIButton { return recaptchaView.closeButton }

    private let viewModel: RecaptchaViewModel
    private let recaptchaView = RecaptchaView()

    private var currentURL: URL?

    override func loadView() {
        self.view = recaptchaView
    }

    init(viewModel: RecaptchaViewModel) {
        self.viewModel = viewModel
        super.init(viewModel: viewModel, nibName: nil)
        automaticallyAdjustsScrollViewInsets = false
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setAccesibilityIds()
        webView.navigationDelegate = self

        if let url = viewModel.url {
            loadUrl(url)
        }
        setupTouchEvents()
    }

    private func setupTouchEvents() {
        closeButton.addTarget(viewModel, action: #selector(RecaptchaViewModel.closeButtonPressed), for: .touchUpInside)
    }

    // MARK: - Private methods

    private func loadUrl(_ url: URL) {
        activityIndicator.startAnimating()
        let request = URLRequest(url: url)
        webView.load(request)
    }
}


// MARK: - UIWebViewDelegate

extension RecaptchaViewController: WKNavigationDelegate {

    func webView(_ webView: WKWebView,
                 decidePolicyFor navigationAction: WKNavigationAction,
                 decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {

        guard let currentURL = navigationAction.request.url else {
            decisionHandler(.cancel)
            return
        }
        self.currentURL = currentURL
        viewModel.startedLoadingURL(currentURL)
        decisionHandler(.allow)
    }

    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        activityIndicator.stopAnimating()

        if let url = currentURL {
            viewModel.urlLoaded(url)
        }
    }
}


// MARK: - Accesibility ids

fileprivate extension RecaptchaViewController {
    func setAccesibilityIds() {
        closeButton.set(accessibilityId: .recaptchaCloseButton)
        activityIndicator.set(accessibilityId: .recaptchaLoading)
        webView.set(accessibilityId: .recaptchaWebView)
    }
}
