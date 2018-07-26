import WebKit
import LGComponents

final class CommunityViewController: BaseViewController {

    private let viewModel: CommunityViewModel
    private let webView = WKWebView()

    init(viewModel: CommunityViewModel) {
        self.viewModel = viewModel
        super.init(viewModel: viewModel, nibName: nil)
        hidesBottomBarWhenPushed = false
        floatingSellButtonHidden = false
        hasTabBar = true
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        loadWeb()
    }

    private func setupUI() {
        view.backgroundColor = .white
        view.addSubviewForAutoLayout(webView)
        setupNavBar()
        setupConstraints()
    }

    private func setupNavBar() {
        navigationController?.setNavigationBarHidden(!viewModel.showNavBar, animated: false)
        guard viewModel.showCloseButton else { return }
        setNavBarCloseButton(#selector(close))
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

    private func loadWeb() {
        guard let urlRequest = viewModel.urlRequest else { return }
        webView.load(urlRequest)
    }

    @objc private func close() {
        viewModel.didTapClose()
    }
}
