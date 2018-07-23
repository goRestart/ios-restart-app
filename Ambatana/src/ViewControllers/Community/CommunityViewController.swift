import WebKit
import LGComponents

final class CommunityViewController: BaseViewController {

    private let viewModel: CommunityViewModel
    private let webView = WKWebView()

    init(viewModel: CommunityViewModel) {
        self.viewModel = viewModel
        super.init(viewModel: viewModel, nibName: nil)
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
        webView.layout(with: view).fill()
    }

    private func loadWeb() {
        guard let urlRequest = viewModel.urlRequest else { return }
        webView.load(urlRequest)
    }
}
