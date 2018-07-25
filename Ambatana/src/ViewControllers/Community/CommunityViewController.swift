import WebKit
import LGComponents

final class CommunityViewController: BaseViewController {

    private let viewModel: CommunityViewModel
    private let webView = WKWebView()

    init(viewModel: CommunityViewModel) {
        self.viewModel = viewModel
        super.init(viewModel: viewModel, nibName: nil)
        hasTabBar = viewModel.showTabBar
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
        setupConstraints()
    }

    private func setupConstraints() {
        let constraints = [
            webView.topAnchor.constraint(equalTo: safeTopAnchor),
            webView.bottomAnchor.constraint(equalTo: safeBottomAnchor),
            webView.leftAnchor.constraint(equalTo: view.leftAnchor),
            webView.rightAnchor.constraint(equalTo: view.rightAnchor)
        ]

        NSLayoutConstraint.activate(constraints)
    }

    private func loadWeb() {
        guard let urlRequest = viewModel.urlRequest else { return }
        webView.load(urlRequest)
    }
}
