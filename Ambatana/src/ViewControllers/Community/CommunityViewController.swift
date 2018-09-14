import WebKit
import LGComponents
import RxSwift
import Foundation

final class CommunityViewController: BaseViewController {

    private let viewModel: CommunityViewModel
    private let webView = WKWebView()
    private let disposeBag = DisposeBag()

    private let letgoHomeURL = "https://letgo.com/"
    private let letgoLoginURL = "login=true&community=true"
    private var initialURL: URL?

    init(viewModel: CommunityViewModel) {
        self.viewModel = viewModel
        super.init(viewModel: viewModel, nibName: nil)
        hidesBottomBarWhenPushed = false
        floatingSellButtonHidden = false
        hasTabBar = true
    }

    @available(*, unavailable)
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupRx()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        viewModel.didAppear()
    }

    private func setupUI() {
        view.backgroundColor = .white
        view.addSubviewForAutoLayout(webView)
        webView.navigationDelegate = self
        webView.allowsBackForwardNavigationGestures = true
        setupNavBar()
        setupConstraints()
    }

    private func setupNavBar() {
        navigationController?.setNavigationBarHidden(!viewModel.showNavBar, animated: false)
        setupNavBarLeftButton()
    }

    private func setupNavBarLeftButton() {
        guard viewModel.showCloseButton else { return }
        if webView.canGoBack, webView.url != initialURL {
            let backButton = UIBarButtonItem(image: R.Asset.IconsButtons.navbarBack.image,
                                             style: .plain, target: self, action: #selector(back))
            self.navigationItem.leftBarButtonItem = backButton
        } else {
            setNavBarCloseButton(#selector(close))
        }
    }

    private func setupConstraints() {
        var constraints = [
            webView.topAnchor.constraint(equalTo: safeTopAnchor),
            webView.leftAnchor.constraint(equalTo: view.leftAnchor),
            webView.rightAnchor.constraint(equalTo: view.rightAnchor)
        ]

        if tabBarController != nil {
            constraints.append(webView.bottomAnchor.constraint(equalTo: safeBottomAnchor))
        } else {
            constraints.append(webView.bottomAnchor.constraint(equalTo: view.bottomAnchor))
        }

        NSLayoutConstraint.activate(constraints)
    }

    private func setupRx() {
        viewModel
            .urlRequest
            .asDriver(onErrorJustReturn: nil)
            .distinctUntilChanged()
            .drive(onNext: { [weak self] request in
                guard let request = request else { return }
                self?.loadWeb(with: request)
            })
            .disposed(by: disposeBag)
    }

    private func loadWeb(with request: URLRequest) {
        clearCookies() { [weak self] in
            self?.webView.load(request)
        }
    }

    private func clearCookies(completion: @escaping ()->Void) {
        let dataStore = WKWebsiteDataStore.default()
        dataStore.fetchDataRecords(ofTypes: WKWebsiteDataStore.allWebsiteDataTypes()) { records in
            dataStore.removeData(ofTypes: WKWebsiteDataStore.allWebsiteDataTypes(),
                                 for: records.filter { $0.displayName.contains("letgo.com") },
                                 completionHandler: completion)
        }
    }

    @objc private func close() {
        viewModel.didTapClose()
    }

    @objc private func back() {
        webView.goBack()
    }
}

extension CommunityViewController: WKNavigationDelegate {

    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        setupNavBarLeftButton()
        initialURL = initialURL ?? webView.url
    }

    func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
        guard let urlString = navigationAction.request.url?.absoluteString else {
            decisionHandler(.allow)
            return
        }
        if urlString == letgoHomeURL {
            viewModel.openLetgoHome()
            decisionHandler(.cancel)
        }
        else if urlString.contains(letgoLoginURL) {
            viewModel.openLetgoLogin()
            decisionHandler(.cancel)
        }
        else {
            decisionHandler(.allow)
        }
    }
}
